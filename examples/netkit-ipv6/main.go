package main

import (
	"context"
	"encoding/binary"
	"flag"
	"fmt"
	"log"
	"net"
	"os/signal"
	"syscall"

	"github.com/cassamajor/xcnf/examples/netkit-ipv6/bytecode"
	"github.com/cassamajor/xcnf/examples/netkit-ipv6/netkit"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/ringbuf"
	"github.com/cilium/ebpf/rlimit"
)

func main() {
	deviceName := flag.String("name", "nk0", "Netkit device name")
	flag.Parse()

	if err := run(*deviceName); err != nil {
		log.Fatal(err)
	}
}

func run(deviceName string) error {
	// Remove memlock limit
	if err := rlimit.RemoveMemlock(); err != nil {
		return fmt.Errorf("removing memlock: %w", err)
	}

	// Create netkit pair
	log.Printf("Creating netkit pair %q...", deviceName)
	pair, err := netkit.CreatePair(deviceName,
		netkit.WithL3Mode(),
	)
	if err != nil {
		return fmt.Errorf("creating netkit pair: %w", err)
	}
	defer func() {
		log.Println("Deleting netkit pair...")
		pair.Delete()
	}()

	// Configure IPv6
	log.Println("Configuring IPv6 link-local addresses...")
	if err := pair.ConfigureIPv6LinkLocal(); err != nil {
		return fmt.Errorf("configuring IPv6: %w", err)
	}

	// Load eBPF objects
	log.Println("Loading eBPF programs...")
	var objs bytecode.NetkitObjects
	if err := bytecode.LoadNetkitObjects(&objs, nil); err != nil {
		return fmt.Errorf("loading eBPF objects: %w", err)
	}
	defer objs.Close()

	// Attach to primary
	log.Println("Attaching to primary interface...")
	primaryLink, err := link.AttachNetkit(link.NetkitOptions{
		Program:   objs.NetkitPrimary,
		Interface: pair.PrimaryIdx,
		Attach:    ebpf.AttachNetkitPrimary,
	})
	if err != nil {
		return fmt.Errorf("attaching primary: %w", err)
	}
	defer primaryLink.Close()

	// Attach to peer
	log.Println("Attaching to peer interface...")
	peerLink, err := link.AttachNetkit(link.NetkitOptions{
		Program:   objs.NetkitPeer,
		Interface: pair.PrimaryIdx,
		Attach:    ebpf.AttachNetkitPeer,
	})
	if err != nil {
		return fmt.Errorf("attaching peer: %w", err)
	}
	defer peerLink.Close()

	// Open ringbuf reader
	rd, err := ringbuf.NewReader(objs.Ipv6Events)
	if err != nil {
		return fmt.Errorf("opening ringbuf: %w", err)
	}
	defer rd.Close()

	// Setup signal handling
	ctx, cancel := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	log.Printf("Monitoring IPv6 traffic on %s (Ctrl+C to exit)", deviceName)
	log.Printf("Primary: %s (index %d)", pair.Primary.Attrs().Name, pair.PrimaryIdx)
	log.Printf("Peer: %s (index %d)", pair.Peer.Attrs().Name, pair.PeerIdx)

	// Poll ringbuf
	go func() {
		for {
			record, err := rd.Read()
			if err != nil {
				return
			}

			printEvent(record.RawSample)
		}
	}()

	<-ctx.Done()
	log.Println("Shutting down...")

	return nil
}

func printEvent(data []byte) {
	if len(data) < 37 {
		return
	}

	var srcAddr, dstAddr [16]byte
	copy(srcAddr[:], data[0:16])
	copy(dstAddr[:], data[16:32])

	nextHeader := data[32]
	payloadLen := binary.LittleEndian.Uint16(data[33:35])
	hopLimit := data[35]
	direction := data[36]

	dirStr := "primary"
	if direction == 1 {
		dirStr = "peer"
	}

	fmt.Printf("[%s] IPv6: %s -> %s | next=%d len=%d ttl=%d\n",
		dirStr,
		net.IP(srcAddr[:]).String(),
		net.IP(dstAddr[:]).String(),
		nextHeader,
		payloadLen,
		hopLimit,
	)
}

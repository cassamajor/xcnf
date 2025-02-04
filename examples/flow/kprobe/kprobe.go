package kprobe

import (
	"context"
	"log"

	"github.com/cassamajor/xcnf/examples/flow/bytecode"
	"github.com/cassamajor/xcnf/examples/flow/clsact"
	"github.com/cassamajor/xcnf/examples/flow/flowtable"
	"github.com/cassamajor/xcnf/examples/flow/packet"
	"github.com/cilium/ebpf/ringbuf"
	"github.com/vishvananda/netlink"
	"golang.org/x/sys/unix"
)

const (
	tenMB    = 1024 * 1024 * 10
	twentyMB = tenMB * 2
	fortyMB  = tenMB * 4
)

type probe struct {
	iface      netlink.Link
	handle     *netlink.Handle
	qdisc      *clsact.ClsAct
	bpfObjects *bytecode.ProbeObjects
	filters    []*netlink.BpfFilter
}

// loadObjects instantiates an empty `ProbeObjects` struct that holds the eBPF program and maps.
func (p *probe) loadObjects() error {
	log.Printf("Loading probe object to kernel")

	var objs bytecode.ProbeObjects

	// Load the eBPF program into the kernel
	if err := bytecode.LoadProbeObjects(&objs, nil); err != nil {
		return err
	}

	p.bpfObjects = &objs

	return nil
}

// setRlimit locks memory for resources to ensure our process has access to enough memory to be able to run.
func setRlimit() error {
	log.Println("Setting rlimit")

	return unix.Setrlimit(unix.RLIMIT_MEMLOCK, &unix.Rlimit{
		Cur: twentyMB,
		Max: fortyMB,
	})
}

func newProbe(iface netlink.Link) (*probe, error) {
	log.Println("Creating a new probe")

	handle, err := netlink.NewHandle(unix.NETLINK_ROUTE)

	if err != nil {
		log.Printf("Failed getting netlink handle: %v", err)
		return nil, err
	}

	hook := probe{
		iface:  iface,
		handle: handle,
	}

	if err := hook.loadObjects(); err != nil {
		return nil, err
	}

	if err := hook.createQdisc(); err != nil {
		log.Printf("Failed creating qdisc: %v", err)
		return nil, err
	}

	if err := hook.createFilters(); err != nil {
		log.Printf("Failed creating qdisc filters: %v", err)
		return nil, err
	}

	return &hook, nil
}

// createQdisc creates the `clasact` qdisc
func (p *probe) createQdisc() error {
	log.Printf("Creating qdisc")

	p.qdisc = clsact.NewClsAct(&netlink.QdiscAttrs{
		LinkIndex: p.iface.Attrs().Index,
		Handle:    netlink.MakeHandle(0xffff, 0),
		Parent:    netlink.HANDLE_CLSACT,
	})

	if err := p.handle.QdiscAdd(p.qdisc); err != nil {
		if err := p.handle.QdiscReplace(p.qdisc); err != nil {
			return err
		}
	}

	return nil
}

// createFilters creates BPF filters and classifiers
func (p *probe) createFilters() error {
	log.Printf("Creating qdisc filters")

	p.addFilter(netlink.FilterAttrs{
		LinkIndex: p.iface.Attrs().Index,
		Handle:    netlink.MakeHandle(0xffff, 0),
		Parent:    netlink.HANDLE_MIN_INGRESS,
		Protocol:  unix.ETH_P_IP,
	})

	p.addFilter(netlink.FilterAttrs{
		LinkIndex: p.iface.Attrs().Index,
		Handle:    netlink.MakeHandle(0xffff, 0),
		Parent:    netlink.HANDLE_MIN_EGRESS,
		Protocol:  unix.ETH_P_IP,
	})

	p.addFilter(netlink.FilterAttrs{
		LinkIndex: p.iface.Attrs().Index,
		Handle:    netlink.MakeHandle(0xffff, 0),
		Parent:    netlink.HANDLE_MIN_INGRESS,
		Protocol:  unix.ETH_P_IPV6,
	})

	p.addFilter(netlink.FilterAttrs{
		LinkIndex: p.iface.Attrs().Index,
		Handle:    netlink.MakeHandle(0xffff, 0),
		Parent:    netlink.HANDLE_MIN_EGRESS,
		Protocol:  unix.ETH_P_IPV6,
	})

	for _, filter := range p.filters {
		if err := p.handle.FilterAdd(filter); err != nil {
			if err := p.handle.FilterReplace(filter); err != nil {
				return err
			}
		}
	}
	return nil
}

// addFilter takes a netlink filter to build a BPF filter or classifiers, passing filter attributes to our program's file descriptor.
func (p *probe) addFilter(attrs netlink.FilterAttrs) {
	p.filters = append(p.filters, &netlink.BpfFilter{
		FilterAttrs:  attrs,
		Fd:           p.bpfObjects.ProbePrograms.Flat.FD(),
		DirectAction: true,
	})
}

func Run(ctx context.Context, iface netlink.Link) error {
	log.Println("Starting up the probe")

	// Lock memory for resources
	if err := setRlimit(); err != nil {
		log.Printf("Failed setting rlimit: %v", err)
		return err
	}

	// Instantiate a new flow table and prune stale entries every 10 seconds
	flowtable := flowtable.NewFlowTable()

	go func() {
		for range flowtable.Ticker.C {
			flowtable.Prune()
		}
	}()

	iface, err := netlink.LinkByName("eth0")

	if err != nil {
		return err
	}

	hook, err := newProbe(iface)

	// Create a ring buffer reader from user space and pass it to the map object
	pipe := hook.bpfObjects.ProbeMaps.Pipe

	reader, err := ringbuf.NewReader(pipe)

	if err != nil {
		log.Println("Failed creating ringbuf reader")
		return err
	}

	// Create a byte slice channel
	c := make(chan []byte)

	go func() {
		for {
			// Poll for events/data that is submitted via `bpf_ringbuf_output`
			event, err := reader.Read()
			if err != nil {
				log.Printf("Failed rading from ringbuf: %v", err)
				return
			}
			// Pass event to the channel when data is received
			c <- event.RawSample
		}
	}()

	for {
		select {
		// Clean up when the program is interrupted or terminated
		case <-ctx.Done():
			flowtable.Ticker.Stop()
			return hook.bpfObjects.Close()

		// Unmarshal, calculate, and display the latency of each flow
		case pkt := <-c:
			packetAttrs, ok := packet.UnmarshalBinary(pkt)
			if !ok {
				log.Printf("Cloud not unmarshall packet: %+v", pkt)
				continue
			}
			packet.CalcLatency(packetAttrs, flowtable)
		}
	}

	return nil
}


// Close will remove the qdisc, netlink handle, eBPF program, and eBPF maps when the program
// gets interrupted (SIGINT) or terminated (SIGTERM)
func (p *probe) Close() error {
	log.Println("Removing qdisc")
	if err := p.handle.QdiscDel(p.qdisc); err != nil {
		log.Println("Failed to delete qdisc")
		return err
	}

	log.Println("Deleting handle")
	p.handle.Delete()

	log.Println("Closing eBPF object")
	if err := p.bpfObjects.Close(); err != nil {
		log.Println("Fail to close the eBPF object")
		return err
	}

	return nil
}
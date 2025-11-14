package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"netkit/bytecode"
	"os"
	"os/signal"
	"syscall"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/link"
)

func resolveInterfaceByName(name string) (int, error) {
	// Resolve the interface name to an interface index
	ifIndex, err := net.InterfaceByName(name)
	if err != nil {
		panic(fmt.Errorf("could not resolve interface %s index: %w", name, err))
	}

	return ifIndex.Index, nil
}

func displayInterfaces() {
	interfaces, err := net.Interfaces()

	if err != nil {
		log.Fatal("Failed fetching network interfaces")
		return
	}

	for _, iface := range interfaces {
		// Resolve the interface name to an interface index
		ifIndex, _ := resolveInterfaceByName(iface.Name)
		fmt.Printf("%d) %s\n", ifIndex, iface.Name)
	}
}

func selectInterface() {
	// Get host interface name from the command line
	interfaceName := flag.String("interface", os.Getenv("PRIMARY_INTERFACE"), "Name of the primary netkit interface")
	if interfaceName == nil || *interfaceName == "" {
		flag.Usage()
	}

	// Resolve the interface name to an interface index
	ifIndex, _ := resolveInterfaceByName(*interfaceName)
	fmt.Printf("Interface %s index is %d\n", *interfaceName, ifIndex)
}

func exist(ifIndex int){
		// Load the programs into the Kernel
		collSpec, err := bytecode.LoadNetkit()
		if err != nil {
			panic(fmt.Errorf("could not load collection spec: %w", err))
		}
	
		coll, err := ebpf.NewCollection(collSpec)
		if err != nil {
			panic(fmt.Errorf("could not load BPF objects from collection spec: %w", err))
		}
		defer coll.Close()
	
		// Attach the program to the primary interface
		primaryLink, err := link.AttachNetkit(link.NetkitOptions{
			Program:   coll.Programs["netkit_primary"],
			Interface: ifIndex,
			Attach:    ebpf.AttachNetkitPrimary,
		})
	
		if err != nil {
			panic(fmt.Errorf("could not attach primary prog %w", err))
		}
		defer primaryLink.Close()
	
		// Attach the program to the peer, directly from the host, via the primary
		peerLink, err := link.AttachNetkit(link.NetkitOptions{
			Program:   coll.Programs["netkit_peer"],
			Interface: ifIndex,
			Attach:    ebpf.AttachNetkitPeer,
		})
	
		if err != nil {
			panic(fmt.Errorf("could not attach peer prog %w", err))
		}
		defer peerLink.Close()

		// Forwarding is now enabled until exit
		done := make(chan os.Signal, 1)
		signal.Notify(done, syscall.SIGINT, syscall.SIGTERM)
		fmt.Printf("%s is now forwarding IP packets until Ctrl+C is pressed.\n", os.Getenv("PRIMARY_INTERFACE"))
		<-done
	}

func main() {
	// selectInterface()
	// displayInterfaces()
	exist(11)
}
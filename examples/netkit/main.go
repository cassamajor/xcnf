package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
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

func main() {
	// selectInterface()
	// displayInterfaces()
}
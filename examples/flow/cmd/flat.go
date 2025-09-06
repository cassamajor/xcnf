package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/vishvananda/netlink"
	"golang.org/x/text/language/display"
)

func main() {
	ifaceFlag := flag.String("i", "etho", "interface to attach the probe to")
	flag.Parse()

	iface, err := netlink.LinkByName(*ifaceFlag)

	if err != nil {
		log.Printf("Could not find interface %v: %v", *ifaceFlag, err)
		displayInterfaces()
		os.Exit(1)
	}

	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)

	signalHandler(cancel)
}

func displayInterfaces() {
	interfaces, err := net.Interfaces()

	if err != nil {
		log.Fatal("Failed fetching network interfaces")
		return
	}

	for i, iface := range interfaces {
		fmt.Printf("%d) %s\n", i, iface.Name)
	}
}

//signalHandler will remove the qdisc and its filters when the program is interrupted (SIGINT) or terminated (SIGTERM)
func signalHandler(cancel context.CancelFunc) {
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go func()  {
		<-sigChan
		log.Println("\nExiting")
		cancel()
	}()

	if err := probe.Run(ctx, iface); err != nil {
		log.Fatalf("Failed running the probe: %v", err)
	}
}
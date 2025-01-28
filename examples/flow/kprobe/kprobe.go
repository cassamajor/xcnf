package kprobe

import (
	"log"

	"github.com/cassamajor/xcnf/examples/flow/bytecode"
	"github.com/cassamajor/xcnf/examples/flow/clsact"
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

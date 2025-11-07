---
name: cnf-networking
description: Configure CNF networking components including netkit BPF-programmable network devices, tcx (Traffic Control eXpress for kernel 6.6+), virtual interfaces, network namespaces, routing, and eBPF program attachment. Use when setting up network topology for eBPF-based CNFs or testing packet processing pipelines.
---

# CNF Networking Skill

This skill helps configure networking infrastructure for eBPF-based Cloud Native Network Functions.

## What This Skill Does

Sets up and manages:
1. **netkit devices** - BPF-programmable network device pairs (kernel 6.6+)
2. **tcx (Traffic Control eXpress)** - Modern TC with eBPF (kernel 6.6+)
3. **Network namespaces** - Isolated network stacks for testing
4. **Virtual interfaces** - veth pairs, bridges
5. **Routing configuration** - Routes, rules, forwarding
6. **eBPF program attachment** - Attach to netkit, tcx, XDP

## When to Use

- Setting up CNF testing environments
- Creating network topologies for packet processing
- Attaching eBPF programs to network interfaces
- Configuring traffic control with tcx
- Building network function chains
- Testing multi-namespace scenarios

## Key Technologies

### netkit - BPF-Programmable Network Device

netkit is a modern alternative to veth pairs that allows eBPF programs to be attached to both ends (primary and peer).

**Advantages over veth:**
- Native eBPF attachment points (primary/peer)
- Better performance for BPF processing
- Cleaner API via `link.AttachNetkit()`
- Designed for cloud-native workloads

**Creating netkit pairs:**
```bash
# Create netkit pair
ip link add dev veth0 type netkit mode l3 peer name veth1 peer_mode l3

# Modes:
# - l2: Layer 2 mode (Ethernet)
# - l3: Layer 3 mode (no Ethernet header)

# Move peer to namespace
ip link set veth1 netns test-ns

# Configure addresses
ip addr add 10.0.0.1/24 dev veth0
ip netns exec test-ns ip addr add 10.0.0.2/24 dev veth1

# Bring up interfaces
ip link set veth0 up
ip netns exec test-ns ip link set veth1 up
```

**Attaching eBPF to netkit (Go):**
```go
import (
    "github.com/cilium/ebpf"
    "github.com/cilium/ebpf/link"
)

// Get interface index
iface, err := net.InterfaceByName("veth0")
if err != nil {
    return err
}

// Attach to primary interface
primaryLink, err := link.AttachNetkit(link.NetkitOptions{
    Program:   prog,  // *ebpf.Program
    Interface: iface.Index,
    Attach:    ebpf.AttachNetkitPrimary,
})
if err != nil {
    return err
}
defer primaryLink.Close()

// Attach to peer (from primary side)
peerLink, err := link.AttachNetkit(link.NetkitOptions{
    Program:   prog,
    Interface: iface.Index,
    Attach:    ebpf.AttachNetkitPeer,
})
if err != nil {
    return err
}
defer peerLink.Close()
```

**eBPF program for netkit:**
```c
#include <linux/bpf.h>
#include <linux/if_link.h>
#include <bpf/bpf_helpers.h>

SEC("netkit/primary")
int netkit_primary(struct __sk_buff *skb) {
    // Process packets on primary interface
    bpf_printk("Primary: packet length %d", skb->len);
    return NETKIT_PASS;  // or NETKIT_DROP, NETKIT_REDIRECT
}

SEC("netkit/peer")
int netkit_peer(struct __sk_buff *skb) {
    // Process packets on peer interface
    bpf_printk("Peer: packet length %d", skb->len);
    return NETKIT_PASS;
}

char _license[] SEC("license") = "GPL";
```

### tcx - Traffic Control eXpress (Kernel 6.6+)

tcx is the modern replacement for TC (Traffic Control) with native eBPF support.

**Advantages over legacy TC:**
- No qdisc required (cleaner setup)
- Better performance
- Simpler API via `link.AttachTCX()`
- Multi-program attachment with priorities
- No dependencies on tc-bpf tooling

**Attaching eBPF to tcx (Go):**
```go
import (
    "github.com/cilium/ebpf"
    "github.com/cilium/ebpf/link"
)

// Get interface index
iface, err := net.InterfaceByName("eth0")
if err != nil {
    return err
}

// Attach to ingress
ingressLink, err := link.AttachTCX(link.TCXOptions{
    Program:   prog,
    Attach:    ebpf.AttachTCXIngress,
    Interface: iface.Index,
})
if err != nil {
    return err
}
defer ingressLink.Close()

// Attach to egress
egressLink, err := link.AttachTCX(link.TCXOptions{
    Program:   prog,
    Attach:    ebpf.AttachTCXEgress,
    Interface: iface.Index,
})
if err != nil {
    return err
}
defer egressLink.Close()
```

**eBPF program for tcx:**
```c
#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <bpf/bpf_helpers.h>

// Can use either "tc" or "tcx/ingress" / "tcx/egress"
SEC("tcx/ingress")
int tcx_ingress(struct __sk_buff *skb) {
    bpf_printk("Ingress: packet from interface %d", skb->ifindex);
    return TC_ACT_OK;  // or TC_ACT_SHOT, TC_ACT_REDIRECT, TC_ACT_PIPE
}

SEC("tcx/egress")
int tcx_egress(struct __sk_buff *skb) {
    bpf_printk("Egress: packet to interface %d", skb->ifindex);
    return TC_ACT_OK;
}

char _license[] SEC("license") = "GPL";
```

**Legacy TC (for kernels < 6.6):**
```bash
# Add clsact qdisc (required for legacy TC)
sudo tc qdisc add dev eth0 clsact

# Attach BPF program
sudo tc filter add dev eth0 ingress bpf direct-action obj prog.o sec tc

# Remove
sudo tc qdisc del dev eth0 clsact
```

**Legacy TC in Go:**
```go
import (
    "github.com/cilium/ebpf/link"
)

// For kernels < 6.6, use AttachTC instead of AttachTCX
tcLink, err := link.AttachTC(link.TCOptions{
    Program:   prog,
    Attach:    ebpf.AttachTCIngress,  // or ebpf.AttachTCEgress
    Interface: iface.Index,
})
```

## Network Namespace Management

**Create namespace:**
```bash
# Create namespace
ip netns add test-ns

# Execute command in namespace
ip netns exec test-ns ip link show

# Delete namespace
ip netns del test-ns
```

**Go code for namespace operations:**
```go
import (
    "runtime"
    "github.com/vishvananda/netns"
)

// Get current namespace
origns, err := netns.Get()
if err != nil {
    return err
}
defer origns.Close()

// Get target namespace
ns, err := netns.GetFromName("test-ns")
if err != nil {
    return err
}
defer ns.Close()

// Switch to namespace
runtime.LockOSThread()
defer runtime.UnlockOSThread()

if err := netns.Set(ns); err != nil {
    return err
}

// Do work in namespace...

// Restore original namespace
if err := netns.Set(origns); err != nil {
    return err
}
```

## Virtual Interface Management

**veth pairs (traditional):**
```bash
# Create veth pair
ip link add veth0 type veth peer name veth1

# Move peer to namespace
ip link set veth1 netns test-ns

# Configure
ip addr add 10.0.0.1/24 dev veth0
ip link set veth0 up

ip netns exec test-ns ip addr add 10.0.0.2/24 dev veth1
ip netns exec test-ns ip link set veth1 up
```

**Bridge setup:**
```bash
# Create bridge
ip link add br0 type bridge

# Add interfaces to bridge
ip link set veth0 master br0

# Configure bridge
ip addr add 192.168.1.1/24 dev br0
ip link set br0 up
```

## Complete CNF Testing Setup Example

### Scenario: CNF between two namespaces

```bash
#!/bin/bash

# Create namespaces
ip netns add ns1
ip netns add ns2

# Create netkit pair (ns1 <-> host)
ip link add dev netkit0 type netkit mode l3 peer name netkit0-peer peer_mode l3
ip link set netkit0-peer netns ns1

# Create netkit pair (host <-> ns2)
ip link add dev netkit1 type netkit mode l3 peer name netkit1-peer peer_mode l3
ip link set netkit1-peer netns ns2

# Configure host interfaces
ip addr add 10.0.1.1/24 dev netkit0
ip addr add 10.0.2.1/24 dev netkit1
ip link set netkit0 up
ip link set netkit1 up

# Configure ns1
ip netns exec ns1 ip addr add 10.0.1.2/24 dev netkit0-peer
ip netns exec ns1 ip link set netkit0-peer up
ip netns exec ns1 ip link set lo up
ip netns exec ns1 ip route add default via 10.0.1.1

# Configure ns2
ip netns exec ns2 ip addr add 10.0.2.2/24 dev netkit1-peer
ip netns exec ns2 ip link set netkit1-peer up
ip netns exec ns2 ip link set lo up
ip netns exec ns2 ip route add default via 10.0.2.1

# Enable forwarding on host
sysctl -w net.ipv4.ip_forward=1

# Now attach eBPF programs to netkit0 and netkit1
# Programs can inspect/modify packets flowing between ns1 and ns2
```

**Corresponding Go application:**
```go
package main

import (
    "log"
    "net"
    "os"
    "os/signal"
    "syscall"

    "github.com/cilium/ebpf"
    "github.com/cilium/ebpf/link"
)

func main() {
    // Load eBPF objects
    spec, err := LoadMyProgram()
    if err != nil {
        log.Fatalf("loading spec: %v", err)
    }

    objs := &MyProgramObjects{}
    if err := spec.LoadAndAssign(objs, nil); err != nil {
        log.Fatalf("loading objects: %v", err)
    }
    defer objs.Close()

    // Attach to netkit0 (primary and peer)
    iface0, _ := net.InterfaceByName("netkit0")

    link0Primary, err := link.AttachNetkit(link.NetkitOptions{
        Program:   objs.NetkitPrimary,
        Interface: iface0.Index,
        Attach:    ebpf.AttachNetkitPrimary,
    })
    if err != nil {
        log.Fatalf("attaching to netkit0 primary: %v", err)
    }
    defer link0Primary.Close()

    link0Peer, err := link.AttachNetkit(link.NetkitOptions{
        Program:   objs.NetkitPeer,
        Interface: iface0.Index,
        Attach:    ebpf.AttachNetkitPeer,
    })
    if err != nil {
        log.Fatalf("attaching to netkit0 peer: %v", err)
    }
    defer link0Peer.Close()

    // Attach to netkit1
    iface1, _ := net.InterfaceByName("netkit1")

    link1Primary, err := link.AttachNetkit(link.NetkitOptions{
        Program:   objs.NetkitPrimary,
        Interface: iface1.Index,
        Attach:    ebpf.AttachNetkitPrimary,
    })
    if err != nil {
        log.Fatalf("attaching to netkit1 primary: %v", err)
    }
    defer link1Primary.Close()

    log.Println("CNF is running, processing packets between ns1 and ns2...")

    // Wait for signal
    sig := make(chan os.Signal, 1)
    signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
    <-sig

    log.Println("Shutting down...")
}
```

## Routing Configuration

**Add routes:**
```bash
# Add route to specific network
ip route add 10.1.0.0/24 via 10.0.0.2 dev veth0

# Add default route
ip route add default via 10.0.0.1

# In namespace
ip netns exec test-ns ip route add default via 10.0.0.1
```

**Enable IP forwarding:**
```bash
# Temporary
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Permanent (add to /etc/sysctl.conf)
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

## Debugging and Monitoring

**View netkit devices:**
```bash
ip link show type netkit
```

**View tcx attachments:**
```bash
# Using bpftool (kernel 6.6+)
bpftool net show dev eth0

# Legacy TC
tc filter show dev eth0 ingress
```

**Monitor packets:**
```bash
# tcpdump on interface
tcpdump -i netkit0 -n

# In namespace
ip netns exec test-ns tcpdump -i netkit0-peer -n

# View eBPF trace logs
tc exec bpf dbg  # Legacy TC
# or
bpftool prog tracelog  # Modern
```

**Test connectivity:**
```bash
# Ping between namespaces
ip netns exec ns1 ping 10.0.2.2

# netcat for TCP/UDP testing
ip netns exec ns2 nc -l 8080
ip netns exec ns1 nc 10.0.2.2 8080
```

## Cleanup

**Remove netkit devices:**
```bash
ip link del dev netkit0
ip link del dev netkit1
```

**Remove namespaces:**
```bash
ip netns del ns1
ip netns del ns2
```

**Detach tcx programs (automatic on link.Close() in Go):**
```bash
# Manual detach with bpftool
bpftool net detach tcx dev eth0 ingress
```

## Best Practices

1. **Use netkit over veth** for eBPF-programmable paths
2. **Use tcx over legacy TC** on kernel 6.6+
3. **Always defer link.Close()** to ensure cleanup
4. **Enable IP forwarding** when routing between interfaces
5. **Use network namespaces** for isolation in testing
6. **Monitor with bpftool** for debugging attachments
7. **Check kernel version** before using netkit/tcx features
8. **Use L3 mode for netkit** when Ethernet headers not needed

## Kernel Version Requirements

- **netkit**: Linux 6.6+
- **tcx**: Linux 6.6+
- **Legacy TC with eBPF**: Linux 4.1+
- **XDP**: Linux 4.8+

## Common Patterns

### Pattern 1: Simple netkit CNF
```
[ns1] <--netkit--> [CNF with eBPF] <--netkit--> [ns2]
```

### Pattern 2: Service mesh sidecar
```
[Pod netns] <--netkit--> [Sidecar CNF] <--tcx--> [Host]
```

### Pattern 3: Chain of CNFs
```
[Source] <--netkit--> [CNF1] <--netkit--> [CNF2] <--netkit--> [Dest]
```

### Pattern 4: Traffic mirroring
```
                    ┌──> [Monitor CNF]
                    │
[Traffic] <--tcx--> [Mirror CNF]
                    │
                    └──> [Forward]
```
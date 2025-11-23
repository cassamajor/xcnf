# eBPF Attach Hook - Complete Examples

This file contains complete, production-ready examples demonstrating eBPF program attachment patterns. These examples complement the [SKILL.md](SKILL.md) guidance.

## Table of Contents

1. [Using Known Interface Indices](#using-known-interface-indices)

---

## Using Known Interface Indices

When you create interfaces programmatically, you already have the index from the creation result. Skip the `net.InterfaceByName` lookup and use the index directly.

### Example: Netkit Attachment with CreatePair

This pattern is used in `examples/netkit-ipv6/main.go`.

**Why use known indices?**
- Avoids redundant interface lookup
- Index is already available from creation
- Cleaner code with fewer error paths
- More efficient

```go
package main

import (
    "fmt"
    "log"

    "github.com/cilium/ebpf"
    "github.com/cilium/ebpf/link"

    "example/bytecode"
    "example/netkit"
)

func run() error {
    // Create netkit pair - returns struct with indices
    pair, err := netkit.CreatePair("nk0", netkit.WithL3Mode())
    if err != nil {
        return fmt.Errorf("creating netkit pair: %w", err)
    }
    defer pair.Delete()

    // Load eBPF objects
    var objs bytecode.NetkitObjects
    if err := bytecode.LoadNetkitObjects(&objs, nil); err != nil {
        return fmt.Errorf("loading eBPF objects: %w", err)
    }
    defer objs.Close()

    // Attach to primary using known index
    // No net.InterfaceByName("nk0") needed!
    primaryLink, err := link.AttachNetkit(link.NetkitOptions{
        Program:   objs.NetkitPrimary,
        Interface: pair.PrimaryIdx,  // Use index from struct
        Attach:    ebpf.AttachNetkitPrimary,
    })
    if err != nil {
        return fmt.Errorf("attaching primary: %w", err)
    }
    defer primaryLink.Close()

    // Peer attachment also uses primary's index
    // (Both attachments go through the primary interface)
    peerLink, err := link.AttachNetkit(link.NetkitOptions{
        Program:   objs.NetkitPeer,
        Interface: pair.PrimaryIdx,  // Same index for peer
        Attach:    ebpf.AttachNetkitPeer,
    })
    if err != nil {
        return fmt.Errorf("attaching peer: %w", err)
    }
    defer peerLink.Close()

    log.Printf("Attached to primary (index %d) and peer (index %d)",
        pair.PrimaryIdx, pair.PeerIdx)

    // ... application logic ...

    return nil
}
```

### The Pair Struct Pattern

When creating interfaces programmatically, return a struct with both the link objects and their indices:

```go
type Pair struct {
    Primary    netlink.Link
    Peer       netlink.Link
    PrimaryIdx int
    PeerIdx    int
}

func CreatePair(name string, opts ...Option) (*Pair, error) {
    // ... create interfaces ...

    return &Pair{
        Primary:    primary,
        Peer:       peer,
        PrimaryIdx: primary.Attrs().Index,
        PeerIdx:    peer.Attrs().Index,
    }, nil
}
```

This pattern makes indices immediately available for eBPF attachment without additional lookups.

### Comparison: Lookup vs Known Index

**With interface lookup (when you only have the name):**
```go
iface, err := net.InterfaceByName("nk0")
if err != nil {
    return err
}

l, err := link.AttachNetkit(link.NetkitOptions{
    Program:   prog,
    Interface: iface.Index,
    Attach:    ebpf.AttachNetkitPrimary,
})
```

**With known index (when you created the interface):**
```go
pair, _ := netkit.CreatePair("nk0")

l, err := link.AttachNetkit(link.NetkitOptions{
    Program:   prog,
    Interface: pair.PrimaryIdx,  // Direct use
    Attach:    ebpf.AttachNetkitPrimary,
})
```

### When to Use Each Pattern

| Pattern | Use When |
|---------|----------|
| Interface lookup | Attaching to existing interfaces (eth0, lo) |
| Known index | You created the interface programmatically |

---

## Summary

- When creating interfaces programmatically, store indices in return structs
- Use stored indices directly instead of looking up by name
- Both primary and peer netkit attachments use the primary's index
- See `examples/netkit-ipv6` for a complete working implementation

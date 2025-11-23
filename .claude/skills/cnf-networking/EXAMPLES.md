# CNF Networking - Complete Examples

This file contains complete, production-ready examples demonstrating CNF networking patterns in Go. These examples complement the [SKILL.md](SKILL.md) guidance.

## Table of Contents

1. [Programmatic Netkit Creation](#programmatic-netkit-creation)
2. [IPv6 Link-Local Configuration](#ipv6-link-local-configuration)

---

## Programmatic Netkit Creation

Create netkit device pairs programmatically in Go using vishvananda/netlink instead of shell commands.

### Why Programmatic Creation?

- Proper error handling
- Automatic cleanup with defer
- Type-safe configuration
- Testable code
- No shell command parsing

### Complete Netkit Package

From `examples/netkit-ipv6/netkit/`:

**netkit.go** - Core creation and deletion:

```go
package netkit

import (
    "fmt"
    "syscall"

    "github.com/vishvananda/netlink"
    "golang.org/x/sys/unix"
)

type Pair struct {
    Primary    netlink.Link
    Peer       netlink.Link
    PrimaryIdx int
    PeerIdx    int
}

func CreatePair(name string, opts ...Option) (*Pair, error) {
    if name == "" {
        return nil, fmt.Errorf("netkit: device name cannot be empty")
    }

    cfg := defaultConfig()
    for _, opt := range opts {
        opt(cfg)
    }

    // Create netkit link
    attrs := netlink.NewLinkAttrs()
    attrs.Name = name

    // Set up peer attributes with "p" suffix convention
    // (e.g., "nk0" primary -> "nk0p" peer, similar to veth naming)
    peerName := name + "p"
    peerAttrs := netlink.NewLinkAttrs()
    peerAttrs.Name = peerName

    primary := &netlink.Netkit{
        LinkAttrs: attrs,
        Mode:      cfg.mode,
        Scrub:     cfg.scrubPrimary,
        PeerScrub: cfg.scrubPeer,
    }
    primary.SetPeerAttrs(&peerAttrs)

    if err := netlink.LinkAdd(primary); err != nil {
        return nil, fmt.Errorf("netkit: failed to create primary %q: %w", name, err)
    }

    // Setup cleanup in case of failure
    var cleanupPrimary = true
    defer func() {
        if cleanupPrimary {
            netlink.LinkDel(primary)
        }
    }()

    // Get the peer link (created automatically by netkit)
    peer, err := netlink.LinkByName(peerName)
    if err != nil {
        return nil, fmt.Errorf("netkit: failed to find peer %q: %w", peerName, err)
    }

    // Bring up primary interface
    if err := netlink.LinkSetUp(primary); err != nil {
        return nil, fmt.Errorf("netkit: failed to bring up primary: %w", err)
    }

    // Bring up peer interface
    if err := netlink.LinkSetUp(peer); err != nil {
        return nil, fmt.Errorf("netkit: failed to bring up peer: %w", err)
    }

    cleanupPrimary = false

    return &Pair{
        Primary:    primary,
        Peer:       peer,
        PrimaryIdx: primary.Attrs().Index,
        PeerIdx:    peer.Attrs().Index,
    }, nil
}

func (p *Pair) Delete() error {
    if p == nil || p.Primary == nil {
        return nil
    }

    // Deleting primary automatically deletes peer
    if err := netlink.LinkDel(p.Primary); err != nil {
        // Ignore "not found" errors (idempotent)
        if err == unix.ENODEV || err == syscall.ENODEV {
            return nil
        }
        return fmt.Errorf("netkit: failed to delete: %w", err)
    }

    return nil
}
```

**options.go** - Functional options:

```go
package netkit

import "github.com/vishvananda/netlink"

type config struct {
    mode         netlink.NetkitMode
    scrubPrimary netlink.NetkitScrub
    scrubPeer    netlink.NetkitScrub
}

type Option func(*config)

func defaultConfig() *config {
    return &config{
        mode:         netlink.NETKIT_MODE_L3,
        scrubPrimary: netlink.NETKIT_SCRUB_NONE,
        scrubPeer:    netlink.NETKIT_SCRUB_NONE,
    }
}

func WithL2Mode() Option {
    return func(c *config) {
        c.mode = netlink.NETKIT_MODE_L2
    }
}

func WithL3Mode() Option {
    return func(c *config) {
        c.mode = netlink.NETKIT_MODE_L3
    }
}

func WithNoScrub() Option {
    return func(c *config) {
        c.scrubPrimary = netlink.NETKIT_SCRUB_NONE
        c.scrubPeer = netlink.NETKIT_SCRUB_NONE
    }
}
```

### Usage

```go
// Create L3 netkit pair
pair, err := netkit.CreatePair("nk0", netkit.WithL3Mode())
if err != nil {
    return err
}
defer pair.Delete()

// Use pair.PrimaryIdx for eBPF attachment
primaryLink, err := link.AttachNetkit(link.NetkitOptions{
    Program:   objs.NetkitPrimary,
    Interface: pair.PrimaryIdx,
    Attach:    ebpf.AttachNetkitPrimary,
})
```

### Key Patterns

**SetPeerAttrs for explicit naming:**
```go
// Without SetPeerAttrs - kernel auto-generates peer name
primary := &netlink.Netkit{
    LinkAttrs: attrs,
    Mode:      netlink.NETKIT_MODE_L3,
}
netlink.LinkAdd(primary)  // Peer gets auto-generated name

// With SetPeerAttrs - explicit peer name
peerAttrs := netlink.NewLinkAttrs()
peerAttrs.Name = "nk0p"
primary.SetPeerAttrs(&peerAttrs)
netlink.LinkAdd(primary)  // Peer is named "nk0p"
```

**Cleanup on failure:**
```go
var cleanupPrimary = true
defer func() {
    if cleanupPrimary {
        netlink.LinkDel(primary)
    }
}()

// ... operations that might fail ...

cleanupPrimary = false  // Success - don't cleanup
```

---

## IPv6 Link-Local Configuration

Assign IPv6 link-local addresses to netkit interfaces.

### Why Random IIDs?

Netkit interfaces may not have real MAC addresses, so we generate random Interface IDs (IIDs) for the link-local addresses instead of using EUI-64.

**ipv6.go:**

```go
package netkit

import (
    "crypto/rand"
    "fmt"
    "net"

    "github.com/vishvananda/netlink"
)

// ConfigureIPv6LinkLocal assigns IPv6 link-local addresses to both
// primary and peer interfaces using random Interface IDs (IIDs).
func (p *Pair) ConfigureIPv6LinkLocal() error {
    if err := p.assignLinkLocal(p.Primary); err != nil {
        return fmt.Errorf("primary: %w", err)
    }

    if err := p.assignLinkLocal(p.Peer); err != nil {
        return fmt.Errorf("peer: %w", err)
    }

    return nil
}

func (p *Pair) assignLinkLocal(link netlink.Link) error {
    // Generate a link-local address (fe80::/64)
    addr, err := generateLinkLocalAddr()
    if err != nil {
        return err
    }

    // Create netlink address object
    nlAddr := &netlink.Addr{
        IPNet: &net.IPNet{
            IP:   addr,
            Mask: net.CIDRMask(64, 128),
        },
    }

    // Add address to interface
    if err := netlink.AddrAdd(link, nlAddr); err != nil {
        return fmt.Errorf("failed to add address: %w", err)
    }

    return nil
}

func generateLinkLocalAddr() (net.IP, error) {
    // fe80::/64 prefix
    addr := make(net.IP, 16)
    addr[0] = 0xfe
    addr[1] = 0x80

    // Random Interface ID (last 64 bits)
    iid := make([]byte, 8)
    if _, err := rand.Read(iid); err != nil {
        return nil, fmt.Errorf("failed to generate random IID: %w", err)
    }

    copy(addr[8:], iid)

    return addr, nil
}
```

### Usage

```go
pair, err := netkit.CreatePair("nk0", netkit.WithL3Mode())
if err != nil {
    return err
}
defer pair.Delete()

// Configure IPv6 link-local addresses
if err := pair.ConfigureIPv6LinkLocal(); err != nil {
    return fmt.Errorf("configuring IPv6: %w", err)
}

// Now can send IPv6 traffic between primary and peer
```

### Testing IPv6 Traffic

```bash
# Send multicast ping through the interface
ping6 ff02::1%nk0

# Note: May see warning about source address selection
# This is cosmetic when multiple link-local addresses exist
```

---

## Summary

- **Use vishvananda/netlink** for programmatic netkit creation
- **SetPeerAttrs** for explicit peer naming control
- **Return indices** from creation for eBPF attachment
- **Random IIDs** for link-local addresses when MAC unavailable
- **Idempotent Delete** - ignore ENODEV errors

See `examples/netkit-ipv6` for a complete working implementation.

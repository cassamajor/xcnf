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

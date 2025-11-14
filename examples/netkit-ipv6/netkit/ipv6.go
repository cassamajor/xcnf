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
	// Using random IID since netkit may not have real MAC addresses
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

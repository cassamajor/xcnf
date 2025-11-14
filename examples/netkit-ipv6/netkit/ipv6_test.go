package netkit

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/vishvananda/netlink"
)

func TestConfigureIPv6LinkLocal(t *testing.T) {
	if os.Geteuid() != 0 {
		t.Skip("Requires root privileges")
	}

	pair, err := CreatePair("test_ipv6", WithL3Mode())
	require.NoError(t, err)
	defer pair.Delete()

	err = pair.ConfigureIPv6LinkLocal()
	require.NoError(t, err)

	// Verify primary has link-local address
	primaryAddrs, err := netlink.AddrList(pair.Primary, netlink.FAMILY_V6)
	require.NoError(t, err)

	hasLinkLocal := false
	for _, addr := range primaryAddrs {
		if addr.IP.IsLinkLocalUnicast() {
			hasLinkLocal = true
			// Verify it's in fe80::/64 range
			assert.True(t, addr.IP.To16() != nil)
			assert.Equal(t, byte(0xfe), addr.IP[0])
			assert.Equal(t, byte(0x80), addr.IP[1])
			break
		}
	}
	assert.True(t, hasLinkLocal, "Primary should have link-local address")

	// Verify peer has link-local address
	peerAddrs, err := netlink.AddrList(pair.Peer, netlink.FAMILY_V6)
	require.NoError(t, err)

	hasLinkLocal = false
	for _, addr := range peerAddrs {
		if addr.IP.IsLinkLocalUnicast() {
			hasLinkLocal = true
			break
		}
	}
	assert.True(t, hasLinkLocal, "Peer should have link-local address")
}

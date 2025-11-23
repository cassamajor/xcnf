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

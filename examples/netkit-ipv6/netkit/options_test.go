package netkit

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/vishvananda/netlink"
)

func TestFunctionalOptions(t *testing.T) {
	tests := []struct {
		name     string
		opts     []Option
		validate func(*testing.T, *config)
	}{
		{
			name: "default config",
			opts: []Option{},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, netlink.NETKIT_MODE_L3, cfg.mode)
				assert.Equal(t, netlink.NETKIT_SCRUB_NONE, cfg.scrubPrimary)
				assert.Equal(t, netlink.NETKIT_SCRUB_NONE, cfg.scrubPeer)
			},
		},
		{
			name: "with L2 mode",
			opts: []Option{WithL2Mode()},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, netlink.NETKIT_MODE_L2, cfg.mode)
			},
		},
		{
			name: "with L3 mode explicit",
			opts: []Option{WithL3Mode()},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, netlink.NETKIT_MODE_L3, cfg.mode)
			},
		},
		{
			name: "disable scrubbing",
			opts: []Option{WithNoScrub()},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, netlink.NETKIT_SCRUB_NONE, cfg.scrubPrimary)
				assert.Equal(t, netlink.NETKIT_SCRUB_NONE, cfg.scrubPeer)
			},
		},
		{
			name: "combined options",
			opts: []Option{
				WithL3Mode(),
				WithNoScrub(),
			},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, netlink.NETKIT_MODE_L3, cfg.mode)
				assert.Equal(t, netlink.NETKIT_SCRUB_NONE, cfg.scrubPrimary)
				assert.Equal(t, netlink.NETKIT_SCRUB_NONE, cfg.scrubPeer)
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			cfg := defaultConfig()
			for _, opt := range tt.opts {
				opt(cfg)
			}
			tt.validate(t, cfg)
		})
	}
}

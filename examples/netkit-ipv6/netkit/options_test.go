package netkit

import (
	"testing"

	"github.com/stretchr/testify/assert"
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
				assert.Equal(t, netkitL3, cfg.mode)
				assert.True(t, cfg.scrubPrimary)
				assert.True(t, cfg.scrubPeer)
				assert.Equal(t, 0, cfg.headroom)
				assert.Equal(t, 0, cfg.tailroom)
			},
		},
		{
			name: "with L2 mode",
			opts: []Option{WithL2Mode()},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, netkitL2, cfg.mode)
			},
		},
		{
			name: "with headroom",
			opts: []Option{WithHeadroom(256)},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, 256, cfg.headroom)
			},
		},
		{
			name: "with tailroom",
			opts: []Option{WithTailroom(128)},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, 128, cfg.tailroom)
			},
		},
		{
			name: "disable scrubbing",
			opts: []Option{WithNoScrub()},
			validate: func(t *testing.T, cfg *config) {
				assert.False(t, cfg.scrubPrimary)
				assert.False(t, cfg.scrubPeer)
			},
		},
		{
			name: "combined options",
			opts: []Option{
				WithL3Mode(),
				WithHeadroom(256),
				WithTailroom(128),
			},
			validate: func(t *testing.T, cfg *config) {
				assert.Equal(t, netkitL3, cfg.mode)
				assert.Equal(t, 256, cfg.headroom)
				assert.Equal(t, 128, cfg.tailroom)
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

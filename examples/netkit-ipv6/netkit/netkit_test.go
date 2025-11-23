package netkit

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCreatePair(t *testing.T) {
	if os.Geteuid() != 0 {
		t.Skip("Requires root privileges")
	}

	tests := []struct {
		name    string
		devName string
		opts    []Option
		wantErr bool
	}{
		{
			name:    "create L3 pair",
			devName: "test0",
			opts:    []Option{WithL3Mode()},
			wantErr: false,
		},
		{
			name:    "create with no scrub",
			devName: "test1",
			opts:    []Option{WithL3Mode(), WithNoScrub()},
			wantErr: false,
		},
		{
			name:    "empty name fails",
			devName: "",
			opts:    []Option{},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			pair, err := CreatePair(tt.devName, tt.opts...)

			if tt.wantErr {
				assert.Error(t, err)
				return
			}

			require.NoError(t, err)
			require.NotNil(t, pair)
			defer pair.Delete()

			// Verify pair structure
			assert.NotNil(t, pair.Primary)
			assert.NotNil(t, pair.Peer)
			assert.Greater(t, pair.PrimaryIdx, 0)
			assert.Greater(t, pair.PeerIdx, 0)

			// Verify interface names follow convention
			assert.Equal(t, tt.devName, pair.Primary.Attrs().Name)
			assert.Equal(t, tt.devName+"p", pair.Peer.Attrs().Name)
		})
	}
}

func TestDelete(t *testing.T) {
	if os.Geteuid() != 0 {
		t.Skip("Requires root privileges")
	}

	pair, err := CreatePair("test_del", WithL3Mode())
	require.NoError(t, err)

	err = pair.Delete()
	assert.NoError(t, err)

	// Delete should be idempotent
	err = pair.Delete()
	assert.NoError(t, err)
}

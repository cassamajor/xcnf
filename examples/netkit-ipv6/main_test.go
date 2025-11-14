package main

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/cassamajor/xcnf/examples/netkit-ipv6/bytecode"
	"github.com/cassamajor/xcnf/examples/netkit-ipv6/netkit"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/ringbuf"
	"github.com/cilium/ebpf/rlimit"
	"github.com/stretchr/testify/require"
)

func TestFullWorkflow(t *testing.T) {
	if os.Geteuid() != 0 {
		t.Skip("Requires root privileges")
	}

	// Remove memlock
	require.NoError(t, rlimit.RemoveMemlock())

	// Create pair
	pair, err := netkit.CreatePair("test_full",
		netkit.WithL3Mode(),
	)
	require.NoError(t, err)
	defer pair.Delete()

	// Configure IPv6
	require.NoError(t, pair.ConfigureIPv6LinkLocal())

	// Load eBPF
	var objs bytecode.NetkitObjects
	require.NoError(t, bytecode.LoadNetkitObjects(&objs, nil))
	defer objs.Close()

	// Attach primary
	primaryLink, err := link.AttachNetkit(link.NetkitOptions{
		Program:   objs.NetkitPrimary,
		Interface: pair.PrimaryIdx,
		Attach:    ebpf.AttachNetkitPrimary,
	})
	require.NoError(t, err)
	defer primaryLink.Close()

	// Attach peer
	peerLink, err := link.AttachNetkit(link.NetkitOptions{
		Program:   objs.NetkitPeer,
		Interface: pair.PrimaryIdx,
		Attach:    ebpf.AttachNetkitPeer,
	})
	require.NoError(t, err)
	defer peerLink.Close()

	// Open ringbuf
	rd, err := ringbuf.NewReader(objs.Ipv6Events)
	require.NoError(t, err)
	defer rd.Close()

	// Poll for events briefly
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	eventReceived := false
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			default:
				record, err := rd.Read()
				if err != nil {
					continue
				}
				if len(record.RawSample) >= 37 {
					eventReceived = true
					return
				}
			}
		}
	}()

	// Note: Without generating actual IPv6 traffic, we won't receive events
	// This test validates the setup works correctly
	<-ctx.Done()

	t.Log("Full workflow completed successfully")
	// eventReceived will be false unless traffic is generated
	t.Logf("Event received: %v", eventReceived)
}

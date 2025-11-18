# netkit-ipv6: IPv6 Packet Inspection on Netkit Devices

This example demonstrates programmatic creation and management of netkit device pairs in L3 mode with IPv6 link-local addressing and eBPF-based packet inspection.

## Learning Objectives

- Create netkit device pairs programmatically using vishvananda/netlink
- Configure L3 mode with automatic IPv6 link-local addresses
- Attach eBPF programs to both primary and peer interfaces
- Parse IPv6 packet headers using CO-RE for portability
- Use ringbuf for efficient kernel-to-userspace event streaming
- Apply Functional Options Pattern for flexible configuration

## Prerequisites

- Linux kernel 6.6+ (netkit support)
- Root privileges (CAP_NET_ADMIN, CAP_BPF)
- clang/llvm (for eBPF compilation)
- Go 1.25+
- bpftool (for generating vmlinux.h)

## Architecture

```
┌─────────────┐
│   main.go   │  Creates netkit pair, loads eBPF, logs events
└─────┬───────┘
      │
      ├──► netkit package (Go)
      │    ├── CreatePair() with functional options
      │    ├── ConfigureIPv6LinkLocal()
      │    └── Delete()
      │
      └──► eBPF program (C + CO-RE)
           ├── netkit/primary hook
           ├── netkit/peer hook
           ├── Parse IPv6 headers
           └── Send events via ringbuf
```

## Build

```bash
# Inside OrbStack VM
orb
cd /Users/cassamajor/code/network-axis/xcnf/examples/netkit-ipv6

# Generate vmlinux.h (one-time setup)
cd bytecode
bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h
cd ..

# Generate eBPF bytecode
go generate ./bytecode

# Build application
go build
```

## Usage

```bash
# Run with default device name (nk0)
sudo ./netkit-ipv6

# Specify custom device name
sudo ./netkit-ipv6 -name mydev

# In another terminal, generate IPv6 traffic:
ping6 ff02::1%nk0p  # Multicast to all nodes
```

## Example Output

```
2025/11/14 01:05:10 Creating netkit pair "nk0"...
2025/11/14 01:05:10 Configuring IPv6 link-local addresses...
2025/11/14 01:05:10 Loading eBPF programs...
2025/11/14 01:05:10 Attaching to primary interface...
2025/11/14 01:05:10 Attaching to peer interface...
2025/11/14 01:05:10 Monitoring IPv6 traffic on nk0 (Ctrl+C to exit)
2025/11/14 01:05:10 Primary: nk0 (index 11)
2025/11/14 01:05:10 Peer: nk0p (index 12)
[peer] IPv6: fe80::a4b3:12ff:fe34:5678 -> ff02::1 | next=58 len=64 ttl=255
[primary] IPv6: fe80::2450:f8ea:df44:a99f -> ff02::2 | next=58 len=16 ttl=255
```

## Testing

```bash
# Run all tests (requires root, inside OrbStack VM)
sudo -E go test -v ./...

# Run specific package tests
sudo -E go test -v ./netkit

# Run integration test
sudo -E go test -v . -run TestFullWorkflow
```

## Key Implementation Details

### Functional Options Pattern

The netkit package uses the functional options pattern for flexible configuration:

```go
pair, err := netkit.CreatePair("nk0",
    netkit.WithL3Mode(),
    netkit.WithNoScrub(),
)
```

### Naming Convention

Netkit devices follow a "primary + p" naming convention (similar to veth):
- Primary: `nk0`
- Peer: `nk0p`

This is explicitly configured using `SetPeerAttrs()` before device creation.

### IPv6 Link-Local Addressing

Link-local addresses (fe80::/64) are automatically generated and assigned to both interfaces using random Interface IDs (IIDs). Note that netkit in L3 mode may also auto-generate kernel link-local addresses.

### CO-RE Portability

The eBPF program uses CO-RE (Compile Once, Run Everywhere) with:
- `vmlinux.h` for kernel type definitions
- `BPF_CORE_READ()` for portable field access
- Works across kernel versions 6.6+

### Resource Management

All resources are cleaned up via `defer` statements in reverse creation order:
1. Ringbuf reader
2. eBPF links (detach programs)
3. eBPF objects (unload programs/maps)
4. Netkit device pair (delete interfaces)

## Troubleshooting

**Error: "operation not permitted"**
- Ensure running with root privileges: `sudo ./netkit-ipv6`

**Error: "netkit not supported"**
- Kernel 6.6+ required
- Check: `uname -r`
- This example must run in Linux (OrbStack VM on macOS)

**Error: "not implemented"**
- Running on macOS instead of Linux
- Use: `orb` to enter OrbStack VM

**No events logged**
- Generate IPv6 traffic: `ping6 ff02::1%<interface>p`
- Check interface is up: `ip link show`

**Warning: "source address might be selected on device other than"**
- Cosmetic warning from ping6
- Occurs when multiple link-local addresses exist
- Packets still flow correctly through the interface

## References

- [Netkit Documentation](https://docs.kernel.org/next/networking/netkit.html)
- [vishvananda/netlink](https://github.com/vishvananda/netlink)
- [cilium/ebpf](https://github.com/cilium/ebpf)
- [eBPF CO-RE](https://nakryiko.com/posts/bpf-portability-and-co-re/)
- [IPv6 Link-Local Addresses (RFC 4291)](https://datatracker.ietf.org/doc/html/rfc4291)

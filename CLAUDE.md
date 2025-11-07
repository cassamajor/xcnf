# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an eBPF development repository containing Go-based eBPF applications for network packet processing and system tracing. The project uses the cilium/ebpf library to compile C-based eBPF programs and load them into the Linux kernel from Go userspace applications.

## Development Environment Setup

Development requires a Linux environment with kernel eBPF support. The project uses OrbStack to run an Ubuntu VM on macOS:

```shell
# Create Ubuntu VM with eBPF dependencies
orb create ubuntu ebpf -c config/cloud-init.yaml

# Access the VM
orb

# Teardown when done
orb delete ebpf
```

The cloud-init configuration installs: clang, llvm, libbpf-dev, golang, and creates symlinks to resolve header dependencies.

## Project Architecture

### Two-Part Architecture

Each example follows a consistent pattern with two components:

1. **eBPF Program (C)**: Runs in kernel space
   - Located in `examples/{name}/bytecode/{name}.c`
   - Uses eBPF helpers and kernel headers
   - Compiled to bytecode via bpf2go

2. **Userspace Application (Go)**: Runs in userspace
   - Located in `examples/{name}/main.go`
   - Loads and attaches eBPF programs
   - Reads data from eBPF maps/ringbufs

### Code Generation

The project uses `bpf2go` (from cilium/ebpf) to generate Go bindings from C eBPF programs. Each example has a `bytecode/gen.go` file with a `//go:generate` directive:

```go
//go:generate go tool bpf2go {Name} {source}.c
```

This generates `*_bpfel.go` and `*_bpfeb.go` files (little/big endian) containing:
- Go structs matching eBPF map definitions
- Functions to load programs into the kernel

### Example Structure

```
examples/{name}/
├── main.go              # Userspace application
├── bytecode/
│   ├── gen.go          # go:generate directive
│   ├── {name}.c        # eBPF program source
│   ├── {name}_bpfel.go # Generated (little endian)
│   └── {name}_bpfeb.go # Generated (big endian)
├── go.mod              # Module dependencies
└── README.md           # Example-specific instructions
```

## Common Development Commands

### Compile eBPF Program
```shell
# Must run inside Linux VM (via orb)
cd examples/{name}
go generate ./bytecode
```

This invokes bpf2go to compile the C program and generate Go bindings.

### Build Userspace Application
```shell
# For local testing
go build -o {name}

# For production (statically linked, ARM64 Linux)
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build
```

### Run Application
```shell
# Requires root/capabilities for eBPF operations
sudo ./{name}
```

### Run Tests
```shell
# Some examples include tests (e.g., flow)
sudo -E go test .
```

### View Kernel Trace Logs
```shell
# In a separate terminal, for tc-based programs
sudo tc exec bpf dbg
```

## Key Examples

### netkit
Demonstrates attaching eBPF programs to netkit interfaces (primary/peer). The programs use `link.AttachNetkit()` to attach to both sides of a netkit veth pair.

### flow
TC (Traffic Control) classifier that parses IPv4/IPv6 packets, extracts TCP/UDP flow information, and sends it to userspace via a ringbuf. Shows packet parsing patterns and use of `bpf_ringbuf_output()`.

### ip-counter
Simple XDP program that counts incoming packets on a network interface.

## Container Build Process

Each example can be containerized for deployment. The standard workflow:

```shell
# Set variables
export PROGRAM={name}
export USERNAME={github-username}
export IMAGE_NAME=ebpf-{name}
export CR_PAT={github-token}

# Authenticate to GHCR
echo $CR_PAT | docker login ghcr.io -u $USERNAME --password-stdin

# Create multi-arch builder
docker buildx create --name multi-arch-ebpf --driver docker-container --use --bootstrap

# Build and push multi-arch image
docker buildx build -t ghcr.io/$USERNAME/$IMAGE_NAME:v1 --push --platform linux/amd64,linux/arm64 .

# Test
docker run --privileged --pull=always -it ghcr.io/$USERNAME/$IMAGE_NAME:v1
```

## Adding New Examples

To create a new example:

```shell
# Create directory structure
mkdir -p examples/{name}/bytecode
touch examples/{name}/main.go
touch examples/{name}/bytecode/gen.go
touch examples/{name}/bytecode/{name}.c

# Initialize Go module (inside Linux VM)
orb
cd examples/{name}
go mod init github.com/cassamajor/xcnf/examples/{name}
go get -tool github.com/cilium/ebpf/cmd/bpf2go
go mod tidy

# Compile eBPF program
go generate ./bytecode
```

## Important Implementation Details

### eBPF Program Sections

eBPF programs use `SEC()` macros to specify attachment points:
- `SEC("netkit/primary")` / `SEC("netkit/peer")` - Netkit interfaces
- `SEC("tc")` - TC classifier/action
- `SEC("xdp")` - XDP (eXpress Data Path)
- `SEC("kprobe/...")` - Kernel function probes

### Return Values

Different program types use different return values:
- TC: `TC_ACT_OK`, `TC_ACT_SHOT`, etc.
- Netkit: `NETKIT_PASS`, `NETKIT_DROP`, `NETKIT_REDIRECT`
- XDP: `XDP_PASS`, `XDP_DROP`, `XDP_TX`, etc.

### Packet Parsing Pattern

The flow example demonstrates the standard pattern for parsing network packets:
1. Check packet type (skip broadcast/multicast)
2. Get data pointers: `skb->data` (head) and `skb->data_end` (tail)
3. Bounds check before each header access: `if (ptr + sizeof(header) > tail)`
4. Parse Ethernet → IP (v4/v6) → TCP/UDP
5. Extract data and send to userspace via maps/ringbufs

### IPv4-Mapped IPv6 Addresses

The flow example uses RFC4291 IPv4-Mapped IPv6 addresses to unify IPv4 and IPv6 handling, storing both as `in6_addr` with IPv4 addresses embedded in the last 32 bits.

## Testing Without Userspace

TC programs can be tested directly:

```shell
# Compile C to BPF bytecode
clang -target bpf -S -D __BPF_TRACING__ -Wall -Werror -O2 -emit-llvm -c -g {name}.c
llc -march=bpf -filetype=obj -o {name}.o {name}.ll

# Add qdisc and filter
sudo tc qdisc add dev lo clsact
sudo tc filter add dev lo ingress bpf direct-action obj {name}.o sec tc

# Generate traffic and view logs
ping 127.0.0.1
sudo tc exec bpf dbg

# Cleanup
sudo tc qdisc del dev lo clsact
```

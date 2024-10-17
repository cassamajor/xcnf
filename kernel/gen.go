package kernel

//go:generate go run github.com/cilium/ebpf/cmd/bpf2go Counter counter.c

//go:generate go run github.com/cilium/ebpf/cmd/bpf2go Bpf xdp.c -- -I headers

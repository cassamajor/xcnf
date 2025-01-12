package bytecode

//go:generate go run github.com/cilium/ebpf/cmd/bpf2go Probe flat.c - -O2  -Wall -Werror -Wno-address-of-packed-member

package bytecode

//go:generate go tool bpf2go Probe flat.c - -O2  -Wall -Werror -Wno-address-of-packed-member

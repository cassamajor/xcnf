package bytecode

//go:generate go tool bpf2go -cc clang -cflags "-O2 -g -Wall -Werror" -target amd64,arm64 Netkit netkit_ipv6.c

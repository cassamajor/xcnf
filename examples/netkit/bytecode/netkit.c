//go:build ignore

#include <linux/if_link.h>
#include <bpf/bpf_helpers.h>

SEC("netkit/primary")
int netkit_primary(struct __sk_buff *skb) {
    return NETKIT_PASS;
}

SEC("netkit/peer")
int netkit_peer(struct __sk_buff *skb) {
    return NETKIT_PASS;
}

char _license[] SEC("license") = "GPL";
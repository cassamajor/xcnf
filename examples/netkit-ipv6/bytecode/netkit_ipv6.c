//go:build ignore

#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>
#include <bpf/bpf_core_read.h>

#define ETH_P_IPV6 0x86DD
#define NETKIT_PASS 0

// Event structure sent to userspace
struct ipv6_event {
	__u8 src_addr[16];
	__u8 dst_addr[16];
	__u8 next_header;
	__u16 payload_len;
	__u8 hop_limit;
	__u8 direction;  // 0=primary, 1=peer
} __attribute__((packed));

// Ring buffer for events
struct {
	__uint(type, BPF_MAP_TYPE_RINGBUF);
	__uint(max_entries, 256 * 1024);
} ipv6_events SEC(".maps");

static __always_inline int process_ipv6(struct __sk_buff *skb, __u8 direction) {
	void *data_end = (void *)(long)skb->data_end;
	void *data = (void *)(long)skb->data;

	struct ethhdr *eth = data;

	// Bounds check for Ethernet header
	if ((void *)(eth + 1) > data_end)
		return NETKIT_PASS;

	// Check for IPv6 (ethertype 0x86DD)
	if (eth->h_proto != bpf_htons(ETH_P_IPV6))
		return NETKIT_PASS;

	struct ipv6hdr *ip6 = (void *)(eth + 1);

	// Bounds check for IPv6 header
	if ((void *)(ip6 + 1) > data_end)
		return NETKIT_PASS;

	// Reserve space in ringbuf
	struct ipv6_event *event = bpf_ringbuf_reserve(&ipv6_events,
	                                                sizeof(*event), 0);
	if (!event)
		return NETKIT_PASS;

	// Copy IPv6 data using CO-RE reads
	__builtin_memcpy(event->src_addr, &ip6->saddr, 16);
	__builtin_memcpy(event->dst_addr, &ip6->daddr, 16);
	event->next_header = BPF_CORE_READ(ip6, nexthdr);
	event->payload_len = bpf_ntohs(BPF_CORE_READ(ip6, payload_len));
	event->hop_limit = BPF_CORE_READ(ip6, hop_limit);
	event->direction = direction;

	// Submit to ringbuf
	bpf_ringbuf_submit(event, 0);

	return NETKIT_PASS;
}

SEC("netkit/primary")
int netkit_primary(struct __sk_buff *skb) {
	return process_ipv6(skb, 0);
}

SEC("netkit/peer")
int netkit_peer(struct __sk_buff *skb) {
	return process_ipv6(skb, 1);
}

char _license[] SEC("license") = "GPL";

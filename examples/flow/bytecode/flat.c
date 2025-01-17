//go:build ignore

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#include <linux/bpf.h>
#include <linux/bpf_common.h>

#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/in.h>
#include <linux/in6.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <linux/pkt_cls.h>

#include <bpf/bpf_endian.h>
#include <bpf/bpf_helpers.h>

char _license[] SEC("license") = "Dual MIT/GPL";

/* A feature in RFC4291 called IPv4-Mapped IPv6 Address
allows embedding an IPv4 address in an IPv6 address */
struct packet_t {
    struct in6_addr src_ip;
    struct in6_addr dst_ip;
    __be16 src_port;
    __be16 dst_port;
    __u8 protocol;
    __u8 ttl;
    bool syn;
    bool ack;
    uint64_t ts;
};

struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 512 * 1024); /* 512 KB */
} pipe SEC(".maps");

SEC("tc") /* Program hook point */ 
int flat(struct __sk_buff* skb) {
    bpf_printk("Got a Packet!\n");

    if (bpf_skb_pull_data(skb, 0) < 0) {
        return TC_ACT_OK;
    }

    if (skb->pkt_type == PACKET_BROADCAST || skb->pkt_type == PACKET_MULTICAST) {
        return TC_ACT_OK;
    }


    return 0;
}

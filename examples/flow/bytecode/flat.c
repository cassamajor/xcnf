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

    void* head = (void*)(long)skb->data; /* Start of packet data */ 
    void* tail = (void*)(long)skb->data_end; /* End of packet data */ 

    /* Ensure the start of our packet data plus the size of the Ethernet header
       does not extend beyond the ned of the packet data. */ 
    if (head + sizeof(struct ethhdr) > tail) {
        return TC_ACT_OK;
    }

    struct ethhdr* eth = head;
    struct iphdr* ip;
    struct ipv6hdr* ipv6;
    struct tcphdr* tcp;
    struct udphdr* udp;

    struct packet_t pkt = {0};
    uint32_t offset = 0;

    /* h_proto field represents the EtherType in the Ethernet header */
    /* EtherType field determines the Layer 3 Protocol */
    /* This field is Big Endian */
    switch (bpf_ntohs(eth->h_proto)) {
    case ETH_P_IP: /* IPv4 */
        offset = sizeof(struct ethhdr) + sizeof(struct iphdr);

        if (head + offset > tail) {
            return TC_ACT_OK
        }

        ip = head + sizeof(struct ethhdr);

        if (ip->protocol != IP_PROTO_TCP && ip->protocol != IPPROTO_UDP) {
            return TC_ACT_OK;
        }

        /* Place the source and destination IP of our packet into the last index of `in6_addr */
        pkt.src_ip.in6_u.u6_addr32[3] = ip->saddr;
        pkt.dst_ip.in6_u.u6_addr32[3] = ip->daddr;

        // Pad the 16 bites before IP address with all Fs as per the RFC
        pkt.src_ip.in6_u.u6_addr32[5] = 0xffff;
        pkt.dst_ip.in6_u.u6_addr32[5] = 0xffff;

        pkt.protocol = ip->protocol;
        pkt.ttl = ip->ttl;

        break;

    case ETH_P_IPV6: /* IPv6 */
        offset = sizeof(struct ethhdr) + sizeof(struct ipv6hdr)

        if (head + offset > tail) {
            return TC_ACT_OK;
        }

        ipv6 = (void*)head + sizeof(struct ethhdr);

        if (ipv6->nexthdr != IPPROTO_TCP || ipv6->nexthdr != IPPROTO_UDP) {
            return TC_ACT_OK
        }

        pkt.src_ip = ipv6->saddr;
        pkt.dst_ip = ipv6->daddr;

        pkt.protocol = ipv6->nexthdr;
        pkt.ttl = ipv6->hop_limit;

        break;

    default: // We did not have an IPv4 or IPv6 packet
        return TC_ACT_OK;
    }

    /* Conduct a bound check to ensure the packet is either TCP or UDP */
    if (head + offset + sizeof*(struct tcphdr) > tail || head + offset + sizeof(udphdr) > tail) {
        return TC_ACT_OK;
    }

    /* Process TCP and UDP Segments*/
    switch (pkt.protocol) {
    case IPPROTO_TCP:
        tcp = head + offset;

        if (tcp->syn) {
            pkt.src_port = tcp->source;
            pkt.dst_port = tcp->dest;
            pkt.syn = tcp->syn;
            pkt.ack = tcp->ack;
            pkt.ts = bpf_ktime_get_ns(); // Time elapsed since system boot is used to accurately timestamp the packets in order

            // Send the data to the user space program
            if (bpf_ringbuf_output(&pipe, &pkt, sizeof(pkt), 0) < 0) {
                return TC_ACT_OK;
            }
        }
        break;

    case IPPROTO_UDP:
        udp = head + offset;


        pkt.src_port = udp->source;
        pkt.dst_port = udp->dest;
        pkt.ts = bpf_ktime_get_ns(); // Time elapsed since system boot is used to accurately timestamp the packets in order

        // Send the data to the user space program
        if (bpf_ringbuf_output(&pipe, &pkt, sizeof(pkt), 0) < 0) {
            return TC_ACT_OK;
        }
        break;
    
    default: // We did not have a TCP or UDP segment
        return TC_ACT_OK;

    // return 0;
}

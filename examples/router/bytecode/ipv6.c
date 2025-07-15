#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>  // Required for byte order conversions

SEC("xdp")
int xdp_inspect_packet(struct xdp_md *ctx) {
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;

    struct ethhdr *eth = data;
    if ((void *)(eth + 1) > data_end)
        return XDP_DROP;

    struct ipv6hdr ip6hdr = {0};  // Common struct to store IPv6-formatted IPs
    __u8 protocol = 0;  // Store transport layer protocol
    __u16 src_port = 0, dst_port = 0;  // Store transport ports

    // Handle IPv4 packets (convert to IPv4-Mapped IPv6)
    if (eth->h_proto == __bpf_constant_htons(ETH_P_IP)) {
        struct iphdr *ip = (struct iphdr *)(eth + 1);
        if ((void *)(ip + 1) > data_end)
            return XDP_DROP;

        // Convert IPv4 to IPv4-Mapped IPv6 format
        ip6hdr.saddr.s6_addr32[2] = __bpf_constant_htonl(0x0000FFFF);
        ip6hdr.saddr.s6_addr32[3] = ip->saddr;

        ip6hdr.daddr.s6_addr32[2] = __bpf_constant_htonl(0x0000FFFF);
        ip6hdr.daddr.s6_addr32[3] = ip->daddr;

        protocol = ip->protocol;
    }
    // Handle IPv6 packets
    else if (eth->h_proto == __bpf_constant_htons(ETH_P_IPV6)) {
        struct ipv6hdr *ip6 = (struct ipv6hdr *)(eth + 1);
        if ((void *)(ip6 + 1) > data_end)
            return XDP_DROP;

        // Copy IPv6 addresses directly
        ip6hdr = *ip6;
        protocol = ip6->nexthdr;
    } else {
        return XDP_PASS;  // Not an IP packet
    }

    // Extract Transport Layer (TCP/UDP) Ports
    void *transport_hdr = (void *)(eth + 1) + sizeof(struct ipv6hdr);
    if (protocol == IPPROTO_TCP) {
        struct tcphdr *tcp = (struct tcphdr *)transport_hdr;
        if ((void *)(tcp + 1) > data_end)
            return XDP_DROP;

        src_port = bpf_ntohs(tcp->source);
        dst_port = bpf_ntohs(tcp->dest);
    } else if (protocol == IPPROTO_UDP) {
        struct udphdr *udp = (struct udphdr *)transport_hdr;
        if ((void *)(udp + 1) > data_end)
            return XDP_DROP;

        src_port = bpf_ntohs(udp->source);
        dst_port = bpf_ntohs(udp->dest);
    }

    // Print extracted information
    bpf_printk("Protocol: %u", protocol);
    bpf_printk("Src IP: %x:%x:%x:%x", ip6hdr.saddr.s6_addr32[0], ip6hdr.saddr.s6_addr32[1], 
                                      ip6hdr.saddr.s6_addr32[2], ip6hdr.saddr.s6_addr32[3]);
    bpf_printk("Dst IP: %x:%x:%x:%x", ip6hdr.daddr.s6_addr32[0], ip6hdr.daddr.s6_addr32[1], 
                                      ip6hdr.daddr.s6_addr32[2], ip6hdr.daddr.s6_addr32[3]);
    bpf_printk("Src Port: %u, Dst Port: %u", src_port, dst_port);

    return XDP_PASS;  // Let the packet continue
}

char _license[] SEC("license") = "GPL";
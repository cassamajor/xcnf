//go:build ignore

#include <linux/in.h>
#include <linux/in6.h>
#include <linux/ip.h>
#include <linux/if_ether.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <linux/bpf.h>

#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

struct perf_trace_event {
    __u64 timestamp;
    __u32 processing_time_ns;
    __u8 type;
};

/* A feature in RFC4291 called IPv4-Mapped IPv6 Address
allows embedding an IPv4 address in an IPv6 address */
struct packet {
    struct in6_addr src_ip;
    struct in6_addr dst_ip;
    // __be16 src_port;
    // __be16 dst_port;
    __u16 src_port;
    __u16 dst_port;
    __u8 protocol;
};

struct {
    __uint(type, BPF_MAP_TYPE_PERF_EVENT_ARRAY);
    __uint(key_size, sizeof(int));
    __uint(value_size, sizeof(struct perf_trace_event));
    __uint(max_entries, 1024);
} output_map SEC(".maps");



SEC("xdp") // Program hook point
int xdp_capture(struct xdp_md *ctx) {
    struct packet pkt = {0};

    void *data_end = (void *)(long)ctx->data_end; // End of packet data
    void *data = (void *)(long)ctx->data; // Start of packet data

    // Step 1: Extract Ethernet header
    struct ethhdr *eth = data;

    if ((void *)(eth + 1) > data_end)
        return XDP_DROP;  // Ensure packet is valid

    // Step 2: Check if it's an IPv4 packet
    if (eth->h_proto != __constant_htons(ETH_P_IP))
        return XDP_PASS;

    // Step 3: Extract IP header
    struct iphdr *ip = (struct iphdr *)(eth + 1);
    if ((void *)(ip + 1) > data_end)
        return XDP_DROP;

    // Place the source and destination IP of our packet into the last index of `in6_addr`
    pkt.src_ip.in6_u.u6_addr32[3] = ip->saddr;
    pkt.dst_ip.in6_u.u6_addr32[3] = ip->daddr;
    pkt.protocol = ip->protocol;  // Protocol (TCP/UDP/ICMP etc.)

    // Pad the 16 bites before IP address with all Fs as per the RFC
    pkt.src_ip.in6_u.u6_addr32[5] = 0xffff;
    pkt.dst_ip.in6_u.u6_addr32[5] = 0xffff;

    // Step 4: Extract transport layer headers if TCP/UDP
    if (pkt.protocol == IPPROTO_TCP) {
        struct tcphdr *tcp = (struct tcphdr *)(ip + 1);
        if ((void *)(tcp + 1) > data_end)
            return XDP_DROP;

        pkt.src_port = __bpf_ntohs(tcp->source);
        pkt.dst_port = __bpf_ntohs(tcp->dest);

        bpf_printk("TCP Packet: Src IP: %u, Dst IP: %u, Src Port: %u, Dst Port: %u", 
                   pkt.src_ip, pkt.dst_ip, pkt.src_port, pkt.dst_port);
    } else if (protocol == IPPROTO_UDP) {
        struct udphdr *udp = (struct udphdr *)(ip + 1);
        if ((void *)(udp + 1) > data_end)
            return XDP_DROP;

        pkt.src_port = __bpf_ntohs(udp->source);
        pkt.dst_port = __bpf_ntohs(udp->dest);

        bpf_printk("UDP Packet: Src IP: %u, Dst IP: %u, Src Port: %u, Dst Port: %u", 
                   pkt.src_ip, pkt.dst_ip, pkt.src_port, pkt.dst_port);
    }

    return XDP_PASS; // Let the packet continue
}

char _license[] SEC("license") = "GPL";
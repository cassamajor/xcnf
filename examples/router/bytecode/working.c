#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <linux/in.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

SEC("xdp")
int xdp_inspect_packet(struct xdp_md *ctx) {
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;

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

    __u32 src_ip = ip->saddr;  // Source IP
    __u32 dst_ip = ip->daddr;  // Destination IP
    __u8 protocol = ip->protocol;  // Protocol (TCP/UDP/ICMP etc.)

    // Step 4: Extract transport layer headers if TCP/UDP
    if (protocol == IPPROTO_TCP) {
        struct tcphdr *tcp = (struct tcphdr *)(ip + 1);
        if ((void *)(tcp + 1) > data_end)
            return XDP_DROP;

        __u16 src_port = __bpf_ntohs(tcp->source);
        __u16 dst_port = __bpf_ntohs(tcp->dest);

        bpf_printk("TCP Packet: Src IP: %u, Dst IP: %u, Src Port: %u, Dst Port: %u", 
                   src_ip, dst_ip, src_port, dst_port);
    } else if (protocol == IPPROTO_UDP) {
        struct udphdr *udp = (struct udphdr *)(ip + 1);
        if ((void *)(udp + 1) > data_end)
            return XDP_DROP;

        __u16 src_port = __bpf_ntohs(udp->source);
        __u16 dst_port = __bpf_ntohs(udp->dest);

        bpf_printk("UDP Packet: Src IP: %u, Dst IP: %u, Src Port: %u, Dst Port: %u", 
                   src_ip, dst_ip, src_port, dst_port);
    }

    return XDP_PASS; // Let the packet continue
}

char _license[] SEC("license") = "GPL";
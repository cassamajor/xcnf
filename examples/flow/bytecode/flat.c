#include <stdint.h>
#include <stdlib.h>

#include <linux/bpf.h>

#include <bpf/bpf_helpers.h>

SEC("tc")
int flat(struct __sk_buff* skb) {
    bpf_printk("Got a Packet!\n");

    return 0;
}

char _license[] SEC("license") = "GPL";
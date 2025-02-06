//go:build ignore

#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

struct perf_trace_event {
    __u64 timestamp;
    __u32 processing_time_ns;
    __u8 type;
};

#define TYPE_ENTER 1
#define TYPE_DROP 2
#define TYPE_PASS 3

struct {
    __uint(type, BPF_MAP_TYPE_PERF_EVENT_ARRAY);
    __uint(key_size, sizeof(int));
    __uint(value_size, sizeof(struct perf_trace_event));
    __uint(max_entries, 1024);
} output_map SEC(".maps");

SEC("xdp")
int xdp_dilih(struct xdp_md *ctx) {
    struct perf_trace_event e = {};

    // Perf event for entering xdp program
    e.timestamp = bpf_ktime_get_ns();
    e.type = TYPE_ENTER;
    e.processing_time_ns = 0;
    bpf_perf_event_output(ctx, &output_map, BPF_F_CURRENT_CPU, &e, sizeof(e));

    // Packet dropping logic
    if (bpf_get_prandom_u32() % 2 == 0) {
        // Perf event for dropping packet
        e.type = TYPE_DROP;
        __u64 ts = bpf_ktime_get_ns();
        e.processing_time_ns = ts - e.timestamp;
        e.timestamp = ts;
        bpf_perf_event_output(ctx, &output_map, BPF_F_CURRENT_CPU, &e, sizeof(e));
        return XDP_DROP;
    }

    // Perf event for passing packet
    e.type = TYPE_PASS;
    __u64 ts = bpf_ktime_get_ns();
    e.processing_time_ns = ts - e.timestamp;
    e.timestamp = ts;
    bpf_perf_event_output(ctx, &output_map, BPF_F_CURRENT_CPU, &e, sizeof(e));

    return XDP_PASS;
}

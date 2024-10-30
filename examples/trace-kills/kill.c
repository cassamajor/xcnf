#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

char LICENSE[] SEC("license") = "GPL";

struct syscalls_enter_kill_args {
    long long pad;

    long syscall_nr;
    long pid;
    long sig;
};

SEC("tracepoint/syscalls/sys_enter_kill")
int kill_example(struct syscalls_enter_kill_args *ctx) {
    if(ctx->sig != 9) return 0;

    char fmt[] = "PID %u is being killed!\n";
    bpf_trace_printk(fmt, sizeof(fmt), ctx->pid, sizeof(ctx->pid));

    return 0;
}
In this example, both the user-space and kernel-space programs are written in C. 

Compile the eBPF program:
```shell
clang -target bpf -S -D __BPF_TRACING__ -Wall -Werror -O2 -emit-llvm -c -g kill.c
llc -march=bpf -filetype=obj -o kill.o kill.ll
```

Build the eBPF application:
```shell
gcc -o ebpf loader.c -lbpf -lelf
```

Run the eBPF application:
```shell
sudo ./ebpf &
```

Create a new `bash` process in the background, kill the process, then observe the logged output:
```shell
bash &
pid2kill=$!
kill -n 9 $pid2kill
sudo cat /sys/kernel/debug/tracing/trace_pipe
```

Example output:
```
bash-8882    [001] ....1 144587.569164: bpf_trace_printk: PID 7743 is being killed!
```
In this example, both the user-space and kernel-space programs are written in C. 

Commands to compile the code:
```shell
clang -target bpf -S -D __BPF_TRACING__ -Wall -Werror -O2 -emit-llvm -c -g kill.c
llc -march=bpf -filetype=obj -o kill.o kill.ll
gcc -o ebpf loader.c -lbpf -lelf
```

See the output:
```shell
sudo ./ebpf &
bash & # Make note of the PID
kill -n 9 <PID>
sudo cat /sys/kernel/debug/tracing/trace_pipe
```

Example output:
```
bash-8882    [001] ....1 144587.569164: bpf_trace_printk: PID 7743 is being killed!
```
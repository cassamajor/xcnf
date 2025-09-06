> Although I've made a few optimizations, this code is largely adapted from https://github.com/pouriyajamshidi/flat

Compile the eBPF program:
```shell
go generate ./bytecode
```

Build the eBPF application:
```shell
go build -o flow
```

Run the eBPF application:
```shell
sudo ./flow
```

Test the eBPF program and application:
```shell
sudo -E go test .
```

Display the kernel trace logs in a new terminal:
```shell
sudo tc exec bpf dbg
```

---

# Without userspace application

Compile the eBPF program:
```shell
clang -target bpf -S -D __BPF_TRACING__ -Wall -Werror -O2 -emit-llvm -c -g flat.c
llc -march=bpf -filetype=obj -o flat.o flat.ll
```

Add queueing discipline (qdisc):
```shell
sudo tc qdisc add dev lo clsact
```

Apply a BPF filter for ingress and egress traffic on the loopback interface
```shell
sudo tc filter add dev lo ingress bpf direct-action obj flat.o sec tc
sudo tc filter add dev lo egress bpf direct-action obj flat.o sec tc
```

Generate traffic:
```shell
ping 127.0.0.1
```

Display the kernel trace logs in a new terminal:
```shell
sudo tc exec bpf dbg
```

Remove the qdisc and its filters:
```shell
sudo tc qdisc del dev lo clsact
```

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
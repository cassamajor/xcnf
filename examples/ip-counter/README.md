Compile the eBPF program:
```shell
go generate ./bytecode
```

Build the eBPF application:
```shell
go build -o ip-counter
```

Run the eBPF application:
```shell
sudo ./ip-counter
```
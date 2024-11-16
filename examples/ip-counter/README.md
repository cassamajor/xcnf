Compile the eBPF program:
```
go generate ./bytecode
```

Build the eBPF application:
```
go build
```

Run the eBPF application:
```
sudo ./ip-counter
```
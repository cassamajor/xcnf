Compile the eBPF program:
```
go generate ./bytecode
```

Build the eBPF application:
```
go build -o ip-counter
```

Run the eBPF application:
```
sudo ./ip-counter
```1
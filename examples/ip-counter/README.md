Compile the eBPF program:
```
go generate ./bytecode
```

Build the eBPF application:
```
GOOS=linux GOARCH=amd64 go build
```

Run the eBPF application:
```
sudo ./ip-counter
```1
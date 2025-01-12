Compile the eBPF program:
```
go generate ./bytecode
```

Build the eBPF application:
```
go build -o flow
```

Run the eBPF application:
```
sudo ./flow
```

Test the eBPF program and application:

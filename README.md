# Setup eBPF Development Environment
1. Download [OrbStack](https://orbstack.dev/download)
2. Create an Ubuntu Virtual Machine named `ebpf`, and provide [`config/cloud-init.yaml`](/config/cloud-init.yaml) to automatically install dependencies
    ```shell
    orb create ubuntu ebpf -c config/cloud-init.yaml
    ```
3. Access the Linux Virtual Machine
    ```shell
    orb
    ```
4. For each example in the [examples](./examples/) directory, instructions on how to compile the eBPF program and run the eBPF application are provided in the README.
5. Teardown the Linux Virtual Machine
    ```shell
    orb delete ebpf
    ```

## Repository: Init
```
go mod init github.com/cassamajor/xcnf
go mod tidy
```

## Repository: Structure
For each example in the [examples](./examples/) directory:
- The eBPF program, compiled bytecode, and required headers are located in the `bytecode` directory.
- The eBPF application that runs in user space is located in the parent directory.
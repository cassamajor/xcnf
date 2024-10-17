# Setup eBPF Developer Environment
1. Downloaded [OrbStack](https://orbstack.dev/download)
2. Create an Ubuntu Virtual Machine ([`config/cloud-init.yaml`](./config/cloud-init.yaml) is specified to automatically install dependencies)
    ```shell
    orb create ubuntu ebpf -c config/cloud-init.yaml
    ```
3. Access the Linux Virtual Machine
    ```shell
    orb
    ```
4. Teardown the Linux Virtual Machine
    ```shell
    orb delete ebpf
    ```

## Configure Repository
```shell
go mod init github.com/cassamajor/xcnf
go mod tidy
go generate ./kernel
sudo go run main
```

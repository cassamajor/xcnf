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
4. Compile the eBPF bytecode and run the eBPF loader program
   ```shell
   go generate ./kernel
   sudo go run main.go eth0
   ```
5. Teardown the Linux Virtual Machine
    ```shell
    orb delete ebpf
    ```

## Repository Structure
- The eBPF program and compiled bytecode are in the [kernel](kernel) directory
- Required headers exist in the [kernel/headers](/kernel/headers) directory
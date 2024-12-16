
# Development Workflow for eBPF Programs written in Go

Each example contains a Dockerfile that is capable of compiling the eBPF program, building the eBPF application, and executing the resulting binary. These are the manual steps to achieve the same result.

## Set environment variables
```shell
export PROGRAM=ipcounter
export USERNAME=cassamajor
export IMAGE_NAME=ebpf-ip-counter
export CR_PAT=YOUR_TOKEN
```

## Initialize the module
```shell
go mod init github.com/cassamajor/xcnf/examples/$PROGRAM
go get github.com/cilium/ebpf/cmd/bpf2go
go mod tidy
```

## Compile the eBPF program
```shell
go generate ./bytecode
```

## Build the eBPF application
```shell
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build
```

## Authenticate to the GitHub Container Registry
```shell
echo $CR_PAT | docker login ghcr.io -u $USERNAME --password-stdin
```

## Create a new builder using the `docker-container` driver for multi-arch support
```shell
docker buildx create --name multi-arch-ebpf --driver docker-container --use --bootstrap
```

## Build and push the multi-arch image
```shell
docker buildx build -t ghcr.io/$USERNAME/$IMAGE_NAME:v1 --push --platform linux/amd64,linux/arm64 .
```

## Test the image
```shell
docker run --privileged --pull=always -it ghcr.io/$USERNAME/$IMAGE_NAME:v1

# Output:
# 2024/12/12 20:57:29 Counting incoming packets on eth0..
# 2024/12/12 20:57:30 Received 2 packets
# 2024/12/12 20:57:31 Received 4 packets
# ...
```

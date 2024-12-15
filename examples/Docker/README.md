# Development Workflow for eBPF Programs written in Go

## Initialize the module
```shell
go mod init github.com/cassamajor/xcnf
go mod tidy
go get github.com/cilium/ebpf/cmd/bpf2go
```

## Compile the eBPF program
This is done in the Dockerfile
```Dockerfile
RUN go generate ./bytecode
```

## Build the eBPF application
This is done in the Dockerfile
```Dockerfile
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o ./ip-counter
```

## Build the multi-arch image and push the image
```shell
docker buildx create --name multi-arch-ebpf --driver docker-container --use --bootstrap

docker buildx build -t ghcr.io/cassamajor/docker-example:v1 --platform linux/amd64,linux/arm64 --build-context dirpath=../ip-counter/ .
```

## Test the image
```shell
docker run --privileged --pull=always -it ghcr.io/cassamajor/docker-example:v1
```
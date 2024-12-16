# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM ubuntu:latest AS build

# Install tools required to compile the Restricted C eBPF program
RUN apt-get update && apt-get install -y clang llvm libbpf-dev golang

RUN ln -sf /usr/include/asm-generic/ /usr/include/asm

# Copy eBPF program and application into WORKDIR
WORKDIR /src
COPY bytecode/gen.go bytecode/counter.c ./bytecode/
COPY go.mod go.sum main.go ./

# Download dependencies
RUN go mod download

# Compile the eBPF program into bytecode
RUN go generate ./bytecode

# Build the Go binary for multiple architectures
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o ./ip-counter

# Copy the eBPF program and compiled bytecode from the build stage
FROM scratch AS final
WORKDIR /app
COPY --from=build /src/bytecode/* ./bytecode/
COPY --from=build /src/ip-counter ./

# Execute the eBPF program when the container starts
CMD [ "./ip-counter" ]

LABEL org.opencontainers.image.source=https://github.com/cassamajor/xcnf
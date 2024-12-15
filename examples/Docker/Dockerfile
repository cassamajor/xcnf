# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM ubuntu AS build

# Install tools required to compile the Restricted C eBPF program
RUN apt-get update && apt-get install -y clang llvm libbpf-dev golang

RUN ln -sf /usr/include/asm-generic/ /usr/include/asm

# Copy the Go mod and Go sum files into WORKDIR
WORKDIR /app
COPY --from=dirpath go.mod ./
COPY --from=dirpath go.sum ./

# Download dependencies
RUN go mod download

# Copy eBPF program and application into WORKDIR
COPY --from=dirpath bytecode/gen.go bytecode/counter.c ./bytecode/
COPY --from=dirpath main.go ./

# Compile the eBPF program into bytecode
RUN go generate ./bytecode

# Build the Go binary for multiple architectures
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o ./ip-counter

# Copy the eBPF program and compiled bytecode from the build stage
FROM scratch AS final
WORKDIR /app
COPY --from=build /app/bytecode/* ./bytecode/
COPY --from=build /app/ip-counter ./

# Execute the eBPF program when the container starts
CMD [ "./ip-counter" ]
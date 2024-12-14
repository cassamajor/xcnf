FROM ubuntu

WORKDIR /app

RUN apt-get update && apt-get install -y clang llvm libbpf-dev golang

RUN ln -sf /usr/include/asm-generic/ /usr/include/asm

COPY --from=dirpath go.mod ./
COPY --from=dirpath go.sum ./

RUN go mod download

COPY --from=dirpath bytecode/gen.go bytecode/counter.c ./bytecode/
COPY --from=dirpath main.go ./

# compile application
RUN go generate ./bytecode
RUN go build -o /ip-counter
  
# execute when the container starts
CMD [ "/ip-counter" ]
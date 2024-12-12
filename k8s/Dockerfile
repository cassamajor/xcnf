FROM ubuntu:latest

WORKDIR /app

COPY --from=dirpath * ./

CMD ["./ip-counter"]

LABEL org.opencontainers.image.source=https://github.com/cassamajor/xcnf
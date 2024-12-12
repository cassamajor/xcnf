1. Authenticate with GitHub Container Registry
```shell
docker login ghcr.io -u cassamajor -p $(op read op://development/GitHub/credentials/personal_token)
# export CR_PAT=YOUR_TOKEN
# echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

2. Build the image
```shell
docker build -t ghcr.io/cassamajor/ebpf-ip-counter:v1 --build-context dirpath=../examples/ip-counter/ .
# docker run -it ghcr.io/cassamajor/ebpf-ip-counter:v1
```

3. Push the image
```shell
docker push ghcr.io/cassamajor/ebpf-ip-counter:v1
```

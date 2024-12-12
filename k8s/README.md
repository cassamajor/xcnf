1. Authenticate to GitHub Container Registry
```shell
export CR_PAT=YOUR_TOKEN
echo $CR_PAT | docker login ghcr.io -u cassamajor --password-stdin
```

2. Build the image
```shell
docker build -t ghcr.io/cassamajor/ebpf-ip-counter:v1 --build-context dirpath=../examples/ip-counter/ .
```

3. Validate the image functions as expected:
```shell
docker run --privileged -it ghcr.io/cassamajor/ebpf-ip-counter:v1

# Output:
# 2024/12/12 20:57:29 Counting incoming packets on eth0..
# 2024/12/12 20:57:30 Received 2 packets
# 2024/12/12 20:57:31 Received 4 packets
# ...
```

3. Push the image
```shell
docker push ghcr.io/cassamajor/ebpf-ip-counter:v1
```

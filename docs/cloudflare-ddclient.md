# Cloudflare ddclient

How to add Cloudflare ddns to ddclient config

## Steps

```shell
apt update
apt install -y ddclient
```

Update ddclient
```shell
# /etc/ddclient.conf
protocol=cloudflare \
use=web, web=https://api.ipify.org/ \
login=EMAIL \
password='PASSWORD' \
zone=HOST \
HOST
```

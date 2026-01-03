# Simple website hosting via docker

First install docker

```shell
apt update && apt install curl
curl -fsSL https://get.docker.com | sudo sh
```

Generate mariadb creds
```shell
echo "MARIADB_ROOT_PASSWORD=$(openssl rand -base64 36 | tr -d '\n')" >> .env
echo "MARIADB_PASSWORD=$(openssl rand -base64 60 | tr -d '\n')" >> .env
```

Obtain "Origin Certificate" from Cloudflare dashboard

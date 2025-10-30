# Create K3S Cluster

## Load Balancer

LXC (unprivileged) 1CPU 512RAM
- Static IP (10.10.0.1)
- Ubuntu base image

run
```shell
apt update
apt install nginx -y
```

/etc/nginx/nginx.conf
```
load_module /usr/lib/nginx/modules/ngx_stream_module.so;  

events {}

stream {
  upstream k3s_servers {
    server 10.10.1.10:6443;
    server 10.10.1.11:6443;
    server 10.10.1.12:6443;
  }

  server {
    listen 6443;
    proxy_pass k3s_servers;
  }

  upstream http_servers {
    server 10.10.1.10:80;
    server 10.10.1.11:80;
    server 10.10.1.12:80;
  }

  server {
    listen 80;
    proxy_pass http_servers;
  }

  upstream https_servers {
    server 10.10.1.10:443;
    server 10.10.1.11:443;
    server 10.10.1.12:443;
  }

  server {
    listen 443;
    proxy_pass https_servers;
  }
}
```

```
systemctl restart nginx
```

## K3S Cluster

- LXC image (privileged)
- DO not start

add to /etc/pve/lxc/1xx.conf

```
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop:
lxc.mount.auto: "proc:rw sys:rw"
```

Start image and run
```
apt update && apt upgrade -y && apt install curl nfs-common-y
echo '#!/bin/sh -e
ln -s /dev/console /dev/kmsg
mount - make-rshared /' > /etc/rc.local
chmod +x /etc/rc.local
reboot
```

K3S config
```
curl -sfL https://get.k3s.io | sh -s - server \
  --token=TOKEN \
  --tls-san=10.10.0.1 \
  --datastore-endpoint="mysql://kubernetes:PASSWORD@tcp(10.10.0.103:3306)/kubernetes" \
  --cluster-cidr=172.16.0.0/16 \
  --disable=traefik
```

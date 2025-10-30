# Setting up Nginx Load Balancer

```shell
apt update
apt install -y nginx
```

nginx.conf
```
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
  worker_connections 768;
}

http {
  upstream node_servers {
    server 10.10.1.10;
    server 10.10.1.11;
    server 10.10.1.12;
  }

  server {
    listen 80;
    listen [::]:80;

    server_name _;

    proxy_http_version 1.1;
    proxy_set_header HOST $host;
    proxy_set_header X-Forwarded_Host $host;
    proxy_set_header X-Forwarded_For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    location / {
      proxy_pass http://node_servers;
    }
  }
}

include /etc/nginx/passthrough.conf;
```

passthrough.conf
```
stream {
  upstream https_servers {
    server 10.10.1.10:443 max_fails=3 fail_timeout=30s;
    server 10.10.1.11:443 max_fails=3 fail_timeout=30s;
    server 10.10.1.12:443 max_fails=3 fail_timeout=30s;
  }

  server {
    listen 443;

    proxy_pass https_servers;
    proxy_next_upstream on;
    ssl_preread on;
  }
}
```

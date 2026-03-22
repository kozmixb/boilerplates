# Minio cluster

```yaml
services:
  minio:
    container_name: minio
    image: minio/minio:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.web.rule=Host(`minio.example.com`)"
      - "traefik.http.routers.web.entrypoints=websecure,web"
      - "traefik.http.routers.web.tls.certresolver=default"
      - "traefik.http.routers.web.service=web"
      - "traefik.http.services.web.loadbalancer.server.port=9001"
      - "traefik.http.routers.api.rule=Host(`minio-api.example.com`)"
      - "traefik.http.routers.api.entrypoints=websecure,web"
      - "traefik.http.routers.api.tls.certresolver=default"
      - "traefik.http.routers.api.service=api"
      - "traefik.http.services.api.loadbalancer.server.port=9000"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: "minio"
      MINIO_SERVER_URL: https://minio-api.example.com
      MINIO_BROWSER_REDIRECT_URL: https://minio.example.com
      MINIO_VOLUMES: "http://minio1:9000/data http://minio2:9000/data http://minio3:9000/data"
    volumes:
      - ./data:/data
      - ./config:/root/.minio
    ports:
      - "9000:9000"
      - "9001:9001"
    networks:
      - traefik
    restart: unless-stopped
    command: ["server", "/data", "--console-address", ":9001"]

networks:
  traefik:
```

Enter to container

```bash
docker compose exec -it minio bash

mc alias set local http://localhost:9000 admin YourStrongPassword123
```

## Create bucket

```bash
mc mb local/${BUCKET_NAME} --ignore-existing
```

## Create User

```bash
mc admin user add local ${USER} ${PASS}
```

Connect bucket and user with policy

```bash
cat <<POLICY > /tmp/policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": [
        "arn:aws:s3:::terraform",
        "arn:aws:s3:::terraform/*"
      ]
    }
  ]
}
POLICY

mc admin policy create local terraform-policy /tmp/policy.json
mc admin policy attach local terraform-policy --user ${USER}
```

# Setup Jellyfin on Proxmox

New lxc container with privileged

edit `/etc/pve/lxc/xxx.conf` for your newly build container
```
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.mount.entry: /dev/dri/card0 dev/dri/card0 none bind,optional,create=file
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
```

start the lxc container

Run the following as `root`
```shell
apt install curl
curl -fsSL https://get.docker.com | sh
useradd -s /bin/bash -m ec2-user
usermod -aG docker ec2-user
su ec2-user
```

run the new bit of code as user
```shell
cd
mkdir /home/ec2-user/config
mkdir /home/ec2-user/cache
```

create file `/home/ec2-user/docker-compose.yml`
```
services:
  jellyfin:
    image: jellyfin/jellyfin:10.11.1
    container_name: jellyfin
    user: 1000:1000
    group_add:
      - '993'
    ports:
      - 8096:8096/tcp
      - 7359:7359/udp
    volumes:
      - ./config:/config
      - ./cache:/cache
      - type: bind
        source: ./media
        target: /media
        read_only: true
    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128
      - /dev/dri/card0:/dev/dri/card0
    restart: 'unless-stopped'
    environment:
      - JELLYFIN_PublishedServerUrl=https://jellyfin.service
```

then start jellyfin
```shell
docker compose up -d
```

## Verify video encoding
```shell
docker exec -it jellyfin /usr/lib/jellyfin-ffmpeg/vainfo
docker exec -it jellyfin /usr/lib/jellyfin-ffmpeg/ffmpeg -v verbose -init_hw_device vaapi=va -init_hw_device opencl@va
```

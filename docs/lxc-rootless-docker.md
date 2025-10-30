# Proxmox LXC Rootless docker

Unrprivileged LXC container with debian 13 (tixie)

## Proxmox nodes

Have to update the following file on all proxmox nodes inside the cluster so if HA is enabled this container will be able to run on all

Locations `/etc/subgid /etc/subuid`
```
root:100000:262144
```

## LXC

Create the unprivileged LXC, but dont start it yet and update the

`/etc/pve/lxc/{LXC_ID}.conf`
```shell
features: fuse=1,keyctl=1,nesting=1
lxc.mount.entry: /dev/fuse dev/fuse none bind,create=file 0 0
lxc.cgroup.devices.allow: c 10:229 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.idmap: u 0 100000 262144
lxc.idmap: g 0 100000 262144
```

Start the container run the following commands as `root`
```shell
apt update
apt install -y \
  fuse-overlayfs \
  uidmap \
  curl \
  iptables \
  dbus-user-session
useradd -s /bin/bash -m ec2-user
loginctl enable-linger ec2-user
su ec2-user
```

Following commands as `ec2-user`
```shell
mkdir -p /home/ec2-user/.config/docker/
echo '{ "storage-driver": "fuse-overlayfs" }' > /home/ec2-user/.config/docker/daemon.json
echo 'export XDG_RUNTIME_DIR=/run/user/$(id -u)' >> /home/ec2-user/.bashrc
echo 'export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus' >> /home/ec2-user/.bashrc
exit
reboot
```

And reboot so the user systemctl session will start which is a requirement for rootless docker

Log back in as `root` and change user to `ec2-user`
```shell
su ec2-user
curl -fsSL https://get.docker.com/rootless | sh
echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> /home/ec2-user/.bashrc
echo 'export PATH=/home/ec2-user/bin:$PATH' >> /home/ec2-user/.bashrc
DOCKER_COMPOSE_DIR="$HOME/.docker/cli-plugins"
COMPOSE_VERSION="v2.39.4"
ARCH=$(uname -m)
mkdir -p "$DOCKER_COMPOSE_DIR"
curl -SL "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-linux-$ARCH" -o "$DOCKER_COMPOSE_DIR/docker-compose"
chmod +x "$DOCKER_COMPOSE_DIR/docker-compose"
```

Now you are ready to start any containers as a non-root user in an unprivileged lxc container

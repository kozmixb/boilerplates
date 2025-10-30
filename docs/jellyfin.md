# Setup Jellyfin on Proxmox

/etc/subgui
```
root:44:1
root:104:1
```

/etc/fstab
```
10.10.0.3:/volume1/Media    /mnt/media  nfs4  ro,relatime,user,vers=4.0,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,local_lock=none  0  0
10.10.0.3:/volume1/proxmox    /mnt/proxmox  nfs4  rw,relatime,user,vers=4.0,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,local_lock=none  0  0
```


/etc/pve/lxc/100.conf
```
GNU nano 7.2                              /etc/pve/lxc/100.conf                                        
arch: amd64
cores: 6
features: fuse=1,keyctl=1,nesting=1
hostname: jellyfin
memory: 2048
mp0: /mnt/media,mp=/mnt/media
mp1: nfs-shared:100/vm-100-disk-0.raw,mp=/mnt/jellyfin,backup=1,size=8G
net0: name=eth0,bridge=vmbr0,firewall=1,gw=10.10.0.254,hwaddr=BC:24:11:27:7E:5A,ip=10.10.0.100/24,type=v>
onboot: 0
ostype: ubuntu
rootfs: local-zfs:subvol-100-disk-0,size=40G
swap: 0
tags: public
unprivileged: 1
unused0: local-zfs:subvol-100-disk-1
lxc.apparmor.profile: lxc-container-default-with-nfs
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.mount.entry: /dev/dri/card0 dev/dri/card0 none bind,optional,create=file
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 non bind,optional,create=file
lxc.idmap: u 0 100000 65536
lxc.idmap: g 0 100000 44
lxc.idmap: g 44 44 1
lxc.idmap: g 45 100045 63
lxc.idmap: g 108 104 1
lxc.idmap: g 109 100109 65427
```

Run inside lxc
```
adduser $(id -u -n) video
adduser $(id -u -n) render
```

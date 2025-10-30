# Macvlan

When setting up macvlan for docker so each container can get an external IP we need to make sure those containers can communicate with each other

We want to achieve the following in macvlan, however this is only a temporary solution as config will disappear after a reboot.

```shell
ip link add macvlan link eth0 type macvlan mode bridge
ip addr add {GATEWAY_IP} dev macvlan
ip link set macvlan up
ip route add 172.16.31.11 dev macvlan
ip route add 172.16.31.52 dev macvlan
ip route add 172.16.31.53 dev macvlan
```
# Permanent solution

/etc/networkd-dispatcher/routable.d/10-macvlan-interfaces.sh
```shell
#! /bin/bash

ip link add macvlan link eth0 type macvlan mode bridge
```

/etc/netplan/macvlan.yaml
```yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        macvlan0:
            addresses:
                - 172.16.31.5/32
            routes:
                - to: 172.16.31.11/32
                  via: 172.16.31.5
                  metric: 100
                - to: 172.16.31.52/32
                  via: 172.16.31.5
                  metric: 100
                - to: 172.16.31.53/32
                  via: 172.16.31.5
                  metric: 100
```

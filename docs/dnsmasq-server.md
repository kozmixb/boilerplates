# DNSmasq server

```bash
apt update && apt update && apt install dnsmasq net-tools -y
sysctl net.ipv4.ip_unprivileged_port_start
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak

# After config updated and hosts placed
nano /etc/dnsmasq.conf
systemctl restart dnsmasq.service
```

Update main config

/etc/dnsmasq.conf

```
# Listen on these addresses
listen-address=127.0.0.1,10.101.1.102

# Don't forward plain names (without a dot)
domain-needed
# Don't forward addresses in non-routed address spaces
bogus-priv
# It tells dnsmasq NOT to restrict to the local subnet
#bind-dynamic
# Ensure it doesn't try to use the host's nameservers
# which can cause a loop in LXC
#no-resolv


# Upstream DNS servers (Cloudflare/Google)
server=1.1.1.1
server=8.8.8.8

# Local domain name
domain=example.lan
local=/example.lan/

# Cache size (standard is 150)
cache-size=1000
```

Update /etc/hosts using the following format

```
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

10.101.0.1      example.lan
10.101.0.2      example1.lan
```

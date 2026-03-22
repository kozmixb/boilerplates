# Install nut on linux

First need to install the client and server

```bash
apt update && apt install -y nut-server nut-client nut-snmp
```

Then edit the following files

nano /etc/nut/ups.conf

```bash
[apc]
driver = snmp-ups
port = 10.100.0.10
community = office
snmp_version = v1
desc = "APC SMT3000 Office"
```

nano /etc/nut/nut.conf

```bash
MODE=standalone
```

nano /etc/nut/upsd.conf

```bash
LISTEN 127.0.0.1 3493
LISTEN ::1 3493
```

nano /etc/nut/upsd.users

```bash
[monuser]
password = mypassword
upsmon master
```

nano /etc/nut/upsmon.conf

```bash
MONITOR apc@localhost 1 monuser mypassword master
SHUTDOWNCMD "/sbin/shutdown -h +0"
FINALDELAY 5
```

## Test

```bash
upsc apc@localhost
```

---
layout: post
title: "Raspberry Pi 與 SIM7000 PPP 連線設定"
description: "於 Raspberry Pi 中利用 PPP 協定連接 SIM7000，以中華電信 Cat-M1 為例"
category: articles
tags: [cat-m1, CHT, Raspberry Pi, iot, ppp, sim7000]
comments: false
---

![SIM7000C Module](/files/rasp/SIM7000C.jpg)

# Devices & Software

## Hardwares

- Raspberry Pi Zero W
- SIM7000C Module with USB port
- USB cables
- A SIM card

## Softwares

- Raspberry Pi OS (Other Linux distro works just fine)
- ppp
- Serial Console (optional)

## Hardware Connection

Connect the module to Raspberry Pi with USB cable.

```
+------------------+
|                  |   USB   +----------+
|   Raspberry Pi   | <-------+ SIM7000C |
|                  |         +----------+
+------------------+
```

# Linux Setting

## Package Installation

Some linux distro may already have `ppp` package installed. But in Raspberry Pi OS you have to download it using package manager (`apt` in the case).

```shell
$ sudo apt install ppp
```

If you want to manually configure the module, you probably need a serial console like `minicom` or `screen`. Both of these softwares are available on apt.

```shell
$ sudo apt install minicom # or screen
```

## Connect to the module

When you plug-in the module. System will automatically appears 5 USB devices in the `/dev` folder.

```shell
$ ls -l /dev | grep USB
crw-rw---- 1 root dialout 188,   0 Aug  4 13:32 ttyUSB0
crw-rw---- 1 root dialout 188,   1 Aug  4  2022 ttyUSB1
crw-rw---- 1 root dialout 188,   2 Aug  4 13:32 ttyUSB2
crw-rw---- 1 root dialout 188,   3 Aug  4 13:32 ttyUSB3
crw-rw---- 1 root dialout 188,   4 Aug  4  2022 ttyUSB4
```

In [this document (SIM7000 Series Linux User Guide_V2.00) from SIMCOM](https://github.com/botletics/SIM7000-LTE-Shield/blob/master/SIM7000%20Documentation/Technical%20Documents/SIM7000%20Series%20Linux%20User%20Guide_V2.00.pdf) we can find a table about the **SIM7000 USB Description**. Each USB device provides different functions describe by following table.

| **USB Device** | **Interface** |
| -------------- | ------------- |
| /dev/ttyUSB0   | Diagnostic    |
| /dev/ttyUSB1   | GPS NMEA      |
| /dev/ttyUSB2   | AT            |
| /dev/ttyUSB3   | Modem         |
| /dev/ttyUSB4   | USB Audio     |

## PPP Configuration

When we want to establish a ppp connection. We need to create 2 config files, the chatscript and the peer provider's config.

`/etc/ppp` directory's structure can observed using `tree` command, it contants interfaces and provider's configs.

```shell
$ tree /etc/ppp
/etc/ppp
├── chap-secrets
├── ip-down
├── ip-down.d
│   ├── 0000usepeerdns
│   └── 000resolvconf
├── ip-pre-up
├── ip-pre-up.d
├── ip-up
├── ip-up.d
│   ├── 0000usepeerdns
│   └── 000resolvconf
├── ipv6-down
├── ipv6-down.d
├── ipv6-up
├── ipv6-up.d
├── options
├── pap-secrets
└── peers
    └── provider

6 directories, 13 files
```

### Chatscript

First, create a chatscript that execute the AT commands on SIM7000 module. We can copy the template from `/etc/chatscripts/gprs` to `/etc/ppp/sim7000`. Open copied file and change the APN to `internet.iot` (The CHT's APN).

```shell
$ ls -l /etc/chatscripts/
total 12
-rw-r--r-- 1 root root 950 Jan  7  2021 gprs
-rw-r--r-- 1 root root 653 Jan  7  2021 pap
-rw-r----- 1 root dip  656 Aug  5 16:25 provider


$ sudo cp /etc/chatscripts/gprs /etc/ppp/sim7000
$ sudo vim /etc/ppp/sim7000
# At line 34 change \T into the APN that ISP provieds.
# OK        AT+CGDCONT=1,"IP","\T","",0,0
# OK        AT+CGDCONT=1,"IP","internet.iot","",0,0
```

### Peer Provider Config

In `/etc/ppp/peers/` have a `provider` file. Copy it and rename into anything you want (e.g. sim7000) in the same folder. Open the file and do the following three modifications.

```shell
$ sudo cp /etc/ppp/peers/provider /etc/ppp/peers/sim7000
$ sudo vim /etc/ppp/peers/sim7000
```

#### 1. Replace the chatscript's path

```
 12 # MUST CHANGE: replace ******** with the phone number of your provider.
 13 # The /etc/chatscripts/pap chat script may be modified to change the
 14 # modem initialization string.
 15 connect "/usr/sbin/chat -v -f /etc/ppp/sim7000"
```

#### 2. Change the serial console port

In USB devices section. We can see that the modem's port located in `/dev/ttyUSB3`.

```
 17 # Serial device to which the modem is connected.
 18 /dev/ttyUSB3
```

#### 3. Add few options

```
 23 debug
 24 nocrtscts
 25 nodetach
 26 ipcp-accept-local
 27 ipcp-accept-remote
```

## Establish The Connection

Use `pppd` to call the provider's config  (`sim7000`).

```shell
$ sudo pppd call sim7000
Script /usr/sbin/chat -v -f /etc/ppp/sim7000 finished (pid 8470), status = 0x0
Serial connection established.
using channel 1
Using interface ppp0
Connect: ppp0 <--> /dev/ttyUSB3
sent [LCP ConfReq id=0x1 <asyncmap 0x0> <magic 0xc7630ae8> <pcomp> <accomp>]
rcvd [LCP ConfReq id=0x0 <asyncmap 0x0> <auth chap MD5> <magic 0xae79c4ba> <pcomp> <accomp>]
sent [LCP ConfNak id=0x0 <auth pap>]
rcvd [LCP ConfAck id=0x1 <asyncmap 0x0> <magic 0xc7630ae8> <pcomp> <accomp>]
rcvd [LCP ConfReq id=0x1 <asyncmap 0x0> <auth pap> <magic 0xae79c4ba> <pcomp> <accomp>]
sent [LCP ConfAck id=0x1 <asyncmap 0x0> <auth pap> <magic 0xae79c4ba> <pcomp> <accomp>]
sent [LCP EchoReq id=0x0 magic=0xc7630ae8]
sent [PAP AuthReq id=0x1 user="myusername@realm" password=<hidden>]
rcvd [LCP DiscReq id=0x2 magic=0xae79c4ba]
rcvd [LCP EchoRep id=0x0 magic=0xae79c4ba c7 63 0a e8]
rcvd [PAP AuthAck id=0x1 ""]
PAP authentication succeeded
sent [CCP ConfReq id=0x1 <deflate 15> <deflate(old#) 15> <bsd v1 15>]
sent [IPCP ConfReq id=0x1 <compress VJ 0f 01> <addr 0.0.0.0> <ms-dns1 0.0.0.0> <ms-dns2 0.0.0.0>]
sent [IPV6CP ConfReq id=0x1 <addr fe80::ed80:bb63:1b64:4447>]
rcvd [LCP ProtRej id=0x3 80 fd 01 01 00 0f 1a 04 78 00 18 04 78 00 15 03 2f]
Protocol-Reject for 'Compression Control Protocol' (0x80fd) received
Modem hangup
Connection terminated.
```

If no error shows up. We can use `ip a` command to verify the connection and check the ip address.

```shell
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
# ...
12: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 3
    link/ppp
    inet 10.174.46.45 peer 10.64.64.64/32 scope global ppp0
       valid_lft forever preferred_lft forever
```

But how can we actually know whether the IP can communicate with the public network? By simply use `ping` command with `-I` argument with the interface name `ppp0`.

```shell
$ ping -I ppp0 8.8.8.8 -c 4
PING 8.8.8.8 (8.8.8.8) from 10.174.46.45 ppp0: 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=187 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=46.9 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=113 time=88.0 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=113 time=307 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 46.946/157.260/307.272/100.437 ms
```

Use `ip` command to set the default route to `ppp0` interface. 

```shell
$ sudo ip route add default dev ppp0
```

Verify the routing path using `traceroute` command.

```shell
$ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  10.156.65.128 (10.156.65.128)  318.093 ms  531.195 ms  530.528 ms
 2  10.156.65.1 (10.156.65.1)  440.673 ms 10.156.65.5 (10.156.65.5)  415.479 ms 10.156.65.1 (10.156.65.1)  439.359 ms
 3  * * *
 4  10.156.67.66 (10.156.67.66)  447.782 ms 10.156.67.65 (10.156.67.65)  481.002 ms  480.337 ms
 5  tpdb-3311.hinet.net (210.65.126.94)  479.690 ms tpdb-3312.hinet.net (210.65.126.98)  479.039 ms  488.838 ms
 6  tpdt-3032.hinet.net (220.128.4.190)  497.950 ms  70.715 ms tpdt-3032.hinet.net (220.128.2.250)  69.541 ms
 7  tylc-3032.hinet.net (220.128.9.33)  78.521 ms * *
 8  pcpd-3212.hinet.net (220.128.13.189)  120.847 ms 220-128-13-129.hinet-ip.hinet.net (220.128.13.129)  87.522 ms pcpd-4102.hinet.net (220.128.13.109)  120.041 ms
 9  72.14.202.162 (72.14.202.162)  119.585 ms 72.14.221.186 (72.14.221.186)  119.698 ms 142.250.171.152 (142.250.171.152)  140.647 ms
10  * * *
11  dns.google (8.8.8.8)  129.792 ms  87.433 ms  97.758 ms
```

## Systemd

Now we want the connection automatically start when system startup. We can create a system daemon (`/etc/systemd/system/sim7000.service`) that dialing-up and log the debug information into the log file. 

```yaml
[Unit]
Description=PPP SIM7000C dialing

[Service]
ExecStart=/usr/sbin/pppd call sim7000
KillMode=process
Restart=on-failure
Type=simple

[Install]
WantedBy=multi-user.target
Alias=sim7000.service
```

Reload the daemon and start it.

 ```shell
 $ sudo systemctl daemon-reload
 $ sudo systemctl enable --now sim7000
 $ sudo systemctl status sim7000
 ● sim7000.service - PPP SIM7000C dialing
      Loaded: loaded (/etc/systemd/system/sim7000.service; enabled; vendor preset: enabled)
      Active: active (running) since Mon 2022-08-08 10:58:10 CST; 1min 4s ago
    Main PID: 4174 (pppd)
       Tasks: 1 (limit: 415)
         CPU: 266ms
      CGroup: /system.slice/sim7000.service
              └─4174 /usr/sbin/pppd call sim7000
 
 Aug 08 10:58:13 raspberrypi pppd[4174]: local  IP address 10.172.102.128
 Aug 08 10:58:13 raspberrypi pppd[4174]: remote IP address 10.64.64.64
 Aug 08 10:58:13 raspberrypi pppd[4174]: primary   DNS address 168.95.1.1
 Aug 08 10:58:13 raspberrypi pppd[4174]: secondary DNS address 168.95.192.1
 Aug 08 10:58:13 raspberrypi pppd[4174]: local  IP address 10.172.102.128
 Aug 08 10:58:13 raspberrypi pppd[4174]: remote IP address 10.64.64.64
 Aug 08 10:58:13 raspberrypi pppd[4174]: primary   DNS address 168.95.1.1
 Aug 08 10:58:13 raspberrypi pppd[4174]: secondary DNS address 168.95.192.1
 Aug 08 10:58:43 raspberrypi pppd[4174]: IPV6CP: timeout sending Config-Requests
 Aug 08 10:58:43 raspberrypi pppd[4174]: IPV6CP: timeout sending Config-Requests
 ```

# Deploy

Download the deploy script from https://blog.wilicw.dev/files/deploy_sim7000.sh and exectute it (Only works on debian-base distro).

```shell
$ curl https://blog.wilicw.dev/files/deploy_sim7000.sh | bash -
```

---

# Appendix

This section have some scripts been mentioned earlier in this article.

## PPP

chatscript (`/etc/ppp/sim7000`)

```
# You can use this script unmodified to connect to cellular networks.
# The APN is specified in the peers file as the argument of the -T command
# line option of chat(8).

# For details about the AT commands involved please consult the relevant
# standard: 3GPP TS 27.007 - AT command set for User Equipment (UE).
# (http://www.3gpp.org/ftp/Specs/html-info/27007.htm)

ABORT		BUSY
ABORT		VOICE
ABORT		"NO CARRIER"
ABORT		"NO DIALTONE"
ABORT		"NO DIAL TONE"
ABORT		"NO ANSWER"
ABORT		"DELAYED"
ABORT		"ERROR"

# cease if the modem is not attached to the network yet
ABORT		"+CGATT: 0"

""		AT
TIMEOUT		12
OK		ATH
OK		ATE1

# +CPIN provides the SIM card PIN
#OK		"AT+CPIN=1234"

# +CFUN may allow to configure the handset to limit operations to
# GPRS/EDGE/UMTS/etc to save power, but the arguments are not standard
# except for 1 which means "full functionality".
#OK		AT+CFUN=1

OK		AT+CGDCONT=1,"IP","internet.iot","",0,0
OK		ATD*99#
TIMEOUT		22
CONNECT		""
```

Provider's config (`/etc/ppp/peers/sim7000`)

```
# example configuration for a dialup connection authenticated with PAP or CHAP
#
# This is the default configuration used by pon(1) and poff(1).
# See the manual page pppd(8) for information on all the options.

# MUST CHANGE: replace myusername@realm with the PPP login name given to
# your by your provider.
# There should be a matching entry with the password in /etc/ppp/pap-secrets
# and/or /etc/ppp/chap-secrets.
user "myusername@realm"

# MUST CHANGE: replace ******** with the phone number of your provider.
# The /etc/chatscripts/pap chat script may be modified to change the
# modem initialization string.
connect "/usr/sbin/chat -v -f /etc/ppp/sim7000"

# Serial device to which the modem is connected.
/dev/ttyUSB3

# Speed of the serial line.
115200

debug
nocrtscts
nodetach
ipcp-accept-local
ipcp-accept-remote

# Assumes that your IP address is allocated dynamically by the ISP.
noipdefault
# Try to get the name server addresses from the ISP.
usepeerdns
# Use this connection as the default route.
defaultroute

# Makes pppd "dial again" when the connection is lost.
persist

# Do not ask the remote to authenticate.
noauth
```

## Deploy Script

```bash
#!/bin/bash

chatscript="
ABORT		BUSY
ABORT		VOICE
ABORT		\"NO CARRIER\"
ABORT		\"NO DIALTONE\"
ABORT		\"NO DIAL TONE\"
ABORT		\"NO ANSWER\"
ABORT		\"DELAYED\"
ABORT		\"ERROR\"
ABORT		\"+CGATT: 0\"
\"\"		AT
TIMEOUT		12
OK		ATH
OK		ATE1
OK		AT+CGDCONT=1,\"IP\",\"internet.iot\",\"\",0,0
OK		ATD*99#
TIMEOUT		22
CONNECT		\"\"
"

peers="
user \"myusername@realm\"
connect \"/usr/sbin/chat -v -f /etc/ppp/sim7000\"
/dev/ttyUSB3
115200
debug
nocrtscts
nodetach
ipcp-accept-local
ipcp-accept-remote
noipdefault
usepeerdns
defaultroute
persist
noauth
"

daemonfile="
[Unit]
Description=PPP SIM7000C dialing

[Service]
ExecStart=/usr/sbin/pppd call sim7000
KillMode=process
Restart=on-failure
Type=simple

[Install]
WantedBy=multi-user.target
Alias=sim7000.service
"

echo "$peers" | sudo tee /etc/ppp/peers/sim7000
echo "$chatscript" | sudo tee /etc/ppp/sim7000
echo "$daemonfile" | sudo tee /etc/systemd/system/sim7000.service

if [ "$(whereis pppd)" == "pppd:" ]; then
        sudo apt clean
        sudo apt update -y
        sudo apt update ppp
fi

sudo systemctl daemon-reload
sudo systemctl enable --now sim7000
sudo systemctl status sim7000
```


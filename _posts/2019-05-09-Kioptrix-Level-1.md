---
layout: post
title: "Kioptrix Level #1"
description: "General explanation how to play Kioptrix level 1."
category: articles
tags: [pt, kali, exploit]
comments: false
---

All tool you need

- Kioptrix #1 Download: [vulnhub](https://www.vulnhub.com/entry/kioptrix-level-1-1,22/)

- Kali Linux: [Kali Linux](https://www.kali.org/downloads/)

- VirtualBox: [virtualbox](https://www.virtualbox.org/)

---

Run Kioptrix on VirtualBox

![](https://i.imgur.com/sMYzHv3.png)

---

Use nmap to discover local area network

```
root@kali:~# namp -sn 192.168.2.0/24

Starting Nmap 7.70 ( https://nmap.org ) at 2019-05-10 02:32 EDT
Nmap scan report for 192.168.2.1
Host is up (0.00028s latency).
MAC Address: 00:50:56:C0:00:00 (VMware)
Nmap scan report for 192.168.2.128
Host is up (0.00035s latency).
MAC Address: 00:0C:29:7C:3A:16 (VMware)
Nmap scan report for 192.168.2.254
Host is up (0.00014s latency).
MAC Address: 00:50:56:FF:0D:AC (VMware)
Nmap scan report for 192.168.2.23
Host is up.
Nmap done: 256 IP addresses (4 hosts up) scanned in 28.10 seconds
```

`192.168.2.128` is the Kioptrix host

And use nmap to detect which port is opening and port detail

```
root@kali:~# nmap -sV 192.168.2.128
Starting Nmap 7.70 ( https://nmap.org ) at 2019-05-10 02:38 EDT
Nmap scan report for 192.168.2.128
Host is up (0.0026s latency).
Not shown: 994 closed ports
PORT     STATE SERVICE     VERSION
22/tcp   open  ssh         OpenSSH 2.9p2 (protocol 1.99)
80/tcp   open  http        Apache httpd 1.3.20 ((Unix)  (Red-Hat/Linux) mod_ssl/2.8.4 OpenSSL/0.9.6b)
111/tcp  open  rpcbind     2 (RPC #100000)
139/tcp  open  netbios-ssn Samba smbd (workgroup: MYGROUP)
443/tcp  open  ssl/https   Apache/1.3.20 (Unix)  (Red-Hat/Linux) mod_ssl/2.8.4 OpenSSL/0.9.6b
1024/tcp open  status      1 (RPC #100024)
MAC Address: 00:0C:29:7C:3A:16 (VMware)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 29.65 seconds
```

We can see this server use `Apache httpd 1.3.20`, and use `searchsploit` search this version exploit

```
root@kali:~# searchsploit Apache httpd 1.3.20
Exploits: No Result
Shellcodes: No Result
```

But we can't see any results in this version, so we use google to search exploit

![](https://i.imgur.com/5srwNpc.png)

We can find the exploit call `OpenFuck`

![](https://i.imgur.com/uL6qS86.png)

Copy the code and follow the article in the code annotation

[PaulSec's blog](http://paulsec.github.io/blog/2014/04/14/updating-openfuck-exploit/)

---
layout: post
title: "Raspberry Pi 與 SIM7000 PPP 連線設定"
description: "於 Raspberry Pi 中利用 PPP 協定連接 SIM7000，以中華電信 Cat-M1 為例"
category: articles
tags: [cat-m1, CHT, Raspberry Pi, iot, ppp, sim7000]
comments: false
---

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

```bash
$ sudo apt install ppp
```

If you want to manually configure the module, you probably need a serial console like `minicom` or `screen`. Both of these softwares are available on apt.

```bash
$ sudo apt install minicom # or screen
```

## Connect to the module

When you plug-in the module. System will automatically appears 5 USB devices in the `/dev` folder.

```bash
$ ls -l /dev | grep USB
crw-rw---- 1 root dialout 188,   0 Aug  4 13:32 ttyUSB0
crw-rw---- 1 root dialout 188,   1 Aug  4  2022 ttyUSB1
crw-rw---- 1 root dialout 188,   2 Aug  4 13:32 ttyUSB2
crw-rw---- 1 root dialout 188,   3 Aug  4 13:32 ttyUSB3
crw-rw---- 1 root dialout 188,   4 Aug  4  2022 ttyUSB4
```

In [this document (SIM7000 Series Linux User Guide_V2.00) from SIMCOM](https://github.com/botletics/SIM7000-LTE-Shield/blob/master/SIM7000%20Documentation/Technical%20Documents/SIM7000%20Series%20Linux%20User%20Guide_V2.00.pdf) we can find a table about the **SIM7000 USB Description**. Each USB device provides different functions describe by following table.

| **USB Device** | **Interface** |
|----------------|---------------|
| /dev/ttyUSB0   | Diagnostic    |
| /dev/ttyUSB1   | GPS NMEA      |
| /dev/ttyUSB2   | AT            |
| /dev/ttyUSB3   | Modem         |
| /dev/ttyUSB4   | USB Audio     |

---

# To be continued...
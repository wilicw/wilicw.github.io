---
layout: post
title: "2019 金盾決賽"
description: "Gold Shield 2019. \\CSY教我/"
category: articles
tags: [ctf, GoldShield]
comments: false
---

# Overviews

108 14屆資安技能金盾獎

Team: `ROH`

Rank: `3`

Score: `?` scoreboard 被關了啦

~~家樂福禮券受害者~~

我們這隊只有解出三題，題目跟通靈沒兩樣，都靠隊友 carry ，這裡就來寫一下 `Game 4` `Game 7` `Game 8`

最後意外的拿到第三，而 CSY 毫無疑問的拿了第一

---

# Writeup

## Game4
#### Misc
### Problem
```
某公司已經成立逾20年,公司累積了不少專利資料 ; 但公司的網路管理者,一直使用未加密協定TELNET連線到網路設備的管理介面 (IP: 10.17.0.10) 。商業問謀小明為了竊取該公司的機密,偷偷側錄了一段網路管理者登錄設備的封包檔,並嘗試破解該公司路由設備。
```

### Hint
```
透過封包解析找出可登入設備的一般使用者帳密,再以cisco Cracker取得ENABLE密碼(Flag即為ENABLE密碼)。
```
[封包檔.pcap](/files/goldshield2019/game4.pcap)

### Solve

![wireshark](https://i.imgur.com/Uicju4I.png)

用 wireshark 打開封包，會看到 running config

其中 `enable password 7 07282E404A434B55464B` 應該就是 enable password 了

碰過 cisco packet tracer 應該都知道這種是 type 7 的加密，在網路上找 `Cisco Type 7 Password Decrypt` 來解

### Flag
```
Gold*2019
```

---

## Game 7
#### Stego
### Problem
```
皮卡丘似乎在尋找一些隱藏的檔案 ,相信只要找到它們並且破解其中的密文。就能得到最後的解答
```

[PikaPika.jpg](/files/goldshield2019/PikaPika.jpg)

### Solve

```
# analysis file with binwalk
$ binwalk PikaPika.jpg

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             JPEG image data, JFIF standard 1.01
69769         0x11089         Zip archive data, at least v2.0 to extract, compressed size: 18206, uncompressed size: 18222, name: Gold.zip
88013         0x157CD         Zip archive data, at least v2.0 to extract, compressed size: 194, uncompressed size: 293, name: key.txt
88423         0x15967         End of Zip archive, footer length: 22
```

可以看到裡面有 `Gold.zip` 和 `key.txt`，之後用 binwalk 解開

```
$ binwalk -e PikaPika.jpg
$ tree
.
├── PikaPika.jpg
└── _PikaPika.jpg.extracted
    ├── 11089.zip
    ├── Gold.zip
    └── key.txt
```

key 打開之後貌似是一段歌詞

```
$ cat key.txt
Never give up,
Never lose hope.
Always have faith,
It allows you to cope.
ywdnsl ynrjx bnqq ufxx,
fx ymjd fqbfdx it.
ozxy mfaj ufynjshj,
dtzw iwjfrx bnqq htrj ywzj.
xt uzy ts f xrnqj,
dtz'qq qnaj ymwtzlm dtzw ufns.
pstb ny bnqq ufxx,
fsi xywjslym dtz bnqq lfns
pjd{gwtpjsymjxmnjqi}
```

分析一下把 `gwtpjsymjxmnjqi` -5 就是 key 了 `brokentheshield`

用這把 key 拿去解 gold.zip 會得到一張圖

![flag](/files/goldshield2019/game7flag.jpg)

### Flag

```
HaVe A Good Day!!
```

---

## Game 8
#### Web
### Problem
```
悟毛是個網路言論審查員,今天接獲線民舉報,某網站疑似掌握了元首不可告人的秘密,請在秘密被外洩前幫悟毛找出這個秘密吧。
IP: 10.17.15.246
```
題目主要是一個網站，註解藏了一個上傳點 `/upload`

### Hint
```
link to target
```

經過通靈之後發現應該是用 Linux 建立一個 soft link (symbolic link)，然後打包成一個 zip 傳上去

### Solve

```
$ ln -s ../../flag.txt 123
$ zip 123.zip 123
```

傳上zip檔 flag 就噴出來了

### Flag
```
winniecute
```

---

# 合照
跟主辦單位拿了12萬的板子自嗨了一下 （\\CSY教我/）

![photo](/files/goldshield2019/photo.jpg)

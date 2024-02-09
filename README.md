# wificheck


## Introduction
wifiCheck is a small tool in Bash that prints information about your wifi hardware, setup and reception. It should open your text editor at the end so that you can copy/paste the results in forums for help.

## Installation

You can download or clone from this repository then give executable permission or simply copy this command line from your terminal

```bash
  wget -N -t 5 -T 10 https://raw.githubusercontent.com/olivierPrigent/wifiCheck/main/wificheck.sh && chmod 755 wificheck.sh && ./wificheck.sh -le
```

## Usage


Once copied in your folder, you just have to launch it
wifiCheck can take options, for example

```bash
  ./wificheck -h
```

will print you the help menu

```bash

  wifiCheck is a program that prints wifi information, originally created to help the French Ubuntu forum users to solve their wifi connection problems.
  French is the default language, and bbscode is the default output.

  USAGE:
   ./wificheck.sh [options]

   -l    print long version with iw commands; if iw package is not present, switch to short version
   -v    print a very long version with a scan
   -s    print short version, default behavior
   -e    print english version
   -c    print chinese version
   -n    doesn\'t print bbcode
   -h    print help

```


By default (without option) wifiCheck will give you a short version, in french (for the few translated part, and with bbode \[code\] \[/code\] in order to insert it directly in the french forum

:fr: :uk: :cn: Wifi check comes in french, english and chinese. See the help for related option

:file_folder: As `iw` is not necessarly installed in linux disribution, especialy ubuntu, commands related are not included in the short default version. However it is recommanded to use the long version with `iw`, as it will give you some details about your reception and acces point, wifi modules parameters and systemd network related services, skipping the much longer information. Anyway if you are a wifi user you should install it :+1:

:scroll: the very long option is quiet long, it will give you a thorough scan, all you need to know about your wifi card(s), and all ip tables rules.

:hourglass_flowing_sand: on some systems it might take a few minutes, in mine less than 20 seconds, this comes from the wifi scan, ping, and opening of the ui text editor, I think. So don't hesitate to take a cup of tea after you launch it :tea:





## History

wifiCheck It was first introduced in the french [ubuntu forum] (https://forum.ubuntu-fr.org) as a tool helping for diagnoses that was printing most relevant information about hardware and configuration of your Ubuntu Distro that you could copy/paste directly into the forum with preformated bbCode. As a way to learn coding in bash, and in order to adapt the original script to newer tools like iw and nmcli, I took upon myself to rewrite the original program with the help and advise of the french ubuntu forum contributors.


## Licence

wifi check was intruduced as public licence RIEN À BRANLER which is the french equivalent for WTFPL. I see no reason to change that, I have this repo and you do what the fuck you want, j'en ai rien à branler!

## List of commands

```bash
printf '%(%Y-%m-%d)T\n' -1
uname -r
lsb_release -d
lspci -k -nn | grep -A 3 -i net
sudo lshw -C network
lsusb
lsmod | grep \<wifi_modules\>
dkms status
mokutil --sb-state
sudo rfkill list
ip a
ping \<gateway\>
ping \<cloudflare\>
resolvectl | grep Server
sudo ufw status
nmcli device show
nmcli device wifi

# -l
iw dev
iw dev \<device\> link
iw dev \<device\> station dump
modinfo \<wifi_modules\> |grep parm
systemctl list-units --type=service --all |grep -iE 'network|wpa'
nmcli connection show

# -v
iw list
iw dev \<device\> scan
sudo iptables -vL -t filter|nat|mangle|raw|security
```

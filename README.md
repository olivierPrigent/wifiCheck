
# wifiCheck


## Introduction
wifiCheck is a small tool in Bash that prints information about your wifi hardware, setup and reception. It should open your text editor at the end so that you can copy/paste the results in forums for help. A file `wificheck.log` is created in your `$HOME` directory

## Installation

You can download or clone from this repository then give executable permission or simply copy one of these command line from your terminal, these lines will copy the `wificheck.sh` file to your computer, give the permission and launch it.

To insert in the french forum with BBCode preformated

```bash
  wget -N -t 5 -T 10 https://raw.githubusercontent.com/olivierPrigent/wifiCheck/main/wificheck.sh && chmod 755 wificheck.sh && ./wificheck.sh -l
```

English speaking users (without BBCode)

```bash
  wget -N -t 5 -T 10 https://raw.githubusercontent.com/olivierPrigent/wifiCheck/main/wificheck.sh && chmod 755 wificheck.sh && ./wificheck.sh -len
```

Chinese speaking users (without BBCode)

```bash
  wget -N -t 5 -T 10 https://raw.githubusercontent.com/olivierPrigent/wifiCheck/main/wificheck.sh && chmod 755 wificheck.sh && ./wificheck.sh -lcn
```

### Needed packages
If you want all the informations printed you should make sure these packages are installed on your system although they probably are already present (see below for proper list)

```bash
sudo apt install rfkill iw network-manager lshw mokutil
```





## Usage


Once copied in your folder, you just have to launch it.

wifiCheck can take options, for example

```bash
  ./wificheck -h
```

will print you the help menu

```bash


wifiCheck is a program that prints wifi info, originally created to help in the French Ubuntu forum.
French is the default language, and BBCode is the default output.

USAGE:
./wificheck.sh [options]

-s print short version (most usefull commands), default behavior
-l print long version (more detailed)
-v print a very long version (with iw scan and list plus all iptables)
-e print english version
-c print chinese version
-n doesn't print bbcode
-h print help

More at https://github.com/olivierPrigent/wifiCheck/tree/main

```


By default (without option) wifiCheck will give you a short version, in french (for the few translated part), and with bbode \[code\] \[/code\] in order to insert it directly in the french forum

:fr: :uk: :cn: wifiCheck comes in french, english and chinese as its purpose it to make life easy for beginers. This is mostly for the part in terminal output to indicate the location of the file in case the editor window doesn't open. See the help for related option

:file_folder: A test is performed for each command so that it tells you which package to install in case the command is not present. See the list of package below for complete information. But you should install `network-manager`, `iw`, `mokutils` and `rfkill` though they are probably already installed.

It is recommanded to use the long version, as it will give you some details about your reception and acces point, wifi modules parameters and systemd network related services.

:scroll: The very long option is quiet long especialy if you have several interfaces, it will give you a thorough scan, all you need to know about your wifi card(s), like the supported commands, and all ip tables rules. It

:hourglass_flowing_sand: On some systems it might take a few minutes, in mine less than 20 seconds, this comes from the wifi scan, ping, and opening of the ui text editor, I think. So don't hesitate to take a cup of tea after you launch it :tea:





## History

wifiCheck was first introduced in the french [ubuntu forum](https://forum.ubuntu-fr.org) as a tool helping for diagnoses that was printing most relevant information about hardware and configuration of your Ubuntu Distro from which you could copy/paste directly into the forum with preformated BBCode. It was written by cracolinux .As a way to learn coding in bash, and in order to adapt the original script to newer tools like iw and nmcli, I took upon myself to rewrite the original program with the help and advise of the french ubuntu forum contributors.

You can find the original repository on [framagit](https://framagit.org/cracolinux/wificheck/)


## Licence

wifiCheck was intruduced as public licence RIEN À BRANLER which is the french equivalent for WTFPL. I see no reason to change that, I have this repo for me and you do what the fuck you want, j'en ai rien à branler!

## List of commands

```bash
printf '%(%Y-%m-%d)T\n' -1
uname -r
lsb_release -d
nmcli
iw dev
nmcli device wifi
lsusb
lspci -k -nn | grep -A 3 -i net
lsmod | grep <wifi_modules>
dkms status
mokutil --sb-state
sudo rfkill list
ping <gateway>
ping <cloudflare>
sudo ufw status


# -l
resolvectl | grep Server
cat /etc/network/interfaces
sudo lshw -C network
pccardctl info
ip a
modinfo <wifi_modules> |grep parm
systemctl list-units --type=service --all |grep -iE 'network|wpa'
nmcli connection show
nmcli -f all d show $interface
iw dev <device> link


# -v
iw list
iw dev <device> scan
sudo iptables -vL -t filter|nat|mangle|raw|security
```

## List of required packages (in ubuntu)

### might not be on your system
```bash
dkms
rfkill
iw
network-manager
lshw
mokutil
```

### Should be on your system
```bash
bash
coreutils
lsb-release
iproute2
kmod
ufw
systemd
iptables
pciutils
usbutils
iputils-ping
xdg-utils
pcmciautils
```


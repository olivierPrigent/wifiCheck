#!/usr/bin/env bash


#############################################################################################################################################
# 2012 → 2022 - cracolinux
# 2020 - Mise à jour par j1v3_d4_v0m17 : https://github.com/j1v3/wificheck
# 2020 - Modification suite remarque par Watael : https://forum.ubuntu-fr.org/viewtopic.php?pid=22395338#p22395338
# 2022 - Modification suite à la proposition de Bruno : https://forum.ubuntu-fr.org/viewtopic.php?pid=22552050#p22552050
# 2023 - Ajout de la commande bootctl, remarque par NicoApi73 via xubu1957 : https://forum.ubuntu-fr.org/viewtopic.php?pid=22631234#p22631234
# 2024 - Refonte Astrolivier suppression des commandes obsolètes, ajout de iw, systemctl
#
# v2.1
#
# LICENCE:
#
# 		LICENCE PUBLIQUE RIEN À BRANLER
# 		Version 1, Mars 2009
# 		Copyright (C) 2009 Sam Hocevar
# 		14 rue de Plaisance, 75014 Paris, France
#
# 			La copie et la distribution de copies exactes de cette licence sont
# 			autorisées, et toute modification est permise à condition de changer
# 			le nom de la licence.
#
# 		CONDITIONS DE COPIE, DISTRIBUTION ET MODIFICATION
# 		DE LA LICENCE PUBLIQUE RIEN À BRANLER
#
# 		0. Faites ce que vous voulez, j’en ai RIEN À BRANLER.
#############################################################################################################################################


##uncomment for debug mode in file debug_output.txt located fin local repository
#exec 5> debug_output.txt
#BASH_XTRACEFD="5"
#PS4='$LINENO: '
#set -x

shopt -s nullglob

# Set language as enum : french = 0 ; english = 1 ; chinese = 2 . Default is french.
declare -i which_language
which_language=0

# Set as enum if wificheck prints the short output, the long output or the very long output
# short = 0 ; long = 1 ; very long = 2
declare -i which_version
which_version=0

# set as enum to print bbcode for french forum
# with bbcode = 0 ; without bbcode = 1
declare -i is_bbcode
is_bbcode=0

# variables array that store modules names for lsmod and modinfo
declare -a modules_array

# store lsmod result
declare lsmod_variable

# variable associative array used to check with command -v if a commande is installed or not. the key is the command, and the value is the package which contains the command
declare -A command_array
command_array=([uname]="coreutils" [lsb_release]="lsb-release" [lspci]="pciutils" [lshw]="lshw" [lsusb]="usbutils" [lsmod]="kmod" [dkms]="dkms" [mokutil]="mokutil" [rfkill]="rfkill" [ip]="iproute2" [ping]="iputils-ping" [resolvectl]="systemd" [ufw]="ufw" [nmcli]="network-manager" [iw]="iw" [modinfo]="kmod" [systemctl]="systemd" [iptables]="iptables" [xdg-open]="xdg-utils" [pccardctl]="pcmciautils")

# variable used with command_array
declare key


# print help on stdout with -h or bad argument
help() {
  echo ""
  echo "wifiCheck is a program that prints wifi info, originally created to help in the French Ubuntu forum."
  echo "French is the default language in the terminal output to indicate the file location,"
  echo  "and BBCode is the default output for easy pasting in french forum."
  echo ""
  echo "USAGE:"
  echo " ./wificheck.sh [options]"
  echo ""
  echo " -s    print short version (most usefull commands), default behavior"
  echo " -l    print long version (more detailed)"
  echo " -v    print a very long version (with iw scan, iw list, plus all iptables)"
  echo " -e    print english version in the terminal output"
  echo " -c    print chinese version in the terminal output"
  echo " -n    doesn't print bbcode"
  echo " -h    print help"
  echo ""
  echo "       More at https://github.com/olivierPrigent/wifiCheck/tree/main"
  echo ""
  exit 0
}







# Main function for short version
wificheck_function() {
  echo      "###############################################"
  echo      "###########    Wifi Check    ##################"
  echo      "###########    $(printf '%(%Y-%m-%d)T\n' -1)    ##################"
  echo      "###############################################"



  echo -e "\n\n#####  Current kernel, release, desktop  ######\n"
  key="uname"
  if (command -v "$key")  &>/dev/null ; then
    local uname
    uname=$(uname "-r")
    echo -e " Current Kernel      :  ${uname} "
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi

  key="lsb_release"
  if (command -v "$key")  &>/dev/null ; then
    local release
    release=$(lsb_release "-d")
    echo -e " Release  ${release} "
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi

  echo    " Current Desktop     :  $XDG_CURRENT_DESKTOP"



  echo -e "\n\n################     nmcli    #################\n"
  key="nmcli"
  if (command -v "$key")  &>/dev/null ; then
    nmcli | head -n -3
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n##############    iw dev   ####################\n"
  key="iw"
  if (command -v "$key")  &>/dev/null ; then
    iw dev
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n###########    nmcli dev wifi    ##############\n"
  key="nmcli"
  if (command -v "$key")  &>/dev/null ; then
    nmcli dev wifi
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n################     lsusb     ################\n"
  key="lsusb"
  if (command -v "$key")  &>/dev/null ; then
    lsusb
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n####### lspci -k -nn | grep -A 3 -i net  ######\n"
  key="lspci"
  if (command -v "$key")  &>/dev/null ; then
    lspci -k -nn | grep -A 3 -i net
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n#######   lsmod | grep <wifi_modules>   #######\n"
  key="lsmod"
  if (command -v "$key")  &>/dev/null ; then
    lsmod_function
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n#################  dkms status  ###############\n"

  key="dkms"
  if (command -v "$key")  &>/dev/null ; then
    dkms status
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n#########   mokutil --sb-state    #############\n"

  key="mokutil"
  if (command -v "$key")  &>/dev/null ; then
    mokutil --sb-state
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n##########    sudo rfkill list    #############\n"

  key="rfkill"
  if (command -v "$key")  &>/dev/null ; then
    sudo rfkill list
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n################    ping no-DNS   ###################\n"

  key="ping"
  if (command -v "$key")  &>/dev/null ; then
    ping -q -c1 -w1 $(find_my_gateway) &>/dev/null && echo "ping gateway ipv4 : ok" || echo "ping gateway ipv4 : bad !"
    ping6 -q -c1 -w1 $(find_my_gateway) &>/dev/null && echo "ping gateway ipv6 : ok" || echo "ping gateway ipv6 : bad !"
    ping -4 -q -c1 -w1 1.0.0.1 &>/dev/null && echo "ping cloudflare ipv4 : ok" || echo "ping cloudflare ipv4 : bad !"
    ping -6 -q -c1 -w1 2606:4700:4700::1001 &>/dev/null && echo "ping cloudflare ipv6 : ok" || echo "ping cloudflare ipv6 : bad !"
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi




  echo -e "\n\n###########    sudo ufw status    #############\n"
  key="ufw"
  if (command -v "$key")  &>/dev/null ; then
    sudo ufw status
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi
}





long_function() {
  echo -e "\n\n#########  resolvectl | grep Server  #########\n"
  key="resolvectl"
  if (command -v "$key")  &>/dev/null ; then
    resolvectl | grep Server
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n######    cat /etc/network/interfaces   #######"
  case ${which_language} in
    0)
      echo -e "# ce fichier est obsolète sauf si vous savez ce que vous faîtes #\n"
      ;;

    1)
      echo -e "## this file is deprecated except if you know what you're doing ##\n"
      ;;

    2)
      echo -e "######   该文件已弃用，除非您知道自己在做什么 #######"
      ;;
  esac
  cat /etc/network/interfaces



  echo -e "\n\n########     sudo lshw -C network     #########\n"
  key="lshw"
  if (command -v "$key")  &>/dev/null ; then
    sudo lshw -C network
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n########    PCMCIA card info     #############\n\n"
  key="pccardctl"
  if (command -v "$key")  &>/dev/null; then
      pccardctl info
  else
      echo "'pccardctl' is not installed (package \"pcmciautils\")."
  fi

  echo -e "\n\n################    ip a    ###################\n"

  key="ip"
  if (command -v "$key")  &>/dev/null ; then
    ip a
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi


  echo -e "\n\n#######   modinfo <wifi_modules> |grep parm   #######\n"
  key="modinfo"
  if (command -v "$key")  &>/dev/null ; then
    for module in ${modules_array[@]} ; do
    echo -e "\n  Modules parm for ${module} :"
    modinfo ${module} |grep parm
  done
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n####### systemctl list network units  #########\n"
  key="systemctl"
  if (command -v "$key")  &>/dev/null ; then
    systemctl list-units --type=service --all |grep -iE 'network|wpa'
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi




  echo -e "\n\n########    nmcli connection show   ###########\n"
  key="nmcli"
  if (command -v "$key")  &>/dev/null ; then
    nmcli connection show 2>/dev/null
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi
}






# For long argument. Adds iw and nmcli commands that needs interface name. Goes in a for loop in case there are several interfaces.
interfaces_long_function() {
  echo -e "\n\n#########    nmcli -f all d show $interface     #############\n"
  key="nmcli"
  if (command -v "$key")  &>/dev/null ; then
    nmcli -f all d show $interface
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n#########    iw dev $interface link    #############\n"
  key="iw"
  if (command -v "$key")  &>/dev/null ; then
    iw dev $interface link
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi
}






### For very long argument. Goes in a for loop in case there are several interfaces.
very_long_function() {
key="iptables"
  if (command -v "$key")  &>/dev/null ; then
    echo -e "\n\n#### iptables -vL -t filter|nat|mangle|raw|security  #####\n"
    echo "\n    ### table filter ###"
    sudo iptables -vL -t filter
    echo "\n    ### table nat ###"
    sudo iptables -vL -t nat
    echo "\n    ### table mangle ###"
    sudo iptables -vL -t mangle
    echo "\n    ### table raw ###"
    sudo iptables -vL -t raw
    echo "\n    ### table security ###"
    sudo iptables -vL -t security
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi



  echo -e "\n\n########   iw list  ###########\n"
  key="iw"
  if (command -v "$key")  &>/dev/null ; then
    iw list
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi
}






## For very long argument. Goes in a for loop in case there are several interfaces.
interfaces_very_long_function() {
   echo -e "\n\n########   iw dev $interface station dump  ###########\n"
  key="iw"
  if (command -v "$key")  &>/dev/null ; then
    iw dev $interface station dump
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi


  echo -e "\n\n############    iw dev $interface scan   ############\n"
  key="iw"
  if (command -v "$key")  &>/dev/null ; then
    sudo iw dev $interface scan
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi
}






## find the modules that use cfg80211, find modules that use those modules,
## print the lsmod of all these modules, sort only one instace
lsmod_function() {
  modules_array=("cfg80211")
  lsmod_variable=$(lsmod)

  readarray -t -O"${#modules_array[@]}" modules_array < <(echo "${lsmod_variable}" | grep "cfg80211" | awk '{split($4, a, ","); for (i in a) print a[i]}')

  for i in ${!modules_array[@]} ; do
  readarray -t -O"${#modules_array[@]}"  modules_array   < <(echo "${lsmod_variable}"  | grep ${modules_array[$i]} | awk '{split($4, a, ","); for (i in a) print a[i]}')
  done

  readarray -t modules_array < <(printf "%s\n" "${modules_array[@]}" |sort -u)

  for i in ${!modules_array[@]} ; do
  readarray -t -O"${#modules_array[@]}"  modules_array   < <(echo "${lsmod_variable}"  | grep "${modules_array[$i]}" | awk '{split($4, a, ","); for (i in a) print a[i]}')
  done

  readarray -t modules_array < <(printf "%s\n" "${modules_array[@]}" |sort -u)
  echo  "Module                  Size  Used by"

  for i in ${modules_array}; do
  printf "%s\n" "$(echo "${lsmod_variable}" |grep "${modules_array[i]}" )"
  done
}






### function for ping printing in wificheck_function
find_my_gateway() {
  ip route show default | cut -d" " -f3
}






###### print on terminal at the end
french_terminal_output() {
  echo "####################################################################"
  echo "Le fichier wificheck.log a été crée dans "$HOME""
  echo "Vous n'avez plus qu'à copier/coller son contenu entier sur le forum"
  echo " accès →→ "$HOME"/wificheck.log"
  echo "####################################################################"
}

english_terminal_output() {
  echo "####################################################################"
  echo "File wificheck.log has been created in "$HOME""
  echo "You simply have to copy/paste the entire content on the forum"
  echo "Markup is bbcode for french ubuntu forum"
  echo " acces →→ "$HOME"/wificheck.log"
  echo "####################################################################"
}

chinese_terminal_output() {
  echo "####################################################################"
  echo "wificheck.log 文件已创建在 "$HOME""
  echo "你只需将整个内容复制/粘贴到论坛上"
  echo "标记语言是法国Ubuntu论坛的BBCode"
  echo " 访问 →→ "$HOME"/wificheck.log"
  echo "####################################################################"
}









######################################################
################   main   ############################

## check for arguments and set variable
while getopts "hslecnv" arg; do
  case $arg in
    l)
      which_version=1
      ;;
    s)
      which_version=0
      ;;
    v)
      which_version=2
      ;;
    e)
      which_language=1
      ;;

    c)
      which_language=2
      ;;

    n)
      is_bbcode=1
      ;;

    h)
      help
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      help
      ;;
  esac
done



## print stderr and stdout in file
exec 3>&1
exec &>~/wificheck.log



## chech if we print bbcode
if [[ ${is_bbcode} -eq 0 ]]; then
  echo "[code]"
fi



wificheck_function



## check if we add long version
if [[ ${which_version} -eq 1 ]]; then
  long_function
  for interface in /sys/class/net/w[lw]*; do
    interface=${interface##*/}
    interfaces_long_function
  done
fi



## check if we add very long version
if [[ ${which_version} -eq 2 ]]; then
  long_function
  for interface in /sys/class/net/w[lw]*; do
    interface=${interface##*/}
    interfaces_long_function
  done
    very_long_function
  for interface in /sys/class/net/w[lw]*; do
    interface=${interface##*/}
    interfaces_very_long_function
  done

fi


## chech if we print bbcode
if [[ ${is_bbcode} -eq 0 ]]; then
  echo "[/code]"
fi



## Print back on terminal for the file location
exec >&3-


## check which language to print the file location
case ${which_language} in
  0)
    french_terminal_output
    ;;

  1)
    english_terminal_output
    ;;

  2)
    chinese_terminal_output
    ;;
esac



## open graphical text editor and print nothing on terminal (otherwise terminal won't close)
key="xdg-open"
  if (command -v "$key")  &>/dev/null ; then
    xdg-open ~/wificheck.log 1>/dev/null 2>&1
  else
    echo "command $key is not present you should install ${command_array[$key]} package"
  fi





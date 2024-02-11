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


##uncomment for debug mode in file debug_output.txt in local repository
#exec 5> debug_output.txt
#BASH_XTRACEFD="5"
#PS4='$LINENO: '
#set -x

shopt -s nullglob

# Set language as enum : french = 0 ; english = 1 ; chinese = 2 . Default is french.
declare -i language
language=0

# Set as enum if wificheck prints the short output without iw commands
# or the long output with iw commands
# this mainly because iw is not installed by default, and is quite long as it adds 300 lines minimum.
# short = 0 ; long = 1 ; very long = 2
declare -i short_or_long_output
short_or_long_output=0

# set as enum to print bbcode for french forum
# with bbcode = 0 ; without bbcode = 1
declare -i print_bbcode_or_not
print_bbcode_or_not=0

#variables array for lsmod and modinfo
declare -a modules_array
declare lsmod_variable



# print help on stdout with -h or bad argument
help() {
  echo ""
  echo "wifiCheck is a program that prints wifi info, originally created to help in the French Ubuntu forum."
  echo "French is the default language, and BBCode is the default output."
  echo ""
  echo "USAGE:"
  echo " ./wificheck.sh [options]"
  echo ""
  echo " -l    print long version with iw commands; if iw package is not present, switch to short version"
  echo " -v    print a very long version with a scan"
  echo " -s    print short version, default behavior"
  echo " -e    print english version"
  echo " -c    print chinese version"
  echo " -n    doesn't print bbcode"
  echo " -h    print help"
  exit 0
}







# Main function
wificheck_function() {
  echo      "###############################################"
  echo      "###########    Wifi Check    ##################"
  echo      "###############################################"



  echo -e "\n\n############     Date     #####################\n"
  printf '%(%Y-%m-%d)T\n' -1


  echo -e "\n\n#####  Current kernel, release, desktop  ######\n"

  local uname
  uname=$(uname "-r")
  echo -e " Current Kernel      :  ${uname} "

  local release
  release=$(lsb_release "-d")
  echo -e " Release  ${release} "

  echo    " Current Desktop     :  $XDG_CURRENT_DESKTOP"


  echo -e "\n\n####### lspci -k -nn | grep -A 3 -i net  ######\n"
  lspci -k -nn | grep -A 3 -i net


  echo -e "\n\n########     sudo lshw -C network     #########\n"
  sudo lshw -C network


  echo -e "\n\n################     lsusb     ################\n"
  lsusb


  echo -e "\n\n#######   lsmod | grep <wifi_modules>   #######\n"
  lsmod_function


  echo -e "\n\n#################  dkms status  ###############\n"
  if [[ "$(which "dkms")" = "" ]]; then
   case ${language} in
    0)
      echo "le paquet dkms n'est pas présent"
      ;;

    1)
      echo "dkms package is not available"
      ;;

    2)
      echo "dkms软件包不可用"
      ;;
    esac
  else
    dkms status
  fi


  echo -e "\n\n#########   mokutil --sb-state    #############\n"
  mokutil --sb-state


  echo -e "\n\n##########    sudo rfkill list    #############\n"
  sudo rfkill list


  echo -e "\n\n################    ip a    ###################\n"
  ip a


  echo -e "\n\n################    ping no-DNS   ###################\n"
  ping -q -c1 -w1 $(find_my_gateway) &>/dev/null && echo "ping gateway ipv4 : ok" || echo "ping gateway ipv4 : mauvais !"
  ping6 -q -c1 -w1 $(find_my_gateway) &>/dev/null && echo "ping gateway ipv6 : ok" || echo "ping gateway ipv6 : mauvais"
  ping -4 -q -c1 -w1 1.0.0.1 &>/dev/null && echo "ping cloudflare ipv4 : ok" || echo "ping cloudflare ipv4 : mauvais"
  ping -6 -q -c1 -w1 2606:4700:4700::1001 &>/dev/null && echo "ping cloudflare ipv6 : ok" || echo "ping cloudflare ipv6 : mauvais"


  echo -e "\n\n#########  resolvectl | grep Server  #########\n"
  resolvectl | grep Server


  echo -e "\n\n###########    sudo ufw status    #############\n"
  sudo ufw status


  echo -e "\n\n######    cat /etc/network/interfaces   #######"
  case ${language} in
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


  echo -e "\n\n###########    nmcli dev show    ##############\n"
  nmcli d s


  echo -e "\n\n###########    nmcli dev wifi    ##############\n"
  nmcli dev wifi
}





long_function() {
  echo -e "\n\n#######   modinfo <wifi_modules> |grep parm   #######\n"
  for module in ${modules_array[@]} ; do
    echo -e "\n  Modules parm for ${module} :"
    modinfo ${module} |grep parm
  done

  echo -e "\n\n####### systemctl list network units  #########\n"
  systemctl list-units --type=service --all |grep -iE 'network|wpa'


  echo -e "\n\n########    nmcli connection show   ###########\n"
  nmcli connection show 2>/dev/null


  #echo -e "\n\n#########  time  mtr 8.8.8.8 -rc1   ###########\n"
  #/usr/bin/env time mtr 8.8.8.8 -rc1 | grep -E "real|user|sys"
}




# For long argument. Adds iw commands
iw_long_function() {
  echo -e "\n\n##############    iw dev   ####################\n"
  iw dev

  echo -e "\n\n#########    iw dev $interface link    #############\n"
  iw dev $interface link

  echo -e "\n\n########   iw dev $interface station dump  ###########\n"
  iw dev $interface station dump
}



### very long version
very_long_function() {
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
}




iw_very_long_function() {
  echo -e "\n\n########   iw list  ###########\n"
  iw list

  echo -e "\n\n############    iw dev $interface scan   ############\n"
  sudo iw dev $interface scan
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


##### function to insert bbcode markup for french forum
bbcode_open_function() {
  echo "[code]"
}

bbcode_close_fonction() {
  echo "[/code]"
}


# put stdout and stderr in the file wificheck.log in your $HOME
exec_in_file() {
  exec 3>&1
  exec &>~/wificheck.log
}

# put back stdout on terminal
exec_in_stdout() {
  exec >&3-
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
      short_or_long_output=1
      ;;
    s)
      short_or_long_output=0
      ;;
    v)
      short_or_long_output=2
      ;;
    e)
      language=1
      ;;

    c)
      language=2
      ;;

    n)
      print_bbcode_or_not=1
      ;;

    h)
      help
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      help
      ;;
#    :)
#      echo "Option -$OPTARG requires an argument."
#      help
#      ;;
  esac
done


# check if iw is present, should be distro free
if [[ "$(which "iw")" = "" ]] && [[ ${short_or_long_output} -gt 1 ]] ; then
    short_or_long_output=0

    case ${language} in
    0)
      echo "le paquet iw n'est pas présent"
      ;;

    1)
      echo "iw package is not available"
      ;;

    2)
      echo "iw软件包不可用"
      ;;
    esac
fi



exec_in_file

if [[ ${print_bbcode_or_not} -eq 0 ]]; then
  bbcode_open_function
fi



wificheck_function




if [[ ${short_or_long_output} -eq 1 ]]; then
  for interface in /sys/class/net/w[lw]*; do
    interface=${interface##*/}
    iw_long_function
  done
  long_function
fi


if [[ ${short_or_long_output} -eq 2 ]]; then
  for interface in /sys/class/net/w[lw]*; do
    interface=${interface##*/}
    iw_long_function
    iw_very_long_function
  done
  long_function
  very_long_function
fi


if [[ ${print_bbcode_or_not} -eq 0 ]]; then
  bbcode_close_fonction
fi



exec_in_stdout



case ${language} in
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
xdg-open ~/wificheck.log 1>/dev/null 2>&1




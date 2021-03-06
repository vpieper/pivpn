#!/bin/bash

backupdir=pivpnbackup
date=$(date +%Y%m%d-%H%M%S)
setupVars="/etc/pivpn/setupVars.conf"

if [ ! -f "${setupVars}" ]; then
    echo "::: Missing setup vars file!"
    exit 1
fi

# shellcheck disable=SC1090
source "${setupVars}"

checkbackupdir(){

    if [[ ! -d $install_home/$backupdir ]]; then
        mkdir -p "$install_home"/"$backupdir"
    fi

}

backup_openvpn(){

    openvpndir=/etc/openvpn
    ovpnsdir=${install_home}/ovpns
    checkbackupdir
    backupzip=$date-pivpnovpnbackup.tgz
    # shellcheck disable=SC2210
    tar czpf "$install_home"/"$backupdir"/"$backupzip" "$openvpndir" "$ovpnsdir" > /dev/null 2>&1
    echo -e "Backup crated to $install_home/$backupdir/$backupzip \nTo restore the backup, follow instructions at:\nhttps://github.com/pivpn/pivpn/wiki/FAQ#how-can-i-migrate-my-configs-to-another-pivpn-instance"

}

backup_wireguard(){

    wireguarddir=/etc/wireguard
    configsdir=${install_home}/configs
    checkbackupdir
    backupzip=$date-pivpnwgbackup.tgz
    tar czpf "$install_home"/"$backupdir"/"$backupzip" "$wireguarddir" "$configsdir" > /dev/null 2>&1
    echo -e "Backup crated to $install_home/$backupdir/$backupzip \nTo restore the backup, follow instructions at:\nhttps://github.com/pivpn/pivpn/wiki/FAQ#how-can-i-migrate-my-configs-to-another-pivpn-instance"

}

if [[ ! $EUID -eq 0 ]];then
    if [[ $(dpkg-query -s sudo) ]];then
        export SUDO="sudo"
    else
    echo "::: Please install sudo or run this as root."
    exit 0
  fi
fi

if [[ "${VPN}" == "wireguard" ]]; then
    backup_wireguard
else
    backup_openvpn
fi

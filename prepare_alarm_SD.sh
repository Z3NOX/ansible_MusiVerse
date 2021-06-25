#!/bin/bash
set -e

if [[ $# -lt 2 ]] ; then
   echo "Usage: $0 </dev/mmcblk0> <alarm_image> [<SSID> <WIFI-Passphrase>]"
   echo "partitions a SD card with a 100MB Partition (FAT32). The"
   echo "rest of the SD card is used as ext4 storage for the root system."
   exit 1
fi

device=$1
if [ ! -b ${device} ]; then
    echo "${device} is not a block device"
    exit 1
fi

image=$2
if [ ! -f ${image} ]; then
    echo "${image} is not a regular file or is non-existant"
    exit 1
fi

sfdisk ${device} << EOF
label: dos
label-id: 0x0e360891
device: ${device}
unit: sectors

${device}1 : start=        2048, size=      409600, type=c
${device}2 : start=      413696, type=83
EOF

mkfs.vfat ${device}1
mkdir -p boot
mount "${device}1" boot

mkfs.ext4 ${device}2
mkdir -p root
mount "${device}2" root

echo "Copy files…"
bsdtar -xpf ${image} -C root
sync

mv root/boot/* boot

if [ -z "$3" ] || [ -z "$4" ]; then
    echo "Wifi credentials not supplied. Exit here."
    umount root boot
else
    echo "Create default WIFI connection"
    SSID=$3
    PASS=$4
    if="wlan0"
    if [ "$(cat root/etc/hostname)" == "alarmpi" ]; then
        echo "configure wifi using arch linux netctl configuration"
        cat << EOF >> root/etc/netctl/${if}${SSID}
Description='installed via prepare_SD_RPi.sh'
Interface=${if}
Connection=wireless
Security=wpa
Country=DE
IP=dhcp
ESSID=${SSID}
Key=${PASS}
EOF
        # # netctl-auto method
        # mkdir -p root/etc/systemd/system/sys-subsystem-net-devices-${if}.device.wants
        # ln -s \
        #     /usr/lib/systemd/system/netctl-auto@.service \
        #     root/etc/systemd/system/sys-subsystem-net-devices-${if}.device.wants/netctl-auto@${if}.service

        # netctl enable method
        mkdir -p "root/etc/systemd/system/netctl@${if}${SSID}.service.d"
        ln -s \
            /usr/lib/systemd/system/netctl@.service \
            root/etc/systemd/system/multi-user.target.wants/netctl@${if}${SSID}.service
        cat << EOF >> "root/etc/systemd/system/netctl@${if}${SSID}.service.d/profile.conf"
[Unit]
Descritpion=prepare_SD_RPi.sh
BindsTo=sys-subsystem-net-devices-${if}.device
Aftero=sys-subsystem-net-devices-${if}.device
EOF
    elif [ "$(cat root/etc/hostname)" == "raspbian" ]; then
        echo "configure wifi using raspbian wpa_supplicant configuration"
        cat << EOF >> root/etc/systemd/network/${if}.network
[Match]
Name=${if}

[Network]
DHCP=yes
EOF

        wpa_passphrase "${SSID}" "${PASS}" > root/etc/wpa_supplicant/wpa_supplicant-${if}.conf
        
        ln -s \
           /usr/lib/systemd/system/wpa_supplicant@.service \
           root/etc/systemd/system/multi-user.target.wants/wpa_supplicant@${if}.service
    fi

    umount root boot
fi
rmdir root boot

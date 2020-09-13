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
device: /dev/mmcblk0
unit: sectors

/dev/mmcblk0p1 : start=        2048, size=      409600, type=c
/dev/mmcblk0p2 : start=      413696, type=83
EOF

mkfs.vfat ${device}p1
mkdir -p boot
mount "${device}p1" boot

mkfs.ext4 ${device}p2
mkdir -p root
mount "${device}p2" root

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
    if [ "$(cat root/etc/hostname)" == "alarmpi" ]; then
        echo "configure wifi using arch linux netctl configuration"
        cat << EOF >> root/etc/netctl/wlan0-${SSID}
Description='installed via prepare_SD_RPi.sh'
Interface=wlan0
Connection=wireless
Security=wpa
IP=static
Address=('192.168.0.111/24')
Gateway=('192.168.0.1')
DNS=('192.168.0.1' '8.8.8.8')
ESSID=${SSID}
Key=${PASS}
EOF
        mkdir -p root/etc/systemd/system/sys-subsystem-net-devices-wlan0.device.wants
        ln -s \
            /usr/lib/systemd/system/netctl-auto@.service \
            root/etc/systemd/system/sys-subsystem-net-devices-wlan0.device.wants/netctl-auto@wlan0.service
    elif [ "$(cat root/etc/hostname)" == "raspbian" ]; then
        echo "configure wifi using raspbian wpa_supplicant configuration"
        cat << EOF >> root/etc/systemd/network/wlan0.network
[Match]
Name=wlan0

[Network]
DHCP=yes
EOF

        wpa_passphrase "${SSID}" "${PASS}" > root/etc/wpa_supplicant/wpa_supplicant-wlan0.conf
        
        ln -s \
           /usr/lib/systemd/system/wpa_supplicant@.service \
           root/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
    fi

    umount root boot
fi
rmdir root boot

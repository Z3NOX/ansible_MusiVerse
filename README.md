# ansible provisioning for MusiVerse
## prepare SD card
Download an Arch Linux on ARM Image fitting your platform, e.g. using `wget` for the `aarch64` Raspberry Pis: 
```sh
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
```

Now prepare an SD card using this image. **Be aware** that all contents of this card will be completely removed by this process. 

```sh
# replace the X from /dev/mmcblkX:
bash prepare_alarm_SD.sh /dev/mmcblkX ./ArchLinuxARM-rpi-3-latest.tar.gz
```

Optionally, you can provide a WIFI connection that should be used later on to connect your MusiVerse to the local network. This is highly recommended, if your target computer has no ethernet connection (e.g. if it is a Raspberry Pi Zero W).

```sh
bash prepare_alarm_SD.sh /dev/mmcblkX ./ArchLinuxARM-rpi-3-latest.tar.gz MyFancyWifiSSID MyFancyWifiPassphrase
```

## register the IP and prepare alarm for ansible usage
First, connect to the standard alarm user to create a new sudo user called `muser` there.
Therefore get the IP adress of your target and replace it in the `inventory.yml`.
Then, run the playbook restricting to the host `alarm`:
```sh
ansible-playbook -i inventory.yml -l alarm playbook.yml
```

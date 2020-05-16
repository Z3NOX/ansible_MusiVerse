# ansible provisioning for MusiVerse
## prepare SD card
Dowload an Arch Linux on ARM Image fitting your platform, e.g. using `wget` for the `aarch64` Raspberry Pis: 
```sh
wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
```

Now prepare an SD card using this image. **Be aware** that all contents of this card will be completely removed by this process. 

```sh
bash prepare_alarm_SD.sh /dev/mmcblkX ./ArchLinuxARM-rpi-3-latest.tar.gz
```

Optionally, you can provide a WIFI connection that should be used lateron to connect your musiverse to the local network. This is highly recommended, if your target computer has no ethernet connection (e.g. if it is a Raspberry Pi Zero W).

```sh
bash prepare_alarm_SD.sh /dev/mmcblkX ./ArchLinuxARM-rpi-3-latest.tar.gz MyFancyWifiSSID MyFancyWifiPassphrase
```

## connect to the target and run ansible
First, connect to the standard alarm user to create.
Therefore get the IP adress of your target and replace it in the `inventory.yml`
Then, run the playbook restricting to the host `alarm`
```sh
ansible-playbook -i inventory.yml -l alarm playbook.yml
```

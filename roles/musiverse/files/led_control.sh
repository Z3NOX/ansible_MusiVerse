#!/bin/sh
if [ -d /sys/class/leds/led0 ]; then
	echo "gpio" > /sys/class/leds/led0/trigger
	echo "0" > /sys/class/leds/led0/brightness
fi
if [ -d /sys/class/leds/led1 ]; then
	echo "gpio" > /sys/class/leds/led1/trigger
	echo "0" > /sys/class/leds/led1/brightness
fi


while true; do
	if [ -d /sys/class/net/wap0 ]; then
		if [ "$(cat /sys/class/net/wap0/operstate)" == "up" ]; then
			echo "1" > /sys/class/leds/led0/brightness
		else

			echo "0" > /sys/class/leds/led0/brightness
		fi
	else
		echo "0" > /sys/class/leds/led0/brightness
	fi
	sleep 1
done

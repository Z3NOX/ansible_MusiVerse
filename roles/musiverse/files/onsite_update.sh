#!/bin/sh

cd /home/muser/musiverse-ansible

while true; do
	if [ -f "/tmp/update_musiverse" ]; then
		ansible-playbook -i inventory.yml --connection=local -l localhost -t update_musiverse playbook.yml
		rm /tmp/update_musiverse
	fi
	sleep 2
done

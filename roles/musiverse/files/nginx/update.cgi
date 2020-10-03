#!/bin/sh
sudo -u "muser" \
     -D "/home/muser/musiverse-ansible \
     "ansible-playbook -i inventory.yml -l localhost --connection=local -t update_musiverse playbook.yml"

#!/bin/bash
config_file=config.json
old_uuid=$(cat $config_file |grep "\"id\":"|awk -F '"' '{print $4}')
new_uuid=$(cat /proc/sys/kernel/random/uuid)
sed -i "s/$old_uuid/$new_uuid/" $config_file
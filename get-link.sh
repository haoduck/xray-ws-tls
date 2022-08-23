#!/bin/bash
uuid=$(cat config.json |grep '\"id\":'|awk -F '"' '{print $4}')
domain=$(cat Caddyfile |grep ' {'|head -n 1|awk -F ' {' '{print $1}')
path=$(cat Caddyfile|grep handle_path|awk -F ' ' '{print $2}')
clear;echo "vless://${uuid}@${domain}:443?encryption=none&security=tls&type=ws&host=${domain}&path=$path#${domain}-xray-ws-tls"
#!/bin/bash

if [[ `command -v lsof` ]];then
    if [[ `lsof -i:80` ]] || [[ `lsof -i:443` ]];then
        echo "80或443端口被占用，请检查"
        exit 1
    fi
fi

if [[ `command -v apt-get` ]];then apt-get update && apt-get install -y curl unzip; fi
if [[ `command -v yum` ]];then yum install -y curl unzip; fi

_install_docker(){
    read -p '是否需要安装docker？[Y/n] [Default: Y]: ' input
    case $input in
        [yY][eE][sS]|[yY]) install_docker="True" ;;
        [nN][oO]|[nN]) install_docker="False" ;;
        *) install_docker="True" ;;
    esac
    if [[ $install_docker == "True" ]];then
        curl -L get.docker.com|bash
        systemctl enable docker
        systemctl start docker
    fi
}
_install_docker_compose(){
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /bin/docker-compose
    chmod +x /bin/docker-compose
}

if [[ -z `command -v docker` ]];then _install_docker; fi
if [[ -z `command -v docker-compose` ]];then _install_docker_compose; fi

mkdir -p xray-ws-tls;cd xray-ws-tls
curl -skL https://github.com/haoduck/xray-ws-tls/archive/refs/heads/main.zip -o xray-ws-tls.zip
unzip xray-ws-tls.zip && rm -f xray-ws-tls.zip
mv xray-ws-tls-main/* . && rm -rf xray-ws-tls-main/

if [[ ! -f 'docker-compose.yml' ]] || [[ ! -f 'config.json' ]] || [[ ! -f 'Caddyfile' ]];then
    echo '代码下载失败了，请检查'
    exit 1
fi

clear

while [[ ! $domain ]]; do
    read -p '输入你的域名(务必提前解析好!!!): ' domain
done
read -p '输入伪装站点(默认https://www.amazon.com): ' fakesite
read -p '输入uuid(默认随机生成): ' uuid
read -p '输入路径(path，默认/ws): ' path

sed -i "s/你的域名/$domain/" Caddyfile

if [[ $fakesite ]];then
    if [[ ! $fakesite =~ 'https://' ]] || [[ ! $fakesite =~ 'http://' ]];then fakesite="https://$fakesite"; fi
    sed -i "s/reverse_proxy http.*/reverse_proxy $fakesite {/" Caddyfile
fi

if [[ -z $uuid ]];then
    uuid=$(cat /proc/sys/kernel/random/uuid)
fi
old_uuid=$(cat config.json |grep "\"id\":"|awk -F '"' '{print $4}')
sed -i "s/$old_uuid/$uuid/" config.json

if [[ $path ]];then
    if [[ ${path:0:1} != '/' ]];then path="/$path";fi
    sed -i "s/handle_path /ws {/handle_path $path {/" Caddyfile
fi

docker-compose up -d

uuid=$(cat config.json |grep '\"id\":'|awk -F '"' '{print $4}')
domain=$(cat Caddyfile |grep ' {'|head -n 1|awk -F ' {' '{print $1}')
path=$(cat Caddyfile|grep handle_path|awk -F ' ' '{print $2}')
echo -e '\n\n\n';'echo "vless://${uuid}@${domain}:443?encryption=none&security=tls&type=ws&host=${domain}&path=${path:-/ws}#${domain}-xray-ws-tls"
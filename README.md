# xray-ws-tls


## 一键
```
curl -sLO https://raw.githubusercontent.com/haoduck/xray-ws-tls/main/onekey.sh && bash onekey.sh
```


## 安装Docker
```
curl -L get.docker.com|bash
systemctl enable docker
systemctl start docker
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /bin/docker-compose
chmod +x /bin/docker-compose
```

## 使用
获得代码
```
git clone https://github.com/haoduck/xray-ws-tls.git
cd xray-ws-tls
```
或
```
mkdir xray-ws-tls;cd xray-ws-tls
wget https://raw.githubusercontent.com/haoduck/xray-ws-tls/main/docker-compose.yml
wget https://raw.githubusercontent.com/haoduck/xray-ws-tls/main/config.json
wget https://raw.githubusercontent.com/haoduck/xray-ws-tls/main/Caddyfile
# 以下非必须
wget https://raw.githubusercontent.com/haoduck/xray-ws-tls/main/new-uuid.sh
wget https://raw.githubusercontent.com/haoduck/xray-ws-tls/main/get-link.sh
```

修改配置
```
#修改Caddyfile,填写你的域名，务必要提前解析好DNS（必须！），修改伪装站点，默认是亚马逊（可选）
#config.json的配置酌情修改，一般修改uuid即可，硬是不修改，也能用。但建议修改，提供了一个脚本，一键修改
bash new-uuid.sh
```

运行
```
docker-compose up -d
```

## 获取vless链接
不一定有效
```
uuid=$(cat config.json |grep '\"id\":'|awk -F '"' '{print $4}')
domain=$(cat Caddyfile |grep ' {'|head -n 1|awk -F ' {' '{print $1}')
path=$(cat Caddyfile|grep handle_path|awk -F ' ' '{print $2}')
clear;echo "vless://${uuid}@${domain}:443?encryption=none&security=tls&type=ws&host=${domain}&path=$path#${domain}-xray-ws-tls"
```
或
```
bash get-link.sh
```
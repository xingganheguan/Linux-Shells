#!/bin/bash

set -e

[ "$(id -u)" -ne 0 ] && echo "请使用 root 用户运行" && exit 1

# 你的 GitHub Raw 文件地址
WEB_ENV_URL="https://raw.githubusercontent.com/xingganheguan/Linux-Shells/main/web.env"
WEB_COMPOSE_URL="https://raw.githubusercontent.com/xingganheguan/Linux-Shells/main/web-docker-compose.yml"
NGINX_CONF_URL="https://raw.githubusercontent.com/xingganheguan/Linux-Shells/main/2yyc.conf"

# 安装 Docker
apt update
apt install -y curl ca-certificates git

curl -fsSL https://get.docker.com | bash -s docker

mkdir -p /etc/docker

cat > /etc/docker/daemon.json << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "15m",
        "max-file": "3"
    },
    "userland-proxy": false,
    "ipv6": true,
    "fixed-cidr-v6": "fdb::/64",
    "experimental": true,
    "ip6tables": true
}
EOF

systemctl enable docker
systemctl restart docker

# 克隆 dnmp
cd /root

rm -rf /root/dnmp
git clone https://github.com/garylab/dnmp.git

cd /root/dnmp

# 删除原文件并下载新文件，下载后改名
rm -f .env docker-compose.yml

curl -fsSL "$WEB_ENV_URL" -o .env
curl -fsSL "$WEB_COMPOSE_URL" -o docker-compose.yml

# 替换 nginx 配置
rm -f /root/dnmp/services/nginx/conf.d/localhost.conf
curl -fsSL "$NGINX_CONF_URL" -o /root/dnmp/services/nginx/conf.d/2yyc.conf

# 启动容器
docker compose up -d

# 修改密码文件权限
[ -f /home/password.txt ] && chmod 600 /home/password.txt

# 重载 nginx
docker exec nginx nginx -s reload

echo "全部完成"
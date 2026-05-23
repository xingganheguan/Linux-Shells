#!/bin/bash

set -e

# 修改时区
echo "Asia/Shanghai" > /etc/timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装依赖
apt upgrade -y

apt update 

apt install -y xvfb x11-utils x11-xserver-utils xdotool 

apt install -y wget curl screen sudo rsync p7zip-full htop \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libxss1 libxcomposite1 libxdamage1 libxrandr2 \
    libgbm1 libasound2 python3 python3-pip snapd

# 解除 pip 安装模块限制
mv /usr/lib/python3.13/EXTERNALLY-MANAGED /usr/lib/python3.13/EXTERNALLY-MANAGED.old

pip install arrow lxml openpyxl numpy pandas jinja2 requests DrissionPage zhconv

# 安装最新版chrome
# 下载最新版 deb 包
wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# 用 apt 安装（自动解决依赖）
sudo apt-get update
sudo apt-get install -y /tmp/google-chrome.deb

# xvfb 作为后台服务运行
filename="/etc/systemd/system/xvfb.service"
cat>"${filename}"<<EOF
[Unit]
Description=Xvfb Virtual Display
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :99 -screen 0 1920x1080x24 -ac
Restart=always
User=root
Environment=DISPLAY=:99

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now xvfb.service

#!/bin/bash
# Check if user is root
if [ $(id -u) != "0" ]; then
    printf "错误：你必须以root的身份来运行此脚本！\n"
    exit 1
fi

echo "=========================================================================\n"
printf "Auto install net-speeder on your vps,written by tennfy \n"
printf "Version 0.1 \n"

apt-get update
apt-get install libnet1 libpcap0.8 
apt-get install libnet1-dev libpcap0.8-dev
apt-get install gcc
cd ~
wget --no-check-certificate https://github.com/snooda/net-speeder/raw/master/net_speeder.c
wget --no-check-certificate https://github.com/snooda/net-speeder/raw/master/build.sh

chmod +x build.sh

if [ -f /proc/user_beancounters ] || [ -d /proc/bc ]; then
    sh build.sh -DCOOKED
    INTERFACE=venet0
else
    sh build.sh
    INTERFACE=eth0
fi

nohup /root/net_speeder $INTERFACE "ip" >/dev/null 2>&1 &

sed -i 's/exit\ 0/#exit\ 0/' /etc/rc.local
echo 'nohup /root/net_speeder $INTERFACE "ip" >/dev/null 2>&1 &' >> /etc/rc.local  
echo exit 0 >> /etc/rc.local

echo "=========================================================================\n"
echo "已启动net-speeder"
echo "已写入自\n"
echo "自动安装net-speeder完成！Good Bye!"

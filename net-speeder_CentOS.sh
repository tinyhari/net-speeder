#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
if [ $(id -u) != "0" ]; then
    clear
    echo -e "\033[31m 错误：你必须以root的身份来运行此脚本！ \033[0m"
    exit 1
fi
if [ $(arch) == x86_64 ]; then
    OSB=x86_64
elif [ $(arch) == i686 ]; then
    OSB=i386
else
    echo "\033[31m 错误：无法确定操作系统内核  \033[0m"
    exit 1
fi
if egrep -q "5.*" /etc/issue; then
    OST=5
    wget http://dl.fedoraproject.org/pub/epel/5/${OSB}/epel-release-5-4.noarch.rpm
elif egrep -q "6.*" /etc/issue; then
    OST=6
    wget http://dl.fedoraproject.org/pub/epel/6/${OSB}/epel-release-6-8.noarch.rpm
else
    echo "\033[31m 错误: 无法确定操作系统版本. \033[0m"
    exit 1
fi
rpm -Uvh epel-release*rpm
yum install -y libnet libnet-devel libpcap libpcap-devel gcc

mkdir net_speeder
cd net_speeder
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
NS_PATH=/usr/local/net_speeder
mkdir -p $NS_PATH
cp -Rf net_speeder $NS_PATH
echo -e "\033[36m net_speeder 安装完毕. \033[0m"
echo -e "\033[36m 启动方法: nohup ${NS_PATH}/net_speeder $INTERFACE \"ip\" >/dev/null 2>&1 & \033[0m"
echo -e "\033[36m 写入自启方法：echo 'nohup ${NS_PATH}/net_speeder $INTERFACE \"ip\" >/dev/null 2>&1 & ' >> /etc/rc.local \033[0m"

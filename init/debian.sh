#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-04-29
# Updated: 2014-05-14
# Changed: 修复Debian 7升级时需要手动配置libssl1.0.0
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题

cat /etc/issue
uname -a
MemTotal=`free -m | grep Mem | awk '{print $2}'`
echo -e "\nMemory is: ${MemTotal} MB"

apt-get -y update

apt-get remove -y apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common php5 php5-common php5-cgi php5-mysql php5-curl php5-gd
dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common libmysqlclient15off libmysqlclient15-dev mysql-common php5 php5-common php5-cgi php5-mysql php5-curl php5-gd

apt-get -y update

[ ! -z "`cat /etc/issue | grep 7`" ] && DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade || apt-get -y dist-upgrade

apt-get -fy install
apt-get install -y build-essential libncurses5 libncurses5-dev libc6 libc6-dev wget flex re2c unzip bison gcc g++ autoconf patch make automake cmake expect ruby file bzip2 libmhash-dev libtool libjpeg8 libjpeg8-dev libpng12-0 libpng12-dev libxml2 libxml2-dev libmcrypt-dev curl libcurl3 libcurl4-openssl-dev libfreetype6 libfreetype6-dev libpcre3 libpcre3-dev libexpat1-dev libssl-dev libgeoip-dev zlib1g-dev libpng-dev openssl e2fsprogs libsasl2-dev libidn11 libidn11-dev libevent-dev ntpdate
[ `getconf LONG_BIT` = "64" ] && apt-get install -y ia32-libs
apt-get -y autoremove

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate pool.ntpdate.org
echo "01 1 * * * root ntpdate pool.ntpdate.org /etc/cron.daily" >> /etc/crontab
service cron restart

if [ -s /etc/selinux/config ]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
    sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
fi

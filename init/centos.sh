#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-02-07
# Updated: 2014-03-31
# Changed: 将安装内容分离出去, 实现模块化安装
# Updated: 2014-04-08
# Changed: 修复libmemcached安装失败问题
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题

cat /etc/issue
uname -a
MemTotal=`free -m | grep Mem | awk '{print $2}'`
echo -e "\nMemory is: ${MemTotal} MB"

#epel
centosversion=$(cat /etc/redhat-release | grep -o [0-9] | sed 1q)
bit=$(getconf LONG_BIT)
if [ "$centosversion" = "5" ]; then
    if [ "$bit" = "64" ]; then
        rpm -ivh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
    else
        rpm -ivh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
    fi
elif [ "$centosversion" = "6" ]; then
    if [ "$bit" = "64" ]; then
        rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
    else
        rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    fi
fi

#yum
cp /etc/yum.conf /etc/yum.conf.llnmp
sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

yum remove httpd* php* mysql-server mysql* php-mysql -y

yum -y update
yum -y install ncurses ncurses-devel glibc wget flex re2c unzip bison gcc gcc-c++ autoconf autoconf213 patch make automake cmake expect ruby file ntp bzip2 bzip2-devel diff* mhash-devel libtool libtool-libs libjpeg libjpeg-devel libpng libpng-devel libxml2 libxml2-devel libmcrypt-devel curl curl-devel freetype freetype-devel zlib zlib-devel libtool-ltdl-devel expat-devel pcre-devel geoip-devel openssl openssl-devel openldap-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel vixie-cron libevent libevent-devel

[ "$bit" = "64" ] && yum -y install glibc.i686

yum clean all

#set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ntpdate pool.ntpdate.org
echo "01 1 * * * root ntpdate pool.ntpdate.org /etc/cron.daily" >> /etc/crontab
service crond restart

#selinux
if [ -f /etc/selinux/config ]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

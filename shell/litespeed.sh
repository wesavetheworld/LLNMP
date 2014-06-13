#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-03
# Changed: 修复安装时无法继续问题
# Updated: 2014-04-12
# Changed: 更新LiteSpeed为4.2.9版本
# Updated: 2014-04-13
# Changed: 更改端口设定方式
# Updated: 2014-05-15
# Changed: 更新LiteSpeed到4.2.11
# Updated: 2014-05-19
# Changed: 若安装nginx，限定LiteSpeed仅本地访问
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题
# Changed: 升级LiteSpeed到4.2.12

useradd -M -s /sbin/nologin www
mkdir -p /home/wwwroot/default

[ ! -s $SRC_DIR/lsws-4.2.12-std-i386-linux.tar.gz ] && wget -c http://www.litespeedtech.com/packages/4.0/lsws-4.2.12-std-i386-linux.tar.gz -O $SRC_DIR/lsws-4.2.12-std-i386-linux.tar.gz

cd $SRC_DIR
tar zxf lsws-4.2.12-std-i386-linux.tar.gz
cd lsws-4.2.12
rm -f LICENSE
[ "$nginx_install" = "y" ] && port=8088 || port=80

expect -c "
spawn ./install.sh
expect \"license?\" { send \"Yes\r\" }
expect \"Destination\" { send \"\r\" }
expect \"User name\" { send \"$webuser\r\" }
expect \"Password:\" { send \"$webpass\r\" }
expect \"Retype password:\" { send \"$webpass\r\" }
expect \"Email addresses\" { send \"$webemail\r\" }
expect \"User\" { send \"www\r\" }
expect \"Group\" { send \"www\r\" }
expect \"HTTP port\" { send \"$port\r\" }
expect \"Admin HTTP port\" { send \"\r\" }
expect \"Setup up PHP\" { send \"Y\r\" }
expect \"separated list)\" { send \"\r\" }
expect \"Add-on module\" { send \"N\r\" }
expect \"server restarts\" { send \"Y\r\" }
expect \"right now\" { send \"Y\r\" }
"

if [ "$nginx_install" = "y" ]; then
    sed -i 's/<autoUpdateInterval>/<useIpInProxyHeader>1<\/useIpInProxyHeader>\n    &/' /usr/local/lsws/conf/httpd_config.xml
    sed -i 's/<address>*:$port<\/address>/<address>127.0.0.1:$port<\/address>/g' /usr/local/lsws/conf/httpd_config.xml
fi
sed -i 's/<vhRoot>\$SERVER_ROOT\/DEFAULT\/<\/vhRoot>/<vhRoot>\/home\/wwwroot\/default\/<\/vhRoot>/g' /usr/local/lsws/conf/httpd_config.xml
sed -i 's/<configFile>\$VH_ROOT\/conf\/vhconf\.xml<\/configFile>/<configFile>\$SERVER_ROOT\/conf\/default\.xml<\/configFile>/g' /usr/local/lsws/conf/httpd_config.xml

cp $PWD_DIR/conf/vhconf.xml /usr/local/lsws/conf/default.xml
rm -rf /usr/local/lsws/DEFAULT/
mkdir -p /home/wwwlogs/litespeed
chown -R lsadm:lsadm /usr/local/lsws/admin/

service lsws restart

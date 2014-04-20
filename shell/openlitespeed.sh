#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-13
# Changed: 修正安装后无法登陆问题
# Updated: 2014-04-14
# Changed: 解决CentOS 5无法安装OpenLiteSpeed问题
# Updated: 2014-04-15
# Changed: 修复CentOS 5下升级OpenSSL 1.0.1不成功问题
# Updated: 2014-04-20
# Changed: 更改OpenLiteSpeed安装方式, 直接使用rpm安装

useradd -M -s /sbin/nologin www
mkdir -p /home/wwwroot/default

centosversion=$(cat /etc/redhat-release | grep -o [0-9] | sed 1q)
[ "$centosversion" == "5" ] && rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el5.noarch.rpm || rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el6.noarch.rpm
yum install openlitespeed-1.3 -y

chown -R www.www /usr/local/lsws/admin/cgid
chown -R lsadm.www /usr/local/lsws/admin/tmp

sed -i 's/<user>nobody<\/user>/<user>www<\/user>/g' /usr/local/lsws/conf/httpd_config.xml
sed -i 's/<group>nobody<\/group>/<group>www<\/group>/g' /usr/local/lsws/conf/httpd_config.xml
sed -i 's/<vhRoot>\$SERVER_ROOT\/DEFAULT\/<\/vhRoot>/<vhRoot>\/home\/wwwroot\/default\/<\/vhRoot>/g' /usr/local/lsws/conf/httpd_config.xml
sed -i 's/<configFile>\$VH_ROOT\/conf\/vhconf\.xml<\/configFile>/<configFile>\$SERVER_ROOT\/conf\/default\.xml<\/configFile>/g' /usr/local/lsws/conf/httpd_config.xml

[ "$nginx_install" == "n" ] && sed -i 's/<address>*:8088<\/address>/<address>*:80<\/address>/g' /usr/local/lsws/conf/httpd_config.xml

sed -i 's/<vhRoot>\$SERVER_ROOT\/DEFAULT\/<\/vhRoot>/<vhRoot>\/home\/wwwroot\/default\/<\/vhRoot>/g' /usr/local/lsws/conf/httpd_config.xml
sed -i 's/<configFile>\$VH_ROOT\/conf\/vhconf\.xml<\/configFile>/<configFile>\$SERVER_ROOT\/conf\/default\.xml<\/configFile>/g' /usr/local/lsws/conf/httpd_config.xml

cp $PWD_DIR/conf/vhconf.xml /usr/local/lsws/conf/default.xml
rm -rf /usr/local/lsws/DEFAULT/
mkdir -p /home/wwwlogs/litespeed

PASS=`/usr/local/lsws/admin/fcgi-bin/admin_php -q /usr/local/lsws/admin/misc/htpasswd.php $webpass`
echo "$webuser:$PASS" > /usr/local/lsws/admin/conf/htpasswd

service lsws restart

#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
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
# Changed: 更改rpm安装时替换OpenLiteSpeed控制面板使用http方式登陆
# Updated: 2014-04-24
# Changed: 退回1.2.9版本，CentOS 5与6使用不同的安装方式安装
# Updated: 2014-05-01
# Changed: 增加openssl 1.0.1
# Updated: 2014-05-07
# Changed: 去除SPDY支持, 避免安装失败
# Updated: 2014-05-15
# Changed: 更新Openlitespeed到1.3.1
# Updated: 2014-05-19
# Changed: 若安装nginx，限定OpenLiteSpeed仅本地访问
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题
# Changed: 升级OpenLiteSpeed到1.3.2

useradd -M -s /sbin/nologin www
mkdir -p /home/wwwroot/default

centosversion=$(cat /etc/redhat-release | grep -o [0-9] | sed 1q)
if [ "$centosversion" = "5" ]; then
    rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el5.noarch.rpm
    yum -y install openlitespeed-1.3.2

    chown -R www.www /usr/local/lsws/admin/cgid
    chown -R lsadm.www /usr/local/lsws/admin/tmp

    sed -i 's/<user>nobody<\/user>/<user>www<\/user>/g' /usr/local/lsws/conf/httpd_config.xml
    sed -i 's/<group>nobody<\/group>/<group>www<\/group>/g' /usr/local/lsws/conf/httpd_config.xml
    sed -i 's/<secure>1<\/secure>/<secure>0<\/secure>/g' /usr/local/lsws/admin/conf/admin_config.xml

    [ "$nginx_install" = "n" ] && sed -i 's/<address>*:8088<\/address>/<address>*:80<\/address>/g' /usr/local/lsws/conf/httpd_config.xml

    PASS=`/usr/local/lsws/admin/fcgi-bin/admin_php -q /usr/local/lsws/admin/misc/htpasswd.php $webpass`
    echo "$webuser:$PASS" > /usr/local/lsws/admin/conf/htpasswd
else
    [ ! -s $SRC_DIR/openlitespeed-1.3.2.tgz ] && wget -c http://open.litespeedtech.com/packages/openlitespeed-1.3.2.tgz -O $SRC_DIR/openlitespeed-1.3.2.tgz

    cd $SRC_DIR
    tar zxf openlitespeed-1.3.2.tgz
    cd openlitespeed-1.3.2

    [ "$nginx_install" = "n" ] && sed -i "s/HTTP_PORT=8088/HTTP_PORT=80/g" dist/install.sh

    ./configure --prefix=/usr/local/lsws --with-user=www --with-group=www --with-admin=$webuser --with-password=$webpass --with-email=$webemail --enable-adminssl=no
    make -j $cpu_num && make install
fi

if [ "$nginx_install" = "y" ]; then
    sed -i 's/<autoUpdateInterval>/<useIpInProxyHeader>1<\/useIpInProxyHeader>\n    &/' /usr/local/lsws/conf/httpd_config.xml
    sed -i 's/<address>*:$port<\/address>/<address>127.0.0.1:$port<\/address>/g' /usr/local/lsws/conf/httpd_config.xml
fi
sed -i 's/<vhRoot>\$SERVER_ROOT\/DEFAULT\/<\/vhRoot>/<vhRoot>\/home\/wwwroot\/default\/<\/vhRoot>/g' /usr/local/lsws/conf/httpd_config.xml
sed -i 's/<configFile>\$VH_ROOT\/conf\/vhconf\.xml<\/configFile>/<configFile>\$SERVER_ROOT\/conf\/default\.xml<\/configFile>/g' /usr/local/lsws/conf/httpd_config.xml

cp $PWD_DIR/conf/vhconf.xml /usr/local/lsws/conf/default.xml
rm -rf /usr/local/lsws/DEFAULT/
mkdir -p /home/wwwlogs/litespeed

service lsws restart

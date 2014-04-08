#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-05
# Changed: 修复安装后无法登陆LiteSpeed后台问题

[ ! -s $SRC_DIR/php-5.2.17.tar.gz ] && wget -c $GET_URI/php/php-5.2.17.tar.gz -O $SRC_DIR/php-5.2.17.tar.gz

[ ! -s $SRC_DIR/php-litespeed-6.6.tgz ]&& wget -c $GET_URI/php-litespeed/php-litespeed-6.6.tgz -O $SRC_DIR/php-litespeed-6.6.tgz

yum install -y autoconf213

[ ! -s /usr/local/lsws/phpbuild ] && mkdir -p /usr/local/lsws/phpbuild

cd $SRC_DIR
tar zxf php-litespeed-6.6.tgz
tar zxf php-5.2.17.tar.gz
mv $SRC_DIR/litespeed $SRC_DIR/php-5.2.17/sapi/litespeed/
mv $SRC_DIR/php-5.2.17 /usr/local/lsws/phpbuild
cd /usr/local/lsws/phpbuild/php-5.2.17

touch ac*
rm -rf autom4te.*
export PHP_AUTOCONF=/usr/bin/autoconf-2.13
./buildconf --force

if [ `getconf LONG_BIT` == 64 ]; then
    ln -s /usr/local/mysql/lib /usr/local/mysql/lib64
    ln -s /usr/local/mysql/lib/libmysqlclient.so.18  /usr/lib64/
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' '--with-libdir=lib64' '--with-pdo-mysql=/usr/local/mysql/bin/mysql_config' '--with-mysql=/usr/local/mysql' '--with-mysqli=/usr/local/mysql/bin/mysql_config' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-exif' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-magic-quotes' '--enable-mbstring' '--with-iconv' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-bcmath' '--enable-mbregex' '--enable-gd-native-ttf' '--enable-pcntl' '--with-ldap' '--with-ldap-sasl' '--with-xmlrpc' '--enable-zip' '--enable-inline-optimization' '--enable-soap' '--disable-ipv6' '--enable-ftp' '--disable-debug' '--with-gettext' '--with-litespeed'
else
    ln -s /usr/local/mysql/lib/libmysqlclient.so.18  /usr/lib/
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' '--with-pdo-mysql=/usr/local/mysql/bin/mysql_config' '--with-mysql=/usr/local/mysql' '--with-mysqli=/usr/local/mysql/bin/mysql_config' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-exif' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-magic-quotes' '--enable-mbstring' '--with-iconv' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-bcmath' '--enable-mbregex' '--enable-gd-native-ttf' '--enable-pcntl' '--with-ldap' '--with-ldap-sasl' '--with-xmlrpc' '--enable-zip' '--enable-inline-optimization' '--enable-soap' '--disable-ipv6' '--enable-ftp' '--disable-debug' '--with-gettext' '--with-litespeed'
fi
make clean
make -j $cpu_num
make -k install

[ ! -s /usr/local/lsws/lsphp5/lib ] && mkdir -p /usr/local/lsws/lsphp5/lib

yes | cp -rf /usr/local/lsws/phpbuild/php-5.2.17/php.ini-dist /usr/local/lsws/lsphp5/lib/php.ini

cd /usr/local/lsws/fcgi-bin

[ -e "lsphp-5.2.17" ] && mv -s lsphp-5.2.17 lsphp-5.2.17.bak

cp /usr/local/lsws/phpbuild/php-5.2.17/sapi/litespeed/php lsphp-5.2.17
ln -sf lsphp-5.2.17 lsphp5
ln -sf lsphp-5.2.17 lsphp55
chmod a+x lsphp-5.2.17
chown -R lsadm:lsadm /usr/local/lsws/phpbuild/php-5.2.17

sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/display_errors = On/display_errors = Off/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/public function/function/g' /usr/local/lsws/admin/html/classes/DAttr.php

service lsws restart

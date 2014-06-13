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
# Updated: 2014-04-13
# Changed: 修复安装出错问题, 将make clean移到前面
# Updated: 2014-04-29
# Changed: 增加Debian支持
# Updated: 2014-05-09
# Changed: 更新数据库驱动为mysqlnd驱动
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题

[ ! -s $SRC_DIR/php-5.3.28.tar.gz ] && wget -c http://www.php.net/distributions/php-5.3.28.tar.gz -O $SRC_DIR/php-5.3.28.tar.gz

[ ! -s $SRC_DIR/php-litespeed-6.6.tgz ]&& wget -c http://www.litespeedtech.com/packages/lsapi/php-litespeed-6.6.tgz -O $SRC_DIR/php-litespeed-6.6.tgz

[ -f /etc/redhat-release ] && yum install -y autoconf213 || apt-get install autoconf2.13 -y

[ ! -s /usr/local/lsws/phpbuild ] && mkdir -p /usr/local/lsws/phpbuild

cd $SRC_DIR
tar zxf php-litespeed-6.6.tgz
tar zxf php-5.3.28.tar.gz
mv $SRC_DIR/litespeed $SRC_DIR/php-5.3.28/sapi/litespeed/
mv $SRC_DIR/php-5.3.28 /usr/local/lsws/phpbuild
cd /usr/local/lsws/phpbuild/php-5.3.28

make clean
touch ac*
rm -rf autom4te.*
[ -f /etc/redhat-release ] && export PHP_AUTOCONF=/usr/bin/autoconf-2.13 || export PHP_AUTOCONF=/usr/bin/autoconf2.13
./buildconf --force

if [ `getconf LONG_BIT` = 64 ]; then
    ln -s /usr/local/mysql/lib /usr/local/mysql/lib64
    [ ! -f /etc/redhat-release ] && ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib64/libldap.so
    [ ! -z "`cat /etc/issue | grep Ubuntu`" ] && ln -fs /usr/lib/x86_64-linux-gnu/liblber* /usr/lib64/
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' '--with-libdir=lib64' '--with-pdo-mysql=mysqlnd' '--with-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-magic-quotes' '--enable-mbstring' '--with-iconv' '--enable-inline-optimization' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-mbregex' '--enable-gd-native-ttf' '--enable-pcntl' '--with-ldap' '--with-ldap-sasl' '--with-xmlrpc' '--enable-zip' '--enable-soap' '--enable-ftp' '--disable-debug' '--with-gettext' '--enable-bcmath' '--with-litespeed'
else
    ln -s /usr/local/mysql/lib/libmysqlclient.so.18  /usr/lib/
    [ ! -f /etc/redhat-release ] && ln -fs /usr/lib/i386-linux-gnu/libldap.so /usr/lib/libldap.so
    [ ! -z "`cat /etc/issue | grep Ubuntu`" ] && ln -fs /usr/lib/i386-linux-gnu/liblber* /usr/lib/
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' '--with-pdo-mysql=mysqlnd' '--with-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-exif' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-magic-quotes' '--enable-mbstring' '--with-iconv' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-bcmath' '--enable-mbregex' '--enable-gd-native-ttf' '--enable-pcntl' '--with-ldap' '--with-ldap-sasl' '--with-xmlrpc' '--enable-zip' '--enable-inline-optimization' '--enable-soap' '--disable-ipv6' '--enable-ftp' '--disable-debug' '--with-gettext' '--with-litespeed'
fi

make -j $cpu_num
make -k install

[ ! -s /usr/local/lsws/lsphp5/lib ] && mkdir -p /usr/local/lsws/lsphp5/lib

yes | cp -rf /usr/local/lsws/phpbuild/php-5.3.28/php.ini-production /usr/local/lsws/lsphp5/lib/php.ini

cd /usr/local/lsws/fcgi-bin

[ -e "lsphp-5.3.28" ] && mv -s lsphp-5.3.28 lsphp-5.3.28.bak

cp /usr/local/lsws/phpbuild/php-5.3.28/sapi/litespeed/php lsphp-5.3.28
ln -sf lsphp-5.3.28 lsphp5
ln -sf lsphp-5.3.28 lsphp55
chmod a+x lsphp-5.3.28
chown -R lsadm:lsadm /usr/local/lsws/phpbuild/php-5.3.28

sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/display_errors = On/display_errors = Off/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/lsws/lsphp5/lib/php.ini

service lsws restart

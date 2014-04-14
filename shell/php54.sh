#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-08
# Changed: 修复安装出现sapi/cli/php错误问题
# Updated: 2014-04-13
# Changed: 修复安装出错问题, 去除php-litespeed, 将make clean移到前面

[ ! -s $SRC_DIR/php-5.4.26.tar.gz ] && wget -c $GET_URI/php/php-5.4.26.tar.gz -O $SRC_DIR/php-5.4.26.tar.gz

[ ! -s /usr/local/lsws/phpbuild ] && mkdir -p /usr/local/lsws/phpbuild

cd $SRC_DIR
tar zxf php-5.4.26.tar.gz
mv $SRC_DIR/php-5.4.26 /usr/local/lsws/phpbuild
cd /usr/local/lsws/phpbuild/php-5.4.26

make clean
touch ac*
rm -rf autom4te.*

if [ `getconf LONG_BIT` == 64 ]; then
    ln -s /usr/local/mysql/lib /usr/local/mysql/lib64
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' '--with-libdir=lib64' '--with-pdo-mysql=/usr/local/mysql/bin/mysql_config' '--with-mysql=/usr/local/mysql' '--with-mysqli=/usr/local/mysql/bin/mysql_config' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-magic-quotes' '--enable-mbstring' '--with-iconv' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-mbregex' '--enable-gd-native-ttf' '--enable-pcntl' '--with-ldap' '--with-ldap-sasl' '--with-xmlrpc' '--enable-zip' '--enable-inline-optimization' '--enable-soap' '--enable-ftp' '--disable-debug' '--with-gettext' '--enable-bcmath' '--with-litespeed'
else
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' '--with-pdo-mysql=/usr/local/mysql/bin/mysql_config' '--with-mysql=/usr/local/mysql' '--with-mysqli=/usr/local/mysql/bin/mysql_config' '--with-zlib' '--with-gd' '--enable-shmop' '--enable-sockets' '--enable-sysvsem' '--enable-sysvshm' '--enable-magic-quotes' '--enable-mbstring' '--with-iconv' '--enable-inline-optimization' '--with-curl' '--with-curlwrappers' '--with-mcrypt' '--with-mhash' '--with-openssl' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-bcmath' '--enable-mbregex' '--enable-gd-native-ttf' '--enable-pcntl' '--with-ldap' '--with-ldap-sasl' '--with-xmlrpc' '--enable-zip' '--enable-soap' '--enable-ftp' '--disable-debug' '--with-gettext' '--with-litespeed'
fi

PLF=`uname -p`
if [ "x$PLF" = "xx86_64" ] ; then
    DLSCH=`grep 'sys_lib_dlsearch_path_spec="/lib /usr/lib ' libtool`
    if [ "x$DLSCH" != "x" ] ; then
        cp libtool libtool.orig
        sed -e 's/sys_lib_dlsearch_path_spec=\"\/lib \/usr\/lib /sys_lib_dlsearch_path_spec=\"\/lib64 \/usr\/lib64 /' libtool.orig > libtool
    fi
fi

make -j $cpu_num
make -k install

yes | cp -rf /usr/local/lsws/phpbuild/php-5.4.26/php.ini-production /usr/local/lsws/lsphp5/lib/php.ini

cd /usr/local/lsws/fcgi-bin

[ -e "lsphp-5.4.26" ] && mv -s lsphp-5.4.26 lsphp-5.4.26.bak

cp /usr/local/lsws/phpbuild/php-5.4.26/sapi/litespeed/php lsphp-5.4.26
ln -sf lsphp-5.4.26 lsphp5
ln -sf lsphp-5.4.26 lsphp55
chmod a+x lsphp-5.4.26
chown -R lsadm:lsadm /usr/local/lsws/phpbuild/php-5.4.26

sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/display_errors = On/display_errors = Off/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/lsws/lsphp5/lib/php.ini

service lsws restart

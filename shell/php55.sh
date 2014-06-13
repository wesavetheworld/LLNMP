#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-13
# Changed: 修复安装出错问题, 去除php-litespeed, 将make clean移到前面
# Updated: 2014-04-18
# Changed: 更新php版本到5.5.11
# Updated: 2014-05-02
# Changed: 更新php版本到5.5.12
# Updated: 2014-05-09
# Changed: 更新数据库驱动为mysqlnd驱动
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题

[ ! -s $SRC_DIR/php-5.5.13.tar.gz ] && wget -c http://www.php.net/distributions/php-5.5.13.tar.gz -O $SRC_DIR/php-5.5.13.tar.gz

[ ! -s /usr/local/lsws/phpbuild ] && mkdir -p /usr/local/lsws/phpbuild

cd $SRC_DIR
tar zxf php-5.5.13.tar.gz
mv $SRC_DIR/php-5.5.13 /usr/local/lsws/phpbuild
cd /usr/local/lsws/phpbuild/php-5.5.13

make clean
touch ac*
rm -rf autom4te.*

[ "$cache_select" = 3 ] && COMMAND='--enable-opcache' || COMMAND='--disable-opcache'
if [ `getconf LONG_BIT` = 64 ]; then
    ln -s /usr/local/mysql/lib /usr/local/mysql/lib64
    [ ! -f /etc/redhat-release ] && ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib64/libldap.so
    [ ! -z "`cat /etc/issue | grep Ubuntu`" ] && ln -fs /usr/lib/x86_64-linux-gnu/liblber* /usr/lib64/
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' '--with-libdir=lib64' $COMMAND '--with-libdir=lib64' '--with-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-pdo-mysql=mysqlnd' '--with-iconv' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-zlib' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-bcmath' '--enable-shmop' '--enable-exif' '--enable-sysvsem' '--enable-inline-optimization' '--with-curl' '--enable-mbregex' '--enable-mbstring' '--with-mcrypt' '--with-gd' '--enable-gd-native-ttf' '--with-openssl' '--with-mhash' '--enable-pcntl' '--enable-sockets' '--with-xmlrpc' '--enable-ftp' '--with-gettext' '--enable-sysvshm' '--enable-magic-quotes' '--with-curlwrappers' '--with-ldap' '--with-ldap-sasl' '--enable-zip' '--enable-soap' '--disable-debug' '--with-litespeed'
else
    [ ! -f /etc/redhat-release ] && ln -fs /usr/lib/i386-linux-gnu/libldap.so /usr/lib/libldap.so
    [ ! -z "`cat /etc/issue | grep Ubuntu`" ] && ln -fs /usr/lib/i386-linux-gnu/liblber* /usr/lib/
    ./configure '--disable-fileinfo' '--prefix=/usr/local/lsws/lsphp5' $COMMAND '--with-mysql=mysqlnd' '--with-mysqli=mysqlnd' '--with-pdo-mysql=mysqlnd' '--with-iconv' '--with-freetype-dir=/usr/lib' '--with-jpeg-dir=/usr/lib' '--with-png-dir' '--with-zlib' '--with-libxml-dir=/usr' '--enable-xml' '--disable-rpath' '--enable-bcmath' '--enable-shmop' '--enable-exif' '--enable-sysvsem' '--enable-inline-optimization' '--with-curl' '--enable-mbregex' '--enable-mbstring' '--with-mcrypt' '--with-gd' '--enable-gd-native-ttf' '--with-openssl' '--with-mhash' '--enable-pcntl' '--enable-sockets' '--with-xmlrpc' '--enable-ftp' '--with-gettext' '--enable-sysvshm' '--enable-magic-quotes' '--with-curlwrappers' '--with-ldap' '--with-ldap-sasl' '--enable-zip' '--enable-soap' '--disable-debug' '--with-litespeed'
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

[ ! -s /usr/local/lsws/lsphp5/lib ] && mkdir -p /usr/local/lsws/lsphp5/lib

yes | cp -rf /usr/local/lsws/phpbuild/php-5.5.13/php.ini-production /usr/local/lsws/lsphp5/lib/php.ini

cd /usr/local/lsws/fcgi-bin

[ -e "lsphp-5.5.13" ] && mv -s lsphp-5.5.13 lsphp-5.5.13.bak

cp /usr/local/lsws/phpbuild/php-5.5.13/sapi/litespeed/php lsphp-5.5.13
ln -sf lsphp-5.5.13 lsphp5
ln -sf lsphp-5.5.13 lsphp55
chmod a+x lsphp-5.5.13
chown -R lsadm:lsadm /usr/local/lsws/phpbuild/php-5.5.13

sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/display_errors = On/display_errors = Off/g' /usr/local/lsws/lsphp5/lib/php.ini
sed -i 's/expose_php = On/expose_php = Off/g' /usr/local/lsws/lsphp5/lib/php.ini

if [ "$cache_select" = 3 ];then
    sed -i 's@^\[opcache\]@[opcache]\nzend_extension=opcache.so@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.enable=.*@opcache.enable=1@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.memory_consumption.*@opcache.memory_consumption=128@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.interned_strings_buffer.*@opcache.interned_strings_buffer=8@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.max_accelerated_files.*@opcache.max_accelerated_files=4000@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.revalidate_freq.*@opcache.revalidate_freq=60@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.save_comments.*@opcache.save_comments=0@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.fast_shutdown.*@opcache.fast_shutdown=1@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.enable_cli.*@opcache.enable_cli=1@' /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^;opcache.optimization_level.*@opcache.optimization_level=0@' /usr/local/lsws/lsphp5/lib/php.ini
fi

service lsws restart

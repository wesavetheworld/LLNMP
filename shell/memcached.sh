#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-08
# Changed: 修复libmemcached安装失败问题
# Updated: 2014-04-18
# Changed: 更新memcached版本到1.4.18
# Updated: 2014-04-25
# Changed: 更新memcached组件版本到2.2.0
# Updated: 2014-04-29
# Changed: 增加Debian支持
# Updated: 2014-05-02
# Changed: 更新Memcached到1.4.19
# Updated: 2014-05-15
# Changed: 更新Memcached到1.4.20

useradd -M -s /sbin/nologin memcached

[ ! -s $SRC_DIR/memcached-1.4.20.tar.gz ] && wget -c http://www.memcached.org/files/memcached-1.4.20.tar.gz -O $SRC_DIR/memcached-1.4.20.tar.gz

[ ! -s $SRC_DIR/memcached-2.2.0.tgz ] && wget -c http://pecl.php.net/get/memcached-2.2.0.tgz -O $SRC_DIR/memcached-2.2.0.tgz

[ ! -s $SRC_DIR/libmemcached-1.0.18.tar.gz ] && wget --no-check-certificate -c https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz -O $SRC_DIR/libmemcached-1.0.18.tar.gz

[ ! -s $SRC_DIR/memcache-2.2.7.tgz ] && wget -c http://pecl.php.net/get/memcache-2.2.7.tgz -O $SRC_DIR/memcache-2.2.7.tgz

cd $SRC_DIR
tar zxf memcached-1.4.20.tar.gz
cd memcached-1.4.20
./configure --prefix=/usr/local/memcached
make && make install

ln -s /usr/local/memcached/bin/memcached /usr/bin/memcached

if [ -f /etc/redhat-release ]; then
    cp $PWD_DIR/conf/memcached-centos /etc/init.d/memcached
    chmod +x /etc/init.d/memcached
    chkconfig --add memcached
    chkconfig memcached on
else
    cp $PWD_DIR/conf/memcached-debian /etc/init.d/memcached
    chmod +x /etc/init.d/memcached
    update-rc.d memcached defaults
fi

service memcached start

cd $SRC_DIR
tar zxf memcache-2.2.7.tgz
cd memcache-2.2.7
/usr/local/lsws/lsphp5/bin/phpize
./configure --with-php-config=/usr/local/lsws/lsphp5/bin/php-config
make && make install

if [ -f "/usr/local/lsws/lsphp5/lib/php/extensions/`ls /usr/local/lsws/lsphp5/lib/php/extensions`/memcache.so" ];then
    sed -i 's/; extension_dir = ".\/"/extension_dir = ".\/"/g' /usr/local/lsws/lsphp5/lib/php.ini
    [ ! -z "`cat /usr/local/lsws/lsphp5/lib/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \".*\"@extension_dir = \"/usr/local/lsws/lsphp5/lib/php/extensions/`ls /usr/local/lsws/lsphp5/lib/php/extensions/`\"@" /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' /usr/local/lsws/lsphp5/lib/php.ini
fi

cd $SRC_DIR
tar zxf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18

#check gcc version
if [ ! -z "`gcc --version | head -n1 | grep 4\.1`" ]; then
    yum -y install gcc44 gcc44-c++ libstdc++44-devel
    export CC=/usr/bin/gcc44
    export CXX=/usr/bin/g++44
fi

./configure --with-memcached=/usr/local/memcached
make && make install

cd $SRC_DIR
tar zxf memcached-2.2.0.tgz
cd memcached-2.2.0
/usr/local/lsws/lsphp5/bin/phpize
./configure --with-php-config=/usr/local/lsws/lsphp5/bin/php-config
make -j $cpu_num && make install

if [ -f "/usr/local/lsws/lsphp5/lib/php/extensions/`ls /usr/local/lsws/lsphp5/lib/php/extensions`/memcached.so" ];then
    sed -i 's/; extension_dir = ".\/"/extension_dir = ".\/"/g' /usr/local/lsws/lsphp5/lib/php.ini
    [ ! -z "`cat /usr/local/lsws/lsphp5/lib/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \".*\"@extension_dir = \"/usr/local/lsws/lsphp5/lib/php/extensions/`ls /usr/local/lsws/lsphp5/lib/php/extensions/`\"@" /usr/local/lsws/lsphp5/lib/php.ini
    sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcached.so"@' /usr/local/lsws/lsphp5/lib/php.ini
fi

cp $PWD_DIR/conf/memcached.php /home/wwwroot/default

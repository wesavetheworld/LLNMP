#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31

[ ! -s $SRC_DIR/xcache-3.1.0.tar.gz ] && wget -c http://xcache.lighttpd.net/pub/Releases/3.1.0/xcache-3.1.0.tar.gz -O $SRC_DIR/xcache-3.1.0.tar.gz

cd $SRC_DIR
tar zxf xcache-3.1.0.tar.gz
cd xcache-3.1.0
/usr/local/lsws/lsphp5/bin/phpize
./configure --with-php-config=/usr/local/lsws/lsphp5/bin/php-config --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer
make -j $cpu_num && make install

cp -R htdocs /home/wwwroot/default/xcache
touch /tmp/xcache
chown www.www /tmp/xcache

cat >> /usr/local/lsws/lsphp5/lib/php.ini <<EOF
[xcache-common]
extension = "xcache.so"
[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "$xcachepass"
[xcache]
xcache.cacher = On
xcache.size  = 20M
xcache.count = $cpu_num
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 300
xcache.var_size = 4M
xcache.var_count = 1
xcache.var_slots = 8K
xcache.var_ttl = 0
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.test = Off
xcache.readonly_protection = On
xcache.mmap_path = "/tmp/xcache"
xcache.coredump_directory = ""
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off
[xcache.coverager]
xcache.coverager = On
xcache.coveragedump_directory = ""
EOF

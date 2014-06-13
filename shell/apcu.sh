#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-13
# Changed: 增加apcu.php
# Updated: 2014-06-13
# Changed: 升级apcu到4.0.6

[ ! -s $SRC_DIR/apcu-4.0.6.tgz ] && wget -c http://pecl.php.net/get/apcu-4.0.6.tgz -O $SRC_DIR/apcu-4.0.6.tgz

cd $SRC_DIR
tar zxf apcu-4.0.6.tgz
cd apcu-4.0.6
/usr/local/lsws/lsphp5/bin/phpize
./configure --with-php-config=/usr/local/lsws/lsphp5/bin/php-config
make -j $cpu_num && make install

cat >> /usr/local/lsws/lsphp5/lib/php.ini <<EOF
[apcu]
extension = apcu.so
apc.enabled = 1
apc.shm_size = 32M
apc.ttl = 7200
apc.enable_cli = 1
EOF

cp apc.php /home/wwwroot/default/apcu.php

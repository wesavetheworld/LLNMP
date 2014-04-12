#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-13
# Changed: 增加eaccelerator.php

[ ! -s $SRC_DIR/eaccelerator-eaccelerator-42067ac.tar.gz ] && wget -c $GET_URI/eaccelerator/eaccelerator-eaccelerator-42067ac.tar.gz -O $SRC_DIR/eaccelerator-eaccelerator-42067ac.tar.gz

cd $SRC_DIR
tar zxf eaccelerator-eaccelerator-42067ac.tar.gz
cd eaccelerator-eaccelerator-42067ac
/usr/local/lsws/lsphp5/bin/phpize
./configure --with-php-config=/usr/local/lsws/lsphp5/bin/php-config --enable-eaccelerator=shared
make -j $cpu_num && make install

mkdir /tmp/eaccelerator
chown -R www.www /tmp/eaccelerator

cat >> /usr/local/lsws/lsphp5/lib/php.ini <<EOF
[eaccelerator]
zend_extension="/usr/local/lsws/lsphp5/lib/php/extensions/`ls /usr/local/lsws/lsphp5/lib/php/extensions`/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/var/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="0"
eaccelerator.shm_prune_period="0"
eaccelerator.shm_only="0"
eaccelerator.compress="0"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "disk_only"
EOF

echo 'kernel.shmmax = 67108864' >> /etc/sysctl.conf
sysctl -p

cp $PWD_DIR/conf/eaccelerator.php /home/wwwroot/default

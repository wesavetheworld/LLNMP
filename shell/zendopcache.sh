#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-13
# Changed: 增加opcache.php

[ ! -s $SRC_DIR/zendopcache-7.0.3.tgz ] && wget -c $GET_URI/zendopcache/zendopcache-7.0.3.tgz -O $SRC_DIR/zendopcache-7.0.3.tgz

cd $SRC_DIR
tar zxf zendopcache-7.0.3.tgz
cd zendopcache-7.0.3
/usr/local/lsws/lsphp5/bin/phpize
./configure --with-php-config=/usr/local/lsws/lsphp5/bin/php-config
make -j $cpu_num && make install

cat >> /usr/local/lsws/lsphp5/lib/php.ini <<EOF
[opcache]
zend_extension="/usr/local/lsws/lsphp5/lib/php/extensions/`ls /usr/local/lsws/lsphp5/lib/php/extensions/`/opcache.so"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
opcache.optimization_level=0
EOF

cp $PWD_DIR/conf/opcache.php /home/wwwroot/default

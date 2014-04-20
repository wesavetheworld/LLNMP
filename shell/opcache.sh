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
# Updated: 2014-04-14
# Changed: 更新安装版本为最新版本, 否则与Zend Optimizer有可能会有冲突
# Updated: 2014-04-19
# Changed: 更改文件名为opcache.sh

[ ! -s $SRC_DIR/ZendOptimizerPlus-master.zip ] && wget -c --no-check-certificate https://github.com/zendtech/ZendOptimizerPlus/archive/master.zip -O $SRC_DIR/ZendOptimizerPlus-master.zip

cd $SRC_DIR
unzip ZendOptimizerPlus-master.zip
cd ZendOptimizerPlus-master
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

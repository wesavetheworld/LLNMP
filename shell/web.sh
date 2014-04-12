#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-13
# Changed: 更新缓存组件链接

cp $PWD_DIR/conf/p.php /home/wwwroot/default/p.php
cp $PWD_DIR/conf/llnmp.jpg /home/wwwroot/default/llnmp.jpg
cp $PWD_DIR/conf/index.html /home/wwwroot/default/index.html

[ "$cache_select" == 1 ] && eaccelerator='<a href="http://{ip}/eaccelerator.php" title="eAccelerator" target="_blank">eAccelerator</a>&nbsp;'
[ "$cache_select" == 2 ] && xcache='<a href="http://{ip}/xcache/" title="xCache" target="_blank">xCache</a>&nbsp;'
[ "$cache_select" == 3 ] && opcache='<a href="http://{ip}/opcache.php" title="Zend Opcache" target="_blank">Zend Opcache</a>&nbsp;'
[ "$cache_select" == 4 ] && apcu='<a href="http://{ip}/apcu.php" title="APCU" target="_blank">APCU</a>&nbsp;'
[ "$cache_select" == "y" ] && redis='<a href="http://{ip}/redis.php" title="Redis" target="_blank">Redis</a>&nbsp;'
[ "$cache_select" == "y" ] && memcached='<a href="http://{ip}/memcached.php" title="Memcached" target="_blank">Memcached</a>&nbsp;'

sed -i "s/{cache}/${eaccelerator}${xcache}${opcache}${apcu}${redis}${memcached}/g" /home/wwwroot/default/index.html

sed -i "s/{ip}/$IP/g" /home/wwwroot/default/index.html


if [ "$php_select" == 1 ]; then
    [ ! -s $SRC_DIR/phpMyAdmin-3.4.8-all-languages.tar.gz ] && wget -c $GET_URI/phpmyadmin/phpMyAdmin-3.4.8-all-languages.tar.gz -O $SRC_DIR/phpMyAdmin-3.4.8-all-languages.tar.gz

    cd $SRC_DIR
    tar zxf phpMyAdmin-3.4.8-all-languages.tar.gz
    mv phpMyAdmin-3.4.8-all-languages /home/wwwroot/default/phpmyadmin/

else    
    [ ! -s $SRC_DIR/phpMyAdmin-4.1.12-all-languages.tar.gz ] && wget -c $GET_URI/phpmyadmin/phpMyAdmin-4.1.12-all-languages.tar.gz -O $SRC_DIR/phpMyAdmin-4.1.12-all-languages.tar.gz

    cd $SRC_DIR
    tar zxf phpMyAdmin-4.1.12-all-languages.tar.gz
    mv phpMyAdmin-4.1.12-all-languages /home/wwwroot/default/phpmyadmin/
fi

chown -R www:www /home/wwwroot/

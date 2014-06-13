#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-13
# Changed: 更新缓存组件链接, 去除eAccelerator
# Updated: 2014-04-18
# Changed: 更新phpmyadmin版本到4.1.13
# Updated: 2014-05-02
# Changed: 更新phpmyadmin版本到4.1.14
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题

cp $PWD_DIR/conf/p.php /home/wwwroot/default/p.php
cp $PWD_DIR/conf/llnmp.jpg /home/wwwroot/default/llnmp.jpg
cp $PWD_DIR/conf/index.html /home/wwwroot/default/index.html

[ "$cache_select" = 1 ] && sed -i 's/{cache}/\&nbsp;<a href=\"http:\/\/{ip}\/opcache\.php\" title=\"Zend Opcache\" target=\"_blank\">Zend Opcache<\/a>/g' /home/wwwroot/default/index.html
[ "$cache_select" = 2 ] && sed -i 's/{cache}/\&nbsp;<a href=\"http:\/\/{ip}\/apcu\.php\" title=\"APCU\" target=\"_blank\">APCU<\/a>/g' /home/wwwroot/default/index.html
[ "$cache_select" = 3 ] && sed -i 's/{cache}/\&nbsp;<a href=\"http:\/\/{ip}\/xcache\/\" title=\"xCache\" target=\"_blank\">xCache<\/a>/g' /home/wwwroot/default/index.html

[ "$redis_install" = "y" ] && sed -i 's/{redis}/\&nbsp;<a href=\"http:\/\/{ip}\/redis\.php\" title=\"Redis\" target=\"_blank\">Redis<\/a>/g' /home/wwwroot/default/index.html || sed -i 's/{redis}//g' /home/wwwroot/default/index.html
[ "$memcache_install" = "y" ] && sed -i 's/{memcached}/\&nbsp;<a href=\"http:\/\/{ip}\/memcached\.php\" title=\"MemCached\" target=\"_blank\">MemCached<\/a>/g' /home/wwwroot/default/index.html || sed -i 's/{memcached}//g' /home/wwwroot/default/index.html

[ "$pureftpd_install" = "y" ] && sed -i 's/{ftp}/<a href=\"http:\/\/{ip}\/ftp\/\" title=\"FTP Manager\" target=\"_blank\">FTP Manager<\/a>\&nbsp;/g' /home/wwwroot/default/index.html || sed -i 's/{ftp}//g' /home/wwwroot/default/index.html

sed -i "s/{ip}/$IP/g" /home/wwwroot/default/index.html


[ ! -s $SRC_DIR/phpMyAdmin-4.1.14-all-languages.tar.gz ] && wget -c http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.1.14/phpMyAdmin-4.1.14-all-languages.tar.gz -O $SRC_DIR/phpMyAdmin-4.1.14-all-languages.tar.gz

cd $SRC_DIR
tar zxf phpMyAdmin-4.1.14-all-languages.tar.gz
mv phpMyAdmin-4.1.14-all-languages /home/wwwroot/default/phpmyadmin/

chown -R www:www /home/wwwroot/

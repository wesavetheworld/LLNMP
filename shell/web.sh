#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31

cp $PWD_DIR/conf/p.php /home/wwwroot/default/p.php
cp $PWD_DIR/conf/llnmp.jpg /home/wwwroot/default/llnmp.jpg
cp $PWD_DIR/conf/index.html /home/wwwroot/default/index.html
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

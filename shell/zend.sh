#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31

mkdir -p /usr/local/lsws/lsphp5/lib/php/zend

if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ]; then
    if [ "$php_select" == 1 ]; then
        [ ! -s $SRC_DIR/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz ] && wget -c $GET_URI/zend/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz -O $SRC_DIR/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz

        cd $SRC_DIR
        tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
        cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi

    if [ "$php_select" == 2 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ] && wget -c $GET_URI/zend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz -O $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi

    if [ "$php_select" == 3 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz ] && wget -c $GET_URI/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz -O $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi
else
    if [ "$php_select" == 1 ]; then
        [ ! -s $SRC_DIR/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz ] && wget -c $GET_URI/zend/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz -O $SRC_DIR/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz

        cd $SRC_DIR
        tar zxf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
        cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi

    if [ "$php_select" == 2 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz ] && wget -c $GET_URI/zend/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz -O $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi

    if [ "$php_select" == 3 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz ] && wget -c $GET_URI/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz -O $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
        cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi
fi

if [ "$php_select" == 1 ]; then
    cat >> /usr/local/lsws/lsphp5/lib/php.ini <<EOF
[Zend Optimizer]
zend_optimizer.optimization_level=1 
zend_extension="/usr/local/lsws/lsphp5/lib/php/zend/ZendOptimizer.so"
EOF
elif [ "$php_select" != 1 ] && [ "$php_select" != 4 ]; then
    cat >> /usr/local/lsws/lsphp5/lib/php.ini <<EOF
[Zend Guard Loader]
zend_extension="/usr/local/lsws/lsphp5/lib/php/zend/ZendGuardLoader.so"
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
fi

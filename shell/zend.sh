#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题

mkdir -p /usr/local/lsws/lsphp5/lib/php/zend

if [ `getconf WORD_BIT` = 32 ] && [ `getconf LONG_BIT` = 64 ]; then
    if [ "$php_select" = 1 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ] && wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz -O $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi

    if [ "$php_select" = 2 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz ] && wget -c http://downloads.zend.com/guard/6.0.0/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz -O $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi
else
    if [ "$php_select" = 1 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz ] && wget -c http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz -O $SRC_DIR/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi

    if [ "$php_select" = 2 ]; then
        [ ! -s $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz ] && wget -c http://downloads.zend.com/guard/6.0.0/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz -O $SRC_DIR/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz

        cd $SRC_DIR
        tar zxf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
        cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/lsws/lsphp5/lib/php/zend/
    fi
fi

if [ "$php_select" != 3 ]; then
    cat >> /usr/local/lsws/lsphp5/lib/php.ini <<EOF
[Zend Guard Loader]
zend_extension="/usr/local/lsws/lsphp5/lib/php/zend/ZendGuardLoader.so"
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
fi

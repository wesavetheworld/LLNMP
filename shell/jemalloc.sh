#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-18
# Changed: 更新jemalloc版本到3.6.0

[ ! -f $SRC_DIR/jemalloc-3.6.0.tar.bz2 ] && wget -c http://www.canonware.com/download/jemalloc/jemalloc-3.6.0.tar.bz2 -O $SRC_DIR/jemalloc-3.6.0.tar.bz2

cd $SRC_DIR
tar xjf jemalloc-3.6.0.tar.bz2
cd jemalloc-3.6.0
./configure && make -j $cpu_num && make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig

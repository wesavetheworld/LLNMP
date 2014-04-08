#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31

[ ! -f $SRC_DIR/jemalloc-3.5.1.tar.bz2 ] && wget -c $GET_URI/jemalloc/jemalloc-3.5.1.tar.bz2 -O $SRC_DIR/jemalloc-3.5.1.tar.bz2

cd $SRC_DIR
tar xjf jemalloc-3.5.1.tar.bz2
cd jemalloc-3.5.1
./configure && make -j $cpu_num && make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig

#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-06-13

useradd -M -s /sbin/nologin mysql
rm -f /etc/my.cnf
mkdir -p /data/mysql

[ "$jemalloc_install" = "y" ] && COMMAND="-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'"

[ ! -f $SRC_DIR/mariadb-10.0.11.tar.gz ] && wget -c http://ftp.osuosl.org/pub/mariadb/mariadb-10.0.11/source/mariadb-10.0.11.tar.gz -O $SRC_DIR/mariadb-10.0.11.tar.gz

cd $SRC_DIR
tar zxf mariadb-10.0.11.tar.gz
cd mariadb-10.0.11
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/data/mysql \
-DWITH_ARIA_STORAGE_ENGINE=1 \
-DWITH_XTRADB_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATEDX_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EMBEDDED_SERVER=OFF \
$COMMAND
make -j $cpu_num && make install

cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
if [ -f /etc/redhat-release ]; then
    chkconfig --add mysqld
    chkconfig mysqld on
else
    update-rc.d mysqld defaults
fi

cat > /etc/my.cnf <<EOF
[client]
port = 3306
socket = /tmp/mysql.sock

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = /usr/local/mysql
datadir = /data/mysql
pid-file = /data/mysql/mysql.pid
user = mysql
bind-address = 127.0.0.1
server-id = 1

skip-name-resolve
#skip-networking
back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 4M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 30

log_error = /data/mysql/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = /data/mysql/mysql-slow.log

performance_schema = 0

#lower_case_table_names = 1

skip-external-locking

default_storage_engine = InnoDB
#default-storage-engine = MyISAM
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 16M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF

Memtatol=`free -m | grep 'Mem:' | awk '{print $2}'`
if [ $Memtatol -gt 1500 -a $Memtatol -le 2500 ]; then
    sed -i 's/table_open_cache = 128/table_open_cache = 256/g' /etc/my.cnf
    sed -i 's/tmp_table_size = 16M/tmp_table_size = 32M/g' /etc/my.cnf
    sed -i 's/thread_cache_size = 8/thread_cache_size = 16/g' /etc/my.cnf
    sed -i 's/query_cache_size = 8M/query_cache_size = 16M/g' /etc/my.cnf
    sed -i 's/innodb_buffer_pool_size = 64M/innodb_buffer_pool_size = 128M/g' /etc/my.cnf
    sed -i 's/myisam_sort_buffer_size = 8M/myisam_sort_buffer_size = 16M/g' /etc/my.cnf
    sed -i 's/key_buffer_size = 8M/key_buffer_size = 16M/g' /etc/my.cnf
elif [ $Memtatol -gt 2500 -a $Memtatol -le 3500 ]; then
    sed -i 's/table_open_cache = 128/table_open_cache = 512/g' /etc/my.cnf
    sed -i 's/tmp_table_size = 16M/tmp_table_size = 64M/g' /etc/my.cnf
    sed -i 's/thread_cache_size = 8/thread_cache_size = 32/g' /etc/my.cnf
    sed -i 's/query_cache_size = 8M/query_cache_size = 32M/g' /etc/my.cnf
    sed -i 's/innodb_buffer_pool_size = 64M/innodb_buffer_pool_size = 512M/g' /etc/my.cnf
    sed -i 's/myisam_sort_buffer_size = 8M/myisam_sort_buffer_size = 32M/g' /etc/my.cnf
    sed -i 's/key_buffer_size = 8M/key_buffer_size = 64M/g' /etc/my.cnf
elif [ $Memtatol -gt 3500 ];then
    sed -i 's/table_open_cache = 128/table_open_cache = 1024/g' /etc/my.cnf
    sed -i 's/tmp_table_size = 16M/tmp_table_size = 128M/g' /etc/my.cnf
    sed -i 's/thread_cache_size = 8/thread_cache_size = 64/g' /etc/my.cnf
    sed -i 's/query_cache_size = 8M/query_cache_size = 64M/g' /etc/my.cnf
    sed -i 's/innodb_buffer_pool_size = 64M/innodb_buffer_pool_size = 1024M/g' /etc/my.cnf
    sed -i 's/myisam_sort_buffer_size = 8M/myisam_sort_buffer_size = 64M/g' /etc/my.cnf
    sed -i 's/key_buffer_size = 8M/key_buffer_size = 256M/g' /etc/my.cnf
fi

/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql

chown mysql.mysql -R /data/mysql
chgrp -R mysql /usr/local/mysql/.

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

service mysqld start

/usr/local/mysql/bin/mysqladmin -u root password $dbpass

cat > /tmp/mysql_sec_script <<EOF
use mysql;
update user set password=password('$dbpass') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$dbpass -h localhost < /tmp/mysql_sec_script
rm -f /tmp/mysql_sec_script

bit=$(getconf LONG_BIT)
if [ "$bit" = "64" ]; then
    [ ! -f /usr/lib64/ ] && mkdir -p /usr/lib64/
    ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/
else
    ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib/
fi

service mysqld restart

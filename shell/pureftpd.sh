#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-03-31
# Updated: 2014-04-29
# Changed: 增加Debian支持
# Updated: 2014-06-13
# Changed: 修复Debian、Ubuntu下默认指向dash问题

[ ! -s $SRC_DIR/pure-ftpd-1.0.36.tar.gz ] && wget -c http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz -O $SRC_DIR/pure-ftpd-1.0.36.tar.gz

[ ! -s $SRC_DIR/User_manager_for-PureFTPd_v2.1_CN.zip ] && wget -c http://soft.vpser.net/ftp/pure-ftpd/User_manager_for-PureFTPd_v2.1_CN.zip -O $SRC_DIR/User_manager_for-PureFTPd_v2.1_CN.zip

bit=$(getconf LONG_BIT)
[ "$bit" = "64" ] && ln -s /usr/local/mysql/lib/libmysqlclient* /usr/lib64/ || ln -s /usr/local/mysql/lib/libmysqlclient* /usr/lib

cd $SRC_DIR
tar zxf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=/usr/local/mysql --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english --with-rfc2640
make -j $cpu_num && make install

cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin/
chmod 755 /usr/local/pureftpd/sbin/pure-config.pl

cat > /usr/local/pureftpd/pureftpd-mysql.conf <<EOF
MYSQLSocket     /tmp/mysql.sock
MYSQLServer     localhost
MYSQLPort       3306
MYSQLUser       ftp
MYSQLPassword   $mysqlftppwd
MYSQLDatabase   ftpusers
MYSQLCrypt  md5
MYSQLGetPW      SELECT Password FROM users WHERE User="\L" AND Status="1" AND (Ipaddress = "*" OR Ipaddress LIKE "\R")
MYSQLGetUID     SELECT Uid FROM users WHERE User="\L" AND Status="1" AND (Ipaddress = "*" OR Ipaddress LIKE "\R")
MYSQLGetGID     SELECT Gid FROM users WHERE User="\L" AND Status="1" AND (Ipaddress = "*" OR Ipaddress LIKE "\R")
MYSQLGetDir     SELECT Dir FROM users WHERE User="\L" AND Status="1" AND (Ipaddress = "*" OR Ipaddress LIKE "\R")
MySQLGetBandwidthUL SELECT ULBandwidth FROM users WHERE User="\L" AND Status="1" AND (Ipaddress = "*" OR Ipaddress LIKE "\R")
MySQLGetBandwidthDL SELECT DLBandwidth FROM users WHERE User="\L" AND Status="1" AND (Ipaddress = "*" OR Ipaddress LIKE "\R")
EOF

cat > /usr/local/pureftpd/pure-ftpd.conf <<EOF
ChrootEveryone              yes
BrokenClientsCompatibility  no
MaxClientsNumber            50
Daemonize                   yes
MaxClientsPerIP             5
VerboseLog                  no
DisplayDotFiles             yes
AnonymousOnly               no
NoAnonymous                 yes
SyslogFacility              ftp
DontResolve                 yes
MaxIdleTime                 15
MySQLConfigFile             /usr/local/pureftpd/pureftpd-mysql.conf
UnixAuthentication          yes
LimitRecursion              2000 8
AnonymousCanCreateDirs      no
MaxLoad                     4
PassivePortRange            20000 30000
AntiWarez                   yes
Umask                       133:022
MinUID                      100
AllowUserFXP                no
AllowAnonymousFXP           no
ProhibitDotFilesWrite       no
ProhibitDotFilesRead        no
AutoRename                  no
AnonymousCantUpload         no
CreateHomeDir               no
MaxDiskUsage                99
CustomerProof               yes
AllowOverwrite              on
AllowStoreRestart           on
EOF

cat > $SRC_DIR/script.mysql <<EOF
INSERT INTO mysql.user (Host, User, Password, Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv, Reload_priv, Shutdown_priv, Process_priv, File_priv, Grant_priv, References_priv, Index_priv, Alter_priv) VALUES('localhost','ftp',PASSWORD('$mysqlftppwd'),'Y','Y','Y','Y','N','N','N','N','N','N','N','N','N','N');
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'ftp'@'localhost' IDENTIFIED BY  '$mysqlftppwd';
FLUSH PRIVILEGES;
drop database if exists ftpusers;
CREATE DATABASE ftpusers;
USE ftpusers;
CREATE TABLE admin (
    Username varchar(35) NOT NULL default '',
    Password char(32) binary NOT NULL default '',
    PRIMARY KEY  (Username)
) ENGINE=MyISAM;
INSERT INTO admin VALUES ('Administrator',MD5('$ftpmanagerpwd'));
CREATE TABLE users (
    User varchar(16) NOT NULL default '',
    Password varchar(32) binary NOT NULL default '',
    Uid int(11) NOT NULL default '14',
    Gid int(11) NOT NULL default '5',
    Dir varchar(128) NOT NULL default '',
    QuotaFiles int(10) NOT NULL default '0',
    QuotaSize int(10) NOT NULL default '0',
    ULBandwidth int(10) NOT NULL default '0',
    DLBandwidth int(10) NOT NULL default '0',
    Ipaddress varchar(15) NOT NULL default '*',
    Comment tinytext,
    Status enum('0','1') NOT NULL default '1',
    ULRatio smallint(5) NOT NULL default '1',
    DLRatio smallint(5) NOT NULL default '1',
    PRIMARY KEY  (User),
    UNIQUE KEY User (User)
) ENGINE=MyISAM;
EOF

/usr/local/mysql/bin/mysql -u root -p$dbpass -h localhost < $SRC_DIR/script.mysql

cp $PWD_DIR/conf/pureftpd /etc/init.d/pureftpd
chmod +x /etc/init.d/pureftpd
if [ -f /etc/redhat-release ]; then
    chkconfig --add pureftpd
    chkconfig pureftpd on
else
    update-rc.d pureftpd defaults
fi

cd $SRC_DIR
unzip User_manager_for-PureFTPd_v2.1_CN.zip
mv ftp /home/wwwroot/default/
chmod 777 -R /home/wwwroot/default/ftp/
chown -R www:www /home/wwwroot/default/ftp/

sed -i 's/English/Chinese/g' /home/wwwroot/default/ftp/config.php
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /home/wwwroot/default/ftp/config.php
sed -i 's/myipaddress.com/localhost/g' /home/wwwroot/default/ftp/config.php
sed -i 's/127.0.0.1/localhost/g' /home/wwwroot/default/ftp/config.php

iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
[ -f /etc/redhat-release ] && service iptables save || iptables-save > /etc/iptables.up.rules
service iptables restart

service pureftpd start

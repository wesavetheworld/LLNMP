# LLNMP 一键安装脚本

本脚本作为lnmp的扩展脚本使用，可一键安装 (Open)LiteSpeed + Nginx/Tengine + MySQL/MariaDB + PHP

支持系统：CentOS 5+, Debian 6+, Ubuntu 12+

使用方法：

```
yum -y install wget screen git # for CentOS/Redhat
# apt-get -y install wget screen git # for Debian/Ubuntu
wget -c http://mirrors.linuxeye.com/lnmp-full.tar.gz
tar zxf lnmp-full.tar.gz
git clone https://github.com/ylqjgm/LLNMP
mv LLNMP/* lnmp/
cd lnmp
screen -S llnmp
./install.sh
```

lnmp主页：[https://github.com/lj2007331/lnmp](https://github.com/lj2007331/lnmp)

康康的博客：[http://www.lovekk.org](http://www.lovekk.org)
#!/bin/bash
#
# Author: Shuang.Ca <ylqjgm@gmail.com>
# Home: http://llnmp.com
# Blog: http://shuang.ca
#
# Version: Ver 0.4
# Created: 2014-05-18
# Updated: 2014-05-19
# Changed: 修正Nginx无法显示图片、CSS等问题

# Check if user is root
if [ $(id -u) != "0" ]; then
  echo "Error: You must be root to run this script, use sudo sh $0"
  exit 1
fi

clear
echo "====================================================================="
echo -e "\033[32mLLNMP V$VERSION for CentOS/RedHat, Debian, Ubuntu Linux VPS Written by Shuang.Ca\033[0m"
echo "====================================================================="
echo -e "\033[32mA tool to auto-compile & install LiteSpeed(OpenLiteSpeed)+MySQL(MariaDB)+PHP on Linux\033[0m"
echo ""
echo -e "\033[32mFor more information please visit http://shuang.ca/\033[0m"
echo "====================================================================="

#Domain name
domain="shuang.ca"
echo "Please input domain:"
read -p "(Default domain: shuang.ca):" domain
if [ "$domain" = "" ]; then
  domain="shuang.ca"
fi

if [ ! -f "//usr/local/lsws/conf/$domain.xml" ]; then
  echo "==========================="
  echo "domain=$domain"
  echo "===========================" 
else
  echo "==========================="
  echo "$domain is exist!"
  echo "==========================="  
  exit 0
fi

#More domain name
read -p "Do you want to add more domain name? (y/n)" add_more_domainame
    
if [ "$add_more_domainame" = 'y' ] || [ "$add_more_domainame" = 'Y' ]; then
  echo "Please input domain name,example(www.shuang.ca,blog.shuang.ca,img.shuang.ca)"
  read -p "Please use \",\" between each domain:" moredomain
  echo "==========================="
  echo domain list="$moredomain"
  echo "==========================="
  moredomainame=" $moredomain"
fi
    
get_char() {
  SAVEDSTTY=`stty -g`
  stty -echo
  stty cbreak
  dd if=/dev/tty bs=1 count=1 2> /dev/null
  stty -raw
  stty echo
  stty $SAVEDSTTY
}

echo ""
echo "Press any key to start or CTRL+C to cancel."
char=`get_char`
    
#Mkdir for vhost
mkdir -p /home/wwwroot/$domain
chown -R www:www /home/wwwroot/$domain

#add httpd conf Virtual host
cp -f /usr/local/lsws/conf/httpd_config.xml /usr/local/lsws/conf/httpd_config.xml.bak
v1="<virtualHost>"
v2="<name>$domain<\/name>"
v3="<vhRoot>\/home\/wwwroot\/$domain<\/vhRoot>"
v4="<configFile>\$SERVER_ROOT\/conf\/$domain.xml<\/configFile>"
v5="<note><\/note>"
v6="<allowSymbolLink>0<\/allowSymbolLink>"
v7="<enableScript>1<\/enableScript>"
v8="<restrained>1<\/restrained>"
v9="<maxKeepAliveReq><\/maxKeepAliveReq>"
v10="<smartKeepAlive><\/smartKeepAlive>"
v11="<setUIDMode>0<\/setUIDMode>"
v12="<staticReqPerSec><\/staticReqPerSec>"
v13="<dynReqPerSec><\/dynReqPerSec>"
v14="<outBandwidth><\/outBandwidth>"
v15="<inBandwidth><\/inBandwidth>"
v16="<\/virtualHost>"
vend="<\/virtualHostList>"
sed -i 's/'$vend'/'$v1'\n'$v2'\n'$v3'\n'$v4'\n'$v5'\n'$v6'\n'$v7'\n'$v8'\n'$v9'\n'$v10'\n'$v11'\n'$v12'\n'$v13'\n'$v14'\n'$v15'\n'$v16'\n&/' /usr/local/lsws/conf/httpd_config.xml

#add httpd conf listen
l1="<vhostMap>"
l2="<vhost>$domain<\/vhost>"
l3="<domain>$domain,$moredomain<\/domain>"
l4="<\/vhostMap>"
lend="<\/vhostMapList>"
sed -i 's/'$lend'/'$l1'\n'$l2'\n'$l3'\n'$l4'\n&/' /usr/local/lsws/conf/httpd_config.xml

#add vhost conf
cat >>/usr/local/lsws/conf/$domain.xml<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<virtualHostConfig>
  <docRoot>\$VH_ROOT/</docRoot>
  <adminEmails></adminEmails>
  <enableGzip>1</enableGzip>
  <logging>
    <log>
      <useServer>0</useServer>
      <fileName>/home/wwwlogs/litespeed/${domain}_error.log</fileName>
      <logLevel>DEBUG</logLevel>
      <rollingSize>10M</rollingSize>
    </log>
    <accessLog>
      <useServer>0</useServer>
      <fileName>/home/wwwlogs/litespeed/${domain}_access.log</fileName>
      <rollingSize>10M</rollingSize>
      <keepDays>30</keepDays>
      <compressArchive>0</compressArchive>
    </accessLog>
  </logging>
  <index>
    <useServer>0</useServer>
    <indexFiles>index.html, index.htm, index.php</indexFiles>
    <autoIndex></autoIndex>
    <autoIndexURI></autoIndexURI>
  </index>
  <htAccess>
    <allowOverride>31</allowOverride>
    <accessFileName>.htaccess</accessFileName>
  </htAccess>
</virtualHostConfig>
EOF

chown -R lsadm:lsadm /usr/local/lsws/conf/$domain.xml
if [ -s /usr/local/nginx ]; then
  if [ "$moredomain" != "" ]; then
    moredomain=$domain,$moredomain
    moredomain=${moredomain//,/ }
  else
    moredomain=$domain
  fi

  cat >>/usr/local/nginx/conf/vhost/$domain.conf<<EOF
log_format $domain '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    '\$status \$body_bytes_sent "\$http_referer" '
    '"\$http_user_agent" \$http_x_forwarded_for';

server {
    listen 80;
    server_name $moredomain;
    index index.html index.htm index.php;
    root /home/wwwroot/$domain;

    error_log /home/wwwlogs/nginx/${domain}_error.log;
    access_log /home/wwwlogs/nginx/${domain}_access.log;

    location / {
        try_files \$uri @litespeed;
    }

    location @litespeed {
        internal;
        proxy_pass http://127.0.0.1:8088;
        include proxy.conf;
    }

    location ~ .*\.(php|php5)?$ {
        proxy_pass http://127.0.0.1:8088;
        include proxy.conf;
    }

    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$ {
        expires 30d;
    }

    location ~ .*\.(js|css)?$ {
        expires 12h;
    }
}
EOF

/usr/local/nginx/sbin/nginx -s reload

fi

service lsws restart

echo "========================================================================="
echo "The virtual host has been created"
echo "The path of the virtual host is /home/wwwroot/$domain/"
echo "Please upload the web files into /home/wwwroot/$domain/"
echo "========================================================================="

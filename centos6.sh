#!/bin/bash

# go to root
cd

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service sshd restart

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.d/rc.local

# install wget and curl
yum -y install wget curl

# setting repo
wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
rpm -Uvh remi-release-6.rpm
rm -f *.rpm

# remove unused
yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl

# update
yum -y update

# install webserver
yum -y install nginx php-fpm php-cli
service nginx restart
service php-fpm restart
chkconfig nginx on
chkconfig php-fpm on

# install essential package
yum -y install iftop htop nmap bc nethogs openvpn vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake

# matiin exim
service exim stop
chkconfig exim off

# setting vnstat
vnstat -u -i venet0
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
sed -i 's/eth0/venet0/g' /etc/sysconfig/vnstat
service vnstat restart
chkconfig vnstat on

# install screenfetch
cd
wget https://github.com/KittyKatt/screenFetch/raw/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bashrc
echo "screenfetch" >> .bashrc

# install webserver
cd
wget -O /etc/nginx/nginx.conf "https://raw.github.com/cyber4rt/installer/master//nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Cyber4rt server</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.github.com/cyber4rt/installer/master/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
service php-fpm restart
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://raw.github.com/cyber4rt/installer/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.github.com/cyber4rt/installer/master/1194.conf"
OS=`uname -p`;
if [ "$OS" == "x86_64" ]; then
  wget -O /etc/openvpn/1194.conf "https://raw.github.com/cyber4rt/installer/master/1194.conf"
fi
wget -O /etc/iptables.up.rules "https://raw.github.com/arieonline/autoscript/master/conf/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.d/rc.local
MYIP=`curl -s ifconfig.me`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
sysctl -w net.ipv4.ip_forward=1
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
service openvpn restart
chkconfig openvpn on
cd

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/1194-client.ovpn "https://raw.github.com/cyber4rt/installer/master/1194.conf"
sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false c-mp3nk
echo "c-mp3nk:$PASS" | chpasswd
echo "c-mp3nk" > pass.txt
echo "$PASS" >> pass.txt
tar cf client.tar 1194-client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cd

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://raw.github.com/cyber4rt/installer/master/badvpn-udpgw"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
cd /etc/snmp/
wget -O /etc/snmp/snmpd.conf "https://raw.github.com/cyber4rt/installer/master/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.github.com/cyber4rt/installer/master/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
service snmpd restart
chkconfig snmpd on
snmpwalk -v 1 -c public localhost | tail
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg public@localhost
curl "https://raw.github.com/cyber4rt/installer/master/mrtg.conf" >> /etc/mrtg/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
cd

# setting port ssh
echo "Port 143" >> /etc/ssh/sshd_config
echo "Port  22" >> /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 109 -p 110 -p 443\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart
chkconfig dropbear on

# install vnstat gui
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
yum -y install fail2ban
service fail2ban restart
chkconfig fail2ban on

# install squid
yum -y install squid3
wget -O /etc/squid/squid.conf "https://raw.github.com/cyber4rt/installer/master/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
service squid3 restart
chkconfig squid on

# install webmin
cd
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.680-1.noarch.rpm
rpm -i webmin-1.680-1.noarch.rpm;
rm webmin-1.680-1.noarch.rpm
service webmin restart
chkconfig webmin on

# downlaod script
wget -O speedtest_cli.py "https://raw.github.com/cyber4rt/installer/master/speedtest_cli.py"
wget -O bench-network.sh "https://raw.github.com/cyber4rt/installer/master/bench-network.sh"
wget -O ps_mem.py "https://raw.github.com/cyber4rt/installer/master/ps_mem.py"
wget -O limit.sh "https://raw.github.com/cyber4rt/installer/master/limit.sh"
wget -O dropmon "https://raw.github.com/cyber4rt/installer/master/dropmon"
wget -O userlogin.sh "https://raw.github.com/cyber4rt/installer/master/userlogin.sh"
wget -O userexpired.sh "https://raw.github.com/cyber4rt/installer/master/userexpired.sh"
wget -O userlimit.sh "https://raw.github.com/cyber4rt/installer/master/userlimit.sh"
echo "0 0 * * * root /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 5 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 10 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 15 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 20 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 25 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 30 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 35 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 40 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 45 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 50 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root sleep 55 /root/userexpired.sh" > /etc/cron.d/userexpired
echo "0 0 * * * root /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 5 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 10 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 15 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 20 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 25 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 30 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 35 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 40 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 45 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 50 /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root sleep 55 /root/userlimit.sh" > /etc/cron.d/userlimit
sed -i '$ i\screen -AmdS limit /root/limit.sh' /etc/rc.local
chmod +x bench-network.sh
chmod +x speedtest_cli.py
chmod +x ps_mem.py
chmod +x userlogin.sh
chmod +x userexpired.sh
chmod +x userlimit.sh
chmod +x limit.sh
chmod +x dropmon

rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# cron
service crond start
chkconfig crond on

# finalisasi
chown -R nginx:nginx /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
service sshd restart
service dropbear restart
service fail2ban restart
service squid restart
service webmin restart
service crond start
chkconfig crond on

# info
clear
echo "cyber4rt | server |"
echo "==============================================="
echo ""
echo "Service"
echo "-------"
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP/client.tar)"
echo "OpenSSH  : 22, 143"
echo "Dropbear : 109, 110, 443"
echo "Squid    : 8080 (limit to IP SSH)"
echo "badvpn   : badvpn-udpgw port 7300"
echo ""
echo "Script"
echo "------"
echo "./ps_mem.py"
echo "./speedtest_cli.py --share"
echo "./bench-network.sh"
echo "./loginview.sh"
echo ""
echo "Account Default (utk SSH dan VPN)"
echo "---------------"
echo "User     : c-mp3nk"
echo "Password : $PASS"
echo ""
echo "Fitur lain"
echo "----------"
echo "Webmin   : http://$MYIP:10000/"
echo "vnstat   : http://$MYIP/vnstat/"
echo "MRTG     : http://$MYIP/mrtg/"
echo "Timezone : Asia/Jakarta"
echo "Fail2Ban : [on]"
echo "IPv6     : [off]"
echo ""
echo "SILAHKAN REBOOT VPS ANDA !"
echo ""
echo "==============================================="

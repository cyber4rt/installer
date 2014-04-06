#!/bin/bash

# go to root
cd

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service sshd restart

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


# setting port ssh
echo "Port 143" >> /etc/ssh/sshd_config
echo "Port 80" >> /etc/ssh/sshd_config
echo "Port  22" >> /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 109 -p 110 -p 443\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart
chkconfig dropbear on


# install openvpn
wget -O /etc/openvpn/openvpn.tar "https://raw.github.com/cyber4rt/installer/master/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "https://raw.github.com/cyber4rt/installer/master/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -O /etc/iptables.up.rules "https://raw.github.com/cyber4rt/installer/master/iptables.up.rules"
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
service openvpn restart

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/1194-client.ovpn "https://raw.github.com/cyber4rt/installer/master/1194-client.conf"
sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false YurisshOS
echo "c-mp3nk:$PASS" | chpasswd
echo "username" > pass.txt
echo "password" >> pass.txt
tar cf client.tar 1194-client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cd

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://raw.github.com/cyber4rt/installer/master/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://raw.github.com/cyber4rt/installer/master/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
# install squid
yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.github.com/cyber4rt/installer/master/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
service squid3 restart

# install webmin
cd
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.680-1.noarch.rpm
rpm -i webmin-1.680-1.noarch.rpm;
rm webmin-1.680-1.noarch.rpm
service webmin restart
chkconfig webmin on

# downlaod script
cd

cd
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

# finishing
chown -R www-data:www-data /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo ""  | tee -a log-install.txt
echo "AUTOSCRIPT INCLUDES" | tee log-install.txt
echo "===============================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.tar)"  | tee -a log-install.txt
echo "OpenSSH  : 22, 80, 143"  | tee -a log-install.txt
echo "Dropbear : 109, 110, 443"  | tee -a log-install.txt
echo "Squid3   : 8080 (limit to IP SSH)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Tools"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel"  | tee -a log-install.txt
echo "bmon"  | tee -a log-install.txt
echo "htop"  | tee -a log-install.txt
echo "iftop"  | tee -a log-install.txt
echo "mtr"  | tee -a log-install.txt
echo "nethogs"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "screenfetch"  | tee -a log-install.txt
echo "./ps_mem.py"  | tee -a log-install.txt
echo "./speedtest_cli.py --share"  | tee -a log-install.txt
echo "./bench-network.sh"  | tee -a log-install.txt
echo "./user-login.sh" | tee -a log-install.txt
echo "./user-expire.sh" | tee -a log-install.txt
echo "./user-limit.sh 2" | tee -a log-install.txt
echo "sh dropmon [port] contoh: ./dropmon.sh 443" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : https://$MYIP:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP:81/vnstat/"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP:81/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Log Installasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "SILAHKAN REBOOT VPS ANDA"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==============================================="  | tee -a log-install.txt

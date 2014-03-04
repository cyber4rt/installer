#!/bin/bash

# go to root
cd

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

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

# install essential package
yum -y install iftop htop nmap bc nethogs openvpn vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake

# matiin exim
service exim stop
chkconfig exim off

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

# install fail2ban
yum -y install fail2ban
service fail2ban restart
chkconfig fail2ban on

# install squid
yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.github.com/arieonline/autoscript/master/conf/squid-centos.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
service squid restart
chkconfig squid on

# install webmin
cd
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.670-1.noarch.rpm
rpm -i webmin-1.670-1.noarch.rpm;
rm webmin-1.670-1.noarch.rpm
service webmin restart
chkconfig webmin on

# downlaod script
cd

wget "https://raw.github.com/cyber4rt/installer/master/loginview.sh"
sed -i 's/auth.log/secure/g' loginview.sh
chmod +x loginview.sh
# cron
service crond start
chkconfig crond on

# finalisasi
chown -R nginx:nginx /home/vps/public_html

service sshd restart
service dropbear restart
service fail2ban restart
service squid restart
service webmin restart

# info
clear
echo "cyber4rt | server |"
echo "==============================================="
echo ""
echo "Service"
echo "-------"
echo "OpenSSH  : 22, 143"
echo "Dropbear : 109, 110, 443"
echo "Squid    : 8080 (limit to IP SSH)"
echo "Script"
echo "------"
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
echo "Timezone : Asia/Jakarta"
echo "Fail2Ban : [on]"
echo ""
echo "SILAHKAN REBOOT VPS ANDA !"
echo ""
echo "==============================================="

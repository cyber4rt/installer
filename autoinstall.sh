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
echo "Port  22" >> /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 109 -p 110 -p 443\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart
chkconfig dropbear on


# install squid
yum -y install squid


# install webmin
cd
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.680-1.noarch.rpm
rpm -i webmin-1.680-1.noarch.rpm;
rm webmin-1.680-1.noarch.rpm
service webmin restart
chkconfig webmin on

# downlaod script
cd

wget "https://raw.github.com/cyber4rt/installer/master/loginview.sh"
sed -i 's/auth.log/secure/g' loginview.sh
chmod +x loginview.sh

service sshd restart
service dropbear restart
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
echo ""
echo "SILAHKAN REBOOT VPS ANDA !"
echo ""
echo "==============================================="

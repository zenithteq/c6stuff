#!/bin/bash

#Update CentOS
yum update -y

#Disable SELinux
setenforce 0
sed -i "s|SELINUX=enforcing|SELINUX=disabled|" /etc/selinux/config

#Install EPEL
yum install epel-release -y

#Install useful tools
yum install vim nano wget unzip rsync -y

#Install monitoring tools
yum install net-tools iptraf iftop mtr iperf bind-utils dstat -y

#Install Vmware Tools (Open VM Tools)
#yum install open-vm-tools -y
#systemctl start vmtoolsd.service
#systemctl enable vmtoolsd.service

#Install Fail2Ban
yum install fail2ban -y
systemctl enable fail2ban
echo "[DEFAULT]
# Ban hosts for one hour:
bantime = 3600
# Override /etc/fail2ban/jail.d/00-firewalld.conf:
banaction = iptables-multiport
[sshd]
enabled = true" > /etc/fail2ban/jail.local
systemctl restart fail2ban

#Install Webmin
clear
read -p "Do you want to install Webmin? [y/n]: " -e -i n INSTALL
 if [[ "$INSTALL" = 'y' ]]; then
  wget http://www.webmin.com/download/rpm/webmin-current.rpm
  yum install perl perl-Net-SSLeay openssl perl-IO-Tty -y
  rpm -U webmin-current.rpm
  iptables -I INPUT -p tcp -m tcp --dport 10000 -j ACCEPT
  service iptables save
 fi

#Update CentOS - redo
yum update -y

#Change hostname
HOSTNAME=$(hostname)
NEW_HOSTNAME="$1"
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
clear
echo "Current IP is:" $IP
echo "Current hostname is:" $HOSTNAME
echo ""
if [ -z "$NEW_HOSTNAME" ]; then
 echo -n "Please enter new hostname: "
 read NEW_HOSTNAME < /dev/tty
fi
echo ""
if [ -z "$NEW_HOSTNAME" ]; then
 echo "Error: no hostname entered. Exiting."
 exit 1
fi
echo "Changing hostname from $HOSTNAME to $NEW_HOSTNAME..."
hostnamectl set-hostname $NEW_HOSTNAME
echo "Done."

#Reboot
reboot

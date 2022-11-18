#!/bin/bash 

#flush all the rules

sudo iptables -t filter -F
sudo iptables -t filter -X
sudo iptables -t nat -F
sudo iptables -t nat -X

#setting the default filter policy
sudo iptables --policy INPUT DROP
sudo iptables --policy OUTPUT ACCEPT
sudo iptables -P FORWARD DROP

#allow localhost traffic 
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#allow incoming nat ports

sudo iptables -A INPUT -p tcp --dport 20 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 60000 -j ACCEPT

#write forward rules
sudo iptables -A FORWARD -p tcp --dport 22 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 80 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 9050 -j ACCEPT
sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

#you can set whatever addresses you want depends on your nat network
#this is just an example between 2 machines on a nat network
LHOST="192.168.1.7"
RHOST="192.168.1.5"

#write nat ruls, DNAT and MASQUERADE

sudo iptables -t nat -A PREROUTING -d $LHOST/32 -p tcp --dport 20 -j DNAT --to-destination $RHOST:22
sudo iptables -t nat -A PREROUTING -d $LHOST/32 -p tcp --dport 8080 -j DNAT --to-destination $RHOST:80
sudo iptables -t nat -A PREROUTING -d $LHOST/32 -p tcp --dport 60000 -j DNAT --to-destination $RHOST:9050

sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8000

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#implement the configuration inside the system ctl
sudo sysctl -p /etc/sysctl.d

#enable the forwarding on the kernel
sudo echo 1 | sudo tee 1>0 /proc/sys/net/ipv4/ip_forward

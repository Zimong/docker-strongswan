#! /usr/bin/env bash

#=========== 
# IPTABLES + FIREWALL
#=========== 

# remove if there were UFW rules
if [ -n "$(which ufw)" ]; then ufw disable fi
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
iptables -Z

# ssh rules

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# loopback 
iptables -A INPUT -i lo -j ACCEPT

# ipsec

iptables -A INPUT -p udp --dport  500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT

iptables -A FORWARD --match policy --pol ipsec --dir in  --proto esp -s 10.0.0.0/24 -j ACCEPT
iptables -A FORWARD --match policy --pol ipsec --dir out --proto esp -d 10.0.0.0/24 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
iptables -t mangle -A FORWARD --match policy --pol ipsec --dir in -s 10.0.0.0/24 -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360

iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP

#=======
# CHANGES TO SYSCTL
#=======

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.ip_no_pmtu_disc=1

#=======
# BOOT
#=======

rm -rf /var/run/starter.charon.pid
ipsec start --nofork


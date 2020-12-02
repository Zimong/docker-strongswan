#! /bin/sh

# update system
apt-get update

# skips interactive dialog for iptables-persistent installer
export DEBIAN_FRONTEND=noninteractive
apt-get -y install strongswan strongswan-plugin-eap-mschapv2 moreutils kmod

#=========== 
# STRONG SWAN CONFIG
#===========

## Create /etc/ipsec.conf

cat << EOF > /etc/ipsec.conf
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    ike=aes256-sha1-modp1024,3des-sha1-modp1024!,aes256-sha2_256
    esp=aes256-sha1,3des-sha1!
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=%any
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightdns=8.8.8.8,8.8.4.4
    rightsourceip=10.0.0.0/24
    authby=secret
EOF

## add secrets to /etc/ipsec.secrets
cat << EOF > /etc/ipsec.secrets

: PSK "SHARED_KEY"
EOF


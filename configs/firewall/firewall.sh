#!/bin/sh

echo "Installing FireWall rules . . ."

iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -t nat -X
iptables -t mangle -X

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -N tcp_filter
iptables -N udp_filter
iptables -N icmp_filter
iptables -N stels_filter

# Filters ===============

iptables -A tcp_filter -p tcp -m conntrack --ctstate INVALID -j REJECT
iptables -A tcp_filter -p tcp -m state --tcp-flags SYN,ACK SYN,ACK --state NEW -j REJECT --reject-with tcp-reset
iptables -A tcp_filter -p tcp ! --syn -m conntrack --ctstate NEW -j REJECT
iptables -A tcp_filter -p tcp -m conntrack --ctstate NEW -j ACCEPT
iptables -A tcp_filter -p tcp -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A tcp_filter -p tcp -j REJECT

iptables -A udp_filter -p udp -j ACCEPT
iptables -A udp_filter -j DROP

iptables -A icmp_filter -p icmp -m conntrack --ctstate INVALID -j REJECT
iptables -A icmp_filter -p icmp --icmp-type 8 -j REJECT --reject-with icmp-host-unreachable
iptables -A icmp_filter -p icmp --icmp-type 0 -j REJECT
iptables -A icmp_filter -p icmp -j ACCEPT

# iptables -A stels_filter -s 192.168.0.0/24 -j ACCEPT
# iptables -A stels_filter -s 192.168.1.0/24 -j ACCEPT
iptables -A stels_filter -m mac --mac-source E0:63:E5:FF:FF:FF -j ACCEPT
iptables -A stels_filter -m mac --mac-source 18:FE:34:FF:FF:FF -j ACCEPT
iptables -A stels_filter -p tcp -j CHAOS --tarpit
iptables -A stels_filter -j DROP

#========================

# NAT ===================

iptables -A FORWARD -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.97.0/24 -j MASQUERADE

#========================

# Start chain ===========

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j icmp_filter

iptables -A INPUT -m mac --mac-source 18:fe:34:ff:ff:09 -j ACCEPT
iptables -A INPUT -m mac --mac-source e0:63:e5:ff:ff:54 -j ACCEPT
iptables -A INPUT -m mac --mac-source 50:e5:49:ff:ff:22 -j ACCEPT

iptables -A INPUT -p tcp --dport 80 -j tcp_filter
iptables -A INPUT -p tcp --dport 443 -j tcp_filter
iptables -A INPUT -p tcp --dport 53 -j tcp_filter
iptables -A INPUT -p udp --dport 53 -j udp_filter
iptables -A INPUT -p udp --dport 67 -j udp_filter
iptables -A INPUT -p udp --dport 68 -j udp_filter
iptables -A INPUT -p tcp --dport 20 -j tcp_filter
iptables -A INPUT -p tcp --dport 21 -j stels_filter
iptables -A INPUT -p tcp --dport 22 -j stels_filter
iptables -A INPUT -p tcp --dport 23 -j stels_filter
iptables -A INPUT -p tcp --dport 25 -j stels_filter
iptables -A INPUT -p tcp -j CHAOS --tarpit
iptables -A INPUT -j DROP

iptables -A OUTPUT -j ACCEPT

#========================
echo "Done."

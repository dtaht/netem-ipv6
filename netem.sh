#!/bin/sh
# Configure netem so that link local packets aren't shaped
# and run at line rate (well, with fq_codel)

IFACE=eth2
NARGS="delay 100ms"
FARGS="noecn limit 800"

ethtool -K $IFACE tso off gso off gro off
TC=`which tc`

tc qdisc del dev $IFACE root 2>/dev/null
#tc -batch <<EOF
$TC qdisc add dev $IFACE root handle 1: prio bands 3
$TC qdisc add dev $IFACE parent 1:1 handle 11: fq_codel $FARGS
$TC qdisc add dev $IFACE parent 1:2 handle 12: netem $NARGS
$TC filter add dev $IFACE protocol all parent 1:0 prio 999 u32 match ip protocol 0 0x00 flowid 1:1
$TC filter add dev $IFACE protocol ip parent 1:0 prio 1 u32 match ip icmp_type 0x08 0xff flowid 1:2
$TC filter add dev $IFACE protocol ip parent 1:0 prio 2 u32 match ip icmp_type 0x00 0xff flowid 1:2
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 3 u32 match ip icmp_type 0x08 0xff flowid 1:2
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 4 u32 match ip icmp_type 0x00 0xff flowid 1:2
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 5 u32 match u16 0xfe80 0xffff at 8 flowid 1:1
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 6 u32 match u16 0xff02 0xffff at 16 flowid 1:1
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 7 u32 match u16 0xfe80 0xffff at 16 flowid 1:1
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 8 u32 match u16 0xff02 0xffff at 8 flowid 1:1
$TC filter add dev $IFACE protocol ip parent 1:0 prio 10 u32 match ip protocol 6 0xff flowid 1:2
#$TC filter add dev $IFACE protocol ip parent 1:0 prio 11 u32 match ip protocol 1 0xff flowid 1:2
$TC filter add dev $IFACE protocol ip parent 1:0 prio 12 u32 match ip protocol 17 0xff flowid 1:2
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 100 u32 match ip protocol 6 0xff flowid 1:2
#$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 101 u32 match ip protocol 1 0xff flowid 1:2
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 102 u32 match ip protocol 17 0xff flowid 1:2
#EOF

exit

tc -batch <<EOF
qdisc add dev $IFACE root handle 1:0 htb default 1
class add dev $IFACE parent 1:0 classid 1:1 htb rate 1500kbit ceil 1500kbit
class add dev $IFACE parent 1:1 classid 1:10 htb rate 450kbit ceil 1500kbit
class add dev $IFACE parent 1:1 classid 1:20 htb rate 900kbit ceil 1470kbit
class add dev $IFACE parent 1:1 classid 1:30 htb rate 150kbit ceil 1470kbit
qdisc add dev $IFACE parent 1:10 handle 11: fq_codel limit 800
qdisc add dev $IFACE parent 1:20 handle 21: fq_codel limit 800
qdisc add dev $IFACE parent 1:30 handle 31: fq_codel limit 800

filter add dev $IFACE protocol ip parent 1:0 prio 10 u32 match ip tos 0xb8 0xfc flowid 1:10
filter add dev $IFACE protocol ip parent 1:0 prio 10 u32 match ip tos 0x88 0xfc flowid 1:20
filter add dev $IFACE protocol ip parent 1:0 prio 10 u32 match ip tos 0x28 0xfc flowid 1:30
filter add dev $IFACE protocol all parent 1:0 prio 999 u32 match ip protocol 0 0x00 flowid 1:0
EOF

eth=eth0

#!/bin/sh
# Configure netem so that link local packets aren't shaped
# and run at line rate (well, with fq_codel)
# One of the things that http://www.lartc.org/lartc.html
# makes very unclear is that they are matching against
# 6in4 packets, not ipv6 packets. This matches against
# native ipv6.

. ./test_setup.inc

TC=

# My problem with using prio for this is that its 
# dependent on the granuality of timestamping in netem
# DRR or (better) SFQ makes more sense but what we
# really want is a FIFO in, spread out, and whatever
# packet is the "Readiest to be delivered", delivered

delay() {
IFACE=$1
tc qdisc del dev $IFACE root 2>/dev/null
tc -batch <<EOF
$TC qdisc add dev $IFACE root handle 1: prio bands 10
$TC qdisc add dev $IFACE parent 1:1 handle 11: $N $S1_ARGS
$TC qdisc add dev $IFACE parent 1:2 handle 12: $N $S2_ARGS
$TC qdisc add dev $IFACE parent 1:3 handle 13: $N $S3_ARGS
$TC qdisc add dev $IFACE parent 1:4 handle 14: $N $S4_ARGS
$TC qdisc add dev $IFACE parent 1:5 handle 15: $N $S5_ARGS
$TC qdisc add dev $IFACE parent 1:6 handle 16: $N $S6_ARGS
$TC qdisc add dev $IFACE parent 1:7 handle 17: $N $S7_ARGS
$TC qdisc add dev $IFACE parent 1:8 handle 18: $N $S8_ARGS 
$TC qdisc add dev $IFACE parent 1:9 handle 19: $N $S9_ARGS
$TC qdisc add dev $IFACE parent 1:a handle 1a: fq_codel
$TC filter add dev $IFACE protocol all parent 1:0 prio 999 u32 match ip protocol 0 0x00 flowid 1:a
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 5 u32 match u16 0xfe80 0xffff at 8 flowid 1:a
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 6 u32 match u16 0xff02 0xffff at 24 flowid 1:a
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 7 u32 match u16 0xfe80 0xffff at 24 flowid 1:a
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 8 u32 match u16 0xff02 0xffff at 8 flowid 1:a
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 101 u32 $MS match u8 0x01 0xff at 23 flowid 1:1
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 102 u32 $MS match u8 0x02 0xff at 23 flowid 1:2
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 103 u32 $MS match u8 0x03 0xff at 23 flowid 1:3
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 104 u32 $MS match u8 0x04 0xff at 23 flowid 1:4
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 105 u32 $MS match u8 0x05 0xff at 23 flowid 1:5
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 106 u32 $MS match u8 0x06 0xff at 23 flowid 1:6
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 107 u32 $MS match u8 0x07 0xff at 23 flowid 1:7
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 108 u32 $MS match u8 0x08 0xff at 23 flowid 1:8
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 109 u32 $MS match u8 0x09 0xff at 23 flowid 1:9
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 110 u32 $MS match u8 0x0a 0xff at 23 flowid 1:a
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 201 u32 $MD match u8 0x01 0xff at 39 flowid 1:1
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 202 u32 $MD match u8 0x02 0xff at 39 flowid 1:2
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 203 u32 $MD match u8 0x03 0xff at 39 flowid 1:3
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 204 u32 $MD match u8 0x04 0xff at 39 flowid 1:4
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 205 u32 $MD match u8 0x05 0xff at 39 flowid 1:5
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 206 u32 $MD match u8 0x06 0xff at 39 flowid 1:6
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 207 u32 $MD match u8 0x07 0xff at 39 flowid 1:7
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 208 u32 $MD match u8 0x08 0xff at 39 flowid 1:8
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 209 u32 $MD match u8 0x09 0xff at 39 flowid 1:9
$TC filter add dev $IFACE protocol ipv6 parent 1:0 prio 210 u32 $MD match u8 0x0a 0xff at 39 flowid 1:a
EOF
}

setup() {
IFACE=$1
ethtool -K $IFACE tso off gso off gro off
$INSMOD ifb
$INSMOD act_mirred
$INSMOD sch_netem
}

redir() {
IFACE=$1
DEV=$2
tc qdisc del dev $IFACE handle ffff: ingress 2> /dev/null
tc qdisc add dev $IFACE handle ffff: ingress
ifconfig $DEV up
tc filter add dev $IFACE parent ffff: protocol all prio 10 u32 \
   match u32 0 0 action mirred egress redirect dev $DEV
}

case $1 in
	up) setup $2; delay $2; delay ifb0; redir $2 ifb0;;
	down) tc qdisc del dev $2 ingress; tc qdisc del dev $2 root; tc qdisc del dev ifb0 root;;
	*) echo "$0 up/down interface" "args incorrect $*"
esac

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

#!/bin/sh
# Setup a server

. ./test_setup.inc

updn() {
IFACE=$1
arg=$2

ip -6 addr $arg $S1/128 dev $IFACE
ip -6 addr $arg $S2/128 dev $IFACE
ip -6 addr $arg $S3/128 dev $IFACE
ip -6 addr $arg $S4/128 dev $IFACE
ip -6 addr $arg $S5/128 dev $IFACE
ip -6 addr $arg $S6/128 dev $IFACE
ip -6 addr $arg $S7/128 dev $IFACE
ip -6 addr $arg $S8/128 dev $IFACE
ip -6 addr $arg $S9/128 dev $IFACE
}

gen_hosts() {
echo $S1 `echo $S1_ARGS | sed 's/ /-/g'`
echo $S2 `echo $S2_ARGS | sed 's/ /-/g'`
echo $S3 `echo $S3_ARGS | sed 's/ /-/g'`
echo $S4 `echo $S4_ARGS | sed 's/ /-/g'`
echo $S5 `echo $S5_ARGS | sed 's/ /-/g'`
echo $S6 `echo $S6_ARGS | sed 's/ /-/g'`
echo $S7 `echo $S7_ARGS | sed 's/ /-/g'`
echo $S8 `echo $S8_ARGS | sed 's/ /-/g'`
echo $S9 `echo $S9_ARGS | sed 's/ /-/g'`
}

case $1 in
	up) updn add ;;
	down) updn del ;;
	restart) updn del; updn up;;
	hosts) gen_hosts;;
	*) echo $0 up or down
esac

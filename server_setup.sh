#!/bin/sh
# Setup a server

IFACE=lo

. ./test_setup.inc

updn() {
arg=$1
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

case $1 in
	up) updn add ;;
	down) updn del ;;
	restart) updn del; updn up;;
	*) $0 up or down
esac

#!/bin/sh
# Configure netem so that link local packets aren't shaped
# and run at line rate (well, with fq_codel)

# My web emulation server prefixes
P=2001:470:8236:1ee1

# To make my life easier and since I 
# Thank god my prefix is decimal

MS="match u32 0x20010470 0xffffffff at 8 \
     match u32 0x82361ee1 0xffffffff at 12"

MD="match u32 0x20010470 0xffffffff at 24 \
     match u32 0x82361ee1 0xffffffff at 28"

export MS MD
N=netem
INSMOD=modprobe
FARGS="noecn limit 800"
DNS=$P::1
NFLIX=$P::8

S1=$P::1
S2=$P::2
S3=$P::3
S4=$P::4
S5=$P::5
S6=$P::6
S7=$P::7
S8=$P::8
S9=$P::9

S1_ARGS="delay 5ms"
S2_ARGS="delay 10ms"
S3_ARGS="delay 15ms"
S4_ARGS="delay 20ms"
S5_ARGS="delay 25ms"
S6_ARGS="delay 30ms"
S7_ARGS="delay 35ms"
S8_ARGS="delay 40ms"
S9_ARGS="delay 50ms"
SA_ARGS="noecn"

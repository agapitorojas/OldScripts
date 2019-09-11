#!/bin/bash

GROUPS="$(/usr/bin/id -Gn sma |tr -s ' ' ',')"

/usr/sbin/groupadd -g 5000 suporteunix && \
/usr/sbin/useradd -c "631/C/*DPBRLA//DPE_BR_LASA/" -u 5001 -g suporteunix -G $(/usr/bin/id -Gn sma |tr -s ' ' ',') arojas && \
echo r0ux1n0l |/usr/bin/passwd --stdin arojas && \
echo OK
#!/bin/bash

if ( which vmware-checkvm >/dev/null 2>&1 ); then
    if ( vmware-checkvm >/dev/null 2>&1 ); then
        echo VMware
        exit 0
    fi
else
    dmidecode -t 9 |grep -B2 -i 'in use' |sed 's/^[ \t]*//g'
fi
#!/bin/sh

# this script installs the polybar module earthquake

destdir=${HOME}/.config/polybar/scripts/earthquake
polybar_conf=${HOME}/.config/polybar/config

install -d ${destdir}
install -b -m 644 *.conf ${destdir}
install -m 554 earthquake.sh ${destdir}

if [ -f ${polybar_conf} ]; then
    cat polybar.conf >> ${polybar_conf}
else
    echo "Add the following lines to your polybar configuration:"
    cat polybar.conf
fi

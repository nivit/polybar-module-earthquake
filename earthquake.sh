#!/usr/bin/env bash
#
# title: Polybar Module - Earthquake
# project-home: https://github.com/nivit/polybar-module-earthquake
# license: MIT

##################
# default values #
##################

debug=0

# program to download USGS data
fetch_cmd=/usr/bin/curl

earthquake_conf=${HOME}/.config/polybar/module/earthquake/earthquake.conf

google_maps_url='https://maps.google.com/maps/@'

jq_cmd=/usr/bin/jq  # program to parse USGS data

# alert on an earthquake with a magnitude greater than that
min_magnitude=4

# satellite view in Google maps
satellite_view=1

tsunami_alert=1

usgs_url='https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_h    our.geojson'

# zoom factor on Google maps
zoom_factor=8

xdg_cmd=/usr/bin/xdg-open


################

earthquake='-- no earthquake data --'

# override default values
if [ -f ${earthquake_conf} ]; then
    . ${earthquake_conf}
fi

# check availability of the requested programs
if ! fetch_cmd_loc="$(type -p "${fetch_cmd}")" || \
    [[ -z ${fetch_cmd_loc} ]]; then
    echo "-- ${fetch_cmd} not installed!";
    exit 1
fi

if ! jq_cmd_loc="$(type -p "${jq_cmd}")" || \
    [[ -z ${jq_cmd_loc} ]]; then
    echo "-- ${jq_cmd} not installed!";
    exit 1
fi

echo ${earthquake}

# vi:expandtab softtabstop=4 smarttab shiftwidth=4 tabstop=4

#!/usr/bin/env bash
#
# title: Polybar Module - Earthquake
# project-home: https://github.com/nivit/polybar-module-earthquake
# license: MIT

##################
# default values #
##################

debug=0

module_dir=${HOME}/.config/polybar/module/earthquake
# program to download USGS data
fetch_cmd=fetch  # FreeBSD

earthquake_conf=${module_dir}/earthquake.conf

earthquake_mode=latest  # or max

earthquakes_json=${module_dir}/last_earthquakes.json

google_maps_url='https://maps.google.com/maps/@'

jq_cmd=jq  # program to parse USGS data

magnitude1_color="#8f9d6a"
magnitude2_color="#838184"
magnitude3_color="#9b703f"
magnitude4_color="#f9ee98"
magnitude_color="#cf6a4c"  # magnitude > 4

# alert on an earthquake with a magnitude greater than that
#min_magnitude=1

# satellite view in Google maps
satellite_view=yes  # or no

tsunami_alert=1
tsunami_icon="⚠ "

underline_title="yes"

usgs_url='https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_hour.geojson'

# zoom factor on Google maps
zoom_factor=8

xdg_cmd=xdg-open

################

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

# select the correct silent option for the fetch command
case "${fetch_cmd}" in
    "fetch" | "wget" )
       fetch_options="-q"
    ;;
    "curl" )
        fetch_options="-s"
    ;;
esac

if ! jq_cmd_loc="$(type -p "${jq_cmd}")" || \
    [[ -z ${jq_cmd_loc} ]]; then
    echo "-- ${jq_cmd} not installed!";
    exit 1
fi

if ! xdg_cmd_loc="$(type -p "${xdg_cmd}")" || \
    [[ -z ${xdg_cmd_loc} ]]; then
    echo "-- ${xdg_cmd} not installed!";
    exit 1
fi

# download USGS data
if [ -z "$1" -o ! -f "${earthquakes_json}" -a "${debug}" = "0" ]; then
    ${fetch_cmd} -o ${earthquakes_json} \
        ${fetch_options}  ${usgs_url}
fi

no_data='-- no earthquake data --'

if [ ! -s ${earthquake_json} ]; then
    echo ${no_data}
    exit 1
fi

if [ ! -z "$1" ]; then
    case "$1" in
        "open-google-map")
            coords=$(${jq_cmd} -c -M -f ${module_dir}/earthquake.jq --arg get coords --arg what ${earthquake_mode} \
                ${earthquakes_json} | tr '\n' ',')

            if [ "${satellite_view}" = "yes" ]; then
                url="${google_maps_url}${coords}${zoom_factor}z/data=!3m1!1e3"
            else
                url="${google_maps_url}${coords}${zoom_factor}z"
            fi

            ${xdg_cmd} ${url}&

            exit 0
        ;;
        "open-event-page")
            url="$(${jq_cmd} -r -M -f ${module_dir}/earthquake.jq --arg get url --arg what ${earthquake_mode} \
                ${earthquakes_json})"
            ${xdg_cmd} ${url}&
            exit 0
        ;;
        "toggle-earthquake-type")
            if [ "${earthquake_mode}" = "latest" ]; then
                earthquake_mode=max
            else
                earthquake_mode=latest
            fi

            sed -i.bak -e "s/^\(earthquake_mode=\).*/\1${earthquake_mode}/" \
                ${module_dir}/earthquake.conf
        ;;
        *)
            echo "-- unknown argument --"
            exit 0
        ;;
    esac
else
    if [ "${tsunami_alert}" = "yes" ]; then
        tsunami=$(${jq_cmd} -r -M -f ${module_dir}/earthquake.jq --arg get tsunami --arg what ${earthquake_mode} ${earthquakes_json})
        if [ "${tsunami}" = "1" ]; then
            tsunami_msg=" %{B#f00 F#fff}-- ${tsunami_icon} TSUNAMI ALERT --"
        fi
    else
        tsunami_msg=""
    fi

    if [ "X${underline_title}X" = "XyesX" ]; then
        mag=$(${jq_cmd} -r -M -f ${module_dir}/earthquake.jq --arg get mag --arg what ${earthquake_mode} ${earthquakes_json})

        case "${mag%%.*}" in
            "1")
                underline_color=${magnitude1_color}
                ;;
            "2")
                underline_color=${magnitude2_color}
                ;;
            "3")
                underline_color=${magnitude3_color}
                ;;
            "4")
                underline_color=${magnitude4_color}
                ;;
            *)
                underline_color=${magnitude_color}
        esac

        underline_format="%{u${underline_color} +u}"
    else
        underline_format=""
    fi

    title=$(${jq_cmd} -r -M -f ${module_dir}/earthquake.jq --arg get title --arg what ${earthquake_mode} ${earthquakes_json})

    echo ${underline_format}${title}${tsunami_msg}

    exit 0
fi

# vi:expandtab softtabstop=4 smarttab shiftwidth=4 tabstop=4

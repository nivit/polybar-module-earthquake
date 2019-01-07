#!/usr/bin/env bash
#
# title: Polybar Module - Earthquake
# project-home: https://github.com/nivit/polybar-module-earthquake
# license: MIT

##################
# default values #
##################

debug=0

# how many seconds to wait before downloading new data
download_interval=300

# program to download USGS data
fetch_cmd=curl  # (curl|fetch|wget)

# what earthquake to show
earthquake_mode=all  # (all|latest|max)

# see https://www.fileformat.info/info/unicode/char/1f703/fontsupport.htm
#earth_icon="🜃"  # Unicode Character 'ALCHEMICAL SYMBOL FOR EARTH' (U+1F703)
# see https://www.fileformat.info/info/unicode/char/1f30d/fontsupport.htm
#earth_icon="🌍"  # Unicode Character 'EARTH GLOBE EUROPE-AFRICA' (U+1F30D)
# see https://www.fileformat.info/info/unicode/char/2637/fontsupport.htm
earth_icon="☷ "  # Unicode Character 'TRIGRAM FOR EARTH' (U+2637)
# see https://www.fileformat.info/info/unicode/char/2641/fontsupport.htm
#earth_icon="♁"  # Unicode Character 'EARTH' (U+2641)


# underline color
magnitude1_color="#8f9d6a"
magnitude2_color="#838184"
magnitude3_color="#9b703f"
magnitude4_color="#f9ee98"
magnitude_color="#cf6a4c"  # magnitude > 4

# satellite view in Google maps
satellite_view=yes  # or no

show_icon="yes"
show_time="yes"

tsunami_alert=1
# see https://www.fileformat.info/info/unicode/char/2635/fontsupport.htm
tsunami_icon="☵"  # Unicode Character 'TRIGRAM FOR WATER' (U+2635)
# see https://www.fileformat.info/info/unicode/char/26a0/fontsupport.htm
#tsunami_icon="⚠ " # Unicode Character 'WARNING SIGN' (U+26A0)
# see https://www.fileformat.info/info/unicode/char/1f30a/fontsupport.htm
#tsunami_icon="🌊 "  # Unicode Character 'WATER WAVE' (U+1F30A)

underline_title="yes"

# zoom factor on Google maps
zoom_factor=8

xdg_cmd=xdg-open

################
# start script #
################

module_dir=${HOME}/.config/polybar/scripts/earthquake
module_obj_dir=${module_dir}/obj
current_earthquake=${module_obj_dir}/current_earthquake.id
earthquake_conf=${module_dir}/earthquake.conf
earthquakes_ids=${module_obj_dir}/earthquakes.ids
earthquakes_json=${module_obj_dir}/last_earthquakes.json
last_download=${module_obj_dir}/last_download_time

google_maps_url='https://maps.google.com/maps/@'
usgs_url='https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_hour.geojson'

if [ ! -f "${module_obj_dir}" ]; then
    mkdir -p "${module_obj_dir}"
fi

# override default values
if [ -f "${earthquake_conf}" ]; then
    # shellcheck source=news.conf disable=SC1091
    . "${earthquake_conf}"
fi

# check availability of the requested programs
if ! fetch_cmd_loc="$(type -p "${fetch_cmd}")" || \
    [[ -z ${fetch_cmd_loc} ]]; then
    echo "-- ${fetch_cmd} not installed!";
    exit 0
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

if ! jq_cmd_loc="$(type -p "jq")" || \
    [[ -z ${jq_cmd_loc} ]]; then
    echo "-- jq not installed!";
    exit 0
fi

if ! xdg_cmd_loc="$(type -p "${xdg_cmd}")" || \
    [[ -z ${xdg_cmd_loc} ]]; then
    echo "-- ${xdg_cmd} not installed!";
    exit 0
fi

if [ -f "${last_download}" ]; then
    old_time=$(cat "${last_download}")
    new_time=$(date +%s)

    delta_time=$((new_time - old_time))

    if [ ${delta_time} -gt ${download_interval} ]; then
        rm -f "${last_download}"
    fi
fi

# download USGS data
if [ ! -f "${last_download}" ]; then
    if [ "${debug}" = "1"  ] &&
       [ -f "${earthquakes_json}".test ]; then
        cp "${earthquakes_json}".test "${earthquakes_json}"
    else
        ${fetch_cmd} -o "${earthquakes_json}" "${fetch_options}" "${usgs_url}"
    fi

    # extract earthquakes ids
    jq -r -M '.features[]|.id' "${earthquakes_json}" > "${earthquakes_ids}"
    cp "${earthquakes_ids}" "${earthquakes_ids}".all

    date +%s > "${last_download}"
fi

# check whether there are earthquakes in the last hour
if [ -f "${earthquakes_json}" ]; then
    no_data=$(jq -r -M 'if .metadata.count > 0 then 1 else 0 end' "${earthquakes_json}")

    if [ ! -s "${earthquakes_json}" ] || \
       [ "${no_data}" = "0" ]; then
        echo '-- no earthquake data --'
        exit 0
    fi
fi

if [ -n "$1" ]; then
    current_id=$(cat "${current_earthquake}")
else
    current_id=$(head -n 1 "${earthquakes_ids}" | tee "${current_earthquake}")
    sed -i.bak -e '1d' "${earthquakes_ids}"

    if [ ! -s "${earthquakes_ids}" ] && \
       [ -f "${earthquakes_ids}".all ]; then
        cp -f "${earthquakes_ids}".all "${earthquakes_ids}"
    fi
fi

# jq (partial) filters
case "${earthquake_mode}" in
    "all")
        jq_args="-r -M --arg id ${current_id}"
        # shellcheck disable=SC2016
        jq_selector='.features[]|select(.id==$id?)|'
        ;;
    "latest")
        jq_args="-r -M --arg id unknown"
        jq_selector='first(.features[])|'
        ;;
    "max")
        jq_args="-r -M --arg id unknown"
        jq_selector='.features|max_by(.properties.mag)|'
        ;;
esac


if [ -n "$1" ]; then
    case "$1" in
        "open-google-map")
            # shellcheck disable=SC2086
            coords=$(jq ${jq_args} ${jq_selector}'[.geometry.coordinates[1,0]?] | tostring | ltrimstr("[") | rtrimstr("]")' \
                "${earthquakes_json}")

            if [ "${satellite_view}" = "yes" ]; then
                url="${google_maps_url}${coords},${zoom_factor}z/data=!3m1!1e3"
            else
                url="${google_maps_url}${coords},${zoom_factor}z"
            fi

            ${xdg_cmd} "${url}"&

            exit 0
        ;;
        "open-event-page")
            # shellcheck disable=SC2086
            url=$(jq ${jq_args} ${jq_selector}.properties.url ${earthquakes_json})
            ${xdg_cmd} "${url}"&
            exit 0
        ;;
        "toggle-earthquake-mode")
            if [ "${earthquake_mode}" = "latest" ]; then
                earthquake_mode=max
            elif [ "${earthquake_mode}" = "max" ]; then
                earthquake_mode=all
            elif [ "${earthquake_mode}" = "all" ]; then
                earthquake_mode=latest
            fi

            sed -i.bak -e "s/^\\(earthquake_mode=\\).*/\\1${earthquake_mode}/" \
                "${earthquake_conf}"
        ;;
        *)
            echo "-- unknown argument --"
            exit 0
        ;;
    esac
else
    if [ "${tsunami_alert}" = "yes" ]; then
        # shellcheck disable=SC2086
        tsunami=$(jq ${jq_args} ${jq_selector}.properties.tsunami ${earthquakes_json})
        if [ "${tsunami}" = "1" ]; then
            tsunami_msg=" %{B#f00 F#fff}-- ${tsunami_icon} TSUNAMI ALERT --"
        fi
    else
        tsunami_msg=""
    fi

    if [ "X${underline_title}X" = "XyesX" ]; then
        # shellcheck disable=SC2086
        mag=$(jq ${jq_args} ${jq_selector}.properties.mag ${earthquakes_json})

        case "${mag%%.*}" in
            "0"|"1")
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

    # shellcheck disable=SC2086
    title=$(jq ${jq_args} ${jq_selector}.properties.title ${earthquakes_json})

    if [ "X${show_icon}X" = "XyesX" ]; then
        icon="${earth_icon} "
    else
        icon=""
    fi

    if [ "X${show_time}X" = "XyesX" ]; then
        # shellcheck disable=SC2086
        time=" - $(jq ${jq_args} ${jq_selector}'(.properties.time?/1000|todate)' "${earthquakes_json}")"
    else
        time=""
    fi

    echo "${underline_format}${icon}${title}${tsunami_msg}${time}"

    exit 0
fi

# vi:expandtab softtabstop=4 smarttab shiftwidth=4 tabstop=4

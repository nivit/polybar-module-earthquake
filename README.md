# Polybar Module - Earthquake

## Description
This [polybar](https://github.com/jaagr/polybar)  module shows magnitude, location and time of the latest seismic event on Earth.

For more information about which earthquakes are shown, see  [ComCat Documentation - Data Availability](https://earthquake.usgs.gov/data/comcat/data-availability.php).

## Screenshots

<img alt="Screenshot of polybar module: earthquake" src="screenshots/polybar-module-earthquake.png" width="643">

*Output of this script*

<img alt="USGS event page for earthquake with id ci38412120" src="screenshots/usgs-ci38412120-event-page.png" width="643">

*USGS event page - [M 1.5 - 13km SSW of Big Bear Lake, CA](https://earthquake.usgs.gov/earthquakes/eventpage/ci38412120/executive) (mouse left click)*

<img alt="Location of the event on Google Maps" src="screenshots/usgs-ci38412120-google-map.png" width="643">

*Location of the seismic event on Google Maps (mouse right click)*

## Installation
Clone or download this repository, then run the following commands:
```
$ cd polybar-module-earthquake  # directory where you clone the repository or unzip the release file
$ sh install.sh
```
Enable this module in your bar, e.g:
```
[bar/mybar]
...
modules-left = earthquake ...
```

Finally, restart polybar.

## Dependencies
This script requires [bash](https://www.gnu.org/software/bash/), [jq](https://stedolan.github.com/jq/) for parsing data, and [curl](https://curl.haxx.se/) or [wget](https://www.gnu.org/s/wget/) for downloading data.

## Configuration
You can change the behavior of this module, by editing the following files:
- `~/.config/polybar/scripts/earthquake/earthquake.conf` (for appearence and behavior of the script);
- `~/config/polybar/scripts/earthquakes/module.conf` (for binding to mouse buttons).

## Running
By default the module cyclically shows magnitude, title and time of the seismic events in the last hour. You can change this behavior by clicking with the middle button of your mouse on the bar. So the bar will show the latest earthquake and, after another middle click, the event with max magnitude, and so on.

## License
This software is licensed under the MIT license. See [LICENSE](LICENSE.md).

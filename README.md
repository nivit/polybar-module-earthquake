# Polybar Module - Earthquake

## Description
This [polybar](https://github.com/jaagr/polybar)  module shows magnitude, location and time of the latest seismic event on Earth.

For more information about which earthquakes are shown, see  [ComCat Documentation - Data Availability](https://earthquake.usgs.gov/data/comcat/data-availability.php).

## Screenshots

Output of this script

<img alt="Screenshot of polybar module: earthquake" src="screenshots/polybar-module-earthquake.png" width="643">

*Output of this script*

<img alt="USGS event page for earthquake with id ci38412120" src="screenshots/usgs-ci38412120-event-page.png" width="643">

*USGS event page - [M 1.5 - 13km SSW of Big Bear Lake, CA](https://earthquake.usgs.gov/earthquakes/eventpage/ci38412120/executive)*

<img alt="Location of the event on Google Maps" src="screenshots/usgs-ci38412120-google-map.png" width="643">

*Location of the seismic event on Google Maps*

## Installation
Clone or download this repository, then run the following commands:
```
$ cd polybar-module-earthquake
$ sh install.sh
```
Enable this module in your bar, e.g:
```
[bar/mybar]
...
modules-left = earthquake ...
```

Finally, restart polybar.

## License
This software is licensed under the MIT license. See [LICENSE](LICENSE.md)

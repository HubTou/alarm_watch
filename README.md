# alarm_watch
A [Luanti](https://www.luanti.org/) client-side mod implementing a [vintage alarm watch](https://www.casio.com/fr/watches/casio/product.F-91W-1/) mutated into a smartwatch.

## Features
* Watch
  * displays the time in 12 or 24h format
* Programmable alarm
  * with [vintage ring](https://pixabay.com/sound-effects/alarm-beep-electronic-91914/) sound and custom message
* Chronometer
  * in game time or real world time
* Light sensor
  * with message and [crowing rooster](https://pixabay.com/sound-effects/rooster-233738/) sound at sunrise (05:45)
  * with message and [hooting owl](https://pixabay.com/sound-effects/owl-hooting-left-to-right-stereo-240676/) sound at sunset (19:30)
* GPS
  * displays location in geographical (latitude/longitude) or Cartesian coordinates (x/z)
* Altimeter
  * y-coordinate (for ores and jewels mining) 
* Compass
  * with cardinal direction faced and angle in degrees
* Discreet head-up display
  * with ability to disable watch, GPS, altimeter and/or compass
  * and backlit lighting (for dark areas)
* Fully configurable
  * with Luanti User Interface
  * or through local chat commands   

## Installation
0. Download this client-side mod
1. [Follow general instructions for enabling client-side mods, installation and activation](https://wiki.minetest.net/Installing_Client-Side_Mods).
2. Copy the *luanti/clientmods/alarm_watch/sounds* folder into *luanti*

## Configuration
* Before launching a game, configure the mod options through Luanti's User Interface:

* While playing, use the following commands for live (but non-persistent) configuration:

For enabling or disabling instruments (only specify one):
```
.alarm_use watch|light_sensor|gps|altimeter|compass
```

For flipping the instruments configuration (only specify one):
```
.alarm_mode watch|gps|chrono
```

## Usage
For setting the alarm at a given hour:minute and with a specified message (which may be a whole sentence):
```
.alarm_set H:M TEXT
```

For disabling the previously setted alarm, use one of the following commands:
```
.alarm_unset
.alarm_reset
```

To start or stop the chronometer (stopwatch):
```
.alarm_chrono
```

To enable/disable the backlit lighting:
```
.alarm_light
```

Get command help ingame with:
```
.help
```

## Caveats
There are still a few issues with this mod:
* Despite providing translations, they are unused (I believe client-side mods don't use translations at all),
* The chronometer results will be incorrect if players go to bed for sleeping, or if time is changed by an admin,
* [local chat commands are uselessly echoed by the game](https://forum.luanti.org/viewtopic.php?t=31183).

## Credits
### Debugging
* [Compass debugging](https://forum.luanti.org/viewtopic.php?t=31167) by [Blockhead](https://forum.luanti.org/memberlist.php?mode=viewprofile&u=24958)

### Music credits:
I have bundled these "Free for use" sounds from [Pixabay](https://pixabay.com/):
* [alarm beep electronic](https://pixabay.com/sound-effects/alarm-beep-electronic-91914/) by reecord2 of [freesound_community](https://pixabay.com/users/freesound_community-46691455/)
* [Rooster](https://pixabay.com/sound-effects/rooster-233738/) by [Stefan_Grace](https://pixabay.com/users/stefan_grace-8153913/)
* [Owlhooting left to right](https://pixabay.com/sound-effects/owl-hooting-left-to-right-stereo-240676/) by [TanwerAman](https://pixabay.com/users/tanweraman-29554143/)

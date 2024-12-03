# alarm_watch
A [Luanti](https://www.luanti.org/) client-side mod implementing a [vintage alarm watch](https://www.casio.com/fr/watches/casio/product.F-91W-1/) mutated into a smartwatch.

Examples of Head-Up Display, showing watch, GPS, altimeter and compass instruments, with backlit on the second screenshot:

![Normal HUD](https://github.com/HubTou/alarm_watch/blob/main/screenshots/normal_hud.png)
![Alternative HUD](https://github.com/HubTou/alarm_watch/blob/main/screenshots/alternative_hud.png)

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
  * displays location in [geographical](https://en.wikipedia.org/wiki/Geographic_coordinate_system) (latitude/longitude) or Cartesian coordinates (x/z)
* Altimeter
  * y-coordinate (for ores and jewels mining) 
* Compass
  * with cardinal direction faced and angle in degrees
* Discreet head-up display in the lower-left corner of the screen
  * with ability to disable watch, GPS, altimeter and/or compass (only keep what you really need)
  * and backlit lighting (for dark areas)
* Fully configurable
  * with Luanti User Interface
  * or through local chat commands   

## Installation
1. Manually download the [latest release](https://github.com/HubTou/alarm_watch/releases) of this mod (as client-side mods download is not handled yet through Luanti's User Interface)
2. Follow general instructions on [client-side mods installation](https://wiki.minetest.net/Installing_Client-Side_Mods):

   * Put the following line in *luanti/minetest.conf* to enable client-side mods (if not already done):
      ```
      enable_client_modding = true
      ```
      
   * Unpack the mod archive in *luanti/clientmods*
   * Rename the mod directory to *luanti/clientmods/alarm_watch*
   * Put the following line in *luanti/clientmods/mods.conf*:
      ```
      load_mod_alarm_watch = true
      ```
3. Copy the *luanti/clientmods/alarm_watch/sounds* folder into *luanti*

Note: If you haven't upgraded yet to luanti 5.10.0 or newer, your *luanti* directory will be called *minetest*...

## Configuration
* Before launching a game, configure the mod options through Luanti's User Interface:
![Configuration in UI](https://github.com/HubTou/alarm_watch/blob/main/screenshots/config.png)

* While playing, use the following commands for live (but non-persistent) configuration:
  * For enabling or disabling instruments (only specify one):
    ```
    .alarm_use watch|light_sensor|gps|altimeter|compass
    ```
  * For flipping the instruments configuration (only specify one):
    ```
    .alarm_mode watch|gps|chrono
    ```

## Usage
For setting the alarm at a given hour:minute and with a specified message (which may be a whole sentence) do:
```
.alarm_set H:M TEXT
```

For example:
```
.alarm_set 17:30 Time to go home before nightfall!
```

For disabling the previously setted alarm, use one of the following commands:
```
.alarm_unset
.alarm_reset
```

To start or stop the chronometer (stopwatch) do:
```
.alarm_chrono
```

To enable/disable the backlit lighting do:
```
.alarm_light
```

To obtain in game command help do:
```
.help
```

or one among:
```
.help alarm_use
.help alarm_mode
.help alarm_set
.help alarm_unset
.help alarm_reset
.help alarm_chrono
.help alarm_light
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

## Possible future directions
The mod is already pretty complete as-is, but drilling down the "smartwatch" concept, there are lots of other possible evolutions:
* Configuration:
  * configurable colors
* GPS improvement:
  * points or areas of interest management (with another HUD)
  * guidance to those waypoints (on this mod's HUD)
* New pedometer instrument for counting steps and elevation per day
* More stats...

Other possible things that would probably better be kept separated from this mod:
* Music player to be used with music records you carry (with another HUD) 
* Death tracker:
  * I have another (not yet published) client-side mod for tracking death locations (that could be integrated with the waypoint system), but that I want to keep separated as it's working with a server-side complementary mod.
* Chat recorder / exporter / translator:
  * I'm also interested in studying a chat recorder, exporter or translator using local [LibreTranslate](https://github.com/LibreTranslate/LibreTranslate) but it's also probably better to keep that separated because of this heavy dependency...

Go to [Discussions](https://github.com/HubTou/alarm_watch/discussions) if you want to suggest other things...

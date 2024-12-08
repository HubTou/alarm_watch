--[[
alarm_watch - A vintage alarm watch mutated into a smartwatch
License: 3-clause BSD (see https://opensource.org/licenses/BSD-3-Clause)
Author: Hubert Tournier
--]]

local mod_name = assert(core.get_current_modname())
local S = core.get_translator(mod_name)
dofile(core.get_modpath(mod_name) .. "/library.lua")

local config = {
	show_watch = core.settings:get("alarm_watch_show_watch") or true,
	watch_display = core.settings:get("alarm_watch_watch_display") or "24h", -- or "12h"
	use_light_sensor = core.settings:get("alarm_watch_use_light_sensor") or true,
	chrono_display = core.settings:get("alarm_watch_chrono_display") or "game_time", -- or "real_time"
	show_gps = core.settings:get("alarm_watch_show_gps") or true,
	gps_display = core.settings:get("alarm_watch_gps_display") or "geographical", -- or "cartesian"
	show_altimeter = core.settings:get("alarm_watch_show_altimeter") or true,
	show_compass = core.settings:get("alarm_watch_show_compass") or true
}

local playerinfo_allowed = true 
local hud = nil
local alarm = nil
local chrono = nil
local time_speed = nil
local light = false
local last_minute = 1

core.register_on_mods_loaded(function()
	--	Check restrictions on client-side mods usage
	local csm_restrictions = core.get_csm_restrictions()
	
	if csm_restrictions.load_client_mods then
		print(core.colorize("red", S("Loading client-side mods is disabled by the server")))
	else
		if csm_restrictions.read_playerinfo then
			print(core.colorize("orange", S("Client-side mod '@1' loaded but server restricts reading player info", mod_name)))
			print(core.colorize("orange", S("GPS, altimeter and compass will be disabled")))
			playerinfo_allowed = false
			config.show_gps = false
			config.show_altimeter = false
			config.show_compass = false
		else
			print(core.colorize("palegreen", S("Client-side mod '@1' loaded", mod_name)))
		end
	end

	-- Get the duration of a game day in real time
	time_speed = core.settings:get("time_speed")
	if not time_speed then
		print(S("ERROR: Unable to get 'time_speed' setting. Assuming 72 value"))
		time_speed = 72 -- 1 day in game = 20 minutes in real time
	end
end)

-- Initialize the Head-UP display
-- with 1 attempt per second during the first 10 seconds after connection
-- as core.localplayer is not immediately initialized...
for i=1,10 do
	core.after(i, function()
		-- Create a HUD displaying (if enabled) watch, GPS, altimeter and compass
		-- See documentation on https://api.minetest.net/hud/
		if not hud and core.localplayer then
			hud = core.localplayer:hud_add({
				name = "Alarm watch",
				type = "text",
				position = {x=0, y=1},
				offset = {x=8, y=-8},
				number = colorspec_to_number("red"),
				alignment = {x=1, y=-1},
				text = ""
			})
		end
	end)
end

core.register_globalstep(function(dtime)
	-- Regularly change the watch, GPS, altimeter and compass display. And raise alarms
	local watch_text = nil
	local gps_text = nil
	local altimeter_text = nil
	local compass_text = nil
	
	if config.show_watch then
		local hour, minute = time_of_day()
		
		if config.watch_display == "24h" then
			watch_text = string.format("%02d:%02d", hour, minute)
		elseif hour == 0 then
			watch_text = string.format("12:%02d %s", minute, S("a.m."))
		elseif hour < 12 then
			watch_text = string.format("%02d:%02d %s", hour, minute, S("a.m."))
		elseif hour == 12 then
			watch_text = string.format("12:%02d %s", hour, minute, S("p.m."))
		else
			watch_text = string.format("%02d:%02d %s", hour - 12, minute, S("p.m."))
		end

		if config.use_light_sensor then
			if hour == 5 and minute == 45 then
				if minute ~= last_minute then
					print(core.colorize("gold", S("The sun has risen")))
					-- The following sound has to be installed in a "sounds" sub-directory of your Luanti client
					core.sound_play("alarm_watch_rooster")
					-- The following sound is included with the VoxeLibre game
					--core.sound_play("mcl_bells_bell_stroke")
				end
			elseif hour == 19 and minute == 30 then
				if minute ~= last_minute then
					print(core.colorize("gold", S("The sun has set")))
					-- The following sound has to be installed in a "sounds" sub-directory of your Luanti client
					core.sound_play("alarm_watch_owl")
					-- The following sound is included with the VoxeLibre game
					--core.sound_play("mcl_bells_bell_stroke")
				end
			end
		end
		
		if alarm and hour == alarm.hour and minute == alarm.minute then
			if minute ~= last_minute then
				print(core.colorize("red", alarm.message))
				-- The following sound has to be installed in a "sounds" sub-directory of your Luanti client
				core.sound_play("alarm_watch_alarm")
				-- The following sound is included with the VoxeLibre game
				--core.sound_play("mcl_bells_bell_stroke")
			end
		end

		-- The following is needed to do things only once as the globalstep function is called several times per minute
		last_minute = minute
	end

	if core.localplayer then
		if config.show_gps then
			local pos = core.localplayer:get_pos()

			if config.gps_display == "geographical" then
				if pos.z < 0 then
					gps_text = string.format("%.0f°%s, ", pos.z * -1, S("N"))
				else
					gps_text = string.format("%.0f°%s, ", pos.z, S("S"))
				end
				if pos.x < 0 then
					gps_text = gps_text .. string.format("%.0f°%s", pos.x * -1, S("W"))
				else
					gps_text = gps_text .. string.format("%.0f°%s", pos.x, S("E"))
				end
			else -- config.gps_display == "cartesian"
				gps_text = string.format("x = %.0f / z = %.0f", pos.x, pos.z)
			end
		end

		if config.show_altimeter then
			local pos = core.localplayer:get_pos()

			altimeter_text = string.format("y = %.0f", pos.y)
		end

		if config.show_compass then
			-- With the help and eagle eye of Blockhead
			-- See https://forum.luanti.org/viewtopic.php?p=440916#p440916
			local radians = core.localplayer:get_last_look_horizontal()
			radians = radians % (2 * math.pi)
			local degrees = math.deg(radians)
			local angle = nil
			if degrees <= 90 then
				angle = 90 - degrees
			else
				angle = 450 - degrees -- 450 = 360 + 90
			end

			-- Unfortunately arrow characters are not supported in the font used in the game...
			if angle > 22.5 and angle <= 67.5 then
				compass_text = S("North-East")
			elseif angle > 67.5 and angle <= 112.5 then
				compass_text = S("East")
			elseif angle > 112.5 and angle <= 157.5 then
				compass_text = S("South-East")
			elseif angle > 157.5 and angle <= 202.5 then
				compass_text = S("South")
			elseif angle > 202.5 and angle <= 247.5 then
				compass_text = S("South-West")
			elseif angle > 247.5 and angle <= 292.5 then
				compass_text = S("West")
			elseif angle > 292.5 and angle <= 337.5 then
				compass_text = S("North-West")
			else
				compass_text = S("North")
			end
			compass_text = string.format("%s (%.0f°)", compass_text, angle)
		end
	else
		gps_text = ""
		altimeter_text = ""
		compass_text = ""
	end

	if hud then
		local hud_text = nil

		if watch_text then
			hud_text = watch_text
		end
		if gps_text then
			if hud_text then
				hud_text = hud_text .. "\n" .. gps_text
			else
				hud_text = gps_text
			end
		end
		if altimeter_text then
			if hud_text then
				hud_text = hud_text .. "\n" .. altimeter_text
			else
				hud_text = altimeter_text
			end
		end
		if compass_text then
			if hud_text then
				hud_text = hud_text .. "\n" .. compass_text
			else
				hud_text = compass_text
			end
		end
		core.localplayer:hud_change(hud, "text", hud_text)
	end
end)

core.register_chatcommand("alarm_use", {
	-- Chat command for enabling/disabling instruments
    params = "watch|light_sensor|gps|altimeter|compass",
    description = S("Enable or disable instruments (watch, light sensor, GPS, altimeter, compass)"),
	func = function(param)
		local words = string.split(param, " ")

		if #words ~= 1 then
			print(S("ERROR: usage: .alarm_use watch|light_sensor|gps|altimeter|compass"))
			return false
		end

		if words[1] == "watch" then
			if config.show_watch then
				config.show_watch = false
			else
				config.show_watch = true
			end
		elseif words[1] == "light_sensor" then
			if config.use_light_sensor then
				print(core.colorize("lime", S("Light sensor alarms disabled")))
				config.use_light_sensor = false
			else
				print(core.colorize("lime", S("Light sensor alarms enabled")))
				config.use_light_sensor = true
			end
		elseif words[1] == "gps" then
			if config.show_gps then
				config.show_gps = false
			elseif playerinfo_allowed then
				config.show_gps = true
			end
		elseif words[1] == "altimeter" then
			if config.show_altimeter then
				config.show_altimeter = false
			elseif playerinfo_allowed then
				config.show_altimeter = true
			end
		elseif words[1] == "compass" then
			if config.show_compass then
				config.show_compass = false
			elseif playerinfo_allowed then
				config.show_compass = true
			end
		else
			print(S("ERROR: usage: .alarm_use watch|light_sensor|gps|altimeter|compass"))
			return false
		end
		
		return true
	end
})

core.register_chatcommand("alarm_mode", {
	-- Chat command for configuring instruments
    params = "watch|chrono",
    description = S("Configure instruments (watch in 24h/12h, chronometer in game/real time)"),
	func = function(param)
		local words = string.split(param, " ")

		if #words ~= 1 then
			print(S("ERROR: usage: .alarm_mode watch|gps|chrono"))
			return false
		end
		
		if words[1] == "watch" then
			if config.watch_display == "24h" then
				config.watch_display = "12h"
			else
				config.watch_display = "24h"
			end
		elseif words[1] == "gps" then
			if config.gps_display == "geographical" then
				print(core.colorize("lime", S("GPS is displaying Cartesian coordinates")))
				config.gps_display = "cartesian"
			else
				print(core.colorize("lime", S("GPS is displaying geographical coordinates")))
				config.gps_display = "geographical"
			end
		elseif words[1] == "chrono" then
			if config.chrono_display == "game_time" then
				print(core.colorize("lime", S("Chronometer is measuring real time")))
				config.chrono_display = "real_time"
			else
				print(core.colorize("lime", S("Chronometer is measuring game time")))
				config.chrono_display = "game_time"
			end
		else
			print(S("ERROR: usage: .alarm_mode watch|gps|chrono"))
			return false
		end
		
		return true
	end
})

core.register_chatcommand("alarm_set", {
	-- Chat command for setting alarms
    params = "H:M TEXT",
    description = S("Set alarm at the specified HOUR:MINUTE time, displaying the given MESSAGE"),
	func = function(param)
		local words = string.split(param, " ")

		if #words < 2 then
			print(S("ERROR: usage: .alarm_set H:M TEXT"))
			return false
		end

		if not string.match(words[1], "^%d+:%d+$") then
			print(S("ERROR: usage: .alarm_set H:M TEXT"))
			return false
		else
			local hour = nil
			local minute = nil
			
			hour, minute = string.match(words[1], "(%d+):(%d+)")
			hour = tonumber(hour)
			minute = tonumber(minute)
			if hour < 0 or hour > 23 or minute < 0 or minute > 59 then
				print(S("ERROR: usage: .alarm_set H:M TEXT"))
				return false
			end

			alarm = {}
			alarm["hour"] = hour
			alarm["minute"] = minute
			alarm["message"] = ""
			for i = 2, #words do
				alarm["message"] = alarm["message"] .. " " .. words[i]
			end
			alarm["message"] = alarm["message"]:trim()
		end
		
		return true
	end
})

core.register_chatcommand("alarm_unset", {
	-- Chat command for unsetting alarms
    params = "",
    description = S("Unset alarm"),
	func = function(param)
		local words = string.split(param, " ")

		if #words > 0 then
			print(S("ERROR: usage: .alarm_unset"))
			return false
		end
		
		alarm = nil
		
		return true
	end
})

core.register_chatcommand("alarm_reset", {
	-- Chat command for reseting alarms
    params = "",
    description = S("Unset alarm (alias of alarm_unset)"),
	func = function(param)
		local words = string.split(param, " ")

		if #words > 0 then
			print(S("ERROR: usage: .alarm_reset"))
			return false
		end
		
		alarm = nil
		
		return true
	end
})

core.register_chatcommand("alarm_chrono", {
	-- Chat command for starting/stopping chronometer
    params = "",
    description = S("Start or stop the chronometer"),
	func = function(param)
		local words = string.split(param, " ")

		if #words > 0 then
			print(S("ERROR: usage: .alarm_chrono"))
			return false
		end

		if chrono then
			local chrono2 = core.get_us_time()
			local seconds = (chrono2 - chrono) / 1000000
			
			if config.chrono_display == "game_time" then
				seconds = seconds * time_speed
			end
			print(core.colorize("lime", S("Stopwatch stopped:") .. " " .. seconds_to_duration(seconds)))
			chrono = nil
		else
			chrono = core.get_us_time()
			print(core.colorize("lime", S("Stopwatch started...")))
		end
		
		return true
	end
})

core.register_chatcommand("alarm_light", {
	-- Chat command for enabling/disabling light
    params = "",
    description = S("Enable or disable the light"),
	func = function(param)
		local words = string.split(param, " ")

		if #words > 0 then
			print(S("ERROR: usage: .alarm_light"))
			return false
		end

		if light then
			core.localplayer:hud_change(hud, "number", colorspec_to_number("red"))
			light = false
		else
			core.localplayer:hud_change(hud, "number", colorspec_to_number("yellow"))
			light = true
		end
		
		return true
	end
})

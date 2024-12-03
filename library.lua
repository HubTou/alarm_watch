--[[
alarm_watch - A vintage alarm watch mutated into a smartwatch
License: 3-clause BSD (see https://opensource.org/licenses/BSD-3-Clause)
Author: Hubert Tournier
--]]

local mod_name = assert(core.get_current_modname())
local S = core.get_translator(mod_name)

function time_of_day()
	-- Return the time in hour and minute from the Luanti time of day (a 0 to 24000 value)
	-- See documentation on https://wiki.minetest.net/Time_of_day
    local timeofday = core.get_timeofday()
	local hour = math.floor((86400 * timeofday) / 3600)
	local minute = math.floor(((86400 * timeofday) % 3600) / 60)
	
	return hour, minute
end

function colorspec_to_number(param)
	-- Convert a color name into its numerical value
	-- See https://www.w3.org/TR/css-color-4/#named-color
	local number = nil
	local color_string = core.colorspec_to_colorstring(param)
	
	if color_string then
		local hex_part = string.sub(color_string, 2, 7)
		number = tonumber(hex_part, 16)
	else
		-- Unknown color name. Using black by default
		number = 0
	end
	
	return number
end

function seconds_to_duration(param)
	-- Return a duration string in days/hours/minutes/seconds from a time in seconds
	local days = math.floor(param / 86400)
	param = param % 86400
	local hours = math.floor(param / 3600)
	param = param % 3600
	local minutes = math.floor(param / 60)
	local seconds = param % 60
	local duration = nil
	
	if days == 1 then
		duration = S("1 day")
	elseif days > 1 then
		duration = S("@1 days", days)
	end

	if hours == 1 then
		if duration then
			duration = duration .. ", " .. S("1 hour")
		else
			duration = S("1 hour")
		end
	elseif hours > 1 then
		if duration then
			duration = duration .. ", " .. S("@1 hours", hours)
		else
			duration = S("@1 hours", hours)
		end
	end

	if minutes == 1 then
		if duration then
			duration = duration .. ", " .. S("1 minute")
		else
			duration = S("1 minute")
		end
	elseif minutes > 1 then
		if duration then
			duration = duration .. ", " .. S("@1 minutes", minutes)
		else
			duration = S("@1 minutes", minutes)
		end
	end

	if seconds == 1 then
		if duration then
			duration = duration .. ", " .. S("1 second")
		else
			duration = S("1 second")
		end
	elseif seconds > 1 then
		if duration then
			duration = duration .. ", " .. S("@1 seconds", string.format("%.2f", seconds))
		else
			duration = S("@1 seconds", string.format("%.2f", seconds))
		end
	end

	return duration
end

local AIA = AIA or LibStub("AceAddon-3.0"):GetAddon("AIA")

function AIA:SplitString(String)
	-- Split comma delimited strings into table entries.
	local Names = {}
	for word in string.gmatch(String,'[^,%s]+') do
		table.insert(Names,string.lower(word))
	end
	return Names
end

function AIA:Filter(List, Compare)
	-- Compare user entered name or names to whoever the event creator/inviter was.
	local Names = AIA:SplitString(List)
	if not string.match(List,'%a') then return true end -- If the user didn't enter any letters, there can't be any names, so just ignore it even if there is something else there.
	for i = 1,#Names do
		if Names[i] == string.lower(Compare) then return true end
	end
	return false
end

function AIA:AddZero(number)
	-- Event date info returns dates without leading zeros, to easily compare dates, this adds them back in if necessary.
	local string = tostring(number)
	if tonumber(string) < 10 then
		string = "0"..string
	end
	return string
end

function AIA:DateConversion(date)
	-- Takes the table of information for the date and formats it as one number for easy comparison to the current date.
	local year = date.year
	local month = date.month
	local monthDay = date.monthDay
	local hour = date.hour
	local minute = date.minute

	month = AIA:AddZero(month)
	monthDay = AIA:AddZero(monthDay)
	hour = AIA:AddZero(hour)
	minute = AIA:AddZero(minute)

	return tonumber(year..month..monthDay..hour..minute)
end
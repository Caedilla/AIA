local AIA = LibStub('AceAddon-3.0'):GetAddon('AIA')

function AIA:IsLeapYear(year)
	return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function AIA:DaysInMonth(month,year)
	return month == 2 and AIA:IsLeapYear(year) and 29 or ('\31\28\31\30\31\30\31\31\30\31\30\31'):byte(month)
end

function AIA:FindEventCreator(event)
	-- For some events invitedBy is an empty string, in these cases creator exists so check for either and return that name.
	if event.creator then
		if string.len(event.creator) > 0 then
			return event.creator
		end
	elseif event.invitedBy then
		if string.len(event.invitedBy) > 0 then
			return event.invitedBy
		end
	else
		return
	end
end

function AIA:SplitString(String)
	-- Split comma delimited strings into table entries.
	local Names = {}
	for word in string.gmatch(String,'[^,%s]+') do
		table.insert(Names,string.lower(word))
	end
	return Names
end

function AIA:StringFilter(List, Compare)
	-- Compare user entered name or names to whoever the event creator/inviter was.
	local Names = AIA:SplitString(List)
	if not string.match(List,'%a') then return true end -- If the user didn't enter any letters, there can't be any names, so just ignore it even if there is something else there.
	if not string.match(Compare,'%a') then return true end -- If there was no supplied Compare values, something funky happened, deal with that elsewhere.
	for i = 1,#Names do
		if Names[i] == string.lower(Compare) then return true end
	end
	return false
end

function AIA:EventFilter(event)
	for i = 0,4 do
		if AIA.db.profile.Filter.Type[i] and event.eventType == i then return true end -- eventType 0 == Raid, 1 == Dungeon, 2 == PvP, 3 == Meeting, 4 == Other
	end
	return false
end

function AIA:AddZero(number)
	-- Event date info returns dates without leading zeros, to easily compare dates, this adds them back in if necessary.
	local string = tostring(number)
	if tonumber(string) < 10 then
		string = '0'.. string
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

function AIA:CheckFilteredEventCount(table)
	local count = 0
	for k,v in pairs(table) do
		if v == true then
			count = count + 1
		end
	end
	return count
end
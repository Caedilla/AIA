local AIA = AIA or LibStub("AceAddon-3.0"):GetAddon("AIA")
local L = LibStub("AceLocale-3.0"):GetLocale("AIA")
local invitesToAccept = {}
local invitesAccepted = 0
local currentDate
local enteredWorld = false
local firstRun = true
local elapsed = 0
totalEvents = {}

function AIA:InviteStatus(event)
	if not event then return end
	if event.calendarType ~= "PLAYER" and event.calendarType ~= "GUILD_EVENT" and event.calendarType ~= "COMMUNITY_EVENT" then return end

	local status = event.inviteStatus
	if not status then return end
	if status == 2 or (status >= 4 and status <= 7) then return "Replied" end -- AIA does nothing for these statuses because they're already forms of accepted.
	-- Statuses: Invited = 1, Accepted = 2, Declined = 3, Confirmed = 4, Out = 5, Standby = 6, Signed Up = 7, Not Signed Up = 8, Tentative = 9

	local inviter = AIA:FindEventCreator(event)
	if not inviter then return end	
	
	if event.inviteType == 1 then -- If the event is invite only or sign up. 1 == Invite, 2 == Sign Up
		if AIA:StringFilter(AIA.db.profile.Filter.Name, inviter) == false then return false end
		if AIA:StringFilter(AIA.db.profile.Filter.Title, event.title) == false then return false end
		if status == 1 then
			if AIA.db.profile.Types.Invited == true then 
				return true
			end
		elseif status == 3 then
			if AIA.db.profile.Types.Declined == true then 
				return true
			end
		elseif status == 9 then
			if AIA.db.profile.Types.Tentative == true then 
				return true
			end
		end
	elseif event.inviteType == 2 then
		if AIA:StringFilter(AIA.db.profile.Filter.SignUp.Name, inviter) == false then return false end
		if AIA:StringFilter(AIA.db.profile.Filter.SignUp.Title, event.title) == false then return false end
		if status == 8 then
			if AIA.db.profile.Types.SignUp == true then		
				return true
			end
		end
	end

	return false
end

function AIA:CheckCalendarEvent(event,m,d,i)
	if not event then return end

	if event.calenderType ~= "PLAYER" and event.calendarType ~= "GUILD_EVENT" and event.calendarType ~= "COMMUNITY_EVENT" then return end

	if AIA:DateConversion(event.startTime) < currentDate then return end -- Only check events that are in the future.

	totalEvents[tostring(m)..tostring(d)..tostring(i)] = true

	if AIA:EventFilter(event) == false then return end

	if AIA:InviteStatus(event) == "Replied" then
		totalEvents[tostring(m)..tostring(d)..tostring(i)] = false
		return
	elseif AIA:InviteStatus(event) == false then 
		return
	end

	totalEvents[tostring(m)..tostring(d)..tostring(i)] = false

	if event.isLocked then return end

	local data = {
		monthOffset = m,
		day = d,
		index = i,
	}

	table.insert(invitesToAccept,data)
	if #invitesToAccept > invitesAccepted then
		invitesAccepted = #invitesToAccept
	end

end

function AIA:CreateCalendarList(eventName)

	if eventName == "PLAYER_ENTERING_WORLD" then
		-- Force the calendar to update so we can grab data immediately.
		C_Calendar.OpenCalendar()
		enteredWorld = true
	end
	if enteredWorld == false then return end
	wipe(invitesToAccept)
	currentDate = tonumber(date("%Y%m%d%H%M"))

	for m = 0,1 do -- This month, and next month only.
		for d = 1,31 do -- Day
			for i = 1,10 do -- Index of events on that day
				local event = C_Calendar.GetDayEvent(m,d,i) or nil
				if event then
					if event.calendarType == "PLAYER" or event.calendarType == "GUILD_EVENT" or event.calendarType == "COMMUNITY_EVENT" then
						if AIA:DateConversion(event.startTime) > currentDate and not event.isLocked then
							totalEvents[tostring(m)..tostring(d)..tostring(i)] = true
							if AIA:InviteStatus(event) == "Replied" then
								totalEvents[tostring(m)..tostring(d)..tostring(i)] = false
							end
							if AIA:EventFilter(event) == true and AIA:InviteStatus(event) == true then
								totalEvents[tostring(m)..tostring(d)..tostring(i)] = false
								local data = {
									monthOffset = m,
									day = d,
									index = i,
								}
								table.insert(invitesToAccept,data)
								if #invitesToAccept > invitesAccepted then
									invitesAccepted = #invitesToAccept
								end
							end
						end
					end
				end
			end
		end
	end

	AIA.Accepter:SetScript("OnUpdate", AIA.AcceptInvite)
end

function AIA:AcceptInvite(timer)
	if timer then
		if firstRun then -- Delay first run when logging in a little bit.
			elapsed = elapsed + timer
			if elapsed > 15 then
				elapsed = 0
				firstRun = false
			else return
			end
		elseif timer then
			elapsed = elapsed + timer
			if elapsed > 0.05 then
				elapsed = 0
			else return
			end
		end
	end
	if firstRun then return end

	if C_Calendar.IsActionPending() then return end
	
	if not invitesToAccept[1] then
		if AIA.db.profile.NotifyFinish then
			if (AIA.db.profile.NotifyOnlyAccepted and invitesAccepted > 0) or not AIA.db.profile.NotifyOnlyAccepted then
				if invitesAccepted == 1 then
					print("|cFFFF2C5AAIA: |r"..L["Accepted "]..invitesAccepted..L[" calendar invite."])
				else
					print("|cFFFF2C5AAIA: |r"..L["Accepted "]..invitesAccepted..L[" calendar invites."])
				end
			end
		end
		if AIA.db.profile.WarnIgnoredEvents == true then
			local eventCount = AIA:CheckFilteredEventCount(totalEvents)
			if (eventCount - invitesAccepted) == 1 then
				print("|cFFFF2C5AAIA: |r"..eventCount - invitesAccepted..L[" calendar invite has been ignored by AIA due to your filters."])
			elseif (eventCount - invitesAccepted) > 0 then
				print("|cFFFF2C5AAIA: |r"..eventCount - invitesAccepted..L[" calendar invites have been ignored by AIA due to your filters."])
			end
		end
		if AIA.db.profile.DisableAfterRunning == true then
			AIA:Disable()
		else
			AIA.Accepter:SetScript("OnUpdate", nil)
		end
		invitesAccepted = 0
		return
	end

	local m = invitesToAccept[1].monthOffset
	local d = invitesToAccept[1].day
	local i = invitesToAccept[1].index
	local event = C_Calendar.GetDayEvent(m,d,i)	
	local openEventIndex = C_Calendar.GetEventIndex()
	local openEventInfo = C_Calendar.GetEventInfo()

	if openEventIndex then -- We have an event open
		if openEventIndex.offsetMonths == m and openEventIndex.monthDay == d and openEventIndex.eventIndex == i then
			-- We have an event open, and the data is all correct.
		else
			-- We have an event open, but it's not the correct one.
			C_Calendar.OpenEvent(m,d,i)
			return
		end
	else
		-- We don't have an event open so open one.
		C_Calendar.OpenEvent(m,d,i)
		return
	end

	if event and openEventInfo and AIA:InviteStatus(openEventInfo) == true then
		if event.inviteType == 1 then
			C_Calendar.EventAvailable()
		elseif event.inviteType == 2 then
			if AIA.db.profile.Types.SignUpTentative == true then
				C_Calendar.EventTentative()
			else
				C_Calendar.EventSignUp()
			end
		end
	end

end

function AIA:CheckAgain()
	print("|cFFFF2C5AAIA: |r"..L["Checking again!"])
	invitesAccepted = 0
	AIA:Enable()
	AIA:CreateCalendarList()
	AIA:AcceptInvite()
end

function AIA:OnEnable()
	AIA.ListMonitor = AIA.ListMonitor or CreateFrame("Frame", "AIA_ListMonitor")
	AIA.ListMonitor:RegisterEvent("PLAYER_ENTERING_WORLD")
	AIA.ListMonitor:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
	AIA.ListMonitor:RegisterEvent("CALENDAR_UPDATE_INVITE_LIST")
	AIA.ListMonitor:RegisterEvent("CALENDAR_ACTION_PENDING")
    AIA.ListMonitor:SetScript("OnEvent", AIA.CreateCalendarList)
    AIA.Accepter = AIA.Accepter or CreateFrame("Frame", "AIA_Accepter")
end

function AIA:OnDisable()
	AIA.ListMonitor:UnregisterAllEvents()
	AIA.ListMonitor:SetScript("OnEvent", nil)
	AIA.Accepter:UnregisterAllEvents()
	AIA.Accepter:SetScript("OnUpdate", nil)
	if AIA.db.profile.NotifyDisable then
		if (AIA.db.profile.NotifyOnlyAccepted and invitesAccepted > 0) or not AIA.db.profile.NotifyOnlyAccepted then
			print("|cFFFF2C5AAIA: |r"..L["No more invites to accept. Shutting down."])
		end
	end	
end
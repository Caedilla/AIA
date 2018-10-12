local AIA = AIA or LibStub("AceAddon-3.0"):GetAddon("AIA")
local L = LibStub("AceLocale-3.0"):GetLocale("AIA")
local InvitesToAccept = {}
local InvitesAccepting = 0
local currentDate
local enteredWorld = false
local firstRun = true
local elapsed = 0

function AIA:EventChecker(event)
	for i = 0,4 do
		if AIA.db.profile.Filter.Type[i] and event.eventType == i then return true end -- eventType 0 == Raid, 1 == Dungeon, 2 == PvP, 3 == Meeting, 4 == Other
	end
	return false
end

function AIA:InviteStatus(event)
	if not event then return end
	local status = event.inviteStatus
	if not status then return end

	if status == 2 or (status >= 4 and status <= 7) then return false end -- AIA does nothing for these statuses because they're already forms of accepted.
	-- Statuses: Invited = 1, Accepted = 2, Declined = 3, Confirmed = 4, Out = 5, Standby = 6, Signed Up = 7, Not Signed Up = 8, Tentative = 9
	if event.inviteType == 1 then -- If the event is invite only or sign up. 1 == Invite, 2 == Sign Up
		if AIA:Filter(AIA.db.profile.Filter.Name, event.invitedBy) == false then return false end
		if AIA:Filter(AIA.db.profile.Filter.Title, event.title) == false then return false end
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
		if AIA:Filter(AIA.db.profile.Filter.SignUp.Name, event.invitedBy) == false then return false end
		if AIA:Filter(AIA.db.profile.Filter.SignUp.Title, event.title) == false then return false end
		if status == 8 then
			if AIA.db.profile.Types.SignUp == true then		
				return true
			end
		end
	end

	return false
end

function AIA:CreateCalendarList(eventName)
	if eventName == "PLAYER_ENTERING_WORLD" then 
		enteredWorld = true
	end
	if enteredWorld == false then return end
	wipe(InvitesToAccept)
	for i = 0,1 do -- This month, and next month only.
		currentDate = tonumber(date("%Y%m%d%H%M"))
		for j = 1,31 do -- Day
			for index = 1,10 do -- Index of events on that day
				local event = C_Calendar.GetDayEvent(i,j,index) or nil
				if event then
					if event.calendarType == "PLAYER" or event.calendarType == "GUILD_EVENT" or event.calendarType == "COMMUNITY_EVENT" then
						if AIA:DateConversion(event.startTime) > currentDate and AIA:EventChecker(event) == true and AIA:InviteStatus(event) == true and not event.isLocked then
							local data = {
								monthOffset = i,
								day = j,
								index = index,
							}
							table.insert(InvitesToAccept,data)
							if #InvitesToAccept > InvitesAccepting then
								InvitesAccepting = #InvitesToAccept
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
			if elapsed > 5 then
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
	if not InvitesToAccept[1] then
		if AIA.db.profile.NotifyFinish then
			if InvitesAccepting == 1 then
				print("|cFFFF2C5AAIA: |r"..L["Accepted "]..InvitesAccepting..L[" calendar invite."])
			else
				print("|cFFFF2C5AAIA: |r"..L["Accepted "]..InvitesAccepting..L[" calendar invites."])
			end
		end		
		if AIA.db.profile.DisableAfterRunning == true then
			AIA:Disable()
		end
		return
	end
	local m = InvitesToAccept[1].monthOffset
	local d = InvitesToAccept[1].day
	local i = InvitesToAccept[1].index
	local event = C_Calendar.GetDayEvent(m,d,i)	
	local openData = C_Calendar.GetEventIndex()
	local openStatus = C_Calendar.GetEventInfo()
	if openData then -- We have an event open
		if openData.offsetMonths == m and openData.monthDay == d and openData.eventIndex == i then
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
	if event and openStatus and AIA:InviteStatus(openStatus) == true then
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
	InvitesAccepting = 0
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
	--AIA.Accepter:SetScript("OnEvent", nil)
	AIA.Accepter:SetScript("OnUpdate", nil)
	if AIA.db.profile.NotifyDisable then
		print("|cFFFF2C5AAIA: |r"..L["No more invites to accept. Shutting down."])
	end	
end
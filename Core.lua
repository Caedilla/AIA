local AIA = LibStub('AceAddon-3.0'):GetAddon('AIA')
local L = LibStub('AceLocale-3.0'):GetLocale('AIA')
local LDB = LibStub('LibDataBroker-1.1'):GetDataObjectByName('AIA')
local invitesToAccept = {}
local invitesAccepted = 0
local currentDate
local currentMonth = tonumber(date('%m'))
local currentYear = tonumber(date('%Y'))
local enteredWorld = false
local firstRun = true
local elapsed = 0
local totalEvents = {}
local eventCount = 0
local sessionAccepted = 0
local currentlyChecking = false
local calendarOpen = false


function AIA:InviteStatus(event)
	if not event then return end
	if event.calendarType ~= 'PLAYER' and event.calendarType ~= 'GUILD_EVENT' and event.calendarType ~= 'COMMUNITY_EVENT' then return end

	local status = event.inviteStatus
	if not status then return end
	if status == 2 or (status >= 4 and status <= 7) then return 'Replied' end -- AIA does nothing for these statuses because they're already forms of accepted.
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

function AIA:CreateCalendarList(eventName)
	if CalendarFrame then
		if CalendarFrame:IsVisible() == true then
			return
		end
	end
	if eventName == 'PLAYER_ENTERING_WORLD' then
		-- Force the calendar to update so we can grab data immediately.
		C_Calendar.OpenCalendar()
		enteredWorld = true
	end
	if enteredWorld == false then return end
	if currentlyChecking then return end

	wipe(invitesToAccept)
	currentDate = tonumber(date('%Y%m%d%H%M'))

	local selectedYear = currentYear
	local selectedMonth = currentMonth

	for m = 0,12 do
		currentlyChecking = true
		selectedMonth = currentMonth + m
		if selectedMonth > 12 then
			selectedMonth = selectedMonth - 12
			selectedYear = currentYear + 1
		end
		C_Calendar.SetAbsMonth(selectedMonth,selectedYear)
		for d = 1,AIA:DaysInMonth(selectedMonth,selectedYear) do
			local numDayEvents = C_Calendar.GetNumDayEvents(0,d) -- Month offset is 0 because we check set the current month above, and check only this month.
			for i = 1,numDayEvents do
				local event = C_Calendar.GetDayEvent(0,d,i) or nil
				if event then
					if event.calendarType == 'PLAYER' or event.calendarType == 'GUILD_EVENT' or event.calendarType == 'COMMUNITY_EVENT' then
						if AIA:DateConversion(event.startTime) > currentDate and not event.isLocked then
							totalEvents[tostring(0)..tostring(d)..tostring(i)] = true
							if AIA:InviteStatus(event) == 'Replied' then
								totalEvents[tostring(0)..tostring(d)..tostring(i)] = false
							end
							if AIA:EventFilter(event) == true and AIA:InviteStatus(event) == true then
								totalEvents[tostring(0)..tostring(d)..tostring(i)] = false
								local data = {
									month = selectedMonth,
									year = selectedYear,
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

	currentlyChecking = false
	AIA.Accepter:SetScript('OnUpdate', AIA.AcceptInvite)
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
		eventCount = AIA:CheckFilteredEventCount(totalEvents)

		if AIA.db.profile.NotifyFinish then
			if (AIA.db.profile.NotifyOnlyAccepted and invitesAccepted > 0) or not AIA.db.profile.NotifyOnlyAccepted then
				if invitesAccepted == 1 then
					print('|cFFFF2C5AAIA: |r'..L['Accepted ']..invitesAccepted..L[' calendar invite.'])
				else
					print('|cFFFF2C5AAIA: |r'..L['Accepted ']..invitesAccepted..L[' calendar invites.'])
				end
			end
		end

		if AIA.db.profile.WarnIgnoredEvents == true then
			if eventCount == 1 then
				print('|cFFFF2C5AAIA: |r'..eventCount..L[' calendar invite has been ignored by AIA due to your filters.'])
			elseif eventCount > 0 then
				print('|cFFFF2C5AAIA: |r'..eventCount..L[' calendar invites have been ignored by AIA due to your filters.'])
			end
		end

		if AIA.db.profile.LDB.WarnIgnoredEvents == true then
			if eventCount == 1 then
				LDB.text = string.format('|cFFFF2C5A%d|r |cFFFFFFFF'..L['Pending invite']..'|r', eventCount)
			elseif eventCount > 0 then
				LDB.text = string.format('|cFFFF2C5A%d|r |cFFFFFFFF'..L['Pending invites']..'|r', eventCount)
			else
				LDB.text = AIA.db.profile.LDB.DisplayName
			end
		else
			LDB.text = AIA.db.profile.LDB.DisplayName
		end

		if AIA.db.profile.DisableAfterRunning == true then
			AIA:Disable()
		else
			AIA.Accepter:SetScript('OnUpdate', nil)
		end

		sessionAccepted = sessionAccepted + invitesAccepted
		invitesAccepted = 0
		currentlyChecking = false

		return
	end

	currentlyChecking = true
	local d = invitesToAccept[1].day
	local i = invitesToAccept[1].index
	local year = invitesToAccept[1].year
	local month = invitesToAccept[1].month
	C_Calendar.SetAbsMonth(month,year)
	local event = C_Calendar.GetDayEvent(0,d,i)
	local openEventIndex = C_Calendar.GetEventIndex()
	local openEventInfo = C_Calendar.GetEventInfo()

	if AIA:InviteStatus(event) == 'Replied' or AIA:InviteStatus(event) == false then
		table.remove(invitesToAccept,1)
		return
	end

	if openEventIndex then -- We have an event open
		if openEventIndex.offsetMonths == 0 and openEventIndex.monthDay == d and openEventIndex.eventIndex == i then
			-- We have an event open, and the data is all correct.
		else
			-- We have an event open, but it's not the correct one.
			C_Calendar.OpenEvent(0,d,i)
			return
		end
	else
		-- We don't have an event open so open one.
		C_Calendar.OpenEvent(0,d,i)
		return
	end

	if event and openEventInfo and AIA:InviteStatus(openEventInfo) == true then
		if event.inviteType == 1 then
			C_Calendar.EventAvailable()
		elseif event.inviteType == 2 then
			C_Calendar.EventSignUp()
		end
	end
end

function LDB:OnTooltipShow()
	self:AddLine('|cFFFF2C5AAIA|r')
	self:AddLine(' ')
	if eventCount == 1 then
		self:AddLine(string.format('|cFFFF2C5A%d|r |cFFFFFFFF'..L['Pending invite']..'|r', eventCount))
	elseif eventCount > 0 then
		self:AddLine(string.format('|cFFFF2C5A%d|r |cFFFFFFFF'..L['Pending invites']..'|r', eventCount))
	end
	if sessionAccepted == 1 then
		self:AddLine(string.format('|cFFFFBE19%d|r |cFFFFFFFF'..L['invite accepted this session']..'|r', sessionAccepted))
	elseif sessionAccepted > 0 then
		self:AddLine(string.format('|cFFFFBE19%d|r |cFFFFFFFF'..L['invites accepted this session']..'|r', sessionAccepted))
	else
		self:AddLine('|cFFFFFFFF'..L['No new invites accepted this session']..'|r')
	end
end

function LDB:OnClick(button)
	local click = {
		['LeftButton'] = AIA.db.profile.LDB.LeftClick,
		['RightButton'] = AIA.db.profile.LDB.RightClick,
		['MiddleButton'] = AIA.db.profile.LDB.MiddleClick,
	}
	if click[button] == 1 then
		AIA:CheckAgain()
	elseif click[button] == 2 then
		GameTimeFrame:Click()
	elseif click[button] == 3 then
		AIA:ChatCommand('Open')
	else return
	end
end

function LDB:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:SetPoint('TOPLEFT', self, 'BOTTOMLEFT')
	GameTooltip:ClearLines()
	GameTooltip:Show()
end

function LDB:OnLeave()
	GameTooltip:Hide()
end

function AIA:LDBDisplayState()
	if AIA.db.profile.Minimap.hide then
		LibStub('LibDBIcon-1.0'):Hide('AIA')
	else
		LibStub('LibDBIcon-1.0'):Show('AIA')
	end
end

function AIA:LDBLockState()
	if AIA.db.profile.Minimap.lock then
		LibStub('LibDBIcon-1.0'):Lock('AIA')
	else
		LibStub('LibDBIcon-1.0'):Unlock('AIA')
	end
end

local function CalendarClosed()
	invitesAccepted = 0
	AIA:Enable()
	AIA:CreateCalendarList()
	AIA:AcceptInvite()
	CalendarFrame:SetScript('OnHide',nil)
end

function AIA:CheckAgain()
	if CalendarFrame then
		if CalendarFrame:IsVisible() == true then
			print('|cFFFF2C5AAIA: |r'..L['Will check again after you close the calendar.'])
			CalendarFrame:SetScript('OnHide',CalendarClosed)
			return
		end
	end
	print('|cFFFF2C5AAIA: |r'..L['Checking again!'])
	invitesAccepted = 0
	AIA:Enable()
	AIA:CreateCalendarList()
	AIA:AcceptInvite()
end

function AIA:OnEnable()
	AIA.ListMonitor = AIA.ListMonitor or CreateFrame('Frame', 'AIA_ListMonitor')
	AIA.ListMonitor:RegisterEvent('PLAYER_ENTERING_WORLD')
	AIA.ListMonitor:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
	AIA.ListMonitor:RegisterEvent('CALENDAR_UPDATE_INVITE_LIST')
	AIA.ListMonitor:RegisterEvent('CALENDAR_ACTION_PENDING')
	AIA.ListMonitor:SetScript('OnEvent', AIA.CreateCalendarList)
	AIA.Accepter = AIA.Accepter or CreateFrame('Frame', 'AIA_Accepter')
end

function AIA:OnDisable()
	AIA.ListMonitor:UnregisterAllEvents()
	AIA.ListMonitor:SetScript('OnEvent', nil)
	AIA.Accepter:UnregisterAllEvents()
	AIA.Accepter:SetScript('OnUpdate', nil)
	if AIA.db.profile.NotifyDisable then
		if (AIA.db.profile.NotifyOnlyAccepted and invitesAccepted > 0) or not AIA.db.profile.NotifyOnlyAccepted then
			print('|cFFFF2C5AAIA: |r'..L['No more invites to accept. Shutting down.'])
		end
	end
end
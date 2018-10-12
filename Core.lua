AIA = AIA or LibStub("AceAddon-3.0"):NewAddon("AIA", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("AIA")
local InvitesToAccept = {}
local InvitesAccepting = 0
local enteredWorld = false
local firstRun = true
local elapsed = 0
local Defaults = {
	profile = {
		DisableAfterRunning = true,
		NotifyDisable = true,
		NotifyFinish = true,
		Types = {
			Tentative = false,
			Declined = false,
			Invited = true,
			SignUp = false,
			SignUpTentative = true,
		},
		Filter = {
			Name = "",
			Title = "",
			SignUp = {
				Name = "",
				Title = "",
			},
			Type = {
				[0] = true,
				[1] = false,
				[2] = false,
				[3] = false,
				[4] = false,
			},
		},
	},
}

local Options = {
	type = "group",
	name = function(info)
		return "AIA - |cFFFF2C5A"..L["Accept Invites Automatically"].. "|r r|cFFFF2C5A" .. string.match(GetAddOnMetadata("AIA","Version"),"%d+") .."|r"
	end,
	order = 0,
	childGroups = "tab",
	args = {
		Main = {
			name = "Options",
			type = "group",
			order = 0,
			args = {
				DisableAfterRunning = {
					name = "|cFF37C5FF"..L["Disable After Running"].."|r",
					desc = L["Sets AIA to disable itself when it has accepted all the invites it is allowed to."],
					descStyle = "inline",
					width = "full",
					order = 0,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.DisableAfterRunning
					end,
					set = function(info, value)
						AIA.db.profile.DisableAfterRunning = value
					end,
				},
				NotifyDisable = {
					name = "|cFF80DAFF"..L["Notify when disabling"].."|r",
					desc = L["Sets if AIA should send a message to the chat window when it is disabled."],
					descStyle = "inline",
					width = "full",
					order = 0,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.NotifyDisable
					end,
					set = function(info, value)
						AIA.db.profile.NotifyDisable = value
					end,
				},
				NotifyFinish = {
					name = "|cFF80DAFF"..L["Notify when finished"].."|r",
					desc = L["Sets if AIA should send a message to the chat window when it has finished."],
					descStyle = "inline",
					width = "full",
					order = 0,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.NotifyFinish
					end,
					set = function(info, value)
						AIA.db.profile.NotifyFinish = value
					end,
				},
				Tentative = {
					name = "|cFFFF8019"..L["Tentative"].."|r",
					desc = L["Override Tentative status. Accepts calender invites where you have replied as tentative."],
					descStyle = "inline",
					width = "full",
					order = 10,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.Types.Tentative
					end,
					set = function(info, value)
						AIA.db.profile.Types.Tentative = value
					end,
				},
				Delined = {
					name = "|CFFFF0000"..L["Declined"].."|r",
					desc = L["Override Declined status. Accepts calender invites where you have replied as declined."],
					descStyle = "inline",
					width = "full",
					order = 10,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.Types.Declined
					end,
					set = function(info, value)
						AIA.db.profile.Types.Declined = value
					end,
				},
				Invited = {
					name = "|cFFFFBE19"..L["Invited"].."|r",
					desc = L["Accepts calendar invites where you haven't replied."],
					descStyle = "inline",
					width = "full",
					order = 10,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.Types.Invited
					end,
					set = function(info, value)
						AIA.db.profile.Types.Invited = value
					end,
				},
				FilterName = {
					name = "|cFFFFCC00"..L["Only accept invites sent by:"].."|r",
					desc = L["Only accept event invites if they were sent by this player."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple names by separating each one with a comma."],
					order = 20,
					type = "input",
					get = function(info)
						return AIA.db.profile.Filter.Name
					end,
					set = function(info, value)
						AIA.db.profile.Filter.Name = value
					end,
				},
				FilterSpacer = {
					name = " ",
					type = "description",
					width = "normal",
					order = 21,
				},
				FilterTitle = {
					name = "|cFFFFCC00"..L["Only accept invites with title:"].."|r",
					desc = L["Only accept event invites if the title of the event matches this."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple events by separating each one with a comma."],
					order = 22,
					type = "input",
					get = function(info)
						return AIA.db.profile.Filter.Title
					end,
					set = function(info, value)
						AIA.db.profile.Filter.Title = value
					end,
				},
				SignUp = {
					name = "|cFF00A98A"..L["Sign Up"].."|r",
					desc = L["Sign Up to events that you are not signed up to."],
					descStyle = "inline",
					width = "full",
					order = 30,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.Types.SignUp
					end,
					set = function(info, value)
						AIA.db.profile.Types.SignUp = value
					end,
				},
				SignUpTentative = {
					name = "|cFF00A98A"..L["Sign up as Tentative"].."|r",
					desc = L["Set yourself to |cFFFF8019Tentative|r for events AIA signs you up for."],
					descStyle = "inline",
					width = "full",
					order = 31,
					type = "toggle",
					hidden = function()
						if AIA.db.profile.Types.SignUp == false then return true end
					end,
					get = function(info)
						return AIA.db.profile.Types.SignUpTentative
					end,
					set = function(info, value)
						AIA.db.profile.Types.SignUpTentative = value
					end,
				},
				Filter_SignUp_Name = {
					name = "|cFF00A98A"..L["Only sign up to events created by:"].."|r",
					desc = L["Only sign up to events if they were created by this player."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple names by separating each one with a comma."],
					order = 33,
					type = "input",
					hidden = function()
						if AIA.db.profile.Types.SignUp == false then return true end
					end,
					get = function(info)
						return AIA.db.profile.Filter.SignUp.Name
					end,
					set = function(info, value)
						AIA.db.profile.Filter.SignUp.Name = value
					end,
				},
				Filter_SignUp_Spacer = {
					name = " ",
					type = "description",
					width = "normal",
					order = 34,
					hidden = function()
						if AIA.db.profile.Types.SignUp == false then return true end
					end,
				},
				Filter_SignUp_Title = {
					name = "|cFF00A98A"..L["Only sign up to events with title:"].."|r",
					desc = L["Only sign up to events if the title of the event matches this."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple events by separating each one with a comma."],
					order = 35,
					type = "input",
					hidden = function()
						if AIA.db.profile.Types.SignUp == false then return true end
					end,
					get = function(info)
						return AIA.db.profile.Filter.SignUp.Title
					end,
					set = function(info, value)
						AIA.db.profile.Filter.SignUp.Title = value
					end,
				},
				FilterType = {
					name = "|cFFFFCC00"..L["Only Accept invites of these types:"].."|r",
					desc = L["Only accept invites if the event type matches this."],
					order = 40,
					type = "multiselect",
					values = {
						[0] = L["Raid"], 
						[1] = L["Dungeon"], 
						[2] = L["PvP"], 
						[3] = L["Meeting"], 
						[4] = L["Other"]
					},
					get = function(info,key)
						return AIA.db.profile.Filter.Type[key]
					end,
					set = function(info, key, value)
						AIA.db.profile.Filter.Type[key] = value
					end,
				},
				CheckAgainSpacer = {
					name = " ",
					type = "description",
					width = "normal",
					order = 45,
				},
				CheckAgain = {
					name = "|cFF80DAFF"..L["Check Again"].."|r",
					desc = L["Makes AIA Check if there is anything to accept now."],
					order = 50,
					type = "execute",
					func = function()
						print("|cFFFF2C5AAIA: |r"..L["Checking again!"])
						InvitesAccepting = 0
						AIA:Enable()
						AIA:CreateCalendarList()
						AIA:AcceptInvite()
					end,
				},
				CheckAgainAfterSpacer = {
					name = " ",
					type = "description",
					width = "normal",
					order = 51,
				},
				FrequencySpacer = {
					name = " ",
					type = "description",
					width = "normal",
					order = 52,
				},
			},
		},
	},
}

function AIA:SplitString(String)
	local Names = {}
	for word in string.gmatch(String,'[^,%s]+') do
		table.insert(Names,string.lower(word))
	end
	return Names
end

function AIA:Filter(List, Compare) -- AIA.db.profile.Filter.Name , event.invitedBy
	local Names = AIA:SplitString(List)
	if not string.match(List,'%a') then return true end -- If the user didn't enter any letters, there can't be any names, so just ignore it.
	for i = 1,#Names do
		if Names[i] == string.lower(Compare) then return true end
	end
	return false
end

function AIA:EventChecker(event)
	if AIA.db.profile.Filter.Type[0] and event.eventType == 0 then return true end
	if AIA.db.profile.Filter.Type[1] and event.eventType == 1 then return true end
	if AIA.db.profile.Filter.Type[2] and event.eventType == 2 then return true end
	if AIA.db.profile.Filter.Type[3] and event.eventType == 3 then return true end
	if AIA.db.profile.Filter.Type[4] and event.eventType == 4 then return true end
	return false
end

--- FUNCTION TO CHECK INVITE STATUS
function AIA:InviteStatus(event)
	local status = event.inviteStatus
	-- Invited = 1, Accepted = 2, Declined = 3, Confirmed = 4, Out = 5, Standby = 6, Signed Up = 7, Not Signed Up = 8, Tentative = 9
	-- event.inviteType = 1 or 2. 1 == Invite, 2 == Sign Up
	if status == 2 or (status >= 4 and status <= 7) then return false end -- AIA does nothing for these statuses because they're already forms of accepted.
	if event.inviteType == 1 then
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

function AIA:DateConversion(date)
	local year = date.year
	local month = date.month
	local monthDay = date.monthDay
	local hour = date.hour
	local minute = date.minute

	month = AIA:AddZero(month)
	monthDay = AIA:AddZero(monthDay)
	hour = AIA:AddZero(hour)
	minute = AIA:AddZero(minute)

	local returnDate = year..month..monthDay..hour..minute
	returnDate = tonumber(returnDate)
	return returnDate
end

function AIA:AddZero(number)
	local string = tostring(number)
	if tonumber(string) < 10 then
		string = "0"..string
	end
	return string
end

--[[
	C_Calendar.GetDayEvent(i,j,index)
	.calendarType == String - One of "PLAYER", "GUILD_EVENT", "ARENA", "HOLIDAY", "COMMUNITY_EVENT"
	.invitedBy = Player who invited. "" if calendarType is not "PLAYER"
	.title = Display Name
	.eventType When calendarType is "PLAYER" 0 == Raid, 1 == Dungeon, 2 == PvP, 3 == Meeting, 4 == Other. For other calendarType values, numbers are different.
]]--

function AIA:CreateCalendarList(eventName)
	if eventName == "PLAYER_ENTERING_WORLD" then
		enteredWorld = true
	end
	if enteredWorld == false then return end
	wipe(InvitesToAccept)
	for i = 0,1 do
		local currentDate = date("%Y%m%d%H%M")
		currentDate = tonumber(currentDate)
		for j = 1,31 do -- Day
			for index = 1,10 do -- Index of events on that day
				local event = C_Calendar.GetDayEvent(i,j,index) or nil
				if event then
					if event.isLocked then break end -- We can't sign up to events that are locked.
					if event.calendarType == "PLAYER" or event.calendarType == "GUILD_EVENT" or event.calendarType == "COMMUNITY_EVENT" then
						if AIA:DateConversion(event.startTime) > currentDate then
							if AIA:EventChecker(event) == true then
								if AIA:InviteStatus(event) == true then
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
		end
	end
	if #InvitesToAccept > 0 then
		AIA.Accepter:SetScript("OnUpdate", AIA.AcceptInvite)
	end
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
	else -- We don't have an event open so open one.
		C_Calendar.OpenEvent(m,d,i)
		return
	end
	if event then
		if openStatus then
			if event.inviteType == 1 then
				if (AIA.db.profile.Types.Invited == false and openStatus.inviteStatus == 1) then return end
				if openStatus.inviteStatus == 2 then return end -- Accepted, don't do anything
				if (AIA.db.profile.Types.Declined == false and openStatus.inviteStatus == 3) then return end
				if openStatus.inviteStatus == 4 then return end -- Confirmed, don't do anything
				if openStatus.inviteStatus == 5 then return end -- Out
				if openStatus.inviteStatus == 6 then return end -- Standby
				if openStatus.inviteStatus == 7 then return end -- Signed Up, don't do anything
				if (AIA.db.profile.Types.Tentative == false and openStatus.inviteStatus == 9) then return end
			elseif event.inviteType == 2 then
				if (AIA.db.profile.Types.SignUp == true and openStatus.inviteStatus == 8) then -- Not Signed Up, Sign Up if Option is selected.	
					if AIA.db.profile.Types.SignUpTentative == true then
						C_Calendar.EventTentative()
						return
					else
						C_Calendar.EventSignUp()
						return
					end
					return 
				end
			end
			
			C_Calendar.EventAvailable()
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

function AIA:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AIADB", Defaults) -- Setup Saved Variables	
	self:RegisterChatCommand("AIA", "ChatCommand") -- Register /AIA command

	-- Add Options
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AIA", Options)
	local Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	Options.args.profiles = Profiles
	Options.args.profiles.order = 99
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AIA", "AIA")
	InterfaceAddOnsList_Update()

	-- Profile Management
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
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

function AIA:ChatCommand(input)
	if string.lower(input) == "check" then
		AIA:CheckAgain()
	else
		if not InCombatLockdown() then
			InterfaceOptionsFrame_OpenToCategory("AIA","AIA")
			InterfaceOptionsFrame_OpenToCategory("AIA","AIA")
		else
			print("|cFFFF2C5AAIA: |r"..L["Cannot configure while in combat."])
		end
	end
end

function AIA:RefreshConfig()
	AIA.db.profile = self.db.profile
end

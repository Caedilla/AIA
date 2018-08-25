AIA = AIA or LibStub("AceAddon-3.0"):NewAddon("AIA", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("AIA")
local InvitesToAccept = {}
local InvitesAccepting = 0
local InvitesToAcceptNumDone = false
local Defaults = {
	profile = {
		DisableAfterRunning = true,
		NotifyDisable = true,
		NotifyFinish = true,
		Types = {
			Tentative = false,
			Declined = false,
			Invited = true
		},
		Filter = {
			Name = "",
			Title = "",
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

--[[
	CALENDAR_INVITESTATUS_INVITED      = 1
	CALENDAR_INVITESTATUS_ACCEPTED     = 2
	CALENDAR_INVITESTATUS_DECLINED     = 3
	CALENDAR_INVITESTATUS_CONFIRMED    = 4
	CALENDAR_INVITESTATUS_OUT          = 5
	CALENDAR_INVITESTATUS_STANDBY      = 6
	CALENDAR_INVITESTATUS_SIGNEDUP     = 7
	CALENDAR_INVITESTATUS_NOT_SIGNEDUP = 8
	CALENDAR_INVITESTATUS_TENTATIVE    = 9
]]--


--[[
C_Calendar.GetDayEvent(i,j,index)

.calendarType == String - One of "PLAYER", "GUILD", "ARENA", "HOLIDAY"
.invitedBy = Player who invited. "" if calendarType is not "PLAYER"
.title = Display Name
.eventType When calendarType is "PLAYER" 0 == Raid, 1 == Dungeon, 2 == PvP, 3 == Meeting, 4 == Other. For other calendarType values, numbers are different.
]]--

local Options = {
	type = "group",
	name = function(info)
		return "AIA - |cFFFF2C5AAccept Invites Automatically|r r|cFFFF2C5A" .. string.match(GetAddOnMetadata("RUF","Version"),"%d+") .."|r"
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
					name = "|cFFFFCC00"..L["Only Accept Invites From:"].."|r",
					desc = L["Only accept invites if they were sent from this player."].."\n"..L["Leave blank to allow all."],
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
					name = "|cFFFFCC00"..L["Only Accept invites with title:"].."|r",
					desc = L["Only accept invites if the title of the event matches this."].."\n"..L["Leave blank to allow all."],
					order = 22,
					type = "input",
					get = function(info)
						return AIA.db.profile.Filter.Title
					end,
					set = function(info, value)
						AIA.db.profile.Filter.Title = value
					end,
				},
				FilterType = {
					name = "|cFFFFCC00"..L["Only Accept invites of these types:"].."|r",
					desc = L["Only accept invites if the event type matches this."],
					order = 25,
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
					order = 30,
				},
				CheckAgain = {
					name = "|cFF80DAFF"..L["Check Again"].."|r",
					desc = L["Makes AIA Check if there is anything to accept now."],
					order = 31,
					type = "execute",
					func = function()
						print("|cFFFF2C5AAIA: |r"..L["Checking again!"])
						InvitesAccepting = 0
						InvitesToAcceptNumDone = false
						AIA:Enable()
						AIA:CreateCalendarList()
						AIA:AcceptInvite()
					end,
				},
			},
		},
	},
}



function AIA:EventChecker(event)
	if AIA.db.profile.Filter.Type[0] and event.eventType == 0 then return true end
	if AIA.db.profile.Filter.Type[1] and event.eventType == 1 then return true end
	if AIA.db.profile.Filter.Type[2] and event.eventType == 2 then return true end
	if AIA.db.profile.Filter.Type[3] and event.eventType == 3 then return true end
	if AIA.db.profile.Filter.Type[4] and event.eventType == 4 then return true end
	return false
end

function AIA:CreateCalendarList()
    wipe(InvitesToAccept)
	for i = 0,12 do
		for j = 1,31 do
			for index = 1,30 do
				local event = C_Calendar.GetDayEvent(i,j,index) or nil
				if event then
					if event.calendarType == "PLAYER" then
						if (AIA.db.profile.Types.Tentative == true and event.inviteStatus == 9) or (AIA.db.profile.Types.Declined == true and event.inviteStatus == 3) or (AIA.db.profile.Types.Invited == true and event.inviteStatus == 1) then
						if string.len(AIA.db.profile.Filter.Name) > 0  and string.lower(AIA.db.profile.Filter.Name) ~= string.lower(event.invitedBy) then return end
						if string.len(AIA.db.profile.Filter.Title) > 0 and string.lower(AIA.db.profile.Filter.Title) ~= string.lower(event.title) then return end
						if AIA:EventChecker(event) == false then return end
							local data = {
								monthOffset = i,
								day = j,
								index = index,
							}
							table.insert(InvitesToAccept,data)
							if InvitesToAcceptNumDone == false then
								InvitesAccepting = InvitesAccepting +1
							end
						end
					end
				end
			end
		end
	end
	InvitesToAcceptNumDone = true
end

function AIA:AcceptInvite()
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
			--if openStatus.inviteStatus == 1 or openStatus.inviteStatus == 9 then
			if (AIA.db.profile.Types.Tentative == true and openStatus.inviteStatus == 9) or (AIA.db.profile.Types.Declined == true and openStatus.inviteStatus == 3) or (AIA.db.profile.Types.Invited == true and openStatus.inviteStatus == 1) then
				C_Calendar.EventAvailable()
				return
			end			
		end
	end
end

function AIA:CheckAgain()
	print("|cFFFF2C5AAIA: |r"..L["Checking again!"])
	InvitesAccepting = 0
	InvitesToAcceptNumDone = false
	AIA:Enable()
	AIA:CreateCalendarList()
	AIA:AcceptInvite()
end

function AIA:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AIADB", Defaults, true) -- Setup Saved Variables	
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
    AIA.ListMonitor:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    --AIA.ListMonitor:RegisterEvent("PLAYER_ENTERING_WORLD")
    AIA.ListMonitor:SetScript("OnEvent", AIA.CreateCalendarList)
    
    AIA.Accepter = AIA.Accepter or CreateFrame("Frame", "AIA_Accepter")
    AIA.Accepter:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
    AIA.Accepter:RegisterEvent("CALENDAR_ACTION_PENDING")
    AIA.Accepter:RegisterEvent("CALENDAR_OPEN_EVENT")
    AIA.Accepter:SetScript("OnEvent", AIA.AcceptInvite)
end

function AIA:OnDisable()
	AIA.ListMonitor:UnregisterAllEvents()
	AIA.ListMonitor:SetScript("OnEvent", nil)
	AIA.Accepter:UnregisterAllEvents()
	AIA.Accepter:SetScript("OnEvent", nil)
	if AIA.db.profile.NotifyDisable then
		print("|cFFFF2C5AAIA: |r"..L["No more invites to accept. Shutting down."])
	end	
end

function AIA:ChatCommand(input)
	if not InCombatLockdown() then
		--LibStub("AceConfigDialog-3.0"):Open("AIA")
		InterfaceOptionsFrame_OpenToCategory("AIA","AIA")
		InterfaceOptionsFrame_OpenToCategory("AIA","AIA")
	else
		print("|cFFFF2C5AAIA: |r"..L["Cannot configure while in combat."])
	end
	if string.lower(input) == "check" then
		AIA:CheckAgain()
	end
end

function AIA:RefreshConfig()
	AIA.db.profile = self.db.profile
end
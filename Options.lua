local AIA = AIA or LibStub("AceAddon-3.0"):GetAddon("AIA")
local L = LibStub("AceLocale-3.0"):GetLocale("AIA")
local AIA_Options = AIA:NewModule("Options")

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

function AIA_Options:OnInitialize()
    self:SetEnabledState(false)
end

function AIA_Options:OnEnable()
	self.db = AIA.db -- Setup Saved Variables	

	-- Add Options
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("AIA", Options)
    local Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("AIA",600,730)
	Options.args.profiles = Profiles
	Options.args.profiles.order = 99

	-- Profile Management
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end

function AIA_Options:RefreshConfig()
	AIA.db.profile = self.db.profile
end
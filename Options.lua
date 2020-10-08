local AIA = LibStub('AceAddon-3.0'):GetAddon('AIA')
local L = LibStub('AceLocale-3.0'):GetLocale('AIA')
local AIA_Options = AIA:NewModule('Options')

local Options = {
	type = "group",
	name = function(info)
		return "AIA - |cFFFF2C5A"..L["Accept Invites Automatically"].. "|r r|cFFFF2C5A" .. string.match(GetAddOnMetadata("AIA","Version"),"%d+") .."|r"
	end,
	order = 0,
	childGroups = "tab",
	args = {
		Filters = {
			name = L["Filtering"],
			type = "group",
			order = 1,
			args = {
				Status = {
					name = L["Filter by status:"],
					type = "group",
					order = 0,
					inline = true,
					args = {
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
						SignUp = {
							name = "|cFF91be0f"..L["Not Signed Up"].."|r",
							desc = L["Sign Up to guild or community events that you are not signed up to or have not been specifically invited to."],
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
					},
				},
				Names = {
					name = L["Filter by event creator/inviter name:"],
					type = "group",
					order = 1,
					inline = true,
					args = {
						FilterName = {
							name = function()
								if AIA.db.profile.Types.Invited == false and AIA.db.profile.Types.Declined == false and AIA.db.profile.Types.Tentative == false then
									return L["Only accept invites sent by:"]
								else
									return "|cFFFFCC00"..L["Only accept invites sent by:"].."|r"
								end
							end,
							desc = L["Only accept event invites if they were sent by this player."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple names by separating each one with a comma."],
							order = 20,
							type = "input",
							width = 1.5,
							disabled = function()
								if AIA.db.profile.Types.Invited == false and AIA.db.profile.Types.Declined == false and AIA.db.profile.Types.Tentative == false then
									return true
								end
							end,
							get = function(info)
								return AIA.db.profile.Filter.Name
							end,
							set = function(info, value)
								AIA.db.profile.Filter.Name = value
							end,
						},
						Filter_SignUp_Name = {
							name = function()
								if AIA.db.profile.Types.SignUp == false then
									return L["Only sign up to events created by:"]
								else
									return "|cFF91be0f"..L["Only sign up to events created by:"].."|r"
								end
							end,
							desc = L["Only sign up to events if they were created by this player."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple names by separating each one with a comma."],
							order = 33,
							type = "input",
							width = 1.5,
							disabled = function()
								if AIA.db.profile.Types.SignUp == false then return true end
							end,
							get = function(info)
								return AIA.db.profile.Filter.SignUp.Name
							end,
							set = function(info, value)
								AIA.db.profile.Filter.SignUp.Name = value
							end,
						},
					},
				},
				Titles = {
					name = L["Filter by event title:"],
					type = "group",
					order = 2,
					inline = true,
					args = {
						FilterTitle = {
							name = function()
								if AIA.db.profile.Types.Invited == false and AIA.db.profile.Types.Declined == false and AIA.db.profile.Types.Tentative == false then
									return L["Only accept invites with title:"]
								else
									return "|cFFFFCC00"..L["Only accept invites with title:"].."|r"
								end
							end,
							desc = L["Only accept event invites if the title of the event matches this."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple events by separating each one with a comma."],
							order = 22,
							type = "input",
							width = 1.5,
							disabled = function()
								if AIA.db.profile.Types.Invited == false and AIA.db.profile.Types.Declined == false and AIA.db.profile.Types.Tentative == false then
									return true
								end
							end,
							get = function(info)
								return AIA.db.profile.Filter.Title
							end,
							set = function(info, value)
								AIA.db.profile.Filter.Title = value
							end,
						},
						Filter_SignUp_Title = {
							name = function()
								if AIA.db.profile.Types.SignUp == false then
									return L["Only sign up to events with title:"]
								else
									return "|cFF91be0f"..L["Only sign up to events with title:"].."|r"
								end
							end,
							desc = L["Only sign up to events if the title of the event matches this."].."\n"..L["Leave blank to allow all."].."\n"..L["You can enter multiple events by separating each one with a comma."],
							order = 35,
							type = "input",
							width = 1.5,
							disabled = function()
								if AIA.db.profile.Types.SignUp == false then return true end
							end,
							get = function(info)
								return AIA.db.profile.Filter.SignUp.Title
							end,
							set = function(info, value)
								AIA.db.profile.Filter.SignUp.Title = value
							end,
						},
					},
				},
				FilterType = {
					name = "|cFFFFCC00"..L["Filter by event type:"].."|r",
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
			},
		},
		Notifications = {
			name = L["Notifications"],
			type = "group",
			order = 0,
			args = {
				DisableAfterRunning = {
					name = "|cFF91be0f"..L["Disable After Running"].."|r",
					desc = L["Sets AIA to disable itself when it has accepted all the invites it is allowed to."].."\n"..L["If left unchecked, AIA will continue to scan and accept any new calendar events while you are playing."],
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
					name = function()
						if AIA.db.profile.DisableAfterRunning == false then
							return L["Notify when disabling"]
						else
							return "|cFF00b2fa"..L["Notify when disabling"].."|r"
						end
					end,
					desc = L["Sets if AIA should send a message to the chat window when it is disabled."],
					descStyle = "inline",
					width = "full",
					order = 1,
					type = "toggle",
					disabled = function()
						if AIA.db.profile.DisableAfterRunning == false then return true end
					end,
					get = function(info)
						return AIA.db.profile.NotifyDisable
					end,
					set = function(info, value)
						AIA.db.profile.NotifyDisable = value
					end,
				},
				Spacer1 = {
					name = " ",
					type = "description",
					width = "normal",
					order = 9,
				},
				NotifyFinish = {
					name = "|cFF00b2fa"..L["Notify when finished"].."|r",
					desc = L["Sets if AIA should send a message to the chat window when it has finished."],
					descStyle = "inline",
					width = "full",
					order = 10,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.NotifyFinish
					end,
					set = function(info, value)
						AIA.db.profile.NotifyFinish = value
					end,
				},
				OnlyNotifyIfAccepted = {
					name = function()
						if AIA.db.profile.NotifyFinish == false then
							return L["Notify only accepted invites"]
						else
							return "|cFF00b2fa"..L["Notify only accepted invites"].."|r"
						end
					end,
					desc = L["AIA will only notify when finished if there were any invites to accept."],
					descStyle = "inline",
					width = "full",
					order = 11,
					type = "toggle",
					disabled = function()
						if AIA.db.profile.NotifyFinish == false then return true end
					end,
					get = function(info)
						return AIA.db.profile.NotifyOnlyAccepted
					end,
					set = function(info, value)
						AIA.db.profile.NotifyOnlyAccepted = value
					end,
				},
				Spacer2 = {
					name = " ",
					type = "description",
					width = "normal",
					order = 19,
				},
				WarnIgnoredEvents = {
					name = "|cFFFF2C5A"..L["Warn about ignored events"].."|r",
					desc = L["Sets if AIA will send a message to the chat window if it ignores an event that does not meet the settings below. As a notification that you have unanswered events to deal with yourself."],
					descStyle = "inline",
					width = "full",
					order = 20,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.WarnIgnoredEvents
					end,
					set = function(info, value)
						AIA.db.profile.WarnIgnoredEvents = value
					end,
				},
			},
		},
		LDB = {
			name = L["Minimap"],
			type = "group",
			order = 60,
			args = {
				Display = {
					name = function()
						if AIA.db.profile.Minimap.hide then
							return "|cFFd83636"..L["Hide Minimap Icon"].."|r"
						else
							return "|cFF82d836"..L["Hide Minimap Icon"].."|r"
						end
					end,
					desc = L["Even if the minimap button is disabled, AIA still provides an LDB plugin if you want it to be displayed with addons such as StatBlockCore or TitanPanel."],
					width = 3,
					order = 0,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.Minimap.hide
					end,
					set = function(info, value)
						AIA.db.profile.Minimap.hide = value
						AIA:LDBDisplayState()
					end,
				},
				Lock = {
					name = function()
						if AIA.db.profile.Minimap.lock then
							return "|cFFd83636"..L["Lock Minimap Icon"].."|r"
						else
							return "|cFF82d836"..L["Lock Minimap Icon"].."|r"
						end
					end,
					width = 3,
					order = 1,
					type = "toggle",
					get = function(info)
						return AIA.db.profile.Minimap.lock
					end,
					set = function(info, value)
						AIA.db.profile.Minimap.lock = value
						AIA:LDBLockState()
					end,
				},
				MouseInteraction = {
					name = L["Mouse Button Interaction"],
					type = "group",
					inline = true,
					order = 30,
					args = {
						LeftClick = {
							name = "|cFFFFCC00"..L["Left Click functionality"].."|r",
							order = 40,
							type = "select",
							values = {
								[0] = L["Do Nothing"],
								[1] = L["Check Again"],
								[2] = L["Open Calendar"],
								[3] = L["Open Options"],
							},
							get = function(info,key)
								return AIA.db.profile.LDB.LeftClick
							end,
							set = function(info, key, value)
								AIA.db.profile.LDB.LeftClick = value
							end,
						},
						RightClick = {
							name = "|cFFFFCC00"..L["Right Click functionality"].."|r",
							order = 41,
							type = "select",
							values = {
								[0] = L["Do Nothing"],
								[1] = L["Check Again"],
								[2] = L["Open Calendar"],
								[3] = L["Open Options"],
							},
							get = function(info,key)
								return AIA.db.profile.LDB.RightClick
							end,
							set = function(info, key, value)
								AIA.db.profile.LDB.RightClick = value
							end,
						},
						MiddleClick = {
							name = "|cFFFFCC00"..L["Middle Click functionality"].."|r",
							order = 42,
							type = "select",
							values = {
								[0] = L["Do Nothing"],
								[1] = L["Check Again"],
								[2] = L["Open Calendar"],
								[3] = L["Open Options"],
							},
							get = function(info,key)
								return AIA.db.profile.LDB.MiddleClick
							end,
							set = function(info, key, value)
								AIA.db.profile.LDB.MiddleClick = value
							end,
						},
					},
				},
			},
		},
		CheckGroup = {
			name = " ",
			type = "group",
			inline = true,
			args = {
				CheckAgainSpacer = {
					name = " ",
					type = "description",
					width = "normal",
				},
				CheckAgain = {
					name = "|cFF40c840"..L["Check Again"].."|r",
					desc = L["Makes AIA Check if there is anything to accept now."],
					type = "execute",
					func = function()
						print("|cFFFF2C5AAIA: |r"..L["Checking again!"])
						AIA:Enable()
						AIA:CreateCalendarList()
						AIA:AcceptInvite()
					end,
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
	LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable('AIA', Options)
	local Profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
	LibStub('AceConfigDialog-3.0'):SetDefaultSize('AIA',590,715)
	Options.args.profiles = Profiles
	Options.args.profiles.order = 99

	-- Profile Management
	self.db.RegisterCallback(self, 'OnProfileChanged', 'RefreshConfig')
	self.db.RegisterCallback(self, 'OnProfileCopied', 'RefreshConfig')
	self.db.RegisterCallback(self, 'OnProfileReset', 'RefreshConfig')
end

function AIA_Options:RefreshConfig()
	AIA.db.profile = self.db.profile
end
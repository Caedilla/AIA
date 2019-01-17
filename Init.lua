local AIA = AIA or LibStub("AceAddon-3.0"):NewAddon("AIA", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("AIA")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("AIA", {type = "data source", text = "AIA"})

function AIA:TempOptions()
	local Options = {
		type = "group",
        name = function(info)
            return "AIA - |cFFFF2C5A"..L["Accept Invites Automatically"].. "|r r|cFFFF2C5A" .. string.match(GetAddOnMetadata("AIA","Version"),"%d+") .."|r"
        end,
		order = 0,
		args = {
				Open = {
					name = L["Open Configuration Panel"],
					type = "execute",
					order = 0,
					func = function() 
						HideUIPanel(InterfaceOptionsFrame) 
						HideUIPanel(GameMenuFrame)
						AIA:ChatCommand("Open") end,
				},
			},
		}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AIA_Blizz", Options) -- Register Options
	self.optionsFrame = AceConfigDialog:AddToBlizOptions("AIA_Blizz", "AIA")
end

function AIA:ChatCommand(input)
	if string.match(string.lower(input),"check") then
		AIA:CheckAgain()
    else
        if not InCombatLockdown() then
			self:EnableModule("Options")
			if AceConfigDialog.OpenFrames["AIA"] then
				AceConfigDialog:Close("AIA")
			else
				AceConfigDialog:Open("AIA")
			end
		else
			print("|cFFFF2C5AAIA: |r"..L["Cannot configure while in combat."])
		end
	end
end

function AIA:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AIADB", AIA.Defaults) -- Setup Saved Variables	
	self:RegisterChatCommand("AIA", "ChatCommand") -- Register /AIA command

	-- Profile Management
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    -- Add Button to Open AIA's Options panel.
	AIA:TempOptions()
	
	LDB.text = AIA.db.profile.LDB.DisplayName
	LDB.icon = "Interface\\Addons\\AIA\\Media\\AIA-Icon.tga"
	LibStub("LibDBIcon-1.0"):Register("AIA", LDB, AIA.db.profile.Minimap)
end

function AIA:RefreshConfig()
	AIA.db.profile = self.db.profile
	AIA:LDBDisplayState()
	AIA:LDBLockState()
end

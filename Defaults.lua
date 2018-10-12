local AIA = AIA or LibStub("AceAddon-3.0"):GetAddon("AIA")
local L = LibStub("AceLocale-3.0"):GetLocale("AIA")

local Defaults = {
	profile = {
		DisableAfterRunning = false,
		NotifyDisable = true,
		NotifyFinish = true,
		NotifyOnlyAccepted = true,
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
AIA.Defaults = Defaults
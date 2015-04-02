-- ------------------------
-- CONFIG
-- ------------------------

-- Faction watch timeout
-- Time in seconds until faction watch is turned off after a faction update
-- 60 = 1 minute, 900 = 15 min, etc.
local OobieUtil_FactionWatchTimeout = 600

-- Auto repair
-- 1 for on, nil for off
local OobieUtil_AutoRepair = 1

-- Auto repair from guild bank, if available
-- 1 for on, nil for off
local OobieUtil_GuildBankAutoRepair = nil

-- ------------------------
-- END CONFIG: DO NOT EDIT
-- BELOW HERE UNLESS YOU
-- KNOW WHAT YOU ARE DOING
-- ------------------------

-- ------------------------
-- GLOBAL VARIABLES
-- ------------------------

Stockpile = CreateFrame("Frame", "Stockpile", UIParent)

-- ------------------------
-- EVENT ACTIONS
-- ------------------------

actions = {

	["CHAT_MSG_LOOT"] = function(arg1, arg2)
		if string.find(arg1, "You receive loot") and string.find(arg1, "cffa335ee") then
			PlaySoundFile("Interface\\AddOns\\OobieUtil\\Item.ogg")
		end
	end,

	["CHAT_MSG_WHISPER"] = function(arg1, arg2)
		local zoneName = GetRealZoneText()
		if (arg1=="doobie") then
			InviteUnit(arg2)
		end
	end,

	["DUEL_REQUESTED"] = function(arg1, arg2)
		CancelDuel()
	end,

	["PLAYER_XP_UPDATE"] = function(arg1, arg2)
		SetWatchedFactionIndex(0)
	end,

	["TRAINER_SHOW"] = function(arg1, arg2)
		SetTrainerServiceTypeFilter("unavailable", 0)
	end,
}

-- -------------------------
-- ONLOAD FUNCTION
-- -------------------------

function Stockpile_OnLoad()

	for event, action in pairs(actions) do
		Stockpile:RegisterEvent(event)
	end

	Stockpile:SetScript("OnEvent", Stockpile.OnEvent)

end

-- -------------------------
-- ONEVENT FUNCTION
-- -------------------------
	
function Stockpile:OnEvent(event, arg1, arg2)

	actions[event](arg1,arg2)

end


-- -------------------------
-- MISC FUNCTIONS
-- -------------------------

-- p FUNCTION
-- Print.  Handy for debugging.
function p(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1, .4, .4)
end


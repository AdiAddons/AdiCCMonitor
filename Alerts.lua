--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

local mod = addon:NewModule('Alerts', 'AceEvent-3.0', 'AceTimer-3.0')

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName)
end

function mod:OnEnable()
	self:RegisterMessage('AdiCCMonitor_SpellAdded')
	self:RegisterMessage('AdiCCMonitor_SpellUpdated', "PlanNextUpdate")
	self:RegisterMessage('AdiCCMonitor_SpellRemoved')
	self.runningTimer = nil
end

--function mod:OnDisable()
--end

function mod:PlanNextUpdate()
	self:Debug('PlanNextUpdate')
	local nextTime
	local now = GetTime()
	for guid, spellId, spell in addon:IterateSpells() do
		local alertTime = spell.expires - 5
		local fadingSoon
		if alertTime > now then
			if not nextTime or alertTime < nextTime then
				nextTime = alertTime
			end
		else
			fadingSoon = true
		end
		if spell.fadingSoon ~= fadingSoon then
			spell.fadingSoon = fadingSoon
			if fadingSoon then
				self:Alert('warning', guid, spellId, spell)
			end
		end
	end
	if nextTime then
		if self.runningTimer then
			self:CancelTimer(self.runningTimer, true)
		end
		self:Debug('Next update in', nextTime - now)
		self.runningTimer = self:ScheduleTimer('PlanNextUpdate', nextTime - now)
	end
end

function mod:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
	self:Alert('applied', guid, spellId, spell)
	return self:PlanNextUpdate()
end

function mod:AdiCCMonitor_SpellRemoved(event, guid, spellID, spell)
	self:Alert('removed', guid, spellId, spell)
	return self:PlanNextUpdate()
end

function mod:Alert(messageID, guid, spellID, spell)
	--@not-debug@--
	if not IsInInstance() then return end
	--@end-not-debug@--
	local targetName = spell.symbol and format('{rt%d}', spell.symbol) or spell.target
	local timeLeft = floor(spell.expires - GetTime() + 0.5)
	local message
	if messageID == 'applied' or messageID == 'warning' then
		message = format(L['%s %d secs.'], targetName, timeLeft)
	elseif messageID == 'removed' then
		message = format(L['%s is free !'], targetName)
	end
	if message then
		SendChatMessage(message, "SAY")
	end
end

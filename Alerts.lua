--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

local mod = addon:NewModule('Alerts', 'AceEvent-3.0', 'AceTimer-3.0', 'LibSink-2.0')

local prefs

local DEFAULT_SETTINGS = {
	profile = {
		messages = { ['*'] = true },
		delay = 5,
	}
}

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, DEFAULT_SETTINGS)
end

function mod:OnEnable()
	prefs = self.db.profile
	self:SetSinkStorage(prefs)
	
	self:RegisterMessage('AdiCCMonitor_SpellAdded')
	self:RegisterMessage('AdiCCMonitor_SpellRemoved')
	self:RegisterMessage('AdiCCMonitor_SpellUpdated')
	self:RegisterMessage('AdiCCMonitor_WipeTarget', 'PlanNextUpdate')
	self.runningTimer = nil
end

--function mod:OnDisable()
--end

function mod:OnConfigChanged(key, ...)
	if key == 'delay' or (key == 'messages' and ... == 'warning') then
		self:PlanNextUpdate()
	end
end

function mod:PlanNextUpdate()
	if self.runningTimer then
		self:CancelTimer(self.runningTimer, true)
		self.runningTimer = nil
	end
	if not prefs.messages.warning then return end
	self:Debug('PlanNextUpdate')
	local delay = prefs.delay
	local nextTime
	local now = GetTime()
	for guid, spellId, spell in addon:IterateSpells() do
		local alertTime = spell.expires - delay
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
		self:Debug('Next update in', nextTime - now)
		self.runningTimer = self:ScheduleTimer('PlanNextUpdate', nextTime - now)
	end
end

function mod:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
	self:Alert('applied', guid, spellID, spell)
	return self:PlanNextUpdate()
end

function mod:AdiCCMonitor_SpellUpdated(event, guid, spellID, spell)
	return self:PlanNextUpdate()
end

function mod:AdiCCMonitor_SpellRemoved(event, guid, spellID, spell)
	self:PlanNextUpdate()
	local messageID = "removed"
	if prefs.messages.early and floor(spell.expires - GetTime()) > 0 and not (prefs.messages.warning and spell.fadingSoon) then
		messageID = "early"
	end
	self:Alert(messageID, guid, spellID, spell)
end

local SYMBOLS = {}
for i = 1, 8 do SYMBOLS[i] = '{'.._G["RAID_TARGET_"..i]..'}' end

function mod:Alert(messageID, guid, spellID, spell)
	if not prefs.messages[messageID] or not IsInstance() then
		return
	end
	local targetName = SYMBOLS[spell.symbol or false] or spell.target
	local timeLeft = floor(spell.expires - GetTime() + 0.5)
	local message
	if messageID == 'applied' or messageID == 'warning' then
		message = format(L['%s %d secs.'], targetName, timeLeft)
	elseif messageID == 'removed' or messageID == 'early' then
		message = format(L['%s is free !'], targetName)
	end
	if message then
		self:Pour('<<'..message..'>>', 1, 1, 1)
	end
end

function mod:GetOptions()
	local sinkOpts = self:GetSinkAce3OptionsDataTable()
	sinkOpts.order = 30
	sinkOpts.inline = true
	return {
		name = L['Alerts'],
		type = 'group',
		handler = addon:GetOptionHandler(self),
		set = 'Set',
		get = 'Get',
		disabled = 'IsDisabled',
		args = {
			messages = {
				name = L['Messages'],
				width = 'full',
				type = 'multiselect',
				values = {
					applied = L['Applied'],
					removed = L['Removed'],
					warning = L['About to end'],
					failure = L['Failures'],
					early = L['Broken early'],
				},
				order = 10,
			},
			delay = {
				name = L['Warning threshold (sec)'],
				desc = L['A warning message is sent when the time left for a spell runs below this value.'],
				type = 'range',
				min = 2,
				max = 15,
				step = 1,
				disabled = function(info) return info.handler:IsDisabled(info) or not prefs.messages.warning end,
				order = 20,
			},			
			output = sinkOpts,
		},
	}
end

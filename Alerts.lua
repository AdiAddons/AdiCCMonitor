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
		inInstances = {
			['*'] = false,
			party = true,
			raid = true,
		},
		messages = { ['*'] = true },
		delay = 5,
		numericalSymbols = (GetLocale() == "deDE"),
	}
}

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, DEFAULT_SETTINGS)
end

function mod:OnEnable()
	prefs = self.db.profile
	self:SetSinkStorage(prefs)
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateListeners')
	self:RegisterMessage('AdiCCMonitor_TestFlagChanged', 'UpdateListeners')
	self:UpdateListeners()
end

function mod:OnDisable()
	addon.UnregisterAllCombatLogEvents(self)
	self.runningTimer = nil
end

function mod:OnConfigChanged(key, ...)
	self:UpdateListeners()
end

function mod:UpdateListeners()
	local listening = addon.testing
	if not listening then
		local _, instanceType = IsInInstance()
		listening = prefs.inInstances[instanceType or "none"]
	end
	if listening then
		if not self.listening then
			self:RegisterMessage('AdiCCMonitor_SpellAdded')
			self:RegisterMessage('AdiCCMonitor_SpellUpdated', 'PlanNextUpdate')
			self:RegisterMessage('AdiCCMonitor_SpellRemoved')
			self:RegisterMessage('AdiCCMonitor_SpellBroken')
			self:RegisterMessage('AdiCCMonitor_WipeTarget', 'PlanNextUpdate')
			self.listening = true
			self:Debug('Started listening')
		end
		if prefs.messages.failure then
			addon.RegisterCombatLogEvent(self, 'SPELL_CAST_FAILED')
			addon.RegisterCombatLogEvent(self, 'SPELL_MISSED')
		else
			addon.UnregisterCombatLogEvent(self, 'SPELL_CAST_FAILED')
			addon.UnregisterCombatLogEvent(self, 'SPELL_MISSED')
		end
		self:PlanNextUpdate()
	elseif self.listening then
		self:UnregisterMessage('AdiCCMonitor_SpellAdded')
		self:UnregisterMessage('AdiCCMonitor_SpellRemoved')
		self:UnregisterMessage('AdiCCMonitor_SpellBroken')
		self:UnregisterMessage('AdiCCMonitor_SpellUpdated')
		self:UnregisterMessage('AdiCCMonitor_WipeTarget')
		addon.UnregisterAllCombatLogEvents(self)
		self:CancelRunningTimer()
		self.listening = nil
		self:Debug('Stopped listening')
	end
end

function mod:SPELL_CAST_FAILED(event, _, _, _, _, _, _, _, spellName, _, reason)
	self:Alert('failure', spellName, reason)
end

function mod:SPELL_MISSED(event, _, _, _, _, _, _, _, spellName, _, missType)
	self:Alert('failure', spellName, _G[missType] or missType)
end

function mod:CancelRunningTimer()
	if self.runningTimer then
		self:CancelTimer(self.runningTimer, true)
		self.runningTimer = nil
	end
end

local function HasOtherSpells(guid, ignoreSpellID)
	for spellID, spell in addon:IterateTargetSpells(guid) do
		if ignoreSpellID ~= spellID then
			return true
		end
	end
end

function mod:PlanNextUpdate()
	self:CancelRunningTimer()
	if not prefs.messages.warning then return end
	self:Debug('PlanNextUpdate')
	local delay = prefs.delay
	local nextTime
	local now = GetTime()
	for guid, data in addon:IterateTargets() do
		local maxTimeLeft, longestSpell
		for spellId, spell in addon:IterateTargetSpells(guid) do
			local alertTime = spell.expires - delay
			if alertTime > now and (not nextTime or alertTime < nextTime) then
				nextTime = alertTime
			end
			local timeLeft = spell.expires - now
			if timeLeft > 0 and (not maxTimeLeft or timeLeft > maxTimeLeft) then
				maxTimeLeft, longestSpell = timeLeft, spell
			end
		end
		if maxTimeLeft and maxTimeLeft < delay then
			if not data.warningAlert then
				data.warningAlert = true
				self:Alert('warning', longestSpell.target, longestSpell.symbol, longestSpell.expires)
			end
		else
			data.warningAlert = nil
		end
	end
	if nextTime then
		self:Debug('Next update in', nextTime - now)
		self.runningTimer = self:ScheduleTimer('PlanNextUpdate', nextTime - now)
	end
end

function mod:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
	self:PlanNextUpdate()
	for otherSpellID, otherSpell in addon:IterateTargetSpells(guid) do
		if otherSpellID ~= spellID and otherSpell.expires > spell.expires then
			return
		end
	end
	self:Alert('applied', spell.target, spell.symbol, spell.expires, spell.name)
end

function mod:AdiCCMonitor_SpellRemoved(event, guid, spellID, spell)
	self:PlanNextUpdate()
	-- Only announce if there is no other spell
	if not HasOtherSpells(guid, spellID) then
		if prefs.messages.early and spell.expires >= GetTime() + 1 and not addon:GetGUIDData(guid).warningAlert then
			self:Alert("early", spell.target, spell.symbol, spell.expires)
		else
			self:Alert("removed", spell.target, spell.symbol, spell.expires)
		end
	end
end

function mod:AdiCCMonitor_SpellBroken(event, guid, spellID, spell, brokenByName, brokenBySpell)
	self:PlanNextUpdate()
	if prefs.messages.early and not HasOtherSpells(guid, spellID) and not addon:GetGUIDData(guid).warningAlert then
		local raidID = UnitInRaid(brokenByName)
		local role = raidID and select(10, GetRaidRosterInfo(raidID)) or UnitGroupRolesAssigned(brokenByName)
		if role ~= "TANK" then
			self:Alert("early", spell.target, spell.symbol, spell.expires, brokenByName, brokenBySpell)
		end
	end
end

local SYMBOLS = { textual = {}, numerical = {} }
for i = 1, 8 do SYMBOLS.textual[i] = '{'.._G["RAID_TARGET_"..i]..'}' end
for i = 1, 8 do SYMBOLS.numerical[i] = '{rt'..i..'}' end

function mod:Alert(messageID, ...)
	if not prefs.messages[messageID] then
		return
	end
	self:Debug('Alert', messageID, ...)
	local message
	if messageID == 'failure' then
		local spell, reason = ...
		message = spell..': '..reason
	else
		local target, symbol, expires, moreArg, moreArg2 = ...
		local targetName = SYMBOLS[prefs.numericalSymbols and "numerical" or "textual"][symbol or false] or target
		local timeLeft = expires and floor(expires - GetTime() + 0.5)
		if messageID == 'applied' then
			message = format(L['%s is affected by %s, lasting %d seconds.'], targetName, moreArg, timeLeft)
		elseif messageID == 'warning' then
			message = format(L['%s will break free in %d seconds.'], targetName, timeLeft)
		elseif messageID == 'removed' then
			message = format(L['%s is free !'], targetName)
		elseif messageID == 'early' then
			if moreArg then
				message = format(L['%s has been freed by %s !'], targetName, moreArg)
				if moreArg2 then
					message = format('%s (%s)', message, moreArg2)
				end
			else
				message = format(L['%s has broken free!'], targetName)
			end
		end
	end
	if message then
		self:Pour('<<'..message..'>>', 1, 1, 1)
	end
end

function mod:GetOptions()
	local sinkOpts = self:GetSinkAce3OptionsDataTable()
	sinkOpts.order = 40
	sinkOpts.inline = true
	return {
		name = L['Alerts'],
		type = 'group',
		handler = addon:GetOptionHandler(self),
		set = 'Set',
		get = 'Get',
		disabled = 'IsDisabled',
		args = {
			inInstances = {
				name = L['Enabled in ...'],
				desc = L['AdiCCMonitor will keep quiet in unchecked zones.'],
				order = 5,
				type = 'multiselect',
				values = {
					raid = L['Raid instances'],
					party = L['5-man instances'],
					arena = L['Arenas'],
					pvp = L['Battlegrounds'],
					none = L['Open world'],
				},
			},
			messages = {
				name = L['Events to announce'],
				width = 'full',
				type = 'multiselect',
				values = {
					applied = L['Beginning'],
					removed = L['End'],
					warning = L['About to end'],
					failure = L['Failures'],
					early = L['Broken early'],
				},
				order = 10,
			},
			_earlyNote = {
				type = 'description',
				name = format(L["Note: '%s' ignores players flagged as tanks."], L['Broken early']),
				order = 11,
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
			numericalSymbols = {
				name = L['Alternative symbol strings'],
				desc = format(L["Use this option if %s or %s are not displayed as icons in chat frames. AdiCCMonitor will use {rt1}..{rt8} instead. Note: stock chat bubbles do not display any of them anyway."], SYMBOLS.textual[1], SYMBOLS.textual[8]),
				type = "toggle",
				order = 30,
			},
			output = sinkOpts,
		},
	}
end

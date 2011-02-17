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
		},
		messages = {
			['*'] = true,
			applied = false,
			removed = false,
		},
		ignoreTank = true,
		delay = 5,
	}
}

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, DEFAULT_SETTINGS)
end

function mod:OnEnable()
	prefs = self.db.profile
	self:SetSinkStorage(prefs)
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateListeners')

	self.partySize = 0
	self.announcer = nil
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('CHAT_MSG_ADDON')
	self:PARTY_MEMBERS_CHANGED('OnEnable')

	self:RegisterMessage('AdiCCMonitor_TestFlagChanged', 'UpdateListeners')
	self:UpdateListeners()
end

function mod:OnDisable()
	addon.UnregisterAllCombatLogEvents(self)
	self:CancelAllTimers()
	self:UpdateChattiness()
end

function mod:OnConfigChanged(key, ...)
	self:UpdateListeners()
	if key == "sink20OutputSink" then
		self:ScheduleTimer("UpdateChattiness", 1)
	end
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
			self:ScheduleTimer("UpdateChattiness", 1)
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
		self:CancelAllTimers()
		self.listening = nil
		self:Debug('Stopped listening')
		self:ScheduleTimer("UpdateChattiness", 1)
	end
end

-- Slightly facade to AceTimer that allows easy rescheduling
do
	local AceTimer = LibStub('AceTimer-3.0')
	local timers = {}
	
	local function ExecTimer(name)
		timers[name] = nil
		mod:Debug('Timer:', name)
		return mod[name](mod)
	end
	
	function mod:ScheduleTimer(name, delay)
		if timers[name] then
			AceTimer.CancelTimer(self, timers[name])
		end
		self:Debug('Scheduling', name, 'in', delay, 'secs')
		timers[name] = AceTimer.ScheduleTimer(self, ExecTimer, delay, name)
	end
	
	function mod:CancelTimer(name)
		if timers[name] then
			self:Debug('Canceling', name)
			AceTimer.CancelTimer(mod, timers[name], true)
			timers[name] = nil
		end
	end
	
	function mod:CancelAllTimers()
		AceTimer.CancelAllTimers(self)
		wipe(timers)
	end
	
end

local playerName = UnitName("player")

function mod:SendMessage(message)
	local channel = (select(2, IsInInstance()) == "pvp") and "BATTLEGROUND" or "RAID"
	if self.partySize == 0 then
		self:CHAT_MSG_ADDON("SendMessage", self.name, message, channel, playerName)
	else
		self:Debug('Sending to', channel, ':', message)
		SendAddonMessage(self.name, message, chan)
	end
end

function mod:SendQuery()
	self:SendMessage("QUERY")
end

function mod:UpdateChattiness()
	self:CancelTimer("SendQuery")
	local chatty = self:IsEnabled() and self.listening and prefs.sink20OutputSink == "Channel" or false
	if chatty ~= self.chatty then
		self.chatty = chatty
		self:SendQuery()
	end
end

function mod:SendReply()
	if self.chatty then
		self:SendMessage("REPLY")
	end
end

function mod:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	if prefix == self.name and sender then
		self:Debug("Message from", sender, ":", message)
		sender = strsplit('-', sender)
		if message == "QUERY" then
			self.announcer = self.chatty and playerName or nil
			self:CancelTimer("SendQuery")
			self:ScheduleTimer("SendReply", 1)
		elseif message == "REPLY" then
			if not self.announcer or sender < self.announcer then
				self.announcer = sender
				self:Debug('New announcer:', self.announcer)
			end
		end
	end
end

function mod:PARTY_MEMBERS_CHANGED()
	local partySize = GetNumRaidMembers()
	if partySize == 0 then
		partySize = GetNumPartyMembers()
	end
	if partySize ~= self.partySize then
		if self.partySize == 0 or (self.announcer and not UnitInParty(self.announcer) and not UnitInRaid(self.announcer)) then
			self:ScheduleTimer("SendQuery", 2)
		elseif partySize == 0 then
			self.announcer = nil
			self:CancelTimer("SendQuery")
			self:CancelTimer("SendReply")
		end
		self.partySize = partySize
	end
end

local ignoredFailures = {
	[SPELL_FAILED_INTERRUPTED] = true,
	[SPELL_FAILED_INTERRUPTED_COMBAT] = true,
	[SPELL_FAILED_NOT_READY] = true,
	[SPELL_FAILED_TARGETS_DEAD] = true,
	[ERR_GENERIC_NO_TARGET] = true,
}

function mod:SPELL_CAST_FAILED(event, _, sourceName, _, _, _, _, _, spellName, _, reason)
	if not ignoredFailures[reason] then
		sourceName = strsplit('-', sourceName)
		self:Alert('failure', sourceName, spellName, reason)
	end
end

function mod:SPELL_MISSED(event, _, sourceName, _, _, _, _, _, spellName, _, missType)
	sourceName = strsplit('-', sourceName)
	self:Alert('failure', sourceName, spellName, _G[missType] or missType)
end

local function HasOtherSpells(guid, ignoreSpellID)
	for spellID, spell in addon:IterateTargetSpells(guid) do
		if ignoreSpellID ~= spellID then
			return true
		end
	end
end

function mod:PlanNextUpdate()
	self:CancelTimer('PlanNextUpdate')
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
				self:Alert('warning', nil, longestSpell.target, longestSpell.symbol, longestSpell.expires)
			end
		else
			data.warningAlert = nil
			data.removedAlert = nil
		end
	end
	if nextTime then
		self:Debug('Next update in', nextTime - now)
		self:ScheduleTimer('PlanNextUpdate', nextTime - now)
	end
end

function mod:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
	self:PlanNextUpdate()
	for otherSpellID, otherSpell in addon:IterateTargetSpells(guid) do
		if otherSpellID ~= spellID and otherSpell.expires > spell.expires + 1 then
			return
		end
	end
	self:Alert('applied', spell.caster, spell.target, spell.symbol, spell.expires, spell.name)
end

function mod:AdiCCMonitor_SpellRemoved(event, guid, spellID, spell)
	self:PlanNextUpdate()
	if HasOtherSpells(guid, spellID) then return end
	local data = addon:GetGUIDData(guid)
	if not data.removedAlert then
		data.removedAlert = true
		self:Alert("removed", spell.caster, spell.target, spell.symbol, spell.expires)
	end
end

function mod:AdiCCMonitor_SpellBroken(event, guid, spellID, spell, brokenByName, brokenBySpell)
	self:PlanNextUpdate()
	if HasOtherSpells(guid, spellID) then return end
	local data = addon:GetGUIDData(guid)
	if data.removedAlert then return end
	data.removedAlert = true
	if prefs.ignoreTank and brokenByName then
		local role = UnitGroupRolesAssigned(brokenByName)
		if not role then
			local raidID = UnitInRaid(brokenByName)
			role = raidID and select(10, GetRaidRosterInfo(raidID))
		end
		if role == "TANK" then
			return
		end
	end
	if prefs.messages.early then
		if not data.warningAlert then
			self:Alert("early", spell.caster, spell.target, spell.symbol, spell.expires, brokenByName, brokenBySpell)
		end
	else
		self:Alert("removed", spell.caster, spell.target, spell.symbol, spell.expires)
	end
end

local SYMBOLS = {}
for i = 1, 8 do SYMBOLS[i] = '{'.._G["RAID_TARGET_"..i]..'}' end

function mod:Alert(messageID, caster, ...)
	if not prefs.messages[messageID] then
		self:Debug(messageID, 'alerts are disabled')
		return
	elseif not addon.testing and caster ~= playerName and self.announcer ~= playerName then
		self:Debug('Ignored alert for', caster, 'since we are not the group announcer')
		return
	end
	self:Debug('Alert', messageID, caster, ...)
	local message
	if messageID == 'failure' then
		local spell, reason = ...
		message = format("%s (%s): %s", spell, caster, reason)
	else
		local target, symbol, expires, moreArg, moreArg2 = ...
		local targetName = target
		if symbol then
			if prefs.sink20OutputSink ~= "Channel" or addon.testing then
				targetName = ICON_LIST[symbol].."0|t"
			else
				targetName = SYMBOLS[symbol]
			end
		end
		local timeLeft = expires and floor(expires - GetTime() + 0.5)
		if messageID == 'applied' then
			message = format(L['%s is affected by %s, lasting %d seconds.'], targetName, moreArg, timeLeft)
		elseif messageID == 'warning' then
			message = format(L['%s will break free in %d seconds.'], targetName, timeLeft)
		elseif messageID == 'removed' then
			message = format(L['%s is free !'], targetName)
		elseif messageID == 'early' then
			if moreArg then
				local name = strsplit('-', moreArg)
				message = format(L['%s has been freed by %s !'], targetName, name)
				if moreArg2 then
					message = format('%s (%s)', message, moreArg2)
				end
			else
				message = format(L['%s has broken free!'], targetName)
			end
		end
	end
	if message then
		message = '<< '..message..' >>'
		if addon.testing then
			print("|cff44ffaa"..format(L["%s would send this alert:"], addon.name).."|r\n"..message)
		else
			self:Pour(message, 1, 1, 1)
		end
	--@debug@
	else
		self:Debug('No message to send (!)')
	--@end-debug@
	end
end

function mod:GetOptions()

	-- Dynamic instance type list
	local allInstanceList = {
		raid = L['Raid instances'],
		party = L['5-man instances'],
		arena = L['Arenas'],
		pvp = L['Battlegrounds'],
		none = L['Open world'],
	}
	local instanceList = {}
	local function GetInstanceList()
		for key, label in pairs(allInstanceList) do
			instanceList[key] = addon.db.profile.inInstances[key] and label or nil
		end
		return instanceList
	end

	-- Fetch LibSink options
	local sinkOpts = self:GetSinkAce3OptionsDataTable()
	sinkOpts.order = 800
	sinkOpts.inline = true
	local sinkOptsSet = sinkOpts.set
	sinkOpts.set =  function(info, ...) 
		sinkOptsSet(info, ...)
		local key = info[#info]
		if key ~= "ScrollArea" and key ~= "Sticky" then
			return self:OnConfigChanged("sink20OutputSink")
		end
	end

	-- Finally our options
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
				values = GetInstanceList,
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
			ignoreTank = {
				name = L['Ignore tanks'],
				desc = L['Keep quiet when a character flagged as a tank breaks a spell.'],
				type = 'toggle',
				order = 30,
			},
			output = sinkOpts,
		},
	}
end

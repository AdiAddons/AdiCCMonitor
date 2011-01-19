--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0', 'AceConsole-3.0')
--@debug@
_G[addonName] = addon
--@end-debug@

--------------------------------------------------------------------------------
-- Debug stuff
--------------------------------------------------------------------------------

--@alpha@
if AdiDebug then
	AdiDebug:Embed(addon, addonName)
else
--@end-alpha@
	function addon.Debug() end
--@alpha@
end
--@end-alpha@

addon:SetDefaultModulePrototype{Debug = addon.Debug}

--------------------------------------------------------------------------------
-- Upvalues
--------------------------------------------------------------------------------

local prefs
local GUIDs = {}
local guidSymbols = {}
local playerSpellDurations = {}

--@debug@
addon.GUIDs = GUIDs
addon.playerSpellDurations = playerSpellDurations
--@end-debug@

--------------------------------------------------------------------------------
-- Default settings
--------------------------------------------------------------------------------

local DEFAULT_SETTINGS = {
	profile = {
		modules = { ['*'] = true },
		onlyMine = false,
	}
}

--------------------------------------------------------------------------------
-- Spell data by spell IDs
--------------------------------------------------------------------------------

-- Provides default durations
local SPELLS = {
	[  710] = 30, -- Banish
	[76780] = 50, -- Bind Elemental
	--[33786] =  6, -- Cyclone
  [  339] = 30, -- Entangling Roots
	[ 5782] = 20, -- Fear
	[ 3355] = 60, -- Freezing Trap
	[51514] = 60, -- Hex
	[ 2637] = 40, -- Hibernate
	[  118] = 50, -- Polymorph
	[61305] = 50, -- Polymorph (Black Cat)
	[28272] = 50, -- Polymorph (Pig)
	[61721] = 50, -- Polymorph (Rabbit)
	[61780] = 50, -- Polymorph (Turkey)
	[28271] = 50, -- Polymorph (Turtle)
	[20066] = 60, -- Repentance
	[ 6770] = 60, -- Sap
	[ 6358] = 30, -- Seduction
	[ 9484] = 50, -- Shackle Undead
	[10326] = 20, -- Turn Evil
	[19386] = 30, -- Wyvern Sting
}

--------------------------------------------------------------------------------
-- Addon initialization and enabling
--------------------------------------------------------------------------------

function addon:OnInitialize()
	self.db = LibStub('AceDB-3.0'):New(addonName.."DB", DEFAULT_SETTINGS, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "Reconfigure")
	self.db.RegisterCallback(self, "OnProfileCopied", "Reconfigure")
	self.db.RegisterCallback(self, "OnProfileReset", "Reconfigure")

	LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.db, addonName)

	LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, self.GetOptions)
	self.blizPanel = LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName, addonName)

	self:RegisterChatCommand("acm", "ChatCommand", true)
	self:RegisterChatCommand(addonName, "ChatCommand", true)
end

function addon:OnEnable()
	prefs = self.db.profile

	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('UNIT_TARGET')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:RegisterEvent('RAID_TARGET_UPDATE', 'FullRefresh')

	self.RegisterCombatLogEvent(self, 'SPELL_AURA_APPLIED')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_REFRESH', 'SPELL_AURA_APPLIED')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_REMOVED')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_BROKEN', 'SPELL_AURA_REMOVED')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_BROKEN_SPELL', 'SPELL_AURA_REMOVED')
	self.RegisterCombatLogEvent(self, 'UNIT_DIED')

	--@debug@
	self:RegisterMessage('AdiCCMonitor_SpellAdded', "SpellDebug")
	self:RegisterMessage('AdiCCMonitor_SpellUpdated', "SpellDebug")
	self:RegisterMessage('AdiCCMonitor_SpellRemoved', "SpellDebug")
	self:RegisterMessage('AdiCCMonitor_WipeTarget', "SpellDebug")
	--@end-debug@

	for name, module in self:IterateModules() do
		module:SetEnabledState(prefs.modules[name])
	end

	self:FullRefresh()
end

function addon:OnDisable()
	self:UnregisterAllCombatLogEvents()
	for guid in pairs(GUIDs) do
		self:RemoveTarget(guid, true)
	end
end

function addon:Reconfigure()
	self:Disable()
	self:Enable()
end

function addon:OnConfigChanged(key, ...)
	if key == 'modules' then
		local name, enabled = ...
		if enabled then
			self:GetModule(name):Enable()
		else
			self:GetModule(name):Disable()
		end
	elseif key == 'onlyMine' then
		self:FullRefresh()
	end
end

function addon:ChatCommand()
	InterfaceOptionsFrame_OpenToCategory(self.blizPanel)
end

--@debug@
function addon:SpellDebug(event, guid, spellID, spell)
	if event == 'AdiCCMonitor_WipeTarget' then
		self:Debug(event, guid)
	else
		self:Debug(event, guid, spellID, ':', spell.target, spell.name, spell.symbol, spell.accurate, spell.duration, spell.expires)
	end
end
--@end-debug@

--------------------------------------------------------------------------------
-- Table recycling
--------------------------------------------------------------------------------

local new, del
do
	local heap = setmetatable({}, {__mode = 'k'})
	function new()
		local t = next(heap)
		if t then
			heap[t] = nil
		else
			t = {}
		end
		return t
	end
	function del(t)
		wipe(t)
		heap[t] = true
	end
end

--------------------------------------------------------------------------------
-- Test
--------------------------------------------------------------------------------

do
	local AceTimer = LibStub('AceTimer-3.0')
	local timerSelf = addonName..'Test'
	local testGUID, testName = "TEST", "DUMMY"
	local testID

	local function CheckTestMode()
		if not GUIDs[testGUID] then
			self.testing = false
			self:SendMessage('AdiCCMonitor_TestFlagChanged', false)
		end
	end

	local function RemoveTimer(spellID)
		addon:RemoveSpell(testGUID, spellID)
		return CheckTestMode()
	end

	local function BreakTimer(spellID)
		addon:RemoveSpell(testGUID, spellID, false, "TEST")
		return CheckTestMode()
	end

	function addon:Test()
		self.testing = not GUIDs[testGUID]
		self:SendMessage('AdiCCMonitor_TestFlagChanged', self.testing)
		AceTimer.CancelAllTimers(timerSelf)
		if self.testing then
			local now = GetTime()
			local toBreak = random(1, 5)
			for i = 1, 5 do
				local duration, name
				while not name do
					testID, duration = next(SPELLS, testID)
					name = testID and GetSpellInfo(testID)
				end
				local timeLeft = random(duration * 2, duration * 10) / 10
				local expires = now + timeLeft
				local isMine = IsSpellKnown(testID)
				local symbol = 1 + i % 8
				self:UpdateSpell(testGUID, testID, name, testName, symbol, duration, expires, isMine, "*Test*", true)
				if i == toBreak then
					AceTimer.ScheduleTimer(timerSelf, BreakTimer, random(1, timeLeft), testID)
				else
					AceTimer.ScheduleTimer(timerSelf, RemoveTimer, timeLeft, testID)
				end
			end
		else
			self:RemoveTarget(testGUID)
		end
	end
end

--------------------------------------------------------------------------------
-- Spell data handling
--------------------------------------------------------------------------------

function addon:GetGUIDData(guid)
	local data, isNew = GUIDs[guid], false
	if not data then
		data = new()
		data.spells = {}
		GUIDs[guid] = data
		isNew = true
	end
	return data, isNew
end

function addon:GetSpellData(guid, spellID)
	local data, isNew = self:GetGUIDData(guid)
	local spell
	if data then
		spell = data.spells[spellID]
		if not spell then
			spell = new()
			data.spells[spellID] = spell
			isNew = true
		end
	end
	return spell, isNew
end

function addon:UpdateSpell(guid, spellID, name, target, symbol, duration, expires, isMine, caster, accurate)
	local spell, isNew = self:GetSpellData(guid, spellID)
	if not isNew and not accurate and spell.accurate then
		self:Debug('Ignore inaccurate data for', spellID, 'on', guid)
		return
	end
	if caster then
		-- Remove the realm
		local _
		caster, _ = strsplit('-', caster, 1)
	end
	if spell.name ~= name or spell.target ~= target or spell.symbol ~= symbol or spell.accurate ~= accurate or spell.duration ~= duration or spell.expires ~= expires or self.caster ~= caster or self.isMine ~= isMine then
		spell.name = name
		spell.target = target
		spell.symbol = symbol
		spell.accurate = accurate
		spell.duration = duration
		spell.expires = expires
		spell.caster = caster
		spell.isMine = isMine
		self:SendMessage(isNew and 'AdiCCMonitor_SpellAdded' or 'AdiCCMonitor_SpellUpdated', guid, spellID, spell)
	end
end

function addon:RemoveSpell(guid, spellID, silent, brokenByName)
	local data = GUIDs[guid]
	local spell = data and data.spells[spellID]
	if spell then
		if not silent then
			self:SendMessage('AdiCCMonitor_SpellRemoved', guid, spellID, spell, brokenByName)
		end
		data.spells[spellID] = del(spell)
		if not next(data.spells) then
			self:Debug('Cleaning up guid', guid)
			GUIDs[guid] = del(data)
		end
	end
end

function addon:RemoveTarget(guid, silent)
	local data = GUIDs[guid]
	guidSymbols[guid] = nil
	if data then
		for id in pairs(data.spells) do
			self:RemoveSpell(guid, id, true)
		end
		if not silent then
			self:SendMessage('AdiCCMonitor_WipeTarget', guid)
		end
	end
end

local seen = {}
function addon:RefreshFromUnit(unit)
	local guid = unit and UnitGUID(unit)
	if not guid or not UnitCanAttack("player", unit) then
		return
	end
	self:Debug('RefreshFromUnit', unit, guid)
	wipe(seen)
	-- Scan current debuffs
	local filter = prefs.onlyMine and "PLAYER" or ""
	local targetName = UnitName(unit)
	local symbol = GetRaidTargetIndex(unit)
	guidSymbols[guid] = symbol
	local index = 0
	repeat
		index = index + 1
		local name, _, _, _, _, duration, expires, caster, _, _, spellID = UnitDebuff(unit, index, nil, filter)
		if name and spellID and SPELLS[spellID] then
			local isMine = (caster == 'player' or caster == 'pet' or caster == 'vehicle')
			seen[spellID] = true
			self:UpdateSpell(guid, spellID, name, targetName, symbol, duration, expires, isMine, UnitName(caster or ""), true)
			local casterGUID = UnitGUID(caster)
			if casterGUID then
				playerSpellDurations[casterGUID..'-'..spellID] = duration
			end
		end
	until not name
	-- Removed debuffs we haven't seen
	for spellID in pairs(self:GetGUIDData(guid).spells) do
		if not seen[spellID] then
			self:RemoveSpell(guid, spellID)
		end
	end
end

function addon:FullRefresh()
	self:RefreshFromUnit('target')
	self:RefreshFromUnit('focus')
	self:RefreshFromUnit('mouseover')
	local prefix, num = "raidtarget", GetNumRaidMembers()
	if num == 0 then
		prefix, num = "partytarget", GetNumPartyMembers()
	end
	for i = 1, num do
		self:RefreshFromUnit(prefix..num)
	end
end

local function spellIterator(t)
	repeat
		if t.data then
			local spell
			t.spellID, spell = next(t.data.spells, t.spellID)
			if t.spellID then
				return t.guid, t.spellID, spell
			end
		end
		t.guid, t.data = next(GUIDs, t.guid)
	until not t.guid
	del(t)
end

function addon:IterateSpells()
	return spellIterator, new()
end

--------------------------------------------------------------------------------
-- Event handling
--------------------------------------------------------------------------------

function addon:UNIT_AURA(event, unit)
	if unit == 'target' or unit == 'focus' then
		return self:RefreshFromUnit(unit)
	end
end

local lastMouseoverGUID, lastMouseoverTime = nil, 0
function addon:UPDATE_MOUSEOVER_UNIT(event)
	if not UnitIsUnit('mouseover', 'target') and not UnitIsUnit('mouseover', 'focus') then
		local guid, now = UnitGUID("mouseover"), GetTime()
		if guid and (lastMouseoverGUID ~= guid or (now or 0) - lastMouseoverTime >= 1 or GetRaidTargetIndex("mouseover") ~= guidSymbols[guid]) then
			lastMouseoverGUID, lastMouseoverTime = guid, now
			return self:RefreshFromUnit("mouseover")
		end
	end
end

function addon:UNIT_TARGET(event, unit)
	local target = (unit == "player") and "target" or gsub(unit.."target", "(%d+)target", "target%1")
	if not UnitIsUnit(target, 'focus') then
		return self:RefreshFromUnit(target)
	end
end

function addon:PLAYER_FOCUS_CHANGED()
	if not UnitIsUnit('focus', 'target') then
		return self:RefreshFromUnit('focus')
	end
end

local bor, band = bit.bor, bit.band

local SYMBOL_MASK = 0
local SYMBOLS = {}
for i = 1, 8 do
	local flag = _G['COMBATLOG_OBJECT_RAIDTARGET'..i]
	SYMBOL_MASK = bor(SYMBOL_MASK, flag)
	SYMBOLS[flag] = i
end

local function GetSymbol(guid, flags)
	return SYMBOLS[band(flags, SYMBOL_MASK)] or guidSymbols[guid]
end

local function GetDefaultDuration(guid, spellID)
	return guid and spellID and (playerSpellDurations[guid..'-'..spellID] or SPELLS[spellID])
end

function addon:SPELL_AURA_APPLIED(_, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName)
	local isMine = band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
	local duration = GetDefaultDuration(sourceGUID, spellID)
	self:UpdateSpell(destGUID, spellID, spellName, destName, GetSymbol(destGUID, destFlags), duration, GetTime()+duration, isMine, sourceName)
end

function addon:SPELL_AURA_REMOVED(event, sourceGUID, sourceName, _, destGUID, _, _, spellID)
	self:RemoveSpell(destGUID, spellID, false, strmatch(event, 'BROKEN') and sourceName or nil)
end

function addon:UNIT_DIED(_, _, _, _, destGUID)
	self:RemoveTarget(destGUID)
end

--------------------------------------------------------------------------------
-- Combat log dispatching
--------------------------------------------------------------------------------

local methods = {}
local combatLogCallbacks = LibStub('CallbackHandler-1.0'):New(methods, "RegisterCombatLogEvent", "UnregisterCombatLogEvent", "UnregisterAllCombatLogEvents")
for k, v in pairs(methods) do addon[k] = v end

local usedLogEvents = {}
local AceEvent = LibStub('AceEvent-3.0')

function combatLogCallbacks:OnUsed(_, event)
	usedLogEvents[event] = true
	AceEvent.RegisterEvent(combatLogCallbacks, 'COMBAT_LOG_EVENT_UNFILTERED', 'OnEvent')
end

function combatLogCallbacks:OnUnused(_, event)
	usedLogEvents[event] = nil
	if not next(usedLogEvents) then
		AceEvent.UnregisterEvent(combatLogCallbacks, 'COMBAT_LOG_EVENT_UNFILTERED')
	end
end

function combatLogCallbacks:OnEvent(_, _, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, ...)
	if destGUID and band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 and usedLogEvents[event] then
		if strsub(event, 1, 6) == 'SPELL_' then
			if not spellID or not SPELLS[spellID] then
				return
			elseif prefs.onlyMine then
				if band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == 0 then
					return
				end
			elseif band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) ~= 0 then
				return
			end
		end
		return self:Fire(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, ...)
	end
end

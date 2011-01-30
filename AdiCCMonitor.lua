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

-- Spells with variable duration
local VARIABLE_DURATION_SPELLS = {
	[ 3355] = true, -- Freezing Trap
	[ 6770] = true, -- Sap
}

-- Spells that do not break on first damage
local RESILIENT_SPELLS = {
	[  339] = true, -- Entangling Roots
	[ 5782] = true, -- Fear
	[51514] = true, -- Hex
	[10326] = true, -- Turn Evil
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
	self:RegisterEvent('PLAYER_ENTERING_WORLD', 'FullRefresh')
	self:RegisterEvent('PLAYER_LEAVING_WORLD')

	self.RegisterCombatLogEvent(self, 'SPELL_AURA_APPLIED')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_REFRESH')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_REMOVED')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_BROKEN')
	self.RegisterCombatLogEvent(self, 'SPELL_AURA_BROKEN_SPELL', 'SPELL_AURA_BROKEN')
	self.RegisterCombatLogEvent(self, 'UNIT_DIED')
	
	self.RegisterCombatLogEvent(self, 'SPELL_DAMAGE')
	self.RegisterCombatLogEvent(self, 'RANGE_DAMAGE', 'SPELL_DAMAGE')
	self.RegisterCombatLogEvent(self, 'SPELL_PERIODIC_DAMAGE', 'SPELL_DAMAGE')
	self.RegisterCombatLogEvent(self, 'SWING_DAMAGE')
	
	--@debug@
	self:RegisterMessage('AdiCCMonitor_SpellAdded', "SpellDebug")
	self:RegisterMessage('AdiCCMonitor_SpellUpdated', "SpellDebug")
	self:RegisterMessage('AdiCCMonitor_SpellRemoved', "SpellDebug")
	self:RegisterMessage('AdiCCMonitor_SpellBroken', "SpellDebug")
	self:RegisterMessage('AdiCCMonitor_WipeTarget', "SpellDebug")
	--@end-debug@

	for name, module in self:IterateModules() do
		module:SetEnabledState(prefs.modules[name])
	end

	self:FullRefresh()
end

function addon:OnDisable()
	self:UnregisterAllCombatLogEvents()
	self:WipeAll(true)
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
function addon:SpellDebug(event, guid, spellID, spell, ...)
	if event == 'AdiCCMonitor_WipeTarget' then
		self:Debug(event, guid)
	else
		self:Debug(event, guid, spellID, '{', 'target=', spell.target, 'name=', spell.name, 'symbol=', spell.symbol, 'accurate=', spell.accurate, 'duration=', spell.duration, 'expires=', spell.expires, 'caster=', spell.caster, 'isMine=', spell.isMine, '}', ...)
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
			addon.testing = false
			addon:SendMessage('AdiCCMonitor_TestFlagChanged', false)
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

function addon:GetGUIDData(guid, passive)
	local data, isNew = GUIDs[guid], false
	if not data and not passive then
		data = new()
		data.spells = new()
		GUIDs[guid] = data
		isNew = true
	end
	return data, isNew
end

function addon:GetSpellData(guid, spellID, passive)
	local data, isNew = self:GetGUIDData(guid, passive)
	local spell
	if data then
		spell = data.spells[spellID]
		if not spell and not passive then
			spell = new()
			data.spells[spellID] = spell
			isNew = true
		end
	end
	return spell, isNew, data
end

function addon:UpdateSpell(guid, spellID, name, target, symbol, duration, expires, isMine, caster, accurate)
	local spell, isNew = self:GetSpellData(guid, spellID)
	if spell and not isNew and RESILIENT_SPELLS[spellID] and not accurate and spell.accurate then
		self:Debug('Ignore inaccurate data for', spellID, 'on', guid)
		return
	end
	if caster then		
		caster = strsplit('-', caster) -- Strip realm name
	end
	if expires then
		expires = ceil(expires*10)/10
	end
	isMine = not not isMine
	accurate = not not accurate
	if isNew or spell.name ~= name or spell.target ~= target or spell.symbol ~= symbol or spell.accurate ~= accurate or spell.duration ~= duration or spell.expires ~= expires or spell.caster ~= caster or spell.isMine ~= isMine then
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

local function delGUID(guid)
	addon:Debug('Cleaning up guid', guid)
	local data = GUIDs[guid]
	for id, spell in pairs(data.spells) do
		del(spell)
	end
	del(data.spells)
	del(data)
	GUIDs[guid] = nil
end

function addon:RemoveSpell(guid, spellID, silent, brokenByName, brokenBySpell)
	local spell, _, data = self:GetSpellData(guid, spellID, true)
	if spell then
		if not silent then
			local broken = brokenByName or spell.expires > GetTime() + 1
			self:SendMessage(broken and 'AdiCCMonitor_SpellBroken' or 'AdiCCMonitor_SpellRemoved', guid, spellID, spell, brokenByName, brokenBySpell)
		end
		data.spells[spellID] = del(spell)
		if not next(data.spells) then
			delGUID(guid)
		end
	end
end

function addon:RemoveTarget(guid, silent)
	guidSymbols[guid] = nil
	if GUIDs[guid] then
		if not silent then
			self:SendMessage('AdiCCMonitor_WipeTarget', guid)
		end
		delGUID(guid)
	end
end

function addon:WipeAll(silent)
	for guid in pairs(GUIDs) do
		self:RemoveTarget(guid, silent)
	end
end

function addon:PLAYER_LEAVING_WORLD()
	return self:WipeAll()
end

local seen = {}
function addon:RefreshFromUnit(unit)
	local guid = unit and UnitGUID(unit)
	if not guid or not UnitCanAttack("player", unit) then
		return
	end
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
			if VARIABLE_DURATION_SPELLS[spellID] then
				local casterGUID = UnitGUID(caster)
				if casterGUID then
					playerSpellDurations[casterGUID..'-'..spellID] = duration
				end
			end
		end
	until not name
	-- Removed debuffs we haven't seen
	for spellID in self:IterateTargetSpells(guid) do
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

function addon:IterateTargets()
	return pairs(GUIDs)
end

local function NOOP() end
function addon:IterateTargetSpells(guid)
	local data = guid and GUIDs[guid]
	if data and data.spells then
		return pairs(data.spells)
	else
		return NOOP
	end
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
	if guid and spellID then
		if VARIABLE_DURATION_SPELLS[spellID] then
			local accurateDuration = playerSpellDurations[guid..'-'..spellID]
			if accurateDuration then
				return accurateDuration, true
			else
				return SPELLS[spellID], false
			end
		else
			return SPELLS[spellID], true
		end
	end
end

function addon:SPELL_AURA_APPLIED(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName)
	self:Debug(event, sourceName, spellName, destGUID)
	local isMine = band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
	local duration, isAccurate = GetDefaultDuration(sourceGUID, spellID)
	self:UpdateSpell(destGUID, spellID, spellName, destName, GetSymbol(destGUID, destFlags), duration, GetTime()+duration, isMine, sourceName, isAccurate)
end

function addon:SPELL_AURA_REFRESH(...)
	-- REFRESH events are sent for resilient spells when their target takes damages.
	if not RESILIENT_SPELLS[select(8, ...)] then
		return self:SPELL_AURA_APPLIED(...)
	end
end

function addon:SPELL_AURA_REMOVED(event, _, _, _, destGUID, _, _, spellID)
	self:Debug(event, destGUID, spellID)
	local data = GUIDs[destGUID]
	if data then
		if RESILIENT_SPELLS[spellID] then
			self:RemoveSpell(destGUID, spellID, false, data.lastDamagedBy, data.lastDamagedWith)
		else
			self:RemoveSpell(destGUID, spellID)
		end
	end
end

function addon:SPELL_AURA_BROKEN(event, _, sourceName, _, destGUID, _, _, spellID, _, _, _, brokenBySpell)
	self:Debug(event, sourceName, brokenBySpell, destGUID)
	self:RemoveSpell(destGUID, spellID, false, sourceName, event == 'SPELL_AURA_BROKEN_SPELL' and brokenBySpell or nil)
end

function addon:UNIT_DIED(_, _, _, _, destGUID)
	self:RemoveTarget(destGUID)
end

function addon:SPELL_DAMAGE(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName)
	if spellID ~= 339 then -- Ignore damage from entangling roots
		local data = GUIDs[destGUID]
		if data then
			self:Debug(event, sourceName, destName, spellName)
			data.lastDamagedBy, data.lastDamagedWith = sourceName, spellName
		end
	end
end

local autoAttackID, autoAttackName = 6603
function addon:SWING_DAMAGE(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
	if not autoAttackName then autoAttackName = GetSpellInfo(autoAttackID) end
	return self:SPELL_DAMAGE(event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, autoAttackID, autoAttackName)
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
		if strsub(event, 1, 11) == 'SPELL_AURA_' then
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

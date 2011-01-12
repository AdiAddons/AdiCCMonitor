--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')
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

--@debug@
addon.GUIDs = GUIDs
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

end

function addon:OnEnable()
	prefs = self.db.profile

	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('UNIT_TARGET')
	self:RegisterEvent('PLAYER_FOCUS_CHANGED')
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	self:RegisterEvent('RAID_TARGET_UPDATE', 'FullRefresh')

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

function addon:UpdateSpell(guid, spellID, name, target, symbol, duration, expires, accurate)
	local spell, isNew = self:GetSpellData(guid, spellID)
	if not isNew and not accurate and spell.accurate then
		self:Debug('Ignore inaccurate data for', spellID, 'on', guid)
		return
	end
	if symbol == false then
		symbol = spell.symbol
	end
	if spell.name ~= name or spell.target ~= target or spell.symbol ~= symbol or spell.accurate ~= accurate or spell.duration ~= duration or spell.expires ~= expires then
		spell.name = name
		spell.target = target
		spell.symbol = symbol
		spell.accurate = accurate
		spell.duration = duration
		spell.expires = expires
		self:SendMessage(isNew and 'AdiCCMonitor_SpellAdded' or 'AdiCCMonitor_SpellUpdated', guid, spellID, spell)
	end
end

function addon:RemoveSpell(guid, spellID, silent)
	local data = GUIDs[guid]
	local spell = data and data.spells[spellID]
	if spell then
		if not silent then
			self:SendMessage('AdiCCMonitor_SpellRemoved', guid, spellID, spell)
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
	local index = 0
	repeat
		index = index + 1
		local name, _, _, _, _, duration, expires, caster, _, _, spellID = UnitDebuff(unit, index, nil, filter)
		if name and spellID and SPELLS[spellID] then
			seen[spellID] = true
			self:UpdateSpell(guid, spellID, name, targetName, symbol, duration, expires, true)
		end
	until not name
	-- Removed debuffs we haven't seen
	for spellID in pairs(self:GetGUIDData(guid).spells) do
		if not seen[spellID] then
			self:RemoveSpell(guid, spellID)
		end
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
		t.guid, t.data = next(addon.GUIDs, t.guid)
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
		if lastMouseoverGUID ~= guid or (now or 0) - lastMouseoverTime >= 1 then
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

local function GetSymbol(flags)
	return SYMBOLS[band(flags, SYMBOL_MASK)]
end

function addon:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, _, ...)
	if not destGUID or band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0 or (prefs.onlyMine and band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == 0) then return end
	if event == 'SPELL_AURA_APPLIED' then
		if spellID and SPELLS[spellID] then
			local duration = SPELLS[spellID]
			self:UpdateSpell(destGUID, spellID, spellName, destName, GetSymbol(destFlags) or false, duration, GetTime()+duration)
		end
	elseif destGUID and GUIDs[destGUID] then
		if event == 'UNIT_DIED' then
			self:RemoveTarget(destGUID)
		elseif spellID and SPELLS[spellID] and GUIDs[destGUID].spells[spellID] then
			if strsub(event, 1, 17) == 'SPELL_AURA_BROKEN' then
				self:RemoveSpell(destGUID, spellID)
			elseif event == 'SPELL_AURA_REFRESH' then
				local duration = SPELLS[spellID]
				self:UpdateSpell(destGUID, spellID, spellName, destName, GetSymbol(destFlags) or false, duration, GetTime()+duration)
			elseif event == 'SPELL_AURA_REMOVED' then
				self:RemoveSpell(destGUID, spellID)
			end
		end
	end
end

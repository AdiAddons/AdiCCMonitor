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
-- Default settings
--------------------------------------------------------------------------------

local DEFAULT_SETTINGS = {
	profile = {
	}
}

--------------------------------------------------------------------------------
-- Spell data by spell IDs
--------------------------------------------------------------------------------

-- Provides default durations
local SPELLS = {
	[  710] = 30, -- Banish
	[76780] = 50, -- Bind Elemental
	[33786] =  6, -- Cyclone
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
	self.GUIDs = {}
end

function addon:OnEnable()
	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('UNIT_TARGET')
	self:RegisterEvent('PLAYTER_TARGET_CHANGED')
	self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end

function addon:OnDisable()
	for guid in pairs(self.GUIDs) do
		self:RemoveTarget(guid)
	end
end

function addon:Reconfigure()
	self:Disable()
	self:Enable()
end

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
	local data, isNew = self.GUIDs[guid], false
	if not data then
		data = new()
		data.spells = {}
		self.GUIDs[guid] = data
		isNew = true
	end
	return data, isNew
end

function addon:GetSpellData(guid, spellID)
	local data, isNew = self:GetSpellData(guid)
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

function addon:UpdateSpell(guid, spellID, duration, expires, accurate)
	local spell, isNew = self:GetSpellData(guid, spellID)
	if not isNew and not accurate and spell.accurate then return end
	if spell.duration ~= duration or spell.expires ~= expires then
		spell.accurate = accurate
		spell.duration = duration
		spell.expires = expires
		self:SendMessage(isNew and 'AddCCMonitor_SpellAdded' or 'AddCCMonitor_SpellUpdated', guid, spellID)
	end
end

function addon:RemoveSpell(guid, spellID)
	local data = self.GUIDs[guid]
	local spell = data and data.spells[spellID]
	if spell then
		self:SendMessage('AdiCCMonitor_SpellRemoved', guid, spellID)
		data.spells[spellID] = del(spell)
		if not next(data.spells) then
			self.GUIDs[guid] = del(data)
		end
	end
en

function addon:RemoveTarget(guid)
	local data = self.GUIDs[guid]
	if data then
		for id in pairs(data.spells) do
			self:RemoveSpell(guid, id)
		end
	end
end

local seen = {}
function addon:RefreshFromUnit(unit)
	local guid = unit and UnitGUID(unit)
	if not guid or not UnitCanAttack("player", unit) then return end
	wipe(seen)
	local index = 1
	repeat
		index = index + 1
		local name, _, _, _, _, duration, expires, caster, _, _, spellID = UnitDebuff(unit, index)
		if name and spellID and SPELLS[spellID] then
			seen[spellID] = true
			self:UpdateSpell(guid, spellID, duration, expires, true)
		end
	until not name
	for spellID in pairs(self:GetGUIDData(guid).spells) do
		if not seen[spellID] then
			self:RemoveSpell(guid, spellID)
		end
	end
end

--------------------------------------------------------------------------------
-- Event handling
--------------------------------------------------------------------------------

function addon:UNIT_AURA(event, unit)
	return self:RefreshFromUnit(unit, true)
end

function addon:PLAYTER_TARGET_CHANGED()
	return self:RefreshFromUnit("target")
end

function addon:UPDATE_MOUSEOVER_UNIT(event, unit)
	return self:RefreshFromUnit("mouseover")
end

function addon:UNIT_TARGET(event, unit)
	return self:RefreshFromUnit(gsub(unit.."target", "(%d+)target", "target%1"))
end

--[[
local ALLIES = bit.bor(
	COMBATLOG_OBJECT_AFFILIATION_RAID,
	COMBATLOG_OBJECT_AFFILIATION_PARTY,
	COMBATLOG_OBJECT_AFFILIATION_MINE
)
]]

function addon:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, _, ...)
	if not destGUID or bit.band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0 then return end
	if event == 'SPELL_AURA_APPLIED' then
		if spellID and SPELLS[spellID] then -- and bit.band(sourceGUID, ALLIES) ~= 0 then
			local duration = SPELLS[spellID]
			self:UpdateSpell(destGUID, spellID, duration, GetTime()+duration)
		end
	elseif destGUID and self.GUIDs[destGUID] then
		if event == 'UNIT_DIED' then
			self:RemoveTarget(destGUID)
		elseif spellID and SPELLS[spellID] and self.GUIDs[destGUID][spellID] then
			if strsub(event, 1, 17) == 'SPELL_AURA_BROKEN' then
				self:RemoveSpell(destGUID, spellID, sourceGUID)
			elseif event == 'SPELL_AURA_REFRESH' then
				local duration = SPELLS[spellID]
				self:UpdateSpell(destGUID, spellID, duration, GetTime()+duration)
			elseif event == 'SPELL_AURA_REMOVED' then
				self:RemoveSpell(destGUID, spellID)
			end
		end
	end
end

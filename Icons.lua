--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

local mod = addon:NewModule('Icons')

local prefs
local anchor

local iconProto = { Debug = addon.Debug }
local iconMeta = { __index = iconProto }
local iconHeap = {}
local activeIcons = {}

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName)
	self:RegisterMessage('AdiCCMonitor_SpellAdded')
	self:RegisterMessage('AdiCCMonitor_SpellUpdated')
	self:RegisterMessage('AdiCCMonitor_SpellRemoved')	
end

function mod:OnEnable()
	prefs = self.db.profile
	if not anchor then
		anchor = self:CreateAnchor()
	end
	anchor:Show()
end

function mod:OnDisable()
	for icon in self:IterateIcons() do
		icon:Release()
	end
	anchor:Hide()
end

function mod:OnConfigChanged(key, ...)
end

function mod:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
	local icon = self:AcquireIcon()
	icon:Update(guid, spellID, spell.symbol, spell.duration, spell.expires)
	icon:Show()
end

function mod:AdiCCMonitor_SpellUpdated(event, guid, spellID, spell)
	for icon in self:IterateIcons() do
		if icon.guid == guid and icon.spellID == spellID then
			return icon:Update(guid, spellID, spell.symbol, spell.duration, spell.expires)
		end
	end
	return self:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
end

function mod:AdiCCMonitor_SpellRemoved(event, guid, spellID, spell)
	for icon in self:IterateIcons() do
		if icon.guid == guid and icon.spellID == spellID then
			return icon:Release()
		end
	end
end

--------------------------------------------------------------------------------
-- Anchor widget
--------------------------------------------------------------------------------

function mod:CreateAnchor()
	local anchor = CreateFrame("Frame", nil, UIParent)
	setmetatable(iconProto, {__index = anchor})
	return anchor
end

--------------------------------------------------------------------------------
-- Icon widgets
--------------------------------------------------------------------------------

function mod:CreateIcon()
	local icon = setmetatable(CreateFrame("Frame", nil, anchor), iconMeta)
	return icon
end

function mod:AcquireIcon()
	local icon = next(iconHeap)
	if not icon then
		icon = self:CreateIcon()
	else
		iconHeap[icon] = nil
	end
	activeIcons[icon] = true
end

function mod:IterateIcons()
	return pairs(activeIcons)
end

function iconProto:Release()
	self.guid, self.spellID, self.symbol, self.duration, self.expires = nil
	self:Hide()
	activeIcons[self] = nil
	iconHeap[self] = true
end

function iconProto:Update(guid, spellID, symbol, duration, expires)
	self.guid = guid
	if self.spellID ~= spellID then
		self.spellID = spellID
		local _, _, texture = GetSpellInfo(spellID)
	end
	if self.symbol ~= symbol then
		self.symbol = symbol
	end
	if self.duration ~= duration or self.expires ~= expires then
		self.duration, self.expires = duration, expires
	end
end

--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

local mod = addon:NewModule('Icons', 'AceEvent-3.0', 'LibMovable-1.0')

local DEFAULT_SETTINGS = {
	profile = {
		iconSize = 32,
		numIcons = 8,
		vertical = false,
		anchor = {},
		alpha = 1,
	}
}

local prefs
local anchor

local iconProto = { Debug = addon.Debug }
local iconMeta = { __index = iconProto }
local iconHeap = {}
local activeIcons = {}

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, DEFAULT_SETTINGS)
	self:RegisterMessage('AdiCCMonitor_SpellAdded')
	self:RegisterMessage('AdiCCMonitor_SpellUpdated')
	self:RegisterMessage('AdiCCMonitor_SpellRemoved')	
end

function mod:OnEnable()
	prefs = self.db.profile
	if not anchor then
		anchor = self:CreateAnchor()
	end
	self:ApplySettings()
	self:FullRefresh()
	anchor:Show()
end

function mod:OnDisable()
	self:Wipe()
	anchor:Hide()
end

function mod:OnConfigChanged()
	self:ApplySettings()
end

function mod:ApplySettings()
	if prefs.vertical then
		anchor:SetSize(prefs.iconSize, prefs.iconSize * prefs.numIcons)
	else
		anchor:SetSize(prefs.iconSize * prefs.numIcons, prefs.iconSize)
	end
	anchor:SetAlpha(prefs.alpha)
	for icon in self:IterateIcons() do
		icon:ApplySettings()
	end
	self:Layout()
end

function mod:FullRefresh()
	self:WipeIcons()
	for guid, spellId, spell in addon:IterateSpells() do
		self:AddSpell(guid, spellID, spell)
	end
	self:Layout()
end

function mod:Wipe()
	for icon in self:IterateIcons() do
		icon:Release()
	end	
end

--------------------------------------------------------------------------------
-- Individual spell handling
--------------------------------------------------------------------------------

function mod:AddSpell(guid, spellID, spell)
	local icon = self:AcquireIcon()
	icon:Update(guid, spellID, spell.symbol, spell.duration, spell.expires)
	icon:Show()
end

function mod:UpdateSpell(icon, guid, spellID, spell)
	for icon in self:IterateIcons() do
		if icon.guid == guid and icon.spellID == spellID then
			icon:Update(guid, spellID, spell.symbol, spell.duration, spell.expires)
			return
		end
	end
	self:AddSpell(guid, spellID, spell)
end

function mod:RemoveSpell(guid, spellID)
	for icon in self:IterateIcons() do
		if icon.guid == guid and icon.spellID == spellID then
			icon:Release()
		end
	end
end

--------------------------------------------------------------------------------
-- Icon layout
--------------------------------------------------------------------------------

local function SortIcons(a, b)
	return a.expires < b.expires
end

local iconOrder = {}
function mod:Layout()
	if not next(activeIcons) then return end
	local point = prefs.anchor.pointFrom
	local dx, dy = 0, 0
	if prefs.vertical then
		dy = strmatch(point, 'BOTTOM') and 1 or -1
	else
		dx = strmatch(point, 'RIGHT') and -1 or 1
	end
	wipe(iconOrder)
	for icon in self:IterateIcons() do
		tinsert(iconOrder, icon)
	end
	table.sort(iconOrder, SortIcons)
	local size, x, y = prefs.iconSize, 0, 0
	local numIcons = prefs.numIcons
	for i, icon in ipairs(iconOrder) do
		if i <= numIcons then
			icon:ClearAllPoints()
			icon:SetPoint(point, anchor, point, x, y)
			icon:Show()
			x = x + dx * size
			y = y + dy * size
		else
			icon:Hide()
		end
	end
end

--------------------------------------------------------------------------------
-- Message handling
--------------------------------------------------------------------------------

function mod:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
	self:AddSpell(guid, spellID, spell)
	self:Layout()
end

function mod:AdiCCMonitor_SpellUpdated(event, guid, spellID, spell)
	self:UpdateSpell(guid, spellID, spell)
	self:Layout()
end

function mod:AdiCCMonitor_SpellRemoved(event, guid, spellID, spell)
	self:RemoveSpell(guid, spellID)
	self:Layout()
end

--------------------------------------------------------------------------------
-- Anchor widget
--------------------------------------------------------------------------------

function mod:CreateAnchor()
	local anchor = CreateFrame("Frame", nil, UIParent)
	setmetatable(iconProto, {__index = anchor})
	self:RegisterMovable(anchor, function() return prefs.anchor end, L['AdiCCMonitor icons'])
	return anchor
end

--------------------------------------------------------------------------------
-- Icon widgets
--------------------------------------------------------------------------------

function mod:IterateIcons()
	return pairs(activeIcons)
end

--[=[
local borderBackdrop = {
	edgeFile = [[Interface\Addons\AdiCCMonitor\white16x16]], edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}
--]=]

function mod:CreateIcon()
	local icon = setmetatable(CreateFrame("Frame", nil, anchor), iconMeta)
	
	--[[
	icon:SetBackdrop(borderBackdrop)
	icon:SetBackdropColor(0, 0, 0, 0)
	icon:SetBackdropBorderColor(1, 1, 1, 1)
	--]]
	
	local texture = icon:CreateTexture(nil, "ARTWORK")
	texture:SetPoint("TOPLEFT", icon, "TOPLEFT", 1, -1)
	texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
	texture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	texture:SetTexture(1,1,1,0)
	icon.Texture = texture

	local cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	cooldown:SetAllPoints(texture)
	cooldown:SetDrawEdge(true)
	cooldown:SetReverse(true)
	icon.Cooldown = cooldown

	local symbol = icon:CreateTexture(nil, "OVERLAY")
	symbol:SetPoint("TOPLEFT", icon, "TOPLEFT", 1, -1)
	symbol:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
	symbol:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	symbol:SetVertexColor(1, 1, 1, 1)
	icon.Symbol = symbol
		
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
	self:ApplySettings()
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
		self.Texture:SetTexture(texture)
	end
	if self.symbol ~= symbol then
		self.symbol = symbol
		if symbol then
			SetRaidTargetIconTexture(self.Symbol, symbol)
			self.Symbol:Show()
		else
			self.Symbol:Hide()
		end
	end
	if self.duration ~= duration or self.expires ~= expires then
		self.duration, self.expires = duration, expires
		if duration and expires then
			self.Cooldown:SetCooldown(expires-duration, duration)
			self.Cooldown:Show()
		else
			self.Cooldown:Hide()
		end
	end
end

function iconProto:ApplySettings()
	self:SetSize(prefs.iconSize, prefs.iconSize)
end

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

function mod:GetOptions()
	return {
		name = L['Icons'],
		type = 'group',
		handler = addon:GetOptionHandler(self),
		set = 'Set',
		get = 'Get',
		disabled = 'IsDisabled',
		args = {
			iconSize = {
				name = L['Icon size'],
				type = 'range',
				min = 16,
				max = 64,
				step = 1,
			},
			vertical = {
				name = L['Vertical'],
				type = 'toggle',
			},
			numIcons = {
				name = L['Number of icons'],
				type = 'range',
				min = 1,
				max = 15,
				step = 1,
			},
			alpha = {
				name = L['Opacity'],
				type = 'range',
				isPercent = true,
				min = 0.01,
				max = 1.00,
				step = 0.01,
				bigStep = 1,
			},
			lockAnchor = {
				name = function() return self:AreMovablesLocked() and L['Unlock anchor'] or L['Lock anchor'] end,
				type = 'execute',
				func = function()
					if self:AreMovablesLocked() then
						self:UnlockMovables()
					else
						self:LockMovables()
					end
				end,
			},
			resetPosition = {
				name = L['Reset position'],
				type = 'execute',
				func = function() self:ResetMovableLayout() end,
			},
		},
	}
end


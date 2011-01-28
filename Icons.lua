--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

local mod = addon:NewModule('Icons', 'AceEvent-3.0', 'LibMovable-1.0')

local ICON_SPACING = 2

local DEFAULT_SETTINGS = {
	profile = {
		iconSize = 32,
		numIcons = 8,
		vertical = false,
		anchor = {
			scale = 1.0,
			pointFrom = "TOPLEFT",
			pointTo = "TOPLEFT",
			xOffset = 20,
			yOffset = -200,
		},
		alpha = 1,
		showSymbol = true,
		showCountdown = true,
		showCooldown = true,
		showCaster = true,
		blinking = true,
		blinkingThreshold = 5,
		countdownSide = "INSIDE_BOTTOM",
		casterSide = "INSIDE_TOP",
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
end

function mod:OnEnable()
	prefs = self.db.profile
	if not anchor then
		anchor = self:CreateAnchor()
	end
	anchor:Show()
	self:RegisterMessage('AdiCCMonitor_SpellAdded')
	self:RegisterMessage('AdiCCMonitor_SpellUpdated')
	self:RegisterMessage('AdiCCMonitor_SpellRemoved')
	self:RegisterMessage('AdiCCMonitor_SpellBroken', 'AdiCCMonitor_SpellRemoved')
	self:RegisterMessage('AdiCCMonitor_WipeTarget')
	self:ApplySettings(true)
end

function mod:OnDisable()
	self:Wipe()
	anchor:Hide()
end

function mod:OnConfigChanged()
	self:ApplySettings()
end

function mod:ApplySettings(fullRefresh)

	if prefs.vertical then
		anchor:SetSize(prefs.iconSize, (ICON_SPACING + prefs.iconSize) * prefs.numIcons - ICON_SPACING)
	else
		anchor:SetSize((ICON_SPACING + prefs.iconSize) * prefs.numIcons - ICON_SPACING, prefs.iconSize)
	end

	anchor:SetAlpha(prefs.alpha)
	anchor:ClearAllPoints()
	local a = prefs.anchor
	anchor:SetScale(a.scale)
	anchor:SetPoint(a.pointFrom, UIParent, a.pointTo, a.xOffset, a.yOffset)

	for icon in self:IterateIcons() do
		icon:UpdateWidgets()
	end

	if fullRefresh then
		self:FullRefresh()
	else
		self:Layout()
	end

end

function mod:FullRefresh()
	self:Wipe()
	for guid, spellId, spell in addon:IterateSpells() do
		self:UpdateSpell(guid, spellID, spell)
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

function mod:AddSpell(guid, spellID, symbol, duration, expires, isMine, caster)
	local icon = self:AcquireIcon()
	icon:Update(guid, spellID, symbol, duration, expires, isMine, caster)
	icon:Show()
end

function mod:UpdateSpell(guid, spellID, symbol, duration, expires, isMine, caster)
	for icon in self:IterateIcons() do
		if icon.guid == guid and icon.spellID == spellID then
			icon:Update(guid, spellID, symbol, duration, expires, isMine, caster)
			return
		end
	end
	self:AddSpell(guid, spellID, symbol, duration, expires, isMine, caster)
end

function mod:RemoveSpell(guid, spellID, instant, broken)
	local now = GetTime()
	for icon in self:IterateIcons() do
		if icon.guid == guid and icon.spellID == spellID then
			if instant then
				icon:Release()
			elseif broken then
				icon.Texture:SetVertexColor(1, 0, 0, 1)
				icon:FadeOut(2)
			else
				icon:FadeOut(1)
			end
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
	local dx, dy = 0, 0
	if prefs.vertical then
		dy = strmatch(prefs.anchor.pointFrom, 'TOP') and -1 or 1
	else
		dx = strmatch(prefs.anchor.pointFrom, 'RIGHT') and -1 or 1
	end
	local point = (dy == -1 and "TOP" or "BOTTOM")..(dx == -1 and "RIGHT" or "LEFT")
	wipe(iconOrder)
	for icon in self:IterateIcons() do
		tinsert(iconOrder, icon)
	end
	table.sort(iconOrder, SortIcons)
	local x, y = 0, 0
	local numIcons = prefs.numIcons
	for i, icon in ipairs(iconOrder) do
		if i <= numIcons then
			local size = prefs.iconSize * (icon.isMine and 1 or 0.8)
			icon:ClearAllPoints()
			icon:SetSize(size, size)
			icon:SetPoint(point, anchor, point, x, y)
			icon:Show()
			x = x + dx * (size + ICON_SPACING)
			y = y + dy * (size + ICON_SPACING)
		else
			icon:Hide()
		end
	end
end

--------------------------------------------------------------------------------
-- Message handling
--------------------------------------------------------------------------------

function mod:AdiCCMonitor_SpellAdded(event, guid, spellID, spell)
	self:AddSpell(guid, spellID, spell.symbol, spell.duration, spell.expires, spell.isMine, spell.caster)
	self:Layout()
end

function mod:AdiCCMonitor_SpellUpdated(event, guid, spellID, spell)
	self:UpdateSpell(guid, spellID, spell.symbol, spell.duration, spell.expires, spell.isMine, spell.caster)
	self:Layout()
end

function mod:AdiCCMonitor_SpellRemoved(event, guid, spellID, spell, broken)
	self:RemoveSpell(guid, spellID, nil, broken)
	self:Layout()
end

function mod:AdiCCMonitor_WipeTarget(event, guid)
	for icon in self:IterateIcons() do
		if icon.guid == guid then
			icon:FadeOut(1)
		end
	end
	self:Layout()
end

--------------------------------------------------------------------------------
-- Anchor widget
--------------------------------------------------------------------------------

local delay = 0
local UPDATE_PERIOD = 0.05

local function OnUpdate(self, elapsed)
	delay = delay + elapsed
	if delay < UPDATE_PERIOD then return end
	local now = GetTime()
	for icon in pairs(activeIcons) do
		if icon:IsVisible() then
			icon:OnUpdate(now, delay)
		end
	end
	delay = 0
end

function mod:CreateAnchor()
	local anchor = CreateFrame("Frame", nil, UIParent)
	setmetatable(iconProto, {__index = anchor})
	anchor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -200)
	anchor:SetClampedToScreen(true)
	anchor:SetFrameStrata("HIGH")
	anchor:SetScript('OnUpdate', OnUpdate)
	anchor.LM10_OnDatabaseUpdated = function() self:Layout() end
	self:RegisterMovable(anchor, function() return prefs.anchor end, L['AdiCCMonitor icons'])
	return anchor
end

--------------------------------------------------------------------------------
-- Icon widgets
--------------------------------------------------------------------------------

function mod:IterateIcons()
	return pairs(activeIcons)
end

local borderBackdrop = {
	edgeFile = [[Interface\Addons\AdiCCMonitor\media\white16x16]], edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0},
}

function mod:CreateIcon()
	local icon = setmetatable(CreateFrame("Frame", nil, anchor), iconMeta)
	icon:SetScript('OnSizeChanged', icon.OnSizeChanged)

	icon:SetBackdrop(borderBackdrop)
	icon:SetBackdropColor(0, 0, 0, 0.5)
	icon:SetBackdropBorderColor(0, 0, 0, 1)

	local texture = icon:CreateTexture(nil, "ARTWORK")
	texture:SetPoint("TOPLEFT", icon, "TOPLEFT", 1, -1)
	texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
	texture:SetTexCoord(5/64, 58/64, 5/64, 58/64)
	texture:SetTexture(1,1,1,0)
	icon.Texture = texture

	local cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	cooldown:SetAllPoints(texture)
	cooldown:SetDrawEdge(true)
	cooldown:SetReverse(true)
	cooldown:Hide()
	cooldown.noCooldownCount = true
	icon.Cooldown = cooldown

	local overlay = CreateFrame("Frame", nil, icon)
	overlay:SetAllPoints(icon)
	overlay:SetFrameLevel(cooldown:GetFrameLevel()+1)

	local symbol = overlay:CreateTexture(nil, "OVERLAY")
	symbol:SetPoint("CENTER")
	symbol:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	symbol:SetVertexColor(1, 1, 1, 1)
	symbol:Hide()
	icon.Symbol = symbol

	local countdown = overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	countdown:Hide()
	icon.Countdown = countdown

	local caster = overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	caster:Hide()
	icon.Caster = caster

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
	return icon
end

function iconProto:Release()
	self.guid, self.spellID, self.symbol, self.duration, self.expires = nil
	self.fadingOut = nil
	self:SetAlpha(prefs.alpha)
	self.Texture:SetVertexColor(1, 1, 1, 1)
	self:Hide()
	activeIcons[self] = nil
	iconHeap[self] = true
end

function iconProto:Update(guid, spellID, symbol, duration, expires, isMine, caster)
	self:StopFadingOut()
	self.guid = guid
	if caster then
		caster = strsplit('-', caster) -- Strip realm name
	end
	if self.spellID ~= spellID or self.symbol ~= symbol or self.duration ~= duration or self.expires ~= expires or self.isMine ~= isMine or self.caster ~= caster then
		self.spellID, self.symbol, self.duration, self.expires, self.isMine, self.caster = spellID, symbol, duration, expires, isMine, caster
		self:UpdateWidgets()
	end
end

function iconProto:UpdateWidgets()
	if self.spellID then
		local _, _, texture = GetSpellInfo(self.spellID)
		self.Texture:SetTexture(texture)
		self.Texture:Show()
	else
		self.Texture:Hide()
	end
	if self.symbol and prefs.showSymbol then
		SetRaidTargetIconTexture(self.Symbol, self.symbol)
		self.Symbol:Show()
	else
		self.Symbol:Hide()
	end
	if self.duration and self.expires and prefs.showCooldown then
		self.Cooldown:SetCooldown(self.expires - self.duration, self.duration)
		self.Cooldown:Show()
	else
		self.Cooldown:Hide()
	end
	if prefs.showCountdown and self:UpdateCountdown(GetTime()) then
		self:SetTextPosition(self.Countdown, prefs.countdownSide)
		self.Countdown:Show()
	else
		self.Countdown:Hide()
	end
	if prefs.showCaster and self.caster then
		self:SetTextPosition(self.Caster, prefs.casterSide)
		self.Caster:SetText(self.caster)
		self.Caster:Show()
	else
		self.Caster:Hide()
	end
end

local cos, PI2 = math.cos, math.pi * 2
function iconProto:OnUpdate(now, elapsed)
	local targetAlpha, targetDelay = prefs.alpha, 1
	local alpha = self:GetAlpha()
	if now > self.expires then
		self:FadeOut(1)
	end
	if self.fadingOut then
		if alpha == 0 or now > self.fadingEnd then
			self:Release()
			mod:Layout()
			return
		else
			targetAlpha, targetDelay = 0, self.fadingDelay
		end
	else
		if prefs.blinking and now > self.expires - prefs.blinkingThreshold then
			targetAlpha, targetDelay = prefs.alpha * (0.55 + 0.45 * cos(now * PI2)), 0.5
		end
		if self.Countdown:IsShown() then
			self:UpdateCountdown(now)
		end
	end
	if alpha ~= targetAlpha then
		if targetAlpha > alpha then
			alpha = min(targetAlpha, alpha + elapsed / targetDelay)
		else
			alpha = max(targetAlpha, alpha - elapsed / targetDelay)
		end
		self:SetAlpha(alpha)
	end
end

function iconProto:FadeOut(delay)
	if not self.fadingOut then
		self.fadingOut = true
		self.fadingDelay = delay
		self.fadingEnd = GetTime() + delay
		self.Countdown:Hide()
		self.Caster:Hide()
	end
end

function iconProto:StopFadingOut()
	if self.fadingOut then
		self.fadingOut = nil
		self.Texture:SetVertexColor(1, 1, 1, 1)
		self:UpdateWidgets()
	end
end

function iconProto:UpdateCountdown(now)
	local timeLeft = self.expires - now
	if timeLeft > 0 then
		self.Countdown:SetFormattedText("%d", ceil(timeLeft))
		return true
	end
end

function iconProto:SetTextPosition(text, side)
	if text.side == side and text.vertical == prefs.vertical then return end
	text.side, text.vertical = side, prefs.vertical
	text:ClearAllPoints()
	local inside = strmatch(side, 'INSIDE_(%w+)')
	if inside then
		text:SetPoint(inside, self, inside, 0, 0)
	elseif side == "OUTSIDE_TOPLEFT" then
		if prefs.vertical then
			text:SetPoint("RIGHT", self, "LEFT", 0, 0)
		else
			text:SetPoint("BOTTOM", self, "TOP", 0, 0)
		end
	elseif side == "OUTSIDE_BOTTOMRIGHT" then
		if prefs.vertical then
			text:SetPoint("LEFT", self, "RIGHT", 0, 0)
		else
			text:SetPoint("TOP", self, "BOTTOM", 0, 0)
		end
	end
end

function iconProto:OnSizeChanged(width, height)
	if width and height then
		mod:Debug(self, 'OnSizeChanged', width, height)
		self.Symbol:SetSize(width*0.5, height*0.5)
	end
end

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

function mod:GetOptions()
	local sides = {
		horizontal = {
			INSIDE_TOP = L['Inside, top'],
			INSIDE_BOTTOM = L['Inside, bottom'],
			INSIDE_LEFT = L['Inside, left'],
			INSIDE_RIGHT = L['Inside, right'],
			OUTSIDE_TOPLEFT = L['Outside, top'],
			OUTSIDE_BOTTOMRIGHT = L['Outside, bottom'],
		},
		vertical = {
			INSIDE_TOP = L['Inside, top'],
			INSIDE_BOTTOM = L['Inside, bottom'],
			INSIDE_LEFT = L['Inside, left'],
			INSIDE_RIGHT = L['Inside, right'],
			OUTSIDE_TOPLEFT = L['Outside, left'],
			OUTSIDE_BOTTOMRIGHT = L['Outside, right'],
		}
	}

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
				desc = L['The size in pixels of icons displaying your spells. Spells of other players are 20% smaller.'],
				type = 'range',
				min = 16,
				max = 64,
				step = 1,
				order = 10,
			},
			vertical = {
				name = L['Vertical'],
				desc = L['The orientation of the icon bar.'],
				type = 'toggle',
				order = 20,
			},
			numIcons = {
				name = L['Number of icons'],
				desc = L['The maximum number of icons to show. '],
				type = 'range',
				min = 1,
				max = 15,
				step = 1,
				order = 30,
			},
			alpha = {
				name = L['Opacity'],
				desc = L['The opacity of all icons. 100% means full opaque while 0% means fully transparent.'],
				type = 'range',
				isPercent = true,
				min = 0.10,
				max = 1,
				step = 0.01,
				order = 40,
			},

			showSymbol = {
				name = L['Show symbol'],
				desc = L['Display the target raid marker.'],
				type = 'toggle',
				order = 50,
			},
			showCountdown = {
				name = L['Show countdown'],
				desc = L['Numerical display of time left.'],
				type = 'toggle',
				order = 60,
			},
			countdownSide = {
				name = L['Countdown position'],
				type = 'select',
				values = function() return sides[prefs.vertical and "vertical" or "horizontal"] end,
				disabled = function(info) return info.handler:IsDisabled() or not prefs.showCountdown end,
				order = 65,
			},
			showCooldown = {
				name = L['Show cooldown model'],
				desc = L['Graphical display of time left.'],
				type = 'toggle',
				order = 70,
			},
			showCaster = {
				name = L['Show caster'],
				desc = L['Caster name.'],
				type = 'toggle',
				order = 75,
			},
			casterSide = {
				name = L['Caster position'],
				type = 'select',
				values = function() return sides[prefs.vertical and "vertical" or "horizontal"] end,
				disabled = function(info) return info.handler:IsDisabled() or not prefs.showCaster end,
				order = 76,
			},
			blinking = {
				name = L['Enable blinking'],
				desc = L['Icons start blinking when the spell is about to end.'],
				type = 'toggle',
				order = 80,
			},
			blinkingThreshold = {
				name = L['Blinking threshold (sec.)'],
				desc = L['The remaining time threshold, below which the icon starts to blink.'],
				type = 'range',
				min = 1,
				max = 15,
				step = 0.5,
				order = 90,
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
				order = 100,
			},
			resetPosition = {
				name = L['Reset position'],
				desc = L['Move the anchor back to its default position.'],
				type = 'execute',
				func = function() self:ResetMovableLayout() end,
				order = 110,
			},
		},
	}
end


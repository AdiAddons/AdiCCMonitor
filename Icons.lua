--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011-2012 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

-- Copy globals in local scope to easily spot global leaks with "luac -l | grep GLOBAL"
local _G = _G
local ceil = _G.ceil
local CreateFrame = _G.CreateFrame
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local ipairs = _G.ipairs
local max = _G.max
local min = _G.min
local next = _G.next
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local SetRaidTargetIconTexture = _G.SetRaidTargetIconTexture
local strmatch = _G.strmatch
local strsplit = _G.strsplit
local tinsert = _G.tinsert
local UIParent = _G.UIParent
local wipe = _G.wipe

local addonName, addon = ...
local L = addon.L
local LSM = LibStub('LibSharedMedia-3.0')

local mod = addon:NewModule('Icons', 'AceEvent-3.0', 'LibMovable-1.0')

local DEFAULT_SETTINGS = {
	profile = {
		iconSize = 32,
		iconSpacing = 2,
		numIcons = 8,
		vertical = false,
		anchor = {
			scale = 1.0,
			pointFrom = "TOPLEFT",
			pointTo = "TOPLEFT",
			xOffset = 20,
			yOffset = -200,
		},
		anchorBig = {
			scale = 2.0,
			pointFrom = "TOP",
			pointTo = "CENTER",
			xOffset = 00,
			yOffset = 50,
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
		fontName = 'Arial Narrow',
		fontSize = 14,
		bigIcons = true,
		bigThreshold = 5,
	}
}

local prefs
local anchor, anchorBig

local iconProto = { Debug = addon.Debug }
local iconMeta = { __index = iconProto }
local iconHeap = {}
local activeIcons = {}

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, DEFAULT_SETTINGS)	
	mod:OnInitializeButtonFacade()
end

function mod:OnEnable()
	prefs = self.db.profile
	if not anchor then
		anchor, anchorBig = self:CreateAnchors()
	end
	anchor:Show()
	if prefs.bigIcons then
		anchorBig:Show()
	end
	self:RegisterMessage('AdiCCMonitor_SpellAdded')
	self:RegisterMessage('AdiCCMonitor_SpellUpdated')
	self:RegisterMessage('AdiCCMonitor_SpellRemoved')
	self:RegisterMessage('AdiCCMonitor_SpellBroken', 'AdiCCMonitor_SpellRemoved')
	self:RegisterMessage('AdiCCMonitor_WipeTarget')
	LSM.RegisterCallback(self, 'LibSharedMedia_SetGlobal', 'OnConfigChanged')
	self:ApplySettings(true)
end

function mod:OnDisable()
	self:Wipe()
	anchor:Hide()
	anchorBig:Hide()
end

function mod:OnConfigChanged()
	self:ApplySettings()
end

function mod:ApplySettings(fullRefresh)

	local width, height
	if prefs.vertical then
		width, height = prefs.iconSize, (prefs.iconSpacing + prefs.iconSize) * prefs.numIcons - prefs.iconSpacing
	else
		width, height = (prefs.iconSpacing + prefs.iconSize) * prefs.numIcons - prefs.iconSpacing, prefs.iconSize
	end
	
	local a = prefs.anchor
	anchor:SetSize(width, height)
	anchor:SetAlpha(prefs.alpha)
	anchor:ClearAllPoints()
	anchor:SetScale(a.scale)
	anchor:SetPoint(a.pointFrom, UIParent, a.pointTo, a.xOffset, a.yOffset)

	if prefs.bigIcons then
		local a = prefs.anchorBig
		anchorBig:SetSize((prefs.iconSpacing + prefs.iconSize) * prefs.numIcons - prefs.iconSpacing, prefs.iconSize)
		anchorBig:SetAlpha(prefs.alpha)	
		anchorBig:ClearAllPoints()
		anchorBig:SetScale(a.scale)
		anchorBig:SetPoint(a.pointFrom, UIParent, a.pointTo, a.xOffset, a.yOffset)
		anchorBig:Show()
	else
		anchorBig:Hide()
	end

	for icon in self:IterateIcons() do
		icon:UpdateWidgets()
	end
	
	self:ApplyButtonFacadeSettings()

	if fullRefresh then
		self:FullRefresh()
	else
		self:Layout()
	end

end

function mod:FullRefresh()
	self:Wipe()
	for guid, spellID, spell in addon:IterateSpells() do
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
local tsort = _G.table.sort
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
	tsort(iconOrder, SortIcons)
	local x, y, count = 0, 0, 0
	local bigX, bigY, bigCount = 0, 0, 0
	local iconSpacing = prefs.iconSpacing
	local numIcons = prefs.numIcons
	for i, icon in ipairs(iconOrder) do
		local warning = icon.warning and bigCount <= numIcons
		if warning or count <= numIcons then
			local size = prefs.iconSize * (icon.isMine and 1 or 0.8)
			icon:ClearAllPoints()
			icon:SetSize(size, size)
			if warning then
				icon:SetParent(anchorBig)
				icon:SetPoint(point, anchorBig, point, bigX, bigY)
				bigX = bigX + dx * (size + iconSpacing)
				bigY = bigY + dy * (size + iconSpacing)
				bigCount = bigCount + 1
			else
				icon:SetParent(anchor)
				icon:SetPoint(point, anchor, point, x, y)
				x = x + dx * (size + iconSpacing)
				y = y + dy * (size + iconSpacing)
				count = count + 1
			end
			icon:Show()
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
local pendingLayout = false

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
	if pendingLayout then
		pendingLayout = false
		mod:Layout()
	end
end

function mod:CreateAnchors()
	local anchor = CreateFrame("Frame", nil, UIParent)
	anchor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -200)
	anchor:SetClampedToScreen(true)
	anchor:SetFrameStrata("HIGH")
	anchor.LM10_OnDatabaseUpdated = function() self:Layout() end
	self:RegisterMovable(anchor, function() return prefs.anchor end, L['AdiCCMonitor icons'])

	local anchorBig = CreateFrame("Frame", nil, UIParent)
	anchorBig:SetScale(2.0)
	anchorBig:SetPoint("TOP", UIParent, "CENTER", 0, 50)
	anchorBig:SetClampedToScreen(true)
	anchorBig:SetFrameStrata("HIGH")
	anchorBig.LM10_Enable = function() prefs.bigIcons = true self:OnConfigChanged() end
	anchorBig.LM10_Disable = function() prefs.bigIcons = false self:OnConfigChanged() end
	anchorBig.LM10_IsEnabled = function() return prefs.bigIcons end
	anchorBig.LM10_OnDatabaseUpdated = function() self:Layout() end
	self:RegisterMovable(anchorBig, function() return prefs.anchorBig end, L['AdiCCMonitor warning icons'])

	anchor:SetScript('OnUpdate', OnUpdate)
	setmetatable(iconProto, {__index = anchor})

	return anchor, anchorBig
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
	cooldown:SetReverse(true)
	cooldown:Hide()
	cooldown.noCooldownCount = true
	icon.Cooldown = cooldown

	local overlay = CreateFrame("Frame", nil, icon)
	overlay:SetAllPoints(icon)
	overlay:SetFrameLevel(cooldown:GetFrameLevel()+1)
	icon.__Overlay = overlay

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
	
	icon:SetSize(prefs.iconSize, prefs.iconSize)
	mod:ButtonFacadeSkin(icon)

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
	self.guid, self.spellID, self.symbol, self.duration, self.expires, self.fadingOut, self.warning = nil
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

local cos, PI2 = _G.math.cos, _G.math.pi * 2
function iconProto:OnUpdate(now, elapsed)
	local targetAlpha, targetDelay = prefs.alpha, 1
	local alpha = self:GetAlpha()
	if now > self.expires then
		self:FadeOut(1)
	end
	if self.fadingOut then
		if alpha == 0 or now > self.fadingEnd then
			self:Release()
			pendingLayout = true
			return
		else
			targetAlpha, targetDelay = 0, self.fadingDelay
		end
	else
		if prefs.blinking and now > self.expires - prefs.blinkingThreshold then
			local f = now % 1
			if f > 0.5 then
				targetAlpha = 1.8 - 1.6 * f 
			else
				targetAlpha = 0.2 + 1.6 * f
			end
			targetDelay = 0.01
		end
		if self.Countdown:IsShown() then
			self:UpdateCountdown(now)
		end
		local warning = prefs.bigIcons and now > self.expires - prefs.bigThreshold
		if warning ~= self.warning then
			self.warning = warning
			pendingLayout = true
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
	if text.side ~= side or text.vertical ~= prefs.vertical then
		text.side, text.vertical = side, prefs.vertical
		text:ClearAllPoints()
		local inside = strmatch(side, 'INSIDE_(%w+)')
		local justify
		if inside then
			text:SetAllPoints(self)
			justify = inside
		else
			if side == "OUTSIDE_TOPLEFT" then
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
			justify = text:GetPoint()
		end
		text:SetJustifyH((justify == "LEFT" or justify == "RIGHT") and justify or "CENTER")
		text:SetJustifyV((justify == "TOP" or justify == "BOTTOM") and justify or "MIDDLE")	
	end
	if text.fontName ~= prefs.fontName or text.size ~= prefs.fontSize then
		text.fontName, text.size = prefs.fontName, prefs.fontSize
		local fontPath = LSM:Fetch(LSM.MediaType.FONT, prefs.fontName)
		text:SetFont(fontPath, prefs.fontSize, "OUTLINE")
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
				desc = L['Size of icons displaying your spells, in pixels. Spells of other players are 20% smaller.'],
				type = 'range',
				min = 16,
				max = 64,
				step = 1,
				order = 10,
			},
			vertical = {
				name = L['Vertical'],
				desc = L['Orientation of the icon bar.'],
				type = 'toggle',
				order = 20,
			},
			numIcons = {
				name = L['Number of icons'],
				desc = L['Maximum number of icons to show.'],
				type = 'range',
				min = 1,
				max = 15,
				step = 1,
				order = 30,
			},
			iconSpacing = {
				name = L['Icon spacing'],
				desc = L['Size of the gap between icons, in pixels.'],
				type = 'range',
				min = 0,
				max = 64,
				step = 1,
				order = 35,
			},
			alpha = {
				name = L['Opacity'],
				desc = L['Opacity of all icons. 100% means full opaque while 0% means fully transparent.'],
				type = 'range',
				isPercent = true,
				min = 0.10,
				max = 1,
				step = 0.01,
				order = 40,
			},
			fontName = {
				name = L['Text font'],
				desc = L['Font to use for the caster and countdown texts'],
				type = 'select',
				dialogControl = 'LSM30_Font',
				values = _G.AceGUIWidgetLSMlists.font,
				order = 50,
			},
			fontSize = {
				name = L['Text size'],
				desc = L['Size, in pixels, of the caster and countdown texts.'],
				type = 'range',
				min = 8,
				max = 32,
				step = 1,
				order = 60,
			},
			showSymbol = {
				name = L['Show symbol'],
				desc = L['Display the target raid marker.'],
				type = 'toggle',
				order = 70,
			},
			showCountdown = {
				name = L['Show countdown'],
				desc = L['Numerical display of time left.'],
				type = 'toggle',
				order = 80,
			},
			countdownSide = {
				name = L['Countdown position'],
				type = 'select',
				values = function() return sides[prefs.vertical and "vertical" or "horizontal"] end,
				disabled = function(info) return info.handler:IsDisabled() or not prefs.showCountdown end,
				order = 90,
			},
			showCooldown = {
				name = L['Show cooldown model'],
				desc = L['Graphical display of time left.'],
				type = 'toggle',
				order = 100,
			},
			showCaster = {
				name = L['Show caster'],
				desc = L['Caster name.'],
				type = 'toggle',
				order = 110,
			},
			casterSide = {
				name = L['Caster position'],
				type = 'select',
				values = function() return sides[prefs.vertical and "vertical" or "horizontal"] end,
				disabled = function(info) return info.handler:IsDisabled() or not prefs.showCaster end,
				order = 120,
			},
			blinking = {
				name = L['Enable blinking'],
				desc = L['Icons start blinking when the spell is about to end.'],
				type = 'toggle',
				order = 130,
			},
			blinkingThreshold = {
				name = L['Blinking threshold (sec.)'],
				desc = L['The remaining time threshold, below which the icon starts to blink.'],
				type = 'range',
				min = 1,
				max = 15,
				step = 0.5,
				order = 140,
			},
			bigIcons = {
				name = L['Enable warning area'],
				desc = L['A second display area, that shows spells about to end.'],
				type = 'toggle',
				width = 'double',
				order = 150,
			},
			bigThreshold = {
				name = L['Warning threshold'],
				desc = L['The remaining time threshold, below which the icon is displayed in the warning area.'],
				type = 'range',
				order = 160,
				min = 1,
				max = 15,
				step = 0.5,
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
				order = -20,
			},
			resetPosition = {
				name = L['Reset position'],
				desc = L['Move the anchor back to its default position.'],
				type = 'execute',
				func = function() self:ResetMovableLayout() end,
				order = -10,
			},
		},
	}
end

--------------------------------------------------------------------------------
-- ButtonFacade support
--------------------------------------------------------------------------------

local LBF = LibStub('LibButtonFacade', true)
if not LBF then
	-- No ButtonFacade, create bgous methods and leave
	function mod:OnInitializeButtonFacade() end
	function mod:ButtonFacadeSkin() end
	function mod:ApplyButtonFacadeSettings() end
else
	-- LBF support

	local group

	function mod:OnInitializeButtonFacade()
		local db = addon.db:RegisterNamespace(self.name.."_ButtonFacade", { profile = { skinID = "Zoomed" } })	
		group = LBF:Group(addonName)
		LBF:RegisterSkinCallback(addonName, function(_, skinID, gloss, backdrop, _, _, colors)
			local skin = db.profile
			skin.skinID, skin.gloss, skin.backdrop, skin.colors = skinID, gloss, backdrop, colors
		end, addon)
		function self:ApplyButtonFacadeSettings()
			local skin = db.profile
			group:Skin(skin.skinID, skin.gloss, skin.backdrop, skin.colors)
		end
	end

	function mod:ButtonFacadeSkin(icon)
		-- Extract existing data
		local data = { Icon = icon.Texture }
		
		-- Hide the default backdrop
		icon:SetBackdrop(nil)

		-- Create a bunch of texture to skin
		data.Backdrop = icon:CreateTexture(nil, "BACKGROUND")
		data.Backdrop:SetAllPoints(icon)
		data.Normal = icon.__Overlay:CreateTexture(nil, "ARTWORK")
		data.Normal:SetAllPoints(icon)
		icon.GetNormalTexture = function() return data.Normal:GetTexture() end
		icon.SetNormalTexture = function(_, ...) return data.Normal:SetTexture(...) end

		-- Register the icon
		group:AddButton(icon, data)
	end
		
end

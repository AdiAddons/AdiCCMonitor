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
-- Addon initialization and enabling
--------------------------------------------------------------------------------

function addon:OnInitialize()
	self.db = LibStub('AceDB-3.0'):New(addonName.."DB", DEFAULT_SETTINGS, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "Reconfigure")
	self.db.RegisterCallback(self, "OnProfileCopied", "Reconfigure")
	self.db.RegisterCallback(self, "OnProfileReset", "Reconfigure")
end

function addon:OnEnable()
end

function addon:OnDisable()
end

function addon:Reconfigure()
	self:Disable()
	self:Enable()
end



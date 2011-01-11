--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

local mod = addon:NewModule('Icons')

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName)
end

function mod:OnEnable()
end

function mod:OnDisable()

end
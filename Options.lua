--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

local options

function addon:GetOptionHandler(target)
	local target = target
	return {
		GetDatabase = function(self, info)
			return target.db.profile, info.args or info[#info]
		end,
		Get = function(self, info)
			local db, key = self:GetDatabase(info)
			return db[key]
		end,
		Set = function(self, info, value)
			local db, key = self:GetDatabase(info)
			db[key] = value
		end,
	}
end

function addon:GetOptions()
	if options then return options end
	options = {
		handler = self:GetOptionHandler(self),
		set = 'Set',
		get = 'Get',
	}
	return options
end

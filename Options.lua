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
		Get = function(self, info, subKey)
			local db, key = self:GetDatabase(info)
			if info.type == 'multiselect' then
				return db[key][subKey]
			else
				return db[key]
			end
		end,
		Set = function(self, info, ...)
			local db, key = self:GetDatabase(info)
			if info.type == 'multiselect' then
				local subKey, value = ...
				db[key][subKey] = value
			else
				db[key] = ...
			end
			if target.OnConfigChanged then
				target:OnConfigChanged(key, ...)
			end
		end,
		IsDisabled = function(self)
			return not target:IsEnabled()
		end,
	}
end

function addon:GetOptions()
	if options then return options end
	local moduleList = {}

	local profileOpts = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
	LibStub('LibDualSpec-1.0'):EnhanceOptions(profileOpts, self.db)
	profileOpts.order = -1

	options = {
		name = addonName,
		type = 'group',
		childGroups = 'tab',
		handler = self:GetOptionHandler(self),
		set = 'Set',
		get = 'Get',
		args = {
			main = {
				name = L['Main'],
				order = 1,
				type = 'group',
				args = {
					modules = {
						name = L['Enabled modules'],
						desc = L[''],
						order = 1,
						type = 'multiselect',
						values = moduleList,
					},
					onlyMine = {
						name = L['Only mine'],
						desc = L['Ignore spells from other players'],
						order  = 10,
						type = 'toggle',
					},
				},
			},
			profiles = profileOpts,
		},
	}
	for name, module in self:IterateModules() do
		moduleList[name] = L[name]
		if module.GetOptions then
			local modOpts = module:GetOptions()
			modOpts.order = 10
			options.args[name] = modOpts
		end
	end
	return options
end

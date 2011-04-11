--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

-- Copy globals in local scope to easily spot global leaks with "luac -l | grep GLOBAL"
local _G = _G
local LibStub, format, GetAddOnMetadata = _G.LibStub, _G.format, _G.GetAddOnMetadata

local addonName, addon = ...
local L = addon.L

local options

function addon:GetOptionHandler(target)
	local target = target
	local handler = {
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
	}
	if target ~= addon then
		handler.IsDisabled = function(self) return not addon.db.profile.modules[target.moduleName] end
	else
		handler.IsDisabled = function(self) return false end
	end
	return handler
end

function addon.GetOptions()
	if options then return options end
	local self = addon

	local moduleList = {}

	local profileOpts = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
	LibStub('LibDualSpec-1.0'):EnhanceOptions(profileOpts, self.db)
	profileOpts.order = -1

	options = {
		name = format("%s v%s", addonName, GetAddOnMetadata(addonName, "Version")),
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
					test = {
						name = L['Test'],
						order = 10,
						desc = L['Simulate some spell events to test the addon.'],
						type = 'execute',
						func = function() self:Test() end,
					},
					inInstances = {
						name = L['Enabled in ...'],
						desc = L['AdiCCMonitor will completely disable itself in unchecked zones.'],
						order = 15,
						type = 'multiselect',
						values = {
							raid = L['Raid instances'],
							party = L['5-man instances'],
							arena = L['Arenas'],
							pvp = L['Battlegrounds'],
							none = L['Open world'],
						},
						disabled = function() return self.testing end,
					},
					modules = {
						name = L['Enabled modules'],
						order = 20,
						type = 'multiselect',
						values = moduleList,
					},
					onlyMine = {
						name = L['Only mine'],
						desc = L['Ignore spells from other players.'],
						order  = 30,
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

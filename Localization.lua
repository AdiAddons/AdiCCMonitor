--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...

local L = setmetatable({}, {
	__index = function(self, key)
		if key ~= nil then
			--@debug@
			addon:Debug('Missing locale', tostring(key))
			--@end-debug@
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addon.L = L

-- %Localization: adiccmonitor

--@noloc[[
-- THE END OF THE FILE IS UPDATED BY A SCRIPT
-- ANY CHANGE BELOW THESES LINES WILL BE LOST
-- CHANGES SHOULD BE MADE USING http://www.wowace.com/addons/adiccmonitor/localization/

-- @noloc[[

------------------------ enUS ------------------------


-- Alerts.lua
L["%s is free !"] = true
L["%s will break free in %d secs."] = true
L["A warning message is sent when the time left for a spell runs below this value."] = true
L["About to end"] = true
L["Alerts"] = true
L["Applied"] = true
L["Broken early"] = true
L["Failures"] = true
L["Messages"] = true
L["Removed"] = true
L["Warning threshold (sec)"] = true

-- Icons.lua
L["AdiCCMonitor icons"] = true
L["Icon size"] = true
L["Icons"] = true
L["Lock anchor"] = true
L["Number of icons"] = true
L["Opacity"] = true
L["Reset position"] = true
L["Show cooldown model"] = true
L["Show countdown"] = true
L["Show symbol"] = true
L["Unlock anchor"] = true
L["Vertical"] = true

-- Options.lua
L["Enabled modules"] = true
L["Ignore spells from other players"] = true
L["Main"] = true
L["Only mine"] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["%s is free !"] = "%s est libre !"
L["%s will break free in %d secs."] = "%s sera libre dans %d secs."
L["A warning message is sent when the time left for a spell runs below this value."] = "Un message d'avertissement est envoyé si le temps restant d'un sort passe en dessous de cette valeur."
L["About to end"] = "Va se terminer"
L["AdiCCMonitor icons"] = "Icônes d'AdiCCMonitor"
L["Alerts"] = "Alertes"
L["Applied"] = "Appliqué"
L["Broken early"] = "Cassé prématurément"
L["Enabled modules"] = "Modules actifs"
L["Failures"] = "Echecs"
L["Icon size"] = "Taille des icônes"
L["Icons"] = "Icônes"
L["Ignore spells from other players"] = "Ignore les sorts des autres joueurs."
L["Lock anchor"] = "Verrouiller"
L["Main"] = "Général"
L["Messages"] = "Messages"
L["Number of icons"] = "Nombre d'icônes"
L["Only mine"] = "Seulement les miens"
L["Opacity"] = "Opacité"
L["Removed"] = "Enlevé"
L["Reset position"] = "Réinit. pos."
L["Show cooldown model"] = "Afficher le cooldown"
L["Show countdown"] = "Afficher le compte à rebours"
L["Show symbol"] = "Afficher le symbole"
L["Unlock anchor"] = "Déverrouiler"
L["Vertical"] = "Vertical"
L["Warning threshold (sec)"] = "Seuil d'alerte (sec)"

------------------------ deDE ------------------------
elseif locale == 'deDE' then
L["%s is free !"] = "%s ist frei !"
L["%s will break free in %d secs."] = "%s kommt in %d Sekunden frei."
L["A warning message is sent when the time left for a spell runs below this value."] = "Es wird eine Warnmeldung gesendet wenn die verbleibende Zeit des Spells unter diesen Wert fällt."
L["About to end"] = "Am Auslaufen"
L["AdiCCMonitor icons"] = "AdiCCMonitor-Symbole"
L["Alerts"] = "Warnungen"
L["Enabled modules"] = "Aktivierte Module"
L["Icon size"] = "Symbolgröße"
L["Icons"] = "Symbole"
L["Ignore spells from other players"] = "Spells von anderen Spielern ignorieren"
L["Lock anchor"] = "Ankerpunkt sperren"
L["Messages"] = "Nachrichten"
L["Number of icons"] = "Anzahl der Symbole"
L["Only mine"] = "Nur eigene"
L["Opacity"] = "Opazität"
L["Removed"] = "Entfernt"
L["Reset position"] = "Position zurücksetzen"
L["Show countdown"] = "Countdown anzeigen"
L["Show symbol"] = "Symbol anzeigen"
L["Unlock anchor"] = "Ankerpunkt entsperren"
L["Vertical"] = "Vertikal"

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
-- no translation

------------------------ esES ------------------------
-- no translation

------------------------ zhTW ------------------------
-- no translation

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
-- no translation
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end

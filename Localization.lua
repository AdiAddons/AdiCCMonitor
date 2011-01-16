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
L["%s has been freed by %s !"] = true
L["%s is affected by %s, lasting %d seconds."] = true
L["%s is free !"] = true
L["%s will break free in %d seconds."] = true
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
L["Blinking threshold (sec.)"] = true
L["Display the target raid marker."] = true
L["Enable blinking"] = true
L["Graphical display of time left."] = true
L["Icon size"] = true
L["Icons start blinking when the spell is about to end."] = true
L["Icons"] = true
L["Lock anchor"] = true
L["Move the anchor back to its default position."] = true
L["Number of icons"] = true
L["Numerical display of time left."] = true
L["Opacity"] = true
L["Reset position"] = true
L["Show cooldown model"] = true
L["Show countdown"] = true
L["Show symbol"] = true
L["The maximum number of icons to show. "] = true
L["The opacity of all icons. 100% means full opaque while 0% means fully transparent."] = true
L["The orientation of the icon bar."] = true
L["The remaining time threshold, below which the icon starts to blink."] = true
L["The size in pixels of icons displaying your spells. Spells of other players are 20% smaller."] = true
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
L["%s has been freed by %s !"] = "%s a été libéré par %s !"
L["%s is affected by %s, lasting %d seconds."] = "%s subit %s pour %s secondes."
L["%s is free !"] = "%s est libre !"
L["%s will break free in %d seconds."] = "%s se libèrera dans %s secondes."
L["A warning message is sent when the time left for a spell runs below this value."] = "Un message d'avertissement est envoyé si le temps restant d'un sort passe en dessous de cette valeur."
L["About to end"] = "Va se terminer"
L["AdiCCMonitor icons"] = "Icônes d'AdiCCMonitor"
L["Alerts"] = "Alertes"
L["Applied"] = "Appliqué"
L["Blinking threshold (sec.)"] = "Seuil de clignotement (sec.)"
L["Broken early"] = "Cassé prématurément"
L["Display the target raid marker."] = "Afficher le symbole de la cible."
L["Enable blinking"] = "Activer le clignotement"
L["Enabled modules"] = "Modules actifs"
L["Failures"] = "Echecs"
L["Graphical display of time left."] = "Affichage graphique du temps restant."
L["Icon size"] = "Taille des icônes"
L["Icons"] = "Icônes"
L["Icons start blinking when the spell is about to end."] = "L'icône commence à clignoter quand le sort est sur le point de se terminer."
L["Ignore spells from other players"] = "Ignore les sorts des autres joueurs."
L["Lock anchor"] = "Verrouiller"
L["Main"] = "Général"
L["Messages"] = "Messages"
L["Move the anchor back to its default position."] = "Déplacer l'ancre à sa position par défaut."
L["Number of icons"] = "Nombre d'icônes"
L["Numerical display of time left."] = "Affichage numérique du temps restant."
L["Only mine"] = "Seulement les miens"
L["Opacity"] = "Opacité"
L["Removed"] = "Enlevé"
L["Reset position"] = "Réinit. pos."
L["Show cooldown model"] = "Afficher le cooldown"
L["Show countdown"] = "Afficher le compte à rebours"
L["Show symbol"] = "Afficher le symbole"
L["The maximum number of icons to show. "] = "Le nombre maximal d'icônes à afficher."
L["The opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "L'opacité de tous les icônes. 100% signifie complétement opaque, 0% complétement transparent."
L["The orientation of the icon bar."] = "L'orientation de la barre d'icônes."
L["The remaining time threshold, below which the icon starts to blink."] = "Le seuil du temps restant au dessous duquel l'icône clignote."
L["The size in pixels of icons displaying your spells. Spells of other players are 20% smaller."] = "La taille en pixels des icônes affichant vos sorts. Les sorts des autres joueurs sont plus petits de 20%"
L["Unlock anchor"] = "Déverrouiler"
L["Vertical"] = "Vertical"
L["Warning threshold (sec)"] = "Seuil d'alerte (sec)"

------------------------ deDE ------------------------
elseif locale == 'deDE' then
L["%s is free !"] = "%s ist frei !"
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

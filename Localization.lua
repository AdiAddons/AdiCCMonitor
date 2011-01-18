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
elseif locale == 'koKR' then
L["%s has been freed by %s !"] = "%s|1이;가; %s에서 자유로워졌습니다!"
L["%s is affected by %s, lasting %d seconds."] = "%s|1이;가; %s에 걸렸습니다. %d초 남았습니다."
L["%s is free !"] = "%s|1은;는; 자유롭습니다!"
L["%s will break free in %d seconds."] = "%s|1은;는; %d초 후에 깨집니다."
L["A warning message is sent when the time left for a spell runs below this value."] = "이 값 이하로 실행 중인 주문에 대해 시간이 남아 있는 경우에 경고 메시지를 보냅니다."
L["About to end"] = "종료될 즈음"
L["AdiCCMonitor icons"] = "AdiCCMonitor 아이콘"
L["Alerts"] = "경고"
L["Applied"] = "적용됨"
L["Blinking threshold (sec.)"] = "반짝임 한계치(초.)"
L["Broken early"] = "초기에 깨짐"
L["Display the target raid marker."] = "대상에 공격대 전술 아이콘을 표시합니다."
L["Enable blinking"] = "반짝임 활성"
L["Enabled modules"] = "활성화된 모듈"
L["Failures"] = "실패"
L["Graphical display of time left."] = "남은 시간을 그래픽으로 표시합니다."
L["Icon size"] = "아이콘 크기"
L["Icons"] = "아이콘"
L["Icons start blinking when the spell is about to end."] = "주문이 종료될 즈음에 아이콘이 반짝거리기 시작합니다."
L["Ignore spells from other players"] = "다른 플레이어의 주문은 무시"
L["Lock anchor"] = "앵커 잠금"
L["Main"] = "메인"
L["Messages"] = "메시지"
L["Move the anchor back to its default position."] = "앵커가 그것의 기본 위치로 되돌려 이동합니다. "
L["Number of icons"] = "아이콘 갯수"
L["Numerical display of time left."] = "남은 시간을 소숫점 표시합니다."
L["Only mine"] = "내것에 한해"
L["Opacity"] = "불투명도"
L["Removed"] = "제거됨"
L["Reset position"] = "위치 초기화"
L["Show cooldown model"] = "블리자드 재사용 대기 보이기"
L["Show countdown"] = "헤아림 수 보이기"
L["Show symbol"] = "상징 보이기"
L["The maximum number of icons to show. "] = "보여 줄 아이콘의 최대 갯수를 설정합니다."
L["The opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "아이콘의 불투명도를 설정합니다. 0%가 완전히 반투명한 것에 반하여 100%는 완전히 불투명함을 의미합니다."
L["The orientation of the icon bar."] = "아이콘 바의 진행 방향을 설정합니다."
L["The remaining time threshold, below which the icon starts to blink."] = "남은 시간의 한계치를 설정합니다. 그 이하에서 아이콘이 반짝거리기 시작합니다."
L["The size in pixels of icons displaying your spells. Spells of other players are 20% smaller."] = "당신의 주문을 아이콘의 픽셀당 크기로 표시합니다. 다른 플레이어의 주문은 20% 더욱 작게 표시합니다."
L["Unlock anchor"] = "앵커 잠금 해제"
L["Vertical"] = "수직"
L["Warning threshold (sec)"] = "경고 한계치(초)"
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end

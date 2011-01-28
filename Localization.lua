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
L["%s has broken free!"] = true
L["%s is affected by %s, lasting %d seconds."] = true
L["%s is free !"] = true
L["%s will break free in %d seconds."] = true
L["5-man instances"] = true
L["A warning message is sent when the time left for a spell runs below this value."] = true
L["About to end"] = true
L["AdiCCMonitor will keep quiet in unchecked zones."] = true
L["Alerts"] = true
L["Alternative symbol strings"] = true
L["Arenas"] = true
L["Battlegrounds"] = true
L["Beginning"] = true
L["Broken early"] = true
L["Enabled in ..."] = true
L["End"] = true
L["Events to announce"] = true
L["Failures"] = true
L["Note: '%s' ignores players flagged as tanks."] = true
L["Open world"] = true
L["Raid instances"] = true
L["Use this option if %s or %s are not displayed as icons in chat frames. AdiCCMonitor will use {rt1}..{rt8} instead. Note: stock chat bubbles do not display any of them anyway."] = true
L["Warning threshold (sec)"] = true

-- Icons.lua
L["AdiCCMonitor icons"] = true
L["Blinking threshold (sec.)"] = true
L["Caster name."] = true
L["Caster position"] = true
L["Countdown position"] = true
L["Display the target raid marker."] = true
L["Enable blinking"] = true
L["Graphical display of time left."] = true
L["Icon size"] = true
L["Icons start blinking when the spell is about to end."] = true
L["Icons"] = true
L["Inside, bottom"] = true
L["Inside, left"] = true
L["Inside, right"] = true
L["Inside, top"] = true
L["Lock anchor"] = true
L["Move the anchor back to its default position."] = true
L["Number of icons"] = true
L["Numerical display of time left."] = true
L["Opacity"] = true
L["Outside, bottom"] = true
L["Outside, left"] = true
L["Outside, right"] = true
L["Outside, top"] = true
L["Reset position"] = true
L["Show caster"] = true
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
L["Ignore spells from other players."] = true
L["Main"] = true
L["Only mine"] = true
L["Simulate some spell events to test the addon."] = true
L["Test"] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["%s has been freed by %s !"] = "%s a été libéré par %s !"
L["%s has broken free!"] = "%s s'est libéré !"
L["%s is affected by %s, lasting %d seconds."] = "%s subit %s pour %s secondes."
L["%s is free !"] = "%s est libre !"
L["%s will break free in %d seconds."] = "%s se libèrera dans %s secondes."
L["5-man instances"] = "Donjons pour cinq"
L["A warning message is sent when the time left for a spell runs below this value."] = "Un message d'avertissement est envoyé si le temps restant d'un sort passe en dessous de cette valeur."
L["About to end"] = "Va se terminer"
L["AdiCCMonitor icons"] = "Icônes d'AdiCCMonitor"
L["AdiCCMonitor will keep quiet in unchecked zones."] = "AdicCMonitor sera silencieux dans les zones désélectionnées."
L["Alerts"] = "Alertes"
L["Alternative symbol strings"] = "Chaînes de symbole alternatives"
L["Arenas"] = "Arènes"
L["Battlegrounds"] = "Champs de bataille"
L["Beginning"] = "Début"
L["Blinking threshold (sec.)"] = "Seuil de clignotement (sec.)"
L["Broken early"] = "Cassé prématurément"
L["Caster name."] = "Nom du lanceur."
L["Caster position"] = "Position du nom du lanceur"
L["Countdown position"] = "Position du compte à rebours."
L["Display the target raid marker."] = "Afficher le symbole de la cible."
L["Enable blinking"] = "Activer le clignotement"
L["Enabled in ..."] = "Activé dans ..."
L["Enabled modules"] = "Modules actifs"
L["End"] = "Fin"
L["Events to announce"] = "Evénements à annoncer."
L["Failures"] = "Echecs"
L["Graphical display of time left."] = "Affichage graphique du temps restant."
L["Icon size"] = "Taille des icônes"
L["Icons"] = "Icônes"
L["Icons start blinking when the spell is about to end."] = "L'icône commence à clignoter quand le sort est sur le point de se terminer."
L["Ignore spells from other players."] = "Ignorer les sorts des autres joueurs."
L["Inside, bottom"] = "A l'intérieur, en bas"
L["Inside, left"] = "A l'intérieur, à gauche"
L["Inside, right"] = "A l'intérieur, à droite"
L["Inside, top"] = "A l'intérieur, en haut"
L["Lock anchor"] = "Verrouiller"
L["Main"] = "Général"
L["Move the anchor back to its default position."] = "Déplacer l'ancre à sa position par défaut."
L["Note: '%s' ignores players flagged as tanks."] = "Note: '%s' ignore les joueurs marqués comme tank."
L["Number of icons"] = "Nombre d'icônes"
L["Numerical display of time left."] = "Affichage numérique du temps restant."
L["Only mine"] = "Seulement les miens"
L["Opacity"] = "Opacité"
L["Open world"] = "Monde"
L["Outside, bottom"] = "A l'extérieur, en bas"
L["Outside, left"] = "A l'extérieur, à gauche"
L["Outside, right"] = "A l'extérieur, à droite"
L["Outside, top"] = "A l'extérieur, en haut"
L["Raid instances"] = "Donjons de raid"
L["Reset position"] = "Réinit. pos."
L["Show caster"] = "Afficher le lanceur"
L["Show cooldown model"] = "Afficher le cooldown"
L["Show countdown"] = "Afficher le compte à rebours"
L["Show symbol"] = "Afficher le symbole"
L["Simulate some spell events to test the addon."] = "Simule des événements de sorts pour tester l'addon."
L["Test"] = "Test"
L["The maximum number of icons to show. "] = "Le nombre maximal d'icônes à afficher."
L["The opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "L'opacité de tous les icônes. 100% signifie complétement opaque, 0% complétement transparent."
L["The orientation of the icon bar."] = "L'orientation de la barre d'icônes."
L["The remaining time threshold, below which the icon starts to blink."] = "Le seuil du temps restant au-dessous duquel l'icône clignote."
L["The size in pixels of icons displaying your spells. Spells of other players are 20% smaller."] = "La taille en pixels des icônes affichant vos sorts. Les sorts des autres joueurs sont plus petits de 20%"
L["Unlock anchor"] = "Déverrouiler"
L["Use this option if %s or %s are not displayed as icons in chat frames. AdiCCMonitor will use {rt1}..{rt8} instead. Note: stock chat bubbles do not display any of them anyway."] = "Utilisez cette option si %s ou %s ne sont pas affichés comme des icônes dans les fenêtres de discussion. AdiCCMonitor utilisera {rt1}..{rt8} à la place. Note: les bulles de discussion n'affichent aucun des deux de toute façon."
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
L["Lock anchor"] = "Ankerpunkt sperren"
L["Number of icons"] = "Anzahl der Symbole"
L["Only mine"] = "Nur eigene"
L["Opacity"] = "Opazität"
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
elseif locale == 'zhTW' then
L["%s has been freed by %s !"] = "%s 被 %s 釋放!"
L["%s is affected by %s, lasting %d seconds."] = "%s 被 %s 受影響, 維持 %d 秒。"
L["%s is free !"] = "%s 釋放!"
L["%s will break free in %d seconds."] = "%s 即將在 %d 秒後掙脫。"
L["5-man instances"] = "5人副本"
L["A warning message is sent when the time left for a spell runs below this value."] = "剩餘時間的法術運行低於此數值時警告訊息發送。"
L["About to end"] = "即將結束"
L["AdiCCMonitor icons"] = "AdiCCMonitor 圖示"
L["Alerts"] = "警報"
L["Alternative symbol strings"] = "替代符號串"
L["Arenas"] = "競技場"
L["Battlegrounds"] = "戰場"
L["Beginning"] = "開始"
L["Blinking threshold (sec.)"] = "閃爍門限(秒數)"
L["Broken early"] = "提早打破"
L["Caster name."] = "施放者名稱。"
L["Caster position"] = "施放者位置"
L["Countdown position"] = "冷卻時間位置"
L["Display the target raid marker."] = "顯示目標團隊記錄。"
L["Enable blinking"] = "啟用閃爍"
L["Enabled in ..."] = "啟用在..."
L["Enabled modules"] = "已啟用模組"
L["End"] = "結束"
L["Events to announce"] = "事件發佈"
L["Failures"] = "失敗"
L["Graphical display of time left."] = "圖形顯示剩餘時間。"
L["Icon size"] = "圖示尺寸"
L["Icons"] = "圖示"
L["Icons start blinking when the spell is about to end."] = "法術即將結束時圖示開始閃爍。"
L["Ignore spells from other players."] = "忽略法術來自其他玩家。"
L["Inside, bottom"] = "在內部, 底"
L["Inside, left"] = "在內部, 左"
L["Inside, right"] = "在內部, 右"
L["Inside, top"] = "在內部, 頂"
L["Lock anchor"] = "鎖住錨點"
L["Main"] = "主要"
L["Move the anchor back to its default position."] = "移動錨點在原處預設值位置。"
L["Number of icons"] = "圖示數量"
L["Numerical display of time left."] = "數字顯示剩餘時間。"
L["Only mine"] = "唯我的"
L["Opacity"] = "不透明"
L["Open world"] = "開放世界"
L["Outside, bottom"] = "在外部, 底"
L["Outside, left"] = "在外部, 左"
L["Outside, right"] = "在外部, 右"
L["Outside, top"] = "在外部, 頂"
L["Raid instances"] = "團隊副本"
L["Reset position"] = "重設位置"
L["Show caster"] = "顯示施放者"
L["Show cooldown model"] = "顯示冷卻時間模型"
L["Show countdown"] = "顯示冷卻時間"
L["Show symbol"] = "顯示記號"
L["Simulate some spell events to test the addon."] = "模擬一些法術事件來測試插件。"
L["Test"] = "測試"
L["The maximum number of icons to show. "] = "顯示圖示最大數量。"
L["The opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "不透明的全部圖示。100% 表示完全不透明，而 0% 表示完全透明。"
L["The orientation of the icon bar."] = "圖示條列的定方位。"
L["The remaining time threshold, below which the icon starts to blink."] = "剩餘時間門限, 低於圖示開始閃爍。"
L["The size in pixels of icons displaying your spells. Spells of other players are 20% smaller."] = "像素大小的圖示顯示你的法術。法術的其他隊員都小20%。"
L["Unlock anchor"] = "解鎖錨點"
L["Vertical"] = "垂直"
L["Warning threshold (sec)"] = "警告門限(秒數)"

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
elseif locale == 'koKR' then
L["%s has been freed by %s !"] = "%s|1이;가; %s에서 자유로워졌습니다!"
L["%s is affected by %s, lasting %d seconds."] = "%s|1이;가; %s에 걸렸습니다. %d초 남았습니다."
L["%s is free !"] = "%s|1은;는; 자유롭습니다!"
L["%s will break free in %d seconds."] = "%s|1은;는; %d초 후에 깨집니다."
L["5-man instances"] = "5인 인던"
L["A warning message is sent when the time left for a spell runs below this value."] = "이 값 이하로 실행 중인 주문에 대해 시간이 남아 있는 경우에 경고 메시지를 보냅니다."
L["About to end"] = "종료될 즈음"
L["AdiCCMonitor icons"] = "AdiCCMonitor 아이콘"
L["Alerts"] = "경고"
L["Arenas"] = "투기장"
L["Battlegrounds"] = "전장"
L["Beginning"] = "시작"
L["Blinking threshold (sec.)"] = "반짝임 한계치(초.)"
L["Broken early"] = "초기에 깨짐"
L["Caster name."] = "시전자 이름"
L["Caster position"] = "시전자 위치"
L["Countdown position"] = "재사용 대기 위치"
L["Display the target raid marker."] = "대상에 공격대 전술 아이콘을 표시합니다."
L["Enable blinking"] = "반짝임 활성"
L["Enabled modules"] = "활성화된 모듈"
L["End"] = "끝"
L["Events to announce"] = "알리기 위한 이벤트"
L["Failures"] = "실패"
L["Graphical display of time left."] = "남은 시간을 그래픽으로 표시합니다."
L["Icon size"] = "아이콘 크기"
L["Icons"] = "아이콘"
L["Icons start blinking when the spell is about to end."] = "주문이 종료될 즈음에 아이콘이 반짝거리기 시작합니다."
L["Ignore spells from other players."] = "다른 플레이어의 주문 무시"
L["Inside, bottom"] = "내부, 하단"
L["Inside, left"] = "내부, 좌측"
L["Inside, right"] = "내부, 우측"
L["Inside, top"] = "내부, 상단"
L["Lock anchor"] = "앵커 잠금"
L["Main"] = "메인"
L["Move the anchor back to its default position."] = "앵커가 그것의 기본 위치로 되돌려 이동합니다. "
L["Number of icons"] = "아이콘 갯수"
L["Numerical display of time left."] = "남은 시간을 소숫점 표시합니다."
L["Only mine"] = "내것에 한해"
L["Opacity"] = "불투명도"
L["Outside, bottom"] = "외부, 하단"
L["Outside, left"] = "외부, 좌측"
L["Outside, right"] = "외부, 우측"
L["Outside, top"] = "외부, 상단"
L["Raid instances"] = "공격대 인던"
L["Reset position"] = "위치 초기화"
L["Show caster"] = "시전자 보이기"
L["Show cooldown model"] = "블리자드 재사용 대기 보이기"
L["Show countdown"] = "헤아림 수 보이기"
L["Show symbol"] = "상징 보이기"
L["Simulate some spell events to test the addon."] = "애드온을 테스트 하기 위해 몇개의 주문 이벤트를 시연합니다."
L["Test"] = "테스트"
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

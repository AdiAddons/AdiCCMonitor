--[[
AdiCCMonitor - Crowd-control monitor.
Copyright 2011-2012 Adirelle (adirelle@gmail.com)
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
L["%s would send this alert:"] = true
L["5-man instances"] = true
L["A warning message is sent when the time left for a spell runs below this value."] = true
L["About to end"] = true
L["AdiCCMonitor will keep quiet in unchecked zones."] = true
L["Alerts"] = true
L["Arenas"] = true
L["Battlegrounds"] = true
L["Beginning"] = true
L["Broken early"] = true
L["Enabled in ..."] = true
L["End"] = true
L["Events to announce"] = true
L["Failures"] = true
L["Ignore tanks"] = true
L["Keep quiet when a character flagged as a tank breaks a spell."] = true
L["Note: '%s' ignores players flagged as tanks."] = true
L["Open world"] = true
L["Raid instances"] = true
L["Warning threshold (sec)"] = true
L["Scenarios"] = true

-- Icons.lua
L["A second display area, that shows spells about to end."] = true
L["AdiCCMonitor icons"] = true
L["AdiCCMonitor warning icons"] = true
L["Blinking threshold (sec.)"] = true
L["Caster name."] = true
L["Caster position"] = true
L["Countdown position"] = true
L["Display the target raid marker."] = true
L["Enable blinking"] = true
L["Enable warning area"] = true
L["Font to use for the caster and countdown texts"] = true
L["Graphical display of time left."] = true
L["Icon size"] = true
L["Icon spacing"] = true
L["Icons start blinking when the spell is about to end."] = true
L["Icons"] = true
L["Inside, bottom"] = true
L["Inside, left"] = true
L["Inside, right"] = true
L["Inside, top"] = true
L["Lock anchor"] = true
L["Maximum number of icons to show."] = true
L["Move the anchor back to its default position."] = true
L["Number of icons"] = true
L["Numerical display of time left."] = true
L["Opacity of all icons. 100% means full opaque while 0% means fully transparent."] = true
L["Opacity"] = true
L["Orientation of the icon bar."] = true
L["Outside, bottom"] = true
L["Outside, left"] = true
L["Outside, right"] = true
L["Outside, top"] = true
L["Reset position"] = true
L["Show caster"] = true
L["Show cooldown model"] = true
L["Show countdown"] = true
L["Show symbol"] = true
L["Size of icons displaying your spells, in pixels. Spells of other players are 20% smaller."] = true
L["Size of the gap between icons, in pixels."] = true
L["Size, in pixels, of the caster and countdown texts."] = true
L["Text font"] = true
L["Text size"] = true
L["The remaining time threshold, below which the icon is displayed in the warning area."] = true
L["The remaining time threshold, below which the icon starts to blink."] = true
L["Unlock anchor"] = true
L["Vertical"] = true
L["Warning threshold"] = true

-- Options.lua
L["AdiCCMonitor will completely disable itself in unchecked zones."] = true
L["Enabled modules"] = true
L["Ignore spells from other players."] = true
L["Main"] = true
L["Only mine"] = true
L["Simulate some spell events to test the addon."] = true
L["Test"] = true


------------------------ frFR ------------------------
local locale = GetLocale()
if locale == 'frFR' then
L["5-man instances"] = "Donjons pour cinq"
L["About to end"] = "Va se terminer"
L["AdiCCMonitor icons"] = "Icônes d'AdiCCMonitor"
L["AdiCCMonitor will completely disable itself in unchecked zones."] = "AdiCCMonitor sera totalement désactivé dans les zones non cochées."
L["AdiCCMonitor will keep quiet in unchecked zones."] = "AdicCMonitor sera silencieux dans les zones désélectionnées."
L["Alerts"] = "Alertes"
L["Arenas"] = "Arènes"
L["A warning message is sent when the time left for a spell runs below this value."] = "Un message d'avertissement est envoyé si le temps restant d'un sort passe en dessous de cette valeur."
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
L["Font to use for the caster and countdown texts"] = "Police utilisée pour le compte à rebours et le nom du lanceur de sort."
L["Graphical display of time left."] = "Affichage graphique du temps restant."
L["Icons"] = "Icônes"
L["Icon size"] = "Taille des icônes"
L["Icon spacing"] = "Espacement des icônes"
L["Icons start blinking when the spell is about to end."] = "L'icône commence à clignoter quand le sort est sur le point de se terminer."
L["Ignore spells from other players."] = "Ignorer les sorts des autres joueurs."
L["Inside, bottom"] = "A l'intérieur, en bas"
L["Inside, left"] = "A l'intérieur, à gauche"
L["Inside, right"] = "A l'intérieur, à droite"
L["Inside, top"] = "A l'intérieur, en haut"
L["Lock anchor"] = "Verrouiller"
L["Main"] = "Général"
L["Maximum number of icons to show."] = "Nombre maximum d'icônes à afficher."
L["Move the anchor back to its default position."] = "Déplacer l'ancre à sa position par défaut."
L["Note: '%s' ignores players flagged as tanks."] = "Note: '%s' ignore les joueurs marqués comme tank."
L["Number of icons"] = "Nombre d'icônes"
L["Numerical display of time left."] = "Affichage numérique du temps restant."
L["Only mine"] = "Seulement les miens"
L["Opacity"] = "Opacité"
L["Opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "Opacité de tous les icônes. 100% signifie totalement opaque alors que 0% signifie totalement transparent."
L["Open world"] = "Monde"
L["Orientation of the icon bar."] = "Orientation de la barre d'icônes."
L["Outside, bottom"] = "A l'extérieur, en bas"
L["Outside, left"] = "A l'extérieur, à gauche"
L["Outside, right"] = "A l'extérieur, à droite"
L["Outside, top"] = "A l'extérieur, en haut"
L["Raid instances"] = "Donjons de raid"
L["Reset position"] = "Réinit. pos."
L["%s has been freed by %s !"] = "%s a été libéré par %s !"
L["%s has broken free!"] = "%s s'est libéré !"
L["Scenarios"] = SCENARIOS
L["Show caster"] = "Afficher le lanceur"
L["Show cooldown model"] = "Afficher le cooldown"
L["Show countdown"] = "Afficher le compte à rebours"
L["Show symbol"] = "Afficher le symbole"
L["Simulate some spell events to test the addon."] = "Simule des événements de sorts pour tester l'addon."
L["%s is affected by %s, lasting %d seconds."] = "%s subit %s pour %s secondes."
L["%s is free !"] = "%s est libre !"
L["Size, in pixels, of the caster and countdown texts."] = "Taille de police, en pixels, du compte à rebours et du nom du lanceur de sort."
L["Size of icons displaying your spells, in pixels. Spells of other players are 20% smaller."] = "Taille des icônes affichant vos sorts, en pixels. Les sorts des autres joueurs sont affichés avec des icônes 20% plus petits."
L["Size of the gap between icons, in pixels."] = "Taille de l'espace entre les icônes, en pixels."
L["%s will break free in %d seconds."] = "%s se libèrera dans %s secondes."
L["%s would send this alert:"] = "%s enverrait cette alerte :"
L["Test"] = "Test"
L["Text font"] = "Police des textes"
L["Text size"] = "Taille des textes"
L["The remaining time threshold, below which the icon starts to blink."] = "Le seuil du temps restant au-dessous duquel l'icône clignote."
L["Unlock anchor"] = "Déverrouiler"
L["Vertical"] = "Vertical"
L["Warning threshold (sec)"] = "Seuil d'alerte (sec)"

------------------------ deDE ------------------------
elseif locale == 'deDE' then
L["5-man instances"] = "5-Mann Instanzen"
L["About to end"] = "Läuft aus"
L["AdiCCMonitor icons"] = "AdiCCMonitor-Symbole"
L["AdiCCMonitor will completely disable itself in unchecked zones."] = "AdiCCMonitor wird sich in unmarkierten Zonen komplett deaktivieren."
L["AdiCCMonitor will keep quiet in unchecked zones."] = "In Gebieten die nicht ausgewählt sind wird AdiCCMonitor keine Meldungen ausgeben."
L["Alerts"] = "Warnungen"
L["Arenas"] = "Arenen"
L["A warning message is sent when the time left for a spell runs below this value."] = "Es wird eine Warnmeldung ausgegeben wenn die verbleibende Zeit des Zauber unter diesen Wert fällt."
L["Battlegrounds"] = "Schlachtfelder"
L["Beginning"] = "Startet"
L["Blinking threshold (sec.)"] = "Aufblink-Grenzwert (Sek.)"
L["Broken early"] = "Zu früh befreit"
L["Caster name."] = "Name des Zaubernden"
L["Caster position"] = "Position des Zaubernden"
L["Countdown position"] = "Position des Countdowns"
L["Display the target raid marker."] = "Zeige des Ziels Schlachtzugssymbol."
L["Enable blinking"] = "Aufblinken aktivieren"
L["Enabled in ..."] = "Aktiviert in ..."
L["Enabled modules"] = "Aktivierte Module"
L["End"] = "Ende"
L["Events to announce"] = "Anzuzeigende Ereignisse"
L["Failures"] = "Fehler"
L["Font to use for the caster and countdown texts"] = "Die für Zauber- und Countdowntexte genutzte Schriftart"
L["Graphical display of time left."] = "Grafische Anzeige der verbleibenden Zeit."
L["Icons"] = "Symbole"
L["Icon size"] = "Symbolgröße"
L["Icon spacing"] = "Symbol Abstand"
L["Icons start blinking when the spell is about to end."] = "Symbole blinken auf wenn der Zauber ausläuft."
L["Ignore spells from other players."] = "Lasse Zauber anderer Spieler außer Acht."
L["Ignore tanks"] = "Tanks ignorieren"
L["Inside, bottom"] = "Innen, unten"
L["Inside, left"] = "Innen, links"
L["Inside, right"] = "Innen, rechts"
L["Inside, top"] = "Innen, oben"
L["Keep quiet when a character flagged as a tank breaks a spell."] = "Keine Warnungen wenn ein als Tank markierter Charaktier einen Zauber bricht."
L["Lock anchor"] = "Verankerung fixieren"
L["Main"] = "Haupteinstellungen"
L["Maximum number of icons to show."] = "Anzahl der maximal angezeigten Symbole."
L["Move the anchor back to its default position."] = "Verankerung zur Ausgangsposition zurücksetzen."
L["Note: '%s' ignores players flagged as tanks."] = "Anmerkung: '%s' lässt Spieler außer Acht die als Tank gekennzeichnet wurden."
L["Number of icons"] = "Anzahl der Symbole"
L["Numerical display of time left."] = "Anzeigen der verbleibenden Zeit in Zahlen."
L["Only mine"] = "Nur eigene"
L["Opacity"] = "Tranzparenz"
L["Opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "Tranzparenz aller Symbole. 100% bedeutet totale Undurchsichtigkeit, 0% bedeutet totale Tranzparenz."
L["Open world"] = "Welt Gebiete"
L["Orientation of the icon bar."] = "Ausrichtung der Symbol-Leiste"
L["Outside, bottom"] = "Außen, unten"
L["Outside, left"] = "Außen, links"
L["Outside, right"] = "Außen, rechts"
L["Outside, top"] = "Außen, oben"
L["Raid instances"] = "Schlachtzugs-Instanzen"
L["Reset position"] = "Position zurücksetzen"
L["%s has been freed by %s !"] = "%s wurde durch/von %s befreit !"
L["%s has broken free!"] = "%s wurde befreit!"
L["Scenarios"] = SCENARIOS
L["Show caster"] = "Zeige Zaubernden"
L["Show cooldown model"] = "Zeige Cooldown Variante"
L["Show countdown"] = "Zeige Countdown"
L["Show symbol"] = "Symbol anzeigen"
L["Simulate some spell events to test the addon."] = "Erzeuge einige Zauberereignisse um die Funktionalität des Addons zu testen."
L["%s is affected by %s, lasting %d seconds."] = "%s wurde mit %s belegt, dauert %d Sekunden an."
L["%s is free !"] = "%s ist frei !"
L["Size, in pixels, of the caster and countdown texts."] = "Größe der Zauber- und Cooldowntexte (in Pixel)."
L["Size of icons displaying your spells, in pixels. Spells of other players are 20% smaller."] = "Symbolgröße zur Anzeige deiner Zauber (in Pixel). Die Zauber anderer Spieler werden 20% kleiner dargestellt."
L["Size of the gap between icons, in pixels."] = "Größe des Abstands zwischen den Symbolen (in Pixel)."
L["%s will break free in %d seconds."] = "%s wird in %d Sekunden wieder frei sein."
L["Test"] = "Test"
L["Text font"] = "Schriftart"
L["Text size"] = "Schriftgröße"
L["The remaining time threshold, below which the icon starts to blink."] = "Der Zeitgrenzwert ab dem die Symbole anfangen aufzublinken."
L["Unlock anchor"] = "Verankerung lösen"
L["Vertical"] = "Vertikal"
L["Warning threshold (sec)"] = "Warngrenzwert (Sek.)"

------------------------ esMX ------------------------
-- no translation

------------------------ ruRU ------------------------
elseif locale == 'ruRU' then
L["5-man instances"] = "Подземелье на 5 человек"
L["About to end"] = "Действие заклинания подходит к концу"
L["AdiCCMonitor icons"] = "Иконки AdiCCMonitor"
L["AdiCCMonitor will completely disable itself in unchecked zones."] = "AdiCCMonitor полностью отключается в неотмеченных зонах."
L["AdiCCMonitor will keep quiet in unchecked zones."] = "AdiCCMonitor будет предупреждать только в отмеченных зонах."
L["Alerts"] = "Предупреждения"
L["Arenas"] = "Арена"
L["A warning message is sent when the time left for a spell runs below this value."] = "Предупреждение посылается, когда время до окончания действия заклинания будет ниже этого значения."
L["Battlegrounds"] = "Поле боя"
L["Beginning"] = "Начало"
L["Blinking threshold (sec.)"] = "Порог мигания, сек."
L["Broken early"] = "Освобождён раньше"
L["Caster name."] = "Имя заклинателя"
L["Caster position"] = "Позиция заклинателя"
L["Countdown position"] = "Позиция обратного отсчёта"
L["Display the target raid marker."] = "Отображать рейд-маркер цели."
L["Enable blinking"] = "Включить мигание"
L["Enabled in ..."] = "Включён в ..."
L["Enabled modules"] = "Включенные модули"
L["End"] = "Конец действия заклинания"
L["Events to announce"] = "События для оповещения"
L["Failures"] = "Неудача"
L["Font to use for the caster and countdown texts"] = "Шрифт используемый для имени заклинателя и текста обратного отсчёта"
L["Graphical display of time left."] = "Графическое отображение оставшегося времени."
L["Icons"] = "Иконки"
L["Icon size"] = "Размер иконок"
L["Icon spacing"] = "Расстояние между иконками"
L["Icons start blinking when the spell is about to end."] = "Иконки начинают мигать, когда действие заклинания подходит к концу."
L["Ignore spells from other players."] = "Игнорировать заклинания других игроков."
L["Ignore tanks"] = "Игнорировать танков"
L["Inside, bottom"] = "Внутри, внизу"
L["Inside, left"] = "Внутри, слева"
L["Inside, right"] = "Внутри, справа"
L["Inside, top"] = "Внутри, вверху"
L["Keep quiet when a character flagged as a tank breaks a spell."] = "Не предуреждать, когда контроль сбивает игрок помеченный как танк."
L["Lock anchor"] = "Закрепить"
L["Main"] = "Основное"
L["Maximum number of icons to show."] = "Макс. число отображаемых иконок."
L["Move the anchor back to its default position."] = "Вернуть в начальное положение."
L["Note: '%s' ignores players flagged as tanks."] = "Примечание: '%s' игнорирует игроков помеченных как танк."
L["Number of icons"] = "Кол-во иконок"
L["Numerical display of time left."] = "Цифровое отображение оставшегося времени."
L["Only mine"] = "Только мои"
L["Opacity"] = "Непрозрачность"
L["Opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "Непрозрачность всех иконок. 100% - полная непрозрачность, 0% - полная прозрачность."
L["Open world"] = "Мир"
L["Orientation of the icon bar."] = "Ориентация полосы иконок."
L["Outside, bottom"] = "Снаружи, внизу"
L["Outside, left"] = "Снаружи, слева"
L["Outside, right"] = "Снаружи, справа"
L["Outside, top"] = "Снаружи, вверху"
L["Raid instances"] = "Рейдовое подземелье"
L["Reset position"] = "Восстановить позицию"
L["%s has been freed by %s !"] = "С %s сбил(а) контроль %s !"
L["%s has broken free!"] = "%s освободился!"
L["Scenarios"] = SCENARIOS
L["Show caster"] = "Показывать заклинателя"
L["Show cooldown model"] = "Показывать модель восстановления "
L["Show countdown"] = "Показывать обратный отсчёт"
L["Show symbol"] = "Показывать символ"
L["Simulate some spell events to test the addon."] = "Симулировать предупреждения для тестирования аддона."
L["%s is affected by %s, lasting %d seconds."] = "%s  под эффектом  %s на %d сек."
L["%s is free !"] = "%s СВОБОДЕН!"
L["Size, in pixels, of the caster and countdown texts."] = "Размер имени заклинателя и текста обратного отсчёта."
L["Size of icons displaying your spells, in pixels. Spells of other players are 20% smaller."] = "Размер иконок заклинаний, в пикселях. Иконки заклинаний других игроков на 20% меньше."
L["Size of the gap between icons, in pixels."] = "Размер интервала между иконками, в пикселях."
L["%s will break free in %d seconds."] = "%s освободится через %d сек."
L["Test"] = "Тест"
L["Text font"] = "Шрифт текста"
L["Text size"] = "Размер текста"
L["The remaining time threshold, below which the icon starts to blink."] = "Порог оставшегося времени, после которого иконка начнёт мигать."
L["Unlock anchor"] = "Переместить"
L["Vertical"] = "Вертикально"
L["Warning threshold (sec)"] = "Порог предупреждения, сек."

------------------------ esES ------------------------
elseif locale == 'esES' then
L["5-man instances"] = "Instancias de 5 jugadores"
L["About to end"] = "A punto de terminar"
L["AdiCCMonitor icons"] = "Iconos de AdiCCMonitor"
L["AdiCCMonitor will completely disable itself in unchecked zones."] = "AdiCCMonitor se desactivará completamente en las zonas sin marcar."
L["AdiCCMonitor will keep quiet in unchecked zones."] = "AdiCCMonitor se estará callado en las zonas sin marcar."
L["Alerts"] = "Alertas"
L["Arenas"] = "Arenas"
L["A warning message is sent when the time left for a spell runs below this value."] = "Se enviará un mensaje de aviso cuando el tiempo restante de un hechizo sea menor que este valor."
L["Battlegrounds"] = "Campos de batalla"
L["Beginning"] = "Inicio"
L["Blinking threshold (sec.)"] = "Antelación del parpadeo (segundos)"
L["Broken early"] = "Roto prematuramente"
L["Caster name."] = "Muestra el nombre del lanzador."
L["Caster position"] = "Posición del lanzador"
L["Countdown position"] = "Posición de la cuenta atrás"
L["Display the target raid marker."] = "Muestra la marca de raid del objetivo."
L["Enable blinking"] = "Activar parpadeo"
L["Enabled in ..."] = "Activado en ..."
L["Enabled modules"] = "Modulos habilitados"
L["End"] = "Fin"
L["Events to announce"] = "Eventos a anunciar"
L["Failures"] = "Fallos"
L["Font to use for the caster and countdown texts"] = "Fuente a usar por los textos de lanzador y cuenta atrás"
L["Graphical display of time left."] = "Visualización gráfica del tiempo restante."
L["Icons"] = "Iconos"
L["Icon size"] = "Tamaño de iconos"
L["Icon spacing"] = "Espaciado de iconos"
L["Icons start blinking when the spell is about to end."] = "Los iconos comienzan a parpadear cuando el hechizo está a punto de terminar."
L["Ignore spells from other players."] = "Ignora los hechizos de otros jugadores."
L["Ignore tanks"] = "Ignorar tanques"
L["Inside, bottom"] = "Dentro, abajo"
L["Inside, left"] = "Dentro, izquierda"
L["Inside, right"] = "Dentro, derecha"
L["Inside, top"] = "Dentro, arriba"
L["Keep quiet when a character flagged as a tank breaks a spell."] = "Guardar silencio cuando un personaje marcado como tanque rompe un hechizo."
L["Lock anchor"] = "Bloquear marco"
L["Main"] = "Principal"
L["Maximum number of icons to show."] = "Máxino número de iconos que se mostrarán."
L["Move the anchor back to its default position."] = "Mueve el marco a su posición original"
L["Note: '%s' ignores players flagged as tanks."] = "Nota: '%s' ignorará a los jugadores marcados como tanques."
L["Number of icons"] = "Número de iconos"
L["Numerical display of time left."] = "Visualización numérica del tiempo restante."
L["Only mine"] = "Solo míos"
L["Opacity"] = "Opacidad"
L["Opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "Opacidad de todos los iconos. 100% serán completamente opacos, mientras que 0% serán completamente transparentes."
L["Open world"] = "Mundo abierto"
L["Orientation of the icon bar."] = "Orientación de la barra de iconos."
L["Outside, bottom"] = "Fuera, abajo"
L["Outside, left"] = "Fuera, izquierda"
L["Outside, right"] = "Fuera, derecha"
L["Outside, top"] = "Fuera, arriba"
L["Raid instances"] = "Instancias de banda"
L["Reset position"] = "Restablecer posición"
L["%s has been freed by %s !"] = "¡ %s ha sido liberado por %s !"
L["%s has broken free!"] = "¡ %s se ha liberado !"
L["Scenarios"] = SCENARIOS
L["Show caster"] = "Mostrar lanzador"
L["Show cooldown model"] = "Mostrar animación de recarga"
L["Show countdown"] = "Mostrar cuenta atrás"
L["Show symbol"] = "Mostrar símbolo"
L["Simulate some spell events to test the addon."] = "Simula el lanzamiento de algunos hechizos para probar el addon."
L["%s is affected by %s, lasting %d seconds."] = "%s ha sido afectado por %s, y durará %d segundos."
L["%s is free !"] = "¡ %s se ha liberado !"
L["Size, in pixels, of the caster and countdown texts."] = "Tamaño, en píxles, de los textos de lanzador y cuenta atrás."
L["Size of icons displaying your spells, in pixels. Spells of other players are 20% smaller."] = "Tamaño de los iconos que muestran tus hechizos, en píxels. Los hechizos de otros jugadores son un 20% más pequeños."
L["Size of the gap between icons, in pixels."] = "Tamaño del espacio entre los iconos, en píxels."
L["%s will break free in %d seconds."] = "%s se liberará en %d segundos"
L["%s would send this alert:"] = "%s mandaría esta alerta:"
L["Test"] = "Test"
L["Text font"] = "Fuente de los textos"
L["Text size"] = "Tamaño de los textos"
L["The remaining time threshold, below which the icon starts to blink."] = "La antelación con la que el icono empezará a parpadear."
L["Unlock anchor"] = "Desbloquear marco"
L["Vertical"] = "Vertical"
L["Warning threshold (sec)"] = "Antelación del aviso (segundos)"

------------------------ zhTW ------------------------
elseif locale == 'zhTW' then
L["5-man instances"] = "5人副本"
L["About to end"] = "即將結束"
L["AdiCCMonitor icons"] = "AdiCCMonitor 圖示"
L["Alerts"] = "警報"
L["Arenas"] = "競技場"
L["A warning message is sent when the time left for a spell runs below this value."] = "剩餘時間的法術運行低於此數值時警告訊息發送。"
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
L["Icons"] = "圖示"
L["Icon size"] = "圖示尺寸"
L["Icon spacing"] = "圖示間隔"
L["Icons start blinking when the spell is about to end."] = "法術即將結束時圖示開始閃爍。"
L["Ignore spells from other players."] = "忽略法術來自其他玩家。"
L["Ignore tanks"] = "忽酪略坦克"
L["Inside, bottom"] = "在內部, 底"
L["Inside, left"] = "在內部, 左"
L["Inside, right"] = "在內部, 右"
L["Inside, top"] = "在內部, 頂"
L["Lock anchor"] = "鎖住錨點"
L["Main"] = "主要"
L["Maximum number of icons to show."] = "最大數量的圖示顯示。"
L["Move the anchor back to its default position."] = "移動錨點在原處預設值位置。"
L["Number of icons"] = "圖示數量"
L["Numerical display of time left."] = "數字顯示剩餘時間。"
L["Only mine"] = "唯我的"
L["Opacity"] = "不透明"
L["Open world"] = "開放世界"
L["Orientation of the icon bar."] = "方向的圖示條列。"
L["Outside, bottom"] = "在外部, 底"
L["Outside, left"] = "在外部, 左"
L["Outside, right"] = "在外部, 右"
L["Outside, top"] = "在外部, 頂"
L["Raid instances"] = "團隊副本"
L["Reset position"] = "重設位置"
L["%s has been freed by %s !"] = "%s 被 %s 釋放!"
L["%s has broken free!"] = "%s 已打破釋放!"
L["Scenarios"] = SCENARIOS
L["Show caster"] = "顯示施放者"
L["Show cooldown model"] = "顯示冷卻時間模型"
L["Show countdown"] = "顯示冷卻時間"
L["Show symbol"] = "顯示記號"
L["Simulate some spell events to test the addon."] = "模擬一些法術事件來測試插件。"
L["%s is affected by %s, lasting %d seconds."] = "%s 被 %s 受影響, 維持 %d 秒。"
L["%s is free !"] = "%s 釋放!"
L["%s will break free in %d seconds."] = "%s 即將在 %d 秒後掙脫。"
L["%s would send this alert:"] = "%s 這將發送警報:"
L["Test"] = "測試"
L["Text font"] = "文字字型"
L["Text size"] = "文字尺寸"
L["The remaining time threshold, below which the icon starts to blink."] = "剩餘時間門限, 低於圖示開始閃爍。"
L["Unlock anchor"] = "解鎖錨點"
L["Vertical"] = "垂直"
L["Warning threshold (sec)"] = "警告門限(秒數)"

------------------------ zhCN ------------------------
-- no translation

------------------------ koKR ------------------------
elseif locale == 'koKR' then
L["5-man instances"] = "5인 인던"
L["About to end"] = "종료될 즈음"
L["AdiCCMonitor icons"] = "AdiCCMonitor 아이콘"
L["AdiCCMonitor will completely disable itself in unchecked zones."] = "AdiCCMonitor는 미확인된 지역에서는 완전히 그자체를 비활성화합니다."
L["AdiCCMonitor will keep quiet in unchecked zones."] = "AdiCCMonitor는 미확인된 지역에서는 침묵으로 일관할 것입니다."
L["Alerts"] = "경고"
L["Arenas"] = "투기장"
L["A warning message is sent when the time left for a spell runs below this value."] = "이 값 이하로 실행 중인 주문에 대해 시간이 남아 있는 경우에 경고 메시지를 보냅니다."
L["Battlegrounds"] = "전장"
L["Beginning"] = "시작"
L["Blinking threshold (sec.)"] = "반짝임 한계치(초.)"
L["Broken early"] = "초기에 깨짐"
L["Caster name."] = "시전자 이름"
L["Caster position"] = "시전자 위치"
L["Countdown position"] = "재사용 대기 위치"
L["Display the target raid marker."] = "대상에 공격대 전술 아이콘을 표시합니다."
L["Enable blinking"] = "반짝임 활성"
L["Enabled in ..."] = "...에서 활성화"
L["Enabled modules"] = "활성화된 모듈"
L["End"] = "끝"
L["Events to announce"] = "알리기 위한 이벤트"
L["Failures"] = "실패"
L["Font to use for the caster and countdown texts"] = "시전자와 재사용 대기에 사용할 글자의 글꼴을 선택합니다."
L["Graphical display of time left."] = "남은 시간을 그래픽으로 표시합니다."
L["Icons"] = "아이콘"
L["Icon size"] = "아이콘 크기"
L["Icon spacing"] = "아이콘 간격"
L["Icons start blinking when the spell is about to end."] = "주문이 종료될 즈음에 아이콘이 반짝거리기 시작합니다."
L["Ignore spells from other players."] = "다른 플레이어의 주문 무시"
L["Ignore tanks"] = "방어전담 무시"
L["Inside, bottom"] = "내부, 하단"
L["Inside, left"] = "내부, 좌측"
L["Inside, right"] = "내부, 우측"
L["Inside, top"] = "내부, 상단"
L["Keep quiet when a character flagged as a tank breaks a spell."] = "방어전담으로 전쟁 중인 캐릭터가 주문을 깰 경우에 침묵으로 일관합니다."
L["Lock anchor"] = "앵커 잠금"
L["Main"] = "메인"
L["Maximum number of icons to show."] = "보여줄 아이콘의 최대 갯수를 설정합니다."
L["Move the anchor back to its default position."] = "앵커가 그것의 기본 위치로 되돌려 이동합니다. "
L["Note: '%s' ignores players flagged as tanks."] = "주의: '%s'|1은;는; 방어 전담으로 전쟁 중인 플레이어는 무시합니다."
L["Number of icons"] = "아이콘 갯수"
L["Numerical display of time left."] = "남은 시간을 소숫점 표시합니다."
L["Only mine"] = "내것에 한해"
L["Opacity"] = "불투명도"
L["Opacity of all icons. 100% means full opaque while 0% means fully transparent."] = "모든 아이콘의 불투명도를 설정합니다. 0%가 완전히 반투명한 동안에 100%는 완전히 반투명함을 의미합니다."
L["Orientation of the icon bar."] = "아이콘바의 진행 방향"
L["Outside, bottom"] = "외부, 하단"
L["Outside, left"] = "외부, 좌측"
L["Outside, right"] = "외부, 우측"
L["Outside, top"] = "외부, 상단"
L["Raid instances"] = "공격대 인던"
L["Reset position"] = "위치 초기화"
L["%s has been freed by %s !"] = "%s|1이;가; %s에서 자유로워졌습니다!"
L["%s has broken free!"] = "%s|1이;가; 완전히 깨졌습니다!"
L["Scenarios"] = SCENARIOS
L["Show caster"] = "시전자 보이기"
L["Show cooldown model"] = "블리자드 재사용 대기 모델 보이기"
L["Show countdown"] = "헤아림 수 보이기"
L["Show symbol"] = "상징 보이기"
L["Simulate some spell events to test the addon."] = "애드온을 테스트 하기 위해 몇개의 주문 이벤트를 시연합니다."
L["%s is affected by %s, lasting %d seconds."] = "%s|1이;가; %s에 걸렸습니다. %d초 남았습니다."
L["%s is free !"] = "%s|1은;는; 자유롭습니다!"
L["Size, in pixels, of the caster and countdown texts."] = "시전자와 재사용 대기의 픽셀당 글자 크기를 설정합니다."
L["Size of icons displaying your spells, in pixels. Spells of other players are 20% smaller."] = "당신의 주문을 표시할 픽셀당 아이콘의 크기를 설정합니다. 다른 플레이어의 주문은 20% 더 작습니다."
L["Size of the gap between icons, in pixels."] = "각 아이콘 사이의 픽셀당 공간 크기를 설정합니다. "
L["%s will break free in %d seconds."] = "%s|1은;는; %d초 후에 깨집니다."
L["%s would send this alert:"] = "이 경고를 %s에 보냅니다:"
L["Test"] = "테스트"
L["Text font"] = "글자 글꼴"
L["Text size"] = "글자 크기"
L["The remaining time threshold, below which the icon starts to blink."] = "남은 시간의 한계치를 설정합니다. 그 이하에서 아이콘이 반짝거리기 시작합니다."
L["Unlock anchor"] = "앵커 잠금 해제"
L["Vertical"] = "수직"
L["Warning threshold (sec)"] = "경고 한계치(초)"

------------------------ ptBR ------------------------
-- no translation
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end

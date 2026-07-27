# Guild Copilot 0.4.3

<p align="center">
  <img src="Brand/GuildCopilotLogo.png" width="240" alt="Guild Copilot Logo">
</p>

Guild Copilot ist ein deutschsprachiger Rekrutierungshelfer für **World of Warcraft: Burning Crusade Classic Anniversary**.

## Funktionen

- automatische Erkennung des eigenen Talentbaums;
- frei bestätigbares Raidprofil mit Primär-Spec, optionalem Dual-Spec, Main/Alt und Flexibilität;
- unsichtbare Profilsynchronisierung zwischen Gildenmitgliedern mit installiertem Addon;
- Gildenroster-Auswertung und TBC-orientierte Supportrollen-Vorschläge;
- moderne, kompakte Oberfläche mit Seitenleiste und sauber begrenzten Scroll-Textfeldern;
- aufklappbare Klassenkarten zur Auswahl ganzer Klassen oder beliebig vieler Specs, ohne Pflichtangabe einer Anzahl;
- editierbare Werbetexte mit Raid-Symbolen und 255-Byte-Kontrolle;
- frei wählbares Raid-Symbol direkt über eine Symbolleiste im Werbeeditor;
- Abschluss-Symbol bleibt auch bei der automatischen 255-Byte-Kürzung erhalten;
- aktive Chatkanäle werden mit einem deutlichen Häkchen markiert;
- drei gewählte Specs werden zur Klasse verdichtet, alle vollständig gewählten Klassen zu „alle Klassen“;
- Klassen lassen sich dauerhaft hoch-/runtersortieren und als hohe Priorität kennzeichnen;
- hohe Prioritäten erscheinen zuerst und als „dringend“ im Werbetext;
- die rechte Auswahlleiste sortiert Klassen per Pfeil und markiert hohe Prioritäten; jede Änderung erzeugt beim nächsten Öffnen sicher einen neuen Text;
- ab sieben ausgewählten Klassen wird die lange Aufzählung als „alle Klassen“ verdichtet;
- ausdrückliche Prüfung über **Text bestätigen**, bevor ein Posting möglich ist;
- ein Klick auf **Suche starten** postet einmalig in alle ausgewählten und verfügbaren Kanäle;
- 120-Sekunden-Sicherheits-Cooldown pro Kanal und zusätzliche Server-Throttle-Erkennung;
- Bewerber-Postfach mit Rekrutierungsfilter für eingehende Whispers und erkannte „Suche Gilde“-Chatnachrichten, auswählbarem Erfolgssound, editierbarer Antwortvorschau, optionalen Raid-Symbolen und Gildeneinladung;
- die Standardtexte für **Danke**, **Gildeninfos** und **Discord** lassen sich mit Platzhaltern gildenweit pflegen;
- Interessenten lassen sich über ein **×** direkt neben ihrem Eintrag entfernen oder nach einem Bestätigungsklick vollständig aus dem Postfach löschen;
- Gildenübersicht mit bis zu 25 zuletzt aktiven Level-70-Spielern, frei wählbaren Raider-Rängen, Raidprofil, Main/Alt-Status und Berufen;
- zwei manuell wählbare Berufe oder automatische Übernahme aus dem WoW-Berufsfenster, synchronisiert mit anderen Addon-Nutzern;
- Gildenwerkstatt mit automatischem Rezeptscan beim Öffnen des Berufsfensters, einschließlich der separaten TBC-Verzauberkunst-Schnittstelle;
- gedrosselte Werkstatt-Synchronisierung zwischen Online-Gildenmitgliedern;
- suchbasierte Gildenwerkstatt: Statt hunderte Rezepte ungefiltert zu laden, werden Ergebnisse erst nach Suchbegriff, Berufsauswahl oder über gespeicherte Favoriten angezeigt;
- bebilderter Berufsfilter, Berufssymbole in der Rezeptliste und lokale Rezeptfavoriten;
- Einstellungsseite für aktive Raider-Ränge, berechtigte Gildenprofil-Editoren, Postfach-Erkennung, TBC-kompatible Erfolgssounds und das Minimap-Symbol;
- Gildenprofil, Editor-Ränge und Postfach-Standardtexte werden zwischen Addon-Nutzern synchronisiert;
- Aufruf über `/gcp`, den Button im Blizzard-Gildenfenster, das verschiebbare Minimap-Symbol oder **Optionen → AddOns → Guild Copilot**;
- eigene statische Addon-Optionsseite mit Schriftlogo, Slash-Befehl und ausdrücklichem Öffnen-Button; sie öffnet kein zweites Fenster mehr automatisch und blockiert dadurch nicht die Escape-Taste;
- eigenes Guild-Copilot-Logo im Fenstertitel und in den Addon-Metadaten;
- Warcraft-Logs-Gildenlink aus Region, Realm und Gildenname automatisch vorbereiten oder direkt einfügen;
- Companion-fähiger Warcraft-Logs-Import, dessen Specs die Roster- und Copilot-Auswertung ergänzen.
- manueller Profilimport ohne API im lesbaren Format `Name;Klasse;Primär-Spec;Dual-Spec`.

## Installation

1. Den Ordner `GuildCopilot` in den Addon-Ordner der TBC-Anniversary-Installation kopieren:
   `World of Warcraft/_anniversary_/Interface/AddOns/`
2. WoW neu starten oder am Charakterbildschirm **AddOns** öffnen.
3. **Guild Copilot** aktivieren und im Spiel `/gcp` eingeben.
4. Im Rekrutierungs-Workflow zuerst das **Gildenprofil** ausfüllen und danach die **Copilot-Vorschläge** prüfen.
5. Unter **Profile & Berufe** das eigene Raidprofil mit **Bestätigen** speichern.
6. Unter **Einstellungen** festlegen, welche Gildenränge als aktive Raider erscheinen und welche Ränge das Gildenprofil bearbeiten dürfen.
7. Optional unter **Warcraft Logs** die Gildenseite speichern und einen Companion-Export importieren.
8. Unter **Gildenwerkstatt** einen Beruf auswählen, einen Rezept-/Spielernamen suchen oder Favoriten öffnen. Jeder Nutzer öffnet seine Berufsfenster mindestens einmal, damit Rezepte erfasst werden.

## Wichtige WoW-Grenzen

WoW erlaubt Addons nicht, Chatwerbung zeitgesteuert oder ohne echten Tastendruck zu versenden. Darum ist **Suche starten** bewusst ein manueller Klick; dieser eine Klick bedient alle ausgewählten Kanäle. Ein Ingame-Addon besitzt außerdem keinen Webzugriff. Deshalb speichert Guild Copilot den Warcraft-Logs-Link und nimmt Daten über einen kontrollierten Import entgegen. Ein echter Abruf muss außerhalb von WoW über die offizielle Warcraft-Logs-API und OAuth erfolgen.

Der mitgelieferte Helfer befindet sich unter `GuildCopilot/Companion/Start-WCL-Import.cmd`. Für den WCL-Client wird `http://localhost/callback` als technisch verlangte Redirect-URL eingetragen; der Companion verwendet sie nicht. Der Client-Secret wird nur für den laufenden Import abgefragt und nicht gespeichert.

## Blizzard-Compliance

- keine Timer, Schleifen oder Hintergrundfunktionen zum Senden von Chatwerbung;
- jedes Posting erfordert einen echten Klick des Spielers;
- standardmäßig ist ausschließlich `Gildenrekrutierung` gewählt;
- SucheNachGruppe, Handel und Allgemein müssen bewusst zugeschaltet werden;
- jedes einzelne Ziel hat mindestens 120 Sekunden lokalen Cooldown;
- der Text muss nach jeder Änderung erneut bestätigt werden;
- Gildenprofile werden nur bei Login oder Änderung kompakt synchronisiert;
- keine Eingabesimulation, WoW-Speicherzugriffe oder Webzugriffe aus WoW;
- keine kostenpflichtigen Funktionen, Spendenaufrufe oder Werbung für Waren und Dienstleistungen.

Die Nutzung bleibt außerdem an die jeweiligen Realm-, Kanal- und Verhaltensregeln gebunden. Blizzard kann Addon-Funktionen jederzeit einschränken. Für eine verbindliche Einzelfallentscheidung nennt Blizzard `WoWUI@blizzard.com`.

## Slash-Befehle

- `/gcp`
- `/guildcopilot`

## Gespeicherte Daten

Einstellungen und Gildendaten liegen in `GuildCopilotDB` (SavedVariables). Über Addon-Nachrichten werden kompakte Charakter- und Werkstattprofile sowie das Gildenprofil mit seinen Berechtigungen und Antwortvorlagen ausschließlich innerhalb der eigenen Gilde synchronisiert.

Die geplanten Module für Raidstatistik, Consumable-Auswertung, Gear-Audit und Mitgliederpflege stehen in [ROADMAP.md](ROADMAP.md).

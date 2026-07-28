# Guild Copilot 0.9.14

<p align="center">
  <img src="Brand/GuildCopilotLogo.png" width="240" alt="Guild Copilot Logo">
</p>

Guild Copilot ist ein deutschsprachiger Rekrutierungshelfer für **World of Warcraft: Burning Crusade Classic Anniversary**.

## Funktionen

- automatische Erkennung des eigenen Talentbaums;
- frei bestätigbares Raidprofil mit Primär-Spec, optionalem Dual-Spec, Main/Alt und Flexibilität;
- unsichtbare Profilsynchronisierung zwischen Gildenmitgliedern mit installiertem Addon; wer neu dazukommt, fragt den Bestand ab und bekommt die Profile der bereits Eingeloggten nachgereicht, statt nur die Änderungen ab dem eigenen Login zu sehen;
- Addon-Erkennung in der Gildenübersicht: sichtbar, wer Guild Copilot nutzt und wessen Datenversion abweicht, ohne Dauerbroadcasts;
- Gildenroster-Auswertung und TBC-orientierte Supportrollen-Vorschläge;
- moderne, kompakte Oberfläche mit Seitenleiste und sauber begrenzten Scroll-Textfeldern;
- Aufklappmenüs mit vielen Einträgen scrollen und öffnen sich in die Richtung, in der Platz ist, statt am Rand des Scrollbereichs abgeschnitten zu werden;
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
- **Werbebalken**: ein kleines, verschiebbares Fenster nur fürs Posten – bestätigter Text, Zahl der bereiten Kanäle und der laufende Cooldown als Countdown direkt im Knopf. Damit muss für Werbung nicht das ganze Addonfenster offen bleiben;
- der Werbebalken sendet ausschließlich per echtem Klick; der Countdown schaltet den Knopf nur frei und löst nie selbst aus. Ein- und ausblenden über den Knopf auf **Werbung posten** oder `/gcp werbung`;
- Bewerber-Postfach mit Rekrutierungsfilter für eingehende Whispers und erkannte „Suche Gilde“-Chatnachrichten, auswählbarem Erfolgssound, editierbarer Antwortvorschau, optionalen Raid-Symbolen und Gildeneinladung;
- die Standardtexte für **Danke**, **Gildeninfos** und **Discord** werden direkt im **Postfach** unter den zugehörigen Knöpfen gepflegt – dort, wo sie benutzt werden – und gelten gildenweit;
- Interessenten lassen sich über ein **×** direkt neben ihrem Eintrag entfernen oder nach einem Bestätigungsklick vollständig aus dem Postfach löschen;
- Gildenübersicht mit bis zu 25 zuletzt aktiven Level-70-Spielern, frei wählbaren Raider-Rängen, Raidprofil, Main/Alt-Status und Berufen;
- persönliches **Profil** als erster Menüpunkt mit Raidprofil, Dual-Spec, Berufen und eigener Abmeldung von/bis samt optionalem Grund;
- ranggeschützte Mitgliederpflege mit aktiven Gildenabmeldungen und nach Inaktivität sortierten Prüfvorschlägen;
- Vorschläge lassen sich als dauerhafte **Ausnahme**, **zurückgestellt** (30 Tage) oder **erledigt** ablegen; alle Einträge werden gildenweit synchronisiert, damit nicht zwei Offiziere denselben Fall bearbeiten;
- einzelner Gildenausschluss nur nach einer zweiten, ausdrücklichen Bestätigung, nur mit echter WoW-Berechtigung, nur gegen einen niedrigeren und ungeschützten Rang und niemals automatisch oder in Serie;
- frei wählbare Inaktivitätsgrenze und geschützte Gildenränge; Twinks und aktiv Abgemeldete werden aus den Vorschlägen ausgeschlossen;
- unsichere Main/Twink-Fälle werden ausdrücklich als **Prüfen** statt als Entfernungsvorschlag gekennzeichnet; es gibt keine automatischen Gildenausschlüsse;
- zwei manuell wählbare Berufe oder automatische Übernahme aus dem WoW-Berufsfenster, synchronisiert mit anderen Addon-Nutzern;
- Gildenwerkstatt mit automatischem Rezeptscan beim Öffnen des Berufsfensters, einschließlich der separaten TBC-Verzauberkunst-Schnittstelle;
- gedrosselte Werkstatt-Synchronisierung zwischen Online-Gildenmitgliedern mit Sendewiederholung, Übertragungswarteschlange und sichtbarem Empfangsstatus;
- suchbasierte Gildenwerkstatt: Statt hunderte Rezepte ungefiltert zu laden, werden Ergebnisse erst nach Suchbegriff, Berufsauswahl oder über gespeicherte Favoriten angezeigt;
- bebilderter Berufsfilter, Berufssymbole in der Rezeptliste und lokale Rezeptfavoriten;
- Einstellungsseite für aktive Raider-Ränge, berechtigte Einstellungs-Editoren, Mitgliederpflege-Zugriff, Postfach-Erkennung, TBC-kompatible Erfolgssounds und das Minimap-Symbol;
- in der **Mitgliederpflege** stehen Prüfregeln, Pflegevorschläge und Entscheidungen als zusammenhängender Ablauf untereinander; die Abmeldungen als eigenes Thema darunter;
- Lockout-Schutz für gildenweite Einstellungen: eigener Rang nicht abwählbar, Entzug nur durch höhere Ränge und einmalige Offiziers-Wiederherstellung je Gilde für alte Sperren;
- Gildenprofil, Editor-Ränge, Mitgliederpflege-Zugriff, Raider-Ränge und Postfach-Standardtexte werden zwischen Addon-Nutzern synchronisiert;
- Aufruf über `/gcp`, den Button im Blizzard-Gildenfenster, das verschiebbare Minimap-Symbol oder **Optionen → AddOns → Guild Copilot**;
- eigene statische Addon-Optionsseite mit Schriftlogo, Slash-Befehl und ausdrücklichem Öffnen-Button; sie öffnet kein zweites Fenster mehr automatisch und blockiert dadurch nicht die Escape-Taste;
- zusätzliche direkte Escape-Behandlung für Hauptfenster und Textfelder;
- eigenes Guild-Copilot-Logo im Fenstertitel und in den Addon-Metadaten;
- **Raidauswertung** mit ausdrücklich gestarteter Sitzung: Anwesenheitszeit, Versuche, Siege, Wipes, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände;
- Sitzungen dürfen Raidleiter, Assistenten und die für die Mitgliederpflege freigegebenen Gildenränge starten und beenden;
- die fertige Auswertung wird über den Raidkanal an alle berechtigten Teilnehmer verteilt; Offiziere außerhalb des Raids fragen sie an und erhalten sie per Flüsterkanal;
- gespeichert werden ausschließlich Zusammenfassungen, keine Combat-Log-Rohdaten;
- die Auswertung steht vollständig im Addonfenster: Sitzungsliste und Teilnehmertabelle. Kurze Rückmeldungen wie Start, Ende und abgelehnte Aktionen erscheinen zusätzlich im Chat, damit sie auch bei geschlossenem Fenster ankommen;
- die Übertragung zwischen den Addon-Nutzern läuft über den unsichtbaren Addon-Datenkanal, nicht über sichtbare Chatnachrichten;
- **Ausrüstungsprüfung** über die Inspect-API: fehlende Verzauberungen und leere Sockel je Slot, für die eigene Ausrüstung auch ohne Gruppe;
- geprüft wird nur, wer in Reichweite und erreichbar ist; nicht erreichbare Spieler werden ausdrücklich als übersprungen ausgewiesen;
- Bewertungen stammen aus einem versionierten Regelsatz und zeigen Regel, Quelle und Alter der Daten; unbewertete Verzauberungen werden nie als schlecht gewertet;
- **ohne hinterlegte Bewertung** gilt eine vorhandene Verzauberung standardmäßig als in Ordnung, damit als Fund übrig bleibt, was objektiv aus dem Item-Link hervorgeht: fehlende Verzauberungen und leere Sockel. Das behauptet keine Qualität, es unterscheidet nur verzaubert von nicht verzaubert. Wer stattdessen **Unbekannt** sehen will, schaltet es in den Einstellungen ab;
- die eigene Ausrüstung prüft sich selbst – beim Login und nach jedem Umziehen, entprellt, damit ein kompletter Ausrüstungswechsel nur eine Prüfung auslöst. Auch das ist abschaltbar und wirkt rein lokal, ohne Gildenrang;
- **eigener Regelsatz der Gilde**: ein Klick auf eine Slotzeile stuft die erkannte Verzauberung als Optimal, Solide oder Verbesserbar ein; ein weiterer Klick nimmt die Bewertung zurück;
- gespeichert und geteilt wird nur die Verzauberungs-ID mit ihrer Stufe – den Namen löst jeder Client selbst in seiner Sprache auf;
- den Regelsatz dürfen nur Ränge mit Einstellungsrecht ändern, er gilt gildenweit und wirkt sofort auf alle gespeicherten Prüfungen;
- eine gildeneigene Bewertung hängt allein an der Enchant-ID – ohne Slot, ohne Rolle, ohne Klasse. Sie gilt damit für jeden in der Gilde gleich;
- der Name der Verzauberung kommt aus dem WoW-Tooltip selbst und steht dadurch ohne gepflegte Datenbank im Klartext da („Verzaubert: Außergewöhnliche Gesundheit“), in der Sprache des Clients;
- es gibt bewusst keine Gesamtnote je Spieler;
- die Funde stehen als lesbare Sätze da statt als nackte Zahlen: „2 fehlende Verzauberungen: Kopf, Schulter“, „3 leere Sockel: Brust, Hände“;
- eine Kopfzeile fasst alle geprüften Spieler zusammen, etwa „8 geprüft, davon 5 ohne Funde • 6 fehlende Verzauberungen • 4 leere Sockel“;
- jeder Spieler sieht seine eigene Prüfung unter **Profil → Deine Ausrüstung** und kann sie dort jederzeit selbst auslösen;
- Warcraft-Logs-Gildenlink aus Region, Realm und Gildenname automatisch vorbereiten oder direkt einfügen;
- Companion-fähiger Warcraft-Logs-Import, dessen Specs die Roster- und Copilot-Auswertung ergänzen;
- **Nachanalyse aus Warcraft Logs**: der Companion liest öffentliche Reports und liefert Teilnahme, Anwesenheitszeit, Versuche, Siege, Wipes, Tode, Interrupts, Dispels und Verbrauchsgegenstände;
- Logs-Auswertungen erscheinen als eigene Einträge mit der Quelle **Warcraft Logs** neben den Livesitzungen; beide werden getrennt gehalten und niemals miteinander verrechnet;
- welche Spell-ID welcher Verbrauchskategorie entspricht, entscheidet allein das Addon – unbekannte IDs aus dem Companion werden ignoriert statt falsch einsortiert.
- manueller Profilimport ohne API im lesbaren Format `Name;Klasse;Primär-Spec;Dual-Spec`.

## Installation

0. Der einfachste Weg unter Windows: `Install.cmd` doppelt anklicken. Das Skript sucht die WoW-Installation, ersetzt eine eventuell vorhandene ältere Version und legt das Addon an die richtige Stelle. Wird die Installation nicht gefunden, fragt es nach dem Pfad zum Ordner `_anniversary_`.
1. Von Hand: den Ordner `GuildCopilot` in den Addon-Ordner der TBC-Anniversary-Installation kopieren:
   `World of Warcraft/_anniversary_/Interface/AddOns/`
   Danach muss `GuildCopilot.toc` direkt in `AddOns/GuildCopilot/` liegen – ein doppelt verschachtelter Ordner ist der häufigste Installationsfehler.
2. WoW neu starten oder am Charakterbildschirm **AddOns** öffnen.
3. **Guild Copilot** aktivieren und im Spiel `/gcp` eingeben.
4. Im Rekrutierungs-Workflow zuerst das **Gildenprofil** ausfüllen und danach die **Copilot-Vorschläge** prüfen.
5. Unter **Profil** das eigene Raidprofil mit **Bestätigen** speichern, Berufe übernehmen und bei Bedarf eine Abmeldung eintragen.
6. Unter **Einstellungen** festlegen, welche Gildenränge als aktive Raider erscheinen, die Mitgliederpflege öffnen und gildenweite Einstellungen bearbeiten dürfen.
7. Optional unter **Warcraft Logs** die Gildenseite speichern und einen Companion-Export importieren.
8. Unter **Gildenwerkstatt** einen Beruf auswählen, einen Rezept-/Spielernamen suchen oder Favoriten öffnen. Jeder Nutzer öffnet seine Berufsfenster mindestens einmal, damit Rezepte erfasst werden.
9. Unter **Mitgliederpflege** – mit freigegebenem Gildenrang – Abmeldungen und Inaktivitätsvorschläge prüfen sowie Inaktivitätsgrenze und geschützte Ränge festlegen.
10. Unter **Raidauswertung** vor dem Raid **Sitzung starten** und danach **Sitzung beenden**. Offiziere außerhalb des Raids holen sich die Auswertung über **Auswertung anfordern**.
11. Unter **Ausrüstung** vor dem Raid **Gruppe prüfen**, um fehlende Verzauberungen und leere Sockel zu finden. Die eigene Ausrüstung prüft sich von selbst; **Gruppe prüfen** bleibt bewusst ein Klick, weil dabei für jeden Teilnehmer eine Inspect-Anfrage anfällt.

Alle Mitglieder sollten dieselbe Version fahren. Die Versionsnummer steht im Fenstertitel, und abweichende Datenversionen werden in der Gildenübersicht ausgewiesen.

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
- `/gcp werbung` – blendet den Werbebalken ein oder aus

## Gespeicherte Daten

Einstellungen und Gildendaten liegen in `GuildCopilotDB` (SavedVariables). Über Addon-Nachrichten werden kompakte Charakter- und Werkstattprofile sowie das Gildenprofil mit seinen Berechtigungen und Antwortvorlagen ausschließlich innerhalb der eigenen Gilde synchronisiert.

Die geplanten Module für Raidstatistik, Consumable-Auswertung, Gear-Audit und Mitgliederpflege stehen in [ROADMAP.md](ROADMAP.md).

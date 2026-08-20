# Guild Copilot – Roadmap

Guild Copilot soll ein modularer Gildenassistent werden. Rekrutierung bleibt ein wichtiger Bereich, ist aber nur eines von mehreren Modulen.

## 0.2.1 – UI-Politur und Werbung

- eigene, schlanke Scrollleisten statt der alten Blizzard-Pfeilkästchen;
- stabile Beschriftungen ohne Überlagerung der Icons nach einem Klick;
- frei wählbares Raid-Symbol im Werbeeditor;
- modernes Klassen-Akkordeon und Primär-/Dual-Spec.

## 0.3.0 – Roster und Berufe

- Übersicht der 25 zuletzt aktiven Level-70-Spieler;
- Primär-/Dual-Spec, Main/Alt, Bestätigungsstatus und letzte Onlinezeit;
- zwei Berufe pro Charakter manuell setzen oder aus WoW übernehmen;
- Berufsdaten kompakt mit anderen Guild-Copilot-Nutzern in der Gilde synchronisieren.

## 0.3.1 – Offline-Import und UI-Politur

- Spieler und Specs ohne API als `Name;Klasse;Primär-Spec;Dual-Spec` importieren;
- API-/Companion-Import bleibt für eine automatische Auswertung mehrerer Reports erhalten;
- Rubriküberschriften in der Seitenleiste zentrieren, Navigationspunkte für bessere Lesbarkeit linksbündig belassen.

## 0.4.0 – Gildenwerkstatt

- bekannte Rezepte erfassen, wenn ein Spieler sein WoW-Berufsfenster öffnet;
- durchsuchbar machen, wer in der Gilde welchen Gegenstand herstellen kann;
- Reagenzien und benötigte Mengen direkt am Rezept anzeigen;
- Datenquelle und letzten Aktualisierungszeitpunkt sichtbar machen;
- Rezeptdaten kompakt und nur bei Änderungen innerhalb der Gilde synchronisieren.

Umgesetzt: Rezeptscan über das geöffnete TBC-Berufsfenster, die damalige gedrosselte Gildensynchronisierung, Suche nach Rezept/Beruf/Crafter, Herstellerliste und Reagenzienanzeige. Die feste Drosselung wurde mit 0.9.20 wieder entfernt. Damit ist 0.4.0 abgeschlossen.

Ebenfalls umgesetzt: geordneter Rekrutierungs-Workflow vom Gildenprofil über Copilot-Vorschläge bis zum Posting, ein Filter für die als aktive Raider sichtbaren Gildenränge sowie gezielte Whisper-Erkennung und Löschfunktionen im Bewerber-Postfach.

## 0.4.1 – Einstellungen, Rechte und Werkstattfilter

- zentrale Einstellungsseite für lokale Postfachoptionen und auswählbare Erfolgssounds;
- gildenweit synchronisierte, frei bearbeitbare Standardantworten für Danke, Gildeninfos und Discord;
- Gildenprofil nur für ausgewählte Gildenränge bearbeitbar und mit allen Addon-Nutzern synchronisiert;
- manuelle Roster-Aktualisierung mit sichtbarem Zeitstand für die Copilot-Vorschläge;
- direkter **×**-Knopf an jedem Interessenten;
- Berufsfilter zusätzlich zur freien Werkstattsuche;
- eigener TBC-Craft-API-Scan für Verzauberkunst;
- Warcraft-Logs-Ansicht vollständig innerhalb des Hauptfensters.

## 0.4.2 – Addon-Integration und Branding

- Einstellungen als letzter Navigationspunkt;
- Eintrag in **Optionen → AddOns**, der direkt das Guild-Copilot-Fenster öffnet;
- eigenes Logo ohne Schrift als Addon- und Fenster-Icon;
- Berufssymbole im Werkstattfilter und in der Rezeptliste;
- separate Fußzeile für die Seitennavigation, damit keine Rezeptzeile mehr überdeckt wird;
- Quellcode und Dokumentation für das GitHub-Repository vorbereitet.

## 0.4.3 – Werkstatt-Fokus und schneller Zugriff

- Gildenwerkstatt als gezielte Suche statt ungefilterter Rezeptflut;
- Suche über Rezept- oder Spielernamen, Berufsfilter und lokale Rezeptfavoriten;
- statische Blizzard-Addon-Optionsseite mit Schriftlogo, `/gcp` und ausdrücklichem Öffnen-Button;
- automatisches Öffnen aus der Optionsseite entfernt, damit **Escape** zuverlässig funktioniert;
- verschiebbares Minimap-Symbol: Linksklick öffnet/schließt Guild Copilot, Rechtsklick öffnet die Einstellungen;
- Minimap-Symbol in den Einstellungen ein- und ausschaltbar;
- Erfolgssounds verwenden TBC-kompatible numerische Fallbacks, wenn ein moderner `SOUNDKIT`-Eintrag fehlt.

## 0.4.4 – Abmeldungen und Mitgliederpflege

- persönliche Abmeldung mit Von-/Bis-Datum und optionalem Grund;
- Abmeldungen werden über das Addon-Profil innerhalb der Gilde synchronisiert;
- aktive und geplante Abmeldungen in einer gemeinsamen Übersicht;
- gildenweite, nur durch berechtigte Ränge änderbare Inaktivitätsgrenze;
- geschützte Gildenränge, die nie als Pflegevorschlag erscheinen;
- Pflegevorschläge schließen Twinks und aktiv Abgemeldete aus;
- unbekannter Main/Twink-Status wird als **Prüfen** gekennzeichnet;
- keine automatische Entfernung und derzeit bewusst kein direkter Kick-Knopf;
- Minimap-Symbol in den Blizzard-Rahmen eingepasst, Unicode-Favoritensterne durch echte WoW-Symboltexturen ersetzt und Escape-Schließen zusätzlich abgesichert.

## 0.4.5 – Persönliches Profil, Rechte und zuverlässige Werkstattsynchronisierung

- **Profil** als erster Menüpunkt und Standardansicht;
- Raidprofil, Dual-Spec, Berufe und eigene Abmeldung in einer persönlichen Ansicht gebündelt;
- Mitgliederpflege nur für ausgewählte, gildenweit synchronisierte Gildenränge sichtbar;
- gildenweite Einstellungen nur für ausgewählte Bearbeiter-Ränge änderbar, lokale Komfortoptionen bleiben persönlich;
- aktive Raider-Ränge ebenfalls gildenweit synchronisiert;
- Werkstattpakete damals deutlich gedrosselt, bei Sendefehlern wiederholt und nicht mehr still verworfen; seit 0.9.20 werden erfolgreiche Pakete ohne feste Pause gesendet;
- sichtbarer Status für laufende, fehlgeschlagene und empfangene Rezeptübertragungen.

## 0.4.6 – Lockout-Schutz für Gildenrechte

- der höchste Gildenrang behält immer Zugriff auf gildenweite Einstellungen;
- der eigene Rang kann nicht mehr selbst aus der Bearbeiterliste entfernt werden;
- einen Bearbeiter-Rang darf nur ein tatsächlich höherer Gildenrang abwählen;
- einmalige, über echte Blizzard-Offiziersrechte abgesicherte Wiederherstellung für bereits mit v0.4.5 entstandene Lockouts;
- die Wiederherstellung wird pro Gilde verbucht, damit ein Lockout in einer Gilde die Reparatur in einer anderen nicht verbraucht.

## 0.5 – Raid Monitor

### Addon-Erkennung

- Versions-/Capability-Handshake innerhalb der Gilde;
- sichtbar machen, welche Spieler Guild Copilot installiert haben;
- keine dauernden Broadcasts: Synchronisierung nur bei Login, Gruppenbeitritt oder geänderter Version.

Umgesetzt: `V`-Handshake mit Version, Schemaversion und gemeldeten Fähigkeiten, Antwort nur auf ausdrückliche Anfrage und mit Mindestabstand, Kachel **Mit Addon** in der Gildenübersicht samt Tooltip. Ältere Clients kennen den Handshake nicht, werden aber über die Schemaversion ihrer gewöhnlichen Pakete erkannt und als abweichend gemeldet – damit wird sichtbar, wenn Rezepte und gildenweite Einstellungen mit ihnen gar nicht ausgetauscht werden.

### Live-Raidsitzung

- Sitzung beginnt und endet ausdrücklich durch den Raidlead;
- Teilnehmer, Bosspulls, Siege, Wipes und Anwesenheitszeit erfassen;
- relevante Combat-Log-Ereignisse wie Tod, Wiederbelebung, Interrupt und Dispel zusammenfassen;
- verwendete Tränke, Runen, Fläschchen/Elixiere, Essen, Öle/Steine und Trommeln nach Spell-/Item-ID zählen;
- Rohdaten zeitlich begrenzen und nach der Zusammenfassung verwerfen.

Umgesetzt: Sitzungen mit ausdrücklichem Start und Ende, Anwesenheitszeit, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände nach Spell-ID. Es entsteht kein Rohdatenspeicher – der Combat Log wird laufend verdichtet, gespeichert wird nur die Zusammenfassung.

Die Auswertung selbst wird im Addonfenster angezeigt – Sitzungsliste und Teilnehmertabelle. Kurze Rückmeldungen zu Start, Ende und abgelehnten Aktionen stehen zusätzlich im Chat, damit sie auch bei geschlossenem Fenster ankommen. Die Übertragung zwischen den Addon-Nutzern nutzt den unsichtbaren Addon-Datenkanal.

Steuern und auswerten dürfen Raidleiter, Assistenten und die für die Mitgliederpflege freigegebenen Gildenränge. Die fertige Auswertung geht über den Raidkanal an alle berechtigten Teilnehmer; Offiziere außerhalb des Raids fragen sie an und bekommen sie per Flüsterkanal, damit nichts über den offenen Gildenkanal läuft.

Offen und bewusst noch nicht umgesetzt:

- Bosskämpfe werden ohne Encounter-API heuristisch erkannt (Kampfabschnitt ab 15 Sekunden, benannt nach dem zuletzt gestorbenen Gegner, Wipe ab der Hälfte der Anwesenden). Eine gepflegte Bossliste je Instanz wäre genauer.
- Die Spell-ID-Tabelle für Verbrauchsgegenstände ist ein Ausgangsbestand und muss gegen echte Logs abgeglichen und ergänzt werden. Unbekannte IDs werden nicht gezählt, es entstehen also keine falschen Zahlen.

### Nachanalyse aus Warcraft Logs

- Companion liest nach dem Raid öffentliche Reports über die offizielle WCL-API;
- Import von Teilnahme, beobachteten Specs, Consumables und ausgewählten Ereignissen;
- Live- und WCL-Daten werden getrennt gekennzeichnet und nicht doppelt gezählt;
- private Reports nur nach einer späteren ausdrücklichen OAuth-Benutzerfreigabe.

Umgesetzt: Der Companion liest je Report Kampfabschnitte, Teilnahme, Anwesenheitszeit, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände und exportiert sie im Format `GCPWCL3`. Das Addon legt jede Nachanalyse als eigene Auswertung mit der Quelle **Warcraft Logs** ab. Live-, Sync- und Logs-Daten tragen unterschiedliche Kennungen und können sich gegenseitig nicht überschreiben – eine Auswertung anderer Quelle wird beim Speichern abgelehnt statt vermischt.

Verbrauchsgegenstände überträgt der Companion als reine `Spell-ID:Anzahl`-Paare. Die Zuordnung zur Kategorie trifft ausschließlich `GC.Consumables` im Addon, damit es nur eine maßgebliche Tabelle gibt; unbekannte IDs werden ignoriert. Dauerhafte Buffs zählen wie in der Livesitzung einmal je Spieler und Sitzung.

Der alte Profilimport `GCPWCL1` funktioniert unverändert weiter.

Nachgezogen in 0.9.17: Die ersten Abfragen waren gegen die Dokumentation geschrieben, liefen aber nie durch. Zwei Ursachen:

- `playerDetails` und `table` brauchen ein echtes Zeitfenster. Mit `startTime = 0` und `endTime = 0` antwortet Warcraft Logs mit einem Fehler statt mit leeren Daten – der Abruf brach schon beim ersten Report ab, noch bevor irgendeine Datei entstand.
- Die JSON-Form der `table`-Antworten hängt am Datentyp. Die Auswertung suchte nach Einträgen mit Namen und fand je nach Tabelle nichts.

Ausgewertet wird jetzt über die Ereignisliste (`events`): dort steht je Ereignis eine Akteurs-ID und eine Spell-ID. Namen kommen aus `masterData`, Kategorien weiterhin aus `GC.Consumables`. Damit zählen Tode beim Gestorbenen und Wiederbelebungen beim Wirkenden, genau wie in der Livesitzung.

Dazugekommen sind ein Einzelreport-Modus zum Ausprobieren, eine Schritt-für-Schritt-Ausgabe, ein `--debug`-Schalter für die Rohantworten und eine Suche über die Warcraft-Logs-Seiten `fresh`, `classic` und `www` samt mehrerer Schreibweisen des Gildennamens – der Link nennt ihn nur als Slug.

Das Importformat heißt jetzt `GCPWCL3` und führt die Wiederbelebungen als zusätzliches Feld. Das Addon zerlegt die Zeilen feldweise statt über ein festes Suchmuster, damit ein Companion anderen Alters keinen Import mehr verhindert. `GCPWCL1` und `GCPWCL2` werden unverändert gelesen.

### Was der erste Lauf gegen echte Reports ergeben hat

Erprobt an einem SSC/TK-Report mit 10 Encountern, 26 Teilnehmern und 96 Toden. Vier Fehler, die keine Dokumentation gezeigt hätte:

- **`Resurrects` gibt es im Enum `EventDataType` nicht.** Wiederbelebungen werden jetzt über den gewirkten Zauber gezählt.
- **Ein Fehler riss alles mit.** Alle sechs Ereignisabfragen hingen in einem `try`-Block; der ungültige Enum-Wert vernichtete auch Tode, Interrupts, Dispels und Verbrauchsgegenstände, obwohl diese Abfragen davon unberührt waren. Jede Abfrage ist jetzt einzeln abgesichert und fällt für sich aus.
- **Eine Spell-ID aus dem Gedächtnis war falsch.** `25235` ist nicht „Erlösung", sondern „Flash Heal" – drei Priester bekamen 349, 256 und 209 Wiederbelebungen zugeschrieben. Alle 31 IDs sind jetzt einzeln geprüft, ein Testfall hält die falsche fern.
- **Buffs nennen den Beschenkten, nicht den Verursacher.** Trommeln buffen die ganze Gruppe. Das frühere „Maximum aus Zauber und Buff" machte aus vier Trommlern vierzehn und schrieb einem Krieger 19 Trommeln zu, die er nie benutzt hatte. Jetzt gilt je Spell-ID: gibt es Zauber, ist der Zauber maßgeblich; der Buff zählt nur für Gegenstände, die gar keinen Zauber erzeugen.

Ebenfalls korrigiert: Abgefragt wurde zunächst nur innerhalb der Bosskämpfe. Wiederbelebt wird aber zwischen den Pulls, dispelt und unterbrochen wird auch auf Trash, getrunken wird vor dem Pull – aus 7 Interrupts und 10 Dispels für einen ganzen Raidabend wurden 22 und 146. Nur die Anwesenheitszeit bleibt kampfbasiert, sie misst genau das.

Beobachtete Verbrauchs-IDs aus dem echten Report – 28017, 28491, 28495, 28497, 28499, 28502, 28503, 28507, 28508, 35476, 39625, 39627 – stehen alle in `GC.Consumables`. Essen tauchte erwartungsgemäß nicht auf.

Offen: Private Reports bleiben bewusst ausgeschlossen; dafür wäre die ausdrückliche OAuth-Benutzerfreigabe nötig. Die Anwesenheitszeit meint bei Logs reine Bosskampfzeit und bei Livesitzungen die Sitzungsdauer – beides bleibt getrennt gekennzeichnet, ist aber nicht dasselbe Maß.

## 0.6 – Raid Readiness und Gear Audit

- Ausrüstung über die WoW-Inspect-API erfassen, soweit Spieler in Reichweite und inspizierbar sind;
- fehlende Verzauberungen und Edelsteine pro Slot erkennen;
- Regeln nach Klasse, Spec, Rolle und Content-Phase;
- verständliche Einstufung pro Slot:
  - **Optimal** – aktuelle Top-Empfehlung;
  - **Solide** – wirkungsvolle, raidtaugliche Alternative;
  - **Verbesserbar** – funktional, aber deutlich schwächer;
  - **Fehlt** – kein sinnvoller Effekt erkannt.
- jede Einstufung zeigt Regel, Quelle und Stand der Daten;
- Empfehlungen von wowtbc.gg und weiteren TBC-Quellen werden als IDs und eigene Regeln versioniert, nicht als kopierter Guide-Text;
- Ausnahmen für Farmgear, Widerstandssets und spezielle Encounter-Sets;
- kein pauschaler „guter/schlechter Spieler“-Score.

Umgesetzt: Erfassung über die Inspect-API mit Warteschlange, Reichweiten- und Erreichbarkeitsprüfung, Auswertung je Slot aus dem Item-Link, Zählung fehlender Verzauberungen und leerer Sockel, eigene Ausrüstung auch ohne Gruppe, versionierter Regelsatz mit Regel, Quelle und Datenalter je Einstufung sowie eine eigene Seite ohne Gesamtnote.

Zusätzlich umgesetzt:

- Der Name jeder vorhandenen Verzauberung wird inzwischen aus dem WoW-Tooltip gelesen: das Addon baut den Tooltip einmal mit und einmal mit auf 0 gesetzter Verzauberung auf und nimmt die Zeile, die nur in der ersten Fassung vorkommt. Das ist sprachunabhängig und braucht keine ID-Datenbank. Lässt sich die Vergleichsfassung nicht aufbauen, wird bewusst nichts gemeldet, damit nie der Gegenstandsname als Verzauberung erscheint.
- Der Regelsatz wird jetzt in der Gilde selbst gepflegt: Ein Klick auf eine Slotzeile stuft die erkannte Verzauberung ein, gespeichert wird die ID mit ihrer Stufe, geteilt wird sie gildenweit über das Gildenprofil. Damit sind Empfehlungen wie von wowtbc.gg als IDs und eigene Regeln versioniert statt als abgeschriebener Guide-Text – der externe Guide bleibt die menschliche Vorlage, die Daten entstehen im Client.
- Bewertungen lassen sich je Spec pflegen. Fehlt dort eine Regel, greift die allgemeine Bewertung derselben Enchant-ID für alle Specs.

Offen und bewusst noch nicht umgesetzt:

- Der mitgelieferte statische Regelsatz für **Optimal**, **Solide** und **Verbesserbar** ist weiterhin leer. Die Enchant-IDs müssen aus einer belegbaren Quelle übernommen werden. Standardmäßig gilt eine vorhandene, aber unbewertete Verzauberung lediglich als „in Ordnung“; diese lokale Automatik lässt sich abschalten, dann erscheint **Unbekannt**. Fehlende Verzauberungen und leere Sockel erkennt der Audit in beiden Fällen exakt.
- Ausnahmen für Farmgear, Widerstandssets und Encounter-Sets fehlen noch.
- Content-Phasen sowie zusätzliche Ausnahmen nach Slot oder Rolle sind für gildeneigene Regeln noch nicht abgebildet.
- Seit 0.9.19 stellt jeder Addon-Client die Messdaten seiner eigenen Ausrüstung automatisch der Gilde bereit. Andere Clients bewerten sie mit ihrem aktuellen Regelsatz; die Inspect-Warteschlange bleibt nur Rückfall für Mitglieder ohne frischen Snapshot.

Ergänzt: Die Funde werden als lesbare Sätze mit Slotnamen aufbereitet statt als nackte Zahlen, eine Kopfzeile fasst alle geprüften Spieler zusammen, und jeder Spieler sieht seine eigene Prüfung unter **Profil → Deine Ausrüstung** und kann sie dort selbst auslösen.

Die Guides von [wowtbc.gg](https://wowtbc.gg/) führen spec-spezifische Consumables und Alternativen auf. Diese Trennung eignet sich als Grundlage für die Stufen **Optimal** und **Solide**, muss aber pro Phase und Spec gepflegt werden.

## 0.7 – Mitgliederpflege

Grundlage seit 0.4.4 umgesetzt: Abmeldungen, Inaktivitätsgrenze, Rangschutz und vorsichtige Prüfvorschläge. Der vollständig umgesetzte Zielumfang:

- frei wählbare Inaktivitätsgrenze, zum Beispiel 30, 60 oder 90 Tage;
- letzte Onlinezeit aus dem Gildenroster;
- Main/Alt-Status aus Guild Copilot berücksichtigen;
- Abmeldung mit Grund und Rückkehrdatum;
- geschützte Ränge und manuelle Ausnahmeliste;
- Vorschlagsliste mit klarer Begründung:
  - „67 Tage offline“;
  - „kein Twink verknüpft“;
  - „keine aktive Abmeldung“;
  - „Rang nicht geschützt“.
- Vorschläge können abgelehnt, zurückgestellt oder als erledigt markiert werden;
- niemals automatische Gildenausschlüsse;
- Ausschluss nur einzeln, mit Berechtigungsprüfung und ausdrücklicher Offiziersbestätigung.

Umgesetzt: Vorschläge lassen sich als dauerhafte Ausnahme, zurückgestellt oder erledigt ablegen; zurückgestellte Fälle tauchen nach Ablauf des Datums von selbst wieder auf. Die Einträge werden gildenweit synchronisiert und hängen am Ende der Gildenprofil-Nutzlast, sodass ältere Clients sie ignorieren und beim Empfang nichts löschen.

Der einzelne Gildenausschluss ist umgesetzt und mehrfach abgesichert: nur mit freigegebenem Mitgliederpflege-Rang, nur mit echter Blizzard-Berechtigung (`CanGuildRemove`), nur gegen einen niedrigeren und nicht geschützten Rang, nie gegen den eigenen Charakter, immer nur ein Spieler und erst nach einem zweiten, ausdrücklichen Klick auf derselben Zeile. Nach dem Ausschluss wird der Fall automatisch als erledigt vermerkt. Es gibt weiterhin keinerlei Automatik und keine Sammelaktion.

Damit sind die Punkte aus 0.7 abgearbeitet.

## 0.8 – Verzauberungen beim Namen nennen

Der Item-Link führt nur eine Enchant-ID, die Guides nennen nur Namen. Beides trifft sich im Client: Der Name wird aus dem WoW-Tooltip gelesen und steht dadurch ohne gepflegte Datenbank im Klartext da, in der Sprache des jeweiligen Clients.

Darauf aufbauend pflegt die Gilde ihren Regelsatz selbst. Ein Klick auf eine Slotzeile stuft die erkannte Verzauberung ein, gespeichert und geteilt wird nur die ID mit ihrer Stufe.

## 0.9 – Werbebalken, Automatik und Fehlerbehebungen

Der Werbebalken wurde ein eigenes kleines Fenster, damit für das Posten nicht das ganze Addonfenster offen bleiben muss.

Danach folgten überwiegend Korrekturen an Stellen, die im Spiel auffielen:

- **Sync**: Ein Mitgliedsprofil ging nur beim Login und bei eigener Änderung raus, eine Abfrage gab es nicht. Wer zuerst eingeloggt war, sendete in einen leeren Raum und blieb für alle später Eingeloggten unsichtbar – Berufe und Specs erschienen deshalb nur in einer Richtung. Das Profil hängt jetzt an der vorhandenen Handshake-Antwort, mit eigenem Zeitfenster gegen Kanalflut.
- **Gear Audit, Automatik**: Die eigene Ausrüstung prüft sich selbst, beim Login und nach dem Umziehen. Eine vorhandene, aber nirgends bewertete Verzauberung gilt wahlweise als in Ordnung, statt als „Unbekannt“ aufzufallen. Das behauptet keine Qualität, es unterscheidet nur verzaubert von nicht verzaubert. Bis 0.9.18 waren Selbstprüfung und Ergebnis rein lokal und abschaltbar; 0.9.19 ersetzt diesen Stand durch den festen Hintergrundabgleich.
- **Gear Audit, Statuszeile**: Sie zählte nur die mitgelieferte, absichtlich leere Regelliste. Gildeneigene Bewertungen wurden dadurch nie anerkannt, die Meldung blieb dauerhaft auf „Regelsatz ist noch leer“ stehen.
- **Aufklappmenüs**: Mehrere Seiten liegen in einem ScrollFrame, und ein ScrollFrame beschneidet alles, was über seinen Rand hinausragt. Als Kind der jeweiligen Karte wurde ein aufgeklapptes Menü oben abgeschnitten, unabhängig von seiner Höhe. Es hängt jetzt am Hauptfenster und wird nur noch am Knopf verankert; ab neun Einträgen scrollt es.
- **Kleinigkeiten**: Der Werbebalken kappte seinen Text bei 110 Bytes statt bei den 255, die in den Chat gehen. Die Hinweisspalte der Slot-Tabelle brach um und lief in die Nachbarzeilen. In `GetPlayerFullName` kürzte ein `and`-Ausdruck die Zuweisung auf einen Wert, der Realm kam dadurch nie an.

## Installer 1.0 – ein Fenster für Installation und Logs

Vom bisherigen `GuildCopilot-Installer.exe` existierte nur die fertige Binärdatei, kein Quellcode. „Warcraft Logs dort einbauen" hieß deshalb: alles neu bauen. Die Anwendung liegt jetzt unter `Installer/` im Repository, damit sich das nicht wiederholt.

Übernommen aus der alten Fassung: Installation und Aktualisierung direkt aus GitHub, Erkennung der Spielversionen, gemerkter AddOns-Pfad, Entfernen, Update-Suche, automatische Aktualisierung beim Öffnen und Autostart mit Windows.

Dabei behoben:

- **Versionsvergleich auf ungleich statt auf neuer.** Die alte Fassung bot „Auf 0.9.16 aktualisieren" an, obwohl 0.9.17 installiert war – sie hätte stillschweigend heruntergestuft. Verglichen wird jetzt stellenweise; eine ältere Fassung im Repository wird ausdrücklich als Rückstufung benannt.
- **Versionsabfrage über `raw.githubusercontent.com`.** Deren CDN liefert nach einem Push noch minutenlang den alten Stand aus, was wie ein fehlgeschlagener Upload aussieht. Gelesen wird jetzt über die GitHub-API mit `no-cache`.
- **Löschen vor dem Kopieren.** Ein geöffnetes Explorer-Fenster im `Companion`-Ordner reichte, damit Windows das Löschen verweigert und die Installation abbricht. Kopiert wird jetzt darüber; anschließend werden nur die Dateien entfernt, die es in der neuen Fassung nicht mehr gibt. Gesperrte Altdateien werden benannt und übersprungen.

Neu ist der Bereich **Warcraft Logs**: Zugangsdaten, Gilden- oder Reportlink, Anzahl der Reports, Fortschritt im Verlauf, Importcode direkt in der Zwischenablage. Node.js wird dafür nicht mehr gebraucht. Das Client Secret wird nur auf Wunsch gespeichert, verschlüsselt über die Windows-eigene DPAPI und an das Windows-Konto gebunden.

Die Auswertung ist eine originalgetreue Portierung von `WCL-Import.mjs`. Belegt über `--selftest`: der Aufruf spielt eine mit `--debug` aufgezeichnete API-Antwort durch die Auswertung. Gegen den erprobten SSC/TK-Report erzeugt die C#-Fassung Zeile für Zeile dieselbe Ausgabe wie die geprüfte JavaScript-Fassung.

Der Installer hält sich selbst aktuell: `Installer/dist` enthält die fertige .exe und eine Versionsdatei – ausdrücklich außerhalb von `GuildCopilot/`, damit nichts davon im Addon-Ordner landet. **Installer und Addon werden getrennt gezählt**: der Installer beginnt bei 1.0.0.

Verworfen: Reiter im Fenster. Ein `TabControl` zeichnet seinen Rahmen in den Systemfarben und setzt damit einen hellen Balken mitten ins dunkle Fenster; auch selbst gezeichnete Reiter ändern daran nichts. Beide Bereiche stehen deshalb untereinander in einem Stück.

Offen: Der Live-Abruf gegen die WCL-API ist aus dem Installer heraus noch nicht gelaufen, nur die Auswertung ist belegt. Ein Dateisymbol für die .exe fehlt; das Fenstersymbol kommt aus dem eingebetteten Logo. `Start-WCL-Import.cmd` und der Companion bleiben vorerst als Rückfallebene erhalten.

## 0.9.18 – Stabilität und Abgleich

- WCL-Links werden in Addon, Companion und Installer auf echte `warcraftlogs.com`-Hosts und vollständige Pfade begrenzt;
- Ereignisse vom Trash bleiben für Kennzahlen erhalten, erzeugen aber keine zusätzlichen Teilnehmer ohne Encounter-Anwesenheit;
- UTF-8-Kürzung, beschädigte SavedVariables, alte Postfacheinträge und unvollständige Sync-Transfers sind abgesichert;
- abgelaufene Zurückstellungen blockieren die Mitgliederpflege nicht mehr;
- Installer-Selbstupdate, Autostart, Laufwerkserkennung und Zwischenablage-Rückmeldung behandeln Fehler ohne falsche Erfolgsmeldung;
- README, Roadmap, Ingame-Hilfe und beide Installationswege sind auf denselben Funktionsstand gebracht.

## 0.9.19 – Verteilter Ausrüstungsabgleich

- jeder Client prüft seine eigene Ausrüstung beim Login und nach Änderungen ohne Schalter im Hintergrund;
- übertragen werden nur kompakte Messwerte je Slot, keine fertigen Bewertungen oder fremdsprachigen Tooltiptexte;
- Login-Handshakes liefern einem neu hinzugekommenen Client automatisch die aktuellen Snapshots der bereits anwesenden Addon-Nutzer;
- empfangene Daten werden streng auf Klasse, Spec, Slotzahl, Wertebereiche, Alter, Paketgröße und Absenderkonsistenz geprüft;
- ein Gruppen-Scan verwendet frische Addon-Daten direkt und inspectet nur noch Mitglieder ohne gültigen Snapshot.

Installer 1.0.3 ergänzt einen geordneten Neustart-Handoff und eine Einzelinstanzsperre: Beim Selbstupdate wartet die neue Fassung unsichtbar auf das Ende der alten, sodass nie zwei Installer-Fenster gleichzeitig offen sind.

## 0.9.20 – Sofortiger Rezeptabgleich

- Berufsfenster werden unmittelbar beim Öffnen und anschließend in kurzen Bereitschaftsprüfungen gelesen; häufige `TRADE_SKILL_UPDATE`-Ereignisse können den Scan nicht mehr gegenseitig abbrechen;
- klassische TBC-Rezeptfilter werden einmal pro geöffnetem Beruf zurückgesetzt und sämtliche eingeklappten Kategorien geöffnet, bevor der Bestand gespeichert wird;
- spätere gefilterte Teilansichten löschen keine bereits vollständig eingelesenen Rezepte mehr;
- das moderne TradeSkill-Fallback übernimmt die tatsächlich zurückgegebene gefilterte Rezeptliste korrekt;
- Rezeptpakete verwenden zwischen aktuellen Clients ein kompakteres Format und werden in einem direkten Burst ohne feste Pause gesendet;
- nur eine echte Ablehnung durch WoW unterbricht den Burst kurz für eine automatische Wiederholung; ältere Clients bekommen auf Anfrage weiterhin das bisherige Paketformat.

## 0.9.21 – Verlässliche Eigendaten im Gear Audit

- die feste Zwölf-Zeilen-Grenze der geprüften Spieler wurde durch eine vollständige, dynamische Scrollliste ersetzt;
- der per Addon-Daten erkannte aktuelle Gruppenspieler wird nach **Gruppe prüfen** automatisch ausgewählt und in der Liste sichtbar gemacht;
- leere Pflichtslots und noch nicht lesbare Gegenstände zählen als Funde und werden nicht länger als „ok“ einsortiert;
- ein angelegter Gegenstand mit noch nicht geladenem Item-Link wird über `GetInventoryItemID` erkannt, automatisch erneut gelesen und bis dahin nicht synchronisiert;
- Handshake-Antworten lesen die echte aktuelle Ausrüstung erneut, statt möglicherweise einen gespeicherten alten Snapshot nochmals zu senden;
- `UNIT_INVENTORY_CHANGED` ergänzt `PLAYER_EQUIPMENT_CHANGED`, damit auch Änderungen am Item selbst zuverlässig einen neuen Eigendaten-Snapshot auslösen;
- ein Regressionstest bildet ausdrücklich einen selbst übertragenen, unverzauberten Rücken und mehr als zwölf gespeicherte Spieler ab.

## 0.9.137 – Was vom entfernten Warcraft-Logs-Modul übrig blieb

Aus dem Betrieb kamen drei Beobachtungen am Postfach, alle mit derselben Wurzel:
Das Warcraft-Logs-Importmodul (`WarcraftLogs.lua`) liegt dem ausgelieferten
Addon nicht bei – der Import braucht den Windows-Helfer, den CurseForge nicht
mitschicken kann, deshalb schließt der Paketbau die Datei aus. Zwei nützliche
Dinge hingen aber daran, ohne den Import wirklich zu brauchen.

### Die Profil-Links im Postfach kamen aus dem entfernten Modul

`SetLeadProfileLinks` baute die Armory- und Warcraft-Logs-Charakterseite über
`GC.WarcraftLogs:BuildCharacterLinks`. Fehlt das Modul, ist `GC.WarcraftLogs`
nil, und der Aufruf lieferte nichts – die Felder „Armory" und „Logs" blieben in
jeder Bewerbung leer. Dabei brauchen die Links das Importmodul gar nicht: Region
kommt vom Client (`GetCurrentRegion`), der Realm vom Interessenten (am Namen
angehängt) oder vom eigenen Charakter, der Host aus den Konstanten. Die
Link-Bildung wandert deshalb als `GC.Chat:BuildLeadProfileLinks` in ein
ausgeliefertes Modul und steht damit immer bereit. Die Ersetzung der
URL-Platzhalter läuft bewusst über eine Ersetzungs-**Funktion**, nicht über
einen Ersetzungs-String: Der URL-kodierte Name enthält „%XX"-Sequenzen, die
`gsub` in einem String-Ersatz als Muster läse und bei Umlautnamen mit einem
Fehler abbräche. Der Regressionsanker in `smoke.lua` prüft beide Links über die
Oberfläche.

### Der Hinweis verwies auf eine Seite, die es nicht mehr gibt

Unter den Linkfeldern stand „Für Links zuerst unter Warcraft Logs die
Gildenquelle speichern." Diese Seite ist mit dem Modul verschwunden. Da die
Links jetzt aus Region, Realm und Name entstehen, erscheinen sie fast immer; der
Hinweis meldet nur noch den echten Ausnahmefall (kein Realm bestimmbar) und ohne
den falschen Verweis.

### Der Erkennungsschalter saß in der falschen Karte

„Auch freie Formulierungen erkennen" stand unter „Rekrutierung: Meldungen &
Töne", betrifft aber die Erkennung, nicht Meldungen oder Töne. Er steht jetzt in
der Karte „Postfach-Erkennung", direkt bei den Trigger-Wörtern, auf die er sich
bezieht. Rein eine Umstellung der Oberfläche: Der Schalter bleibt derselbe
(`smartRecruitmentDetection`), sein Zustand und die Abhängigkeit vom
Kanal-Mitlesen ändern sich nicht.

## 0.9.136 – Noch ein Durchlauf, diesmal gegen echte Daten

Auftrag war ein erneuter vollständiger Code- und Feature-Review mit einem
besonderen Blick auf zwei Bereiche: den Ausrüstungstracker (ob Verzauberungen,
Sockel und Steine vollständig erfasst werden) und die Raidauswertung (ob ihre
Zahlen stimmen). Der Review lief adversarisch – jeder Befund wurde von einer
zweiten, unabhängigen Instanz gegen den echten Code gegengeprüft, bevor er als
echt galt. Sieben Stellen wurden geändert, eine bewusst NICHT.

### Die Raidauswertung stimmt – gegen das rohe Kampflog gerechnet

Der Abend vom 19.08.2026 (Festung der Stürme + Höhle des Schlangenschreins) lag
als rohes `WoWCombatLog` vor – dieselbe Datei, die auch Warcraft Logs einliest.
Die eigene Live-Auswertung (Nexarius, 26 Teilnehmer) wurde Spieler für Spieler
dagegen gerechnet, mit denselben Spell-IDs aus `Constants.lua` und denselben
Zählregeln wie im `RaidMonitor`: Tode, Unterbrechungen, Banne, Tränke und
Trommeln stimmen **exakt** überein – 140 Tode, 41 Unterbrechungen, 226 Banne,
271 Tränke, 68 Trommeln, keine einzige Abweichung. Die getragenen Güter
(Fläschchen, Elixiere, Essen) liegen wie erwartet bei LIVE ≥ Log. Die
Auswertung ist damit nicht „plausibel", sondern gegen die Grundwahrheit belegt.

### Was tatsächlich falsch war

- **Bewerbungen mit „|" wurden im Postfach abgeschnitten.** Der gildenweite
  Sync maskiert einen Datensatz beim Senden zweimal (jedes Feld, dann der ganze
  Datensatz). Beim Empfang stand eine Entschlüsselung zu viel: `ReceiveSync`
  entschlüsselt das Paket, ein zusätzliches `UnescapeField` und die Feldzerlegung
  in `ParseInboxRecord` machten zusammen drei. Ein im Text maskiertes „|"
  (Itemlink, Farbcode) wurde dadurch vorzeitig zu einem echten „|", an dem die
  nächste Zerlegung die Nachricht abschnitt. Empirisch nachgestellt: aus „schaut
  euch |cff…|Hitem:…|h[Wappenrock]|h|r an" wurde „schaut euch " – bei einem
  Paket wie bei zehn Teilstücken. Das überflüssige `UnescapeField` fällt weg;
  ein Regressionsanker in `smoke.lua` schickt eine Zeile mit mehreren „|" durch
  den ganzen Weg und erwartet sie unverändert zurück.
- **Der Eintritts-Scan konnte eine Mahlzeit doppelt zählen.** `RaidMonitor`
  entprellt Essen über 60 Sekunden (`auraCountedAt`), damit das Weiteressen –
  der Client meldet die Sattgegessen-Aura im Zehnsekundentakt – nur einmal
  zählt. Der Eintritts-Scan `ScanCarriedConsumables` schrieb ein bereits
  getragenes Essen aber nur in `scanned`, nicht in `auraCountedAt`. Traf kurz
  darauf ein `SPELL_AURA_REFRESH` derselben Aura ein, lief er an der Entprellung
  vorbei und zählte die Mahlzeit ein zweites Mal. Der Scan setzt jetzt für
  Aura-Kategorien dieselbe Entprellung, die der Kampflog-Pfad prüft.
- **Ein Boss-Kill ohne `ENCOUNTER_END` konnte als Wipe gebucht werden.** In
  `CloseSegment` stand die Wipe-Heuristik (Todesquote ≥ 50 %) vor der
  Kill-Erkennung (`bossDied`). Fehlte das Encounter-Endereignis – der Fall, für
  den `bossDied` überhaupt aus dem Kampflog gesetzt wird – und starben beim Kill
  viele Spieler durch die Endmechanik, gewann die Wipe-Heuristik und ein Sieg
  stand als Wipe da. Der wirkliche Tod des Bosses schlägt jetzt die Heuristik;
  ein Wipe (Boss stirbt nicht) fällt weiterhin richtig heraus.
- **„lf" traf als Teilstring mitten in Wörtern.** Die freie Bewerbererkennung
  vergleicht Suchwörter per reinem Teilstring, damit „sucht" auch „gesucht"
  findet. Für das Kürzel „lf " ist das falsch: es steckt im Ende von „half",
  „myself", „wolf", „golf", „shelf". Stand danach irgendwo „guild"/„gilde",
  machte die Reihenfolgeregel daraus einen Bewerber. Kurze Buchstabenkürzel
  („lf", „lfg") werden jetzt nur an einer Wortgrenze gewertet; „sucht"→„gesucht"
  bleibt unberührt. Regressionsanker: „myself and my guild need potions" und
  Geschwister bleiben draußen, ein echtes „Lf … guild" wird weiter erkannt.
- **Ein ausgenommener Ausrüstungsplatz hieß je nach Ansicht anders.** Die
  Slot-Liste kannte in `GEAR_VERDICT_STYLE` keinen Eintrag für `EXEMPT` und
  fiel auf „Unbekannt" zurück, während die Gruppenübersicht denselben Zustand
  „Ausnahme" nannte. `EXEMPT` ist jetzt auch in der Slot-Liste „Ausnahme".
- **Eine rollengebundene Verzauberungsregel griff bei unbekannter Rolle.** In
  `RuleApplies` ließ `if rule.roles and role and …` die ganze Bedingung
  durchfallen, sobald `role` nil war – die Regel wurde angewendet, statt
  übersprungen. Das widerspricht dem Vertrag der Funktion (eine nicht passende
  fremde Regel darf niemanden schlechter dastehen lassen) und war unsymmetrisch
  zum Archetyp-Zweig, der eine unbekannte Spec korrekt ausschließt. Jetzt gilt
  eine Rollen-Regel bei unbekannter Rolle ebenfalls als nicht zutreffend. Der
  Fall ist derzeit ruhend (keine ausgelieferte Regel nutzt `roles`), aber die
  Stelle war falsch, sobald eine dazukäme.
- **Ein beschädigter Warcraft-Logs-Code hätte die Sync-Kodierung verschieben
  können.** Der Report-Code wird zur Auswertungs-ID (`source:code`) und wanderte
  roh in die mit „," und „;" getrennte gildenweite Kodierung. Echte WCL-Codes
  sind URL-sicher alphanumerisch, aber ein von Hand bearbeiteter oder
  beschädigter Import mit „," oder „;" darin hätte die Felder verschoben. Die
  Trennzeichen werden jetzt beim Import entfernt, bevor die ID entsteht.

### Der Ausrüstungstracker: geprüft, erfasst vollständig

Die gespeicherten Ausrüstungsdaten (41 Prüfungen aus dem echten Bestand) wurden
auf Auffälligkeiten durchgesehen: Verzauberungs-IDs, leere Sockel und
Gegenstands-IDs werden durchgehend erfasst; die Sockelzählung liest die leeren
Sockel sprachunabhängig aus den globalen `EMPTY_SOCKET_*`-Zeichenketten des
Clients, die Steine aus dem Itemlink (`item:id:enchant:gem1:gem2:gem3:gem4`).
Kein struktureller Fehler in der Erfassung. Der einzige gefundene Anzeigefehler
war die `EXEMPT`-Beschriftung oben; die Bewertungslogik (`RuleApplies`) bekam
den Rollen-Fix.

### Was bewusst NICHT geändert wurde

Der Review-Durchlauf meldete zusätzlich, dass ein vollständig geleerter
Gildenbank-Tab nicht als leer verteilt wird (`ScanGuildBankTab` behält bei einem
leeren Durchlauf den alten Stand). Das ist genau der Trade-off, den 0.9.135
schon ausdrücklich als bewusste Entscheidung dokumentiert hat: Eine leere
Abfrage ist von „lädt noch" nicht sicher zu unterscheiden, auch nicht am gerade
geöffneten Fach (das `GUILDBANKBAGSLOTS_CHANGED`-Ereignis kann feuern, bevor die
Slots des frisch gewählten Fachs da sind). Ein zunächst probierter Fix über
`GetCurrentGuildBankTab` wurde deshalb wieder verworfen – eine getroffene
Entscheidung wird nicht still überschrieben. Bleibt als offene Frage notiert,
falls sich das Fach-geladen-Signal doch verlässlich fassen lässt.

### Randnotiz zum Postfach-Fehlalarm

Aus dem Betrieb kam erneut, dass etwas im Postfach landet, „was eigentlich nicht
im Trigger ist" – konkret ein englisches „Lf nice leveling guild :)". Das ist
kein neuer Fehler: Es ist die freie Erkennung, die seit 0.9.135 zwar ab Werk aus
ist, deren gespeicherter Schalter beim Besitzer aber noch auf AN steht. Solange
„Auch freie Formulierungen erkennen" an ist, greift die Reihenfolge-Erkennung
unabhängig von der eigenen Wortliste. Für „nur meine Triggerliste" genügt es,
den Schalter in den Einstellungen auszuschalten (die gespeicherte Einstellung
überschreibt die neue Vorgabe). Der „lf"-Fix oben verhindert unabhängig davon,
dass die Erkennung – falls jemand sie anlässt – auf half/self/wolf anspringt.

## 0.9.135 – Ein Durchlauf durch den ganzen Code

Anlass war keine einzelne Beschwerde, sondern die Frage, ob das Addon mit 250 gleichzeitig online Spielern trägt und ob der Code hält, was er verspricht. Also einmal quer durch alle Module, mit einem klaren Auftrag: echte Fehler, keine Geschmacksfragen. Der Netzwerkteil (`Sync.lua`) wurde dabei ausdrücklich gegen das 250-Spieler-Szenario geprüft und trägt — die Antwortwahl (nur wenige Gewählte antworten je Anfrage), das Verstummen bei fremder Antwort, ChatThrottleLib, Kampfpause und Backoff greifen wie vorgesehen. Sieben Stellen wurden geändert.

### Was tatsächlich falsch war

- **Die Spec-Auswahl im Werbeeditor verlor still Daten.** „Ganze Klasse" legt intern alle Specs als gewählt ab, und der Werbetext zählt sie auch alle — nur `IsSpecSelected` meldete im CLASS-Modus `false`, weshalb die Spec-Knöpfe inaktiv aussahen. Ein Klick auf eine einzelne Spec begann damit bei einer leeren Liste und zog die ganze Klasse auf die eine geklickte Spec zusammen, ohne Hinweis. `IsSpecSelected` sagt im CLASS-Modus jetzt die Wahrheit (alle gewählt), und `SetSpec` zählt beim Wechsel auf Einzelauswahl zuerst alle Specs auf, bevor der Klick greift. Ein Klick schaltet damit genau eine Spec ab.
- **`GC.LFormat` konnte Platzhalter doppelt ersetzen.** Der frühere Weg lief zeilenweise, ein `gsub` je Schlüssel, und durchsuchte dabei bereits eingesetzten Text erneut. Enthielt ein Wert selbst `{einanderer}`, ersetzte ihn ein späterer Durchlauf — und welcher zuerst kam, entschied die zufällige `pairs`-Reihenfolge, also fiel dasselbe Ergebnis mal so, mal anders aus. Der Callback-Weg setzt jeden Platzhalter an seiner Fundstelle genau einmal ein.
- **`bossLookupCache` wuchs unbegrenzt.** Der Speicher der Bosserkennung merkte sich jeden je gesehenen Gegnernamen dauerhaft, Fehltreffer als `false`. Über einen Trashabend mit zehntausenden verschiedenen Namen summierte sich das bis zum `/reload`. Es ist derselbe Fall, den der Teilnehmerspeicher über `MAX_NAME_LOOKUP_MISSES` schon gedeckelt hatte — die Deckelung fehlte hier bloß und wurde nachgezogen (`MAX_BOSS_LOOKUP_MISSES`, beim Überlauf werden nur die Fehltreffer geleert, die erkannten Bosse bleiben).
- **Zwei Einstellungsfelder überschrieben laufende Eingaben.** „Anzeigedauer der Meldung" und die Auftrags-Flüstervorlage bekamen bei jedem `SETTINGS_UPDATED` ein `SetText` ohne `HasFocus`-Prüfung — ein Gildenabgleich malt die Seite neu, und mitten im Tippen sprang das Feld auf den gespeicherten Wert zurück. Beide prüfen jetzt `HasFocus`, wie jedes andere Eingabefeld der Datei (der Verlust-Fall war an den Abmeldefeldern schon dokumentiert).

### Kleinere, ebenfalls echte Stellen

- Der Berufsschritt des Einrichtungsassistenten (`RefreshWizardProfessions`) griff als einzige Stelle ohne Nil-Schutz auf `profile.professions` zu; bei einem alt-strukturierten Profil hätte das die Assistentenseite beim Zeichnen abbrechen können. Jetzt mit demselben `(profile.professions or {})`-Schutz wie überall sonst.
- `AnswerSummaryRequest` rief `C_Timer.After` ungeprüft auf, während jede andere Stelle der Datei `C_Timer` absichert; ohne Timer wird die Auswertung jetzt ungestaffelt, aber überhaupt gesendet.
- Das Gildenbank-Manifest akzeptierte `tabIndex 0` und stieß dafür eine Anfrage nach Tab „0" an, den es nicht gibt (die Empfangsseite verlangt ohnehin `≥ 1`). Solche Einträge werden jetzt vorne verworfen — ein gespartes Paket, keine Korruptur.

### Was bewusst NICHT geändert wurde

Zwei Perf-Stellen skalieren mit einer großen Gilde schlechter, sind aber kein Fehler und kein risikoarmer Ein-Zeilen-Fix: `Inventory:GetReagentStatus` scannt je Reagenz alle Account-Charaktere und alle Gildenbank-Tabs, und `Orders:GetBoard` ruft je offenem Fremdauftrag die Herstellerliste neu auf. Beide sind Kandidaten für einen invalidierten Zwischenspeicher wie ihn der Werkstattkatalog schon hat — aber ein falsch invalidierter Cache zeigt veraltete Bestände, und das wäre schlimmer als der jetzige Aufwand. Bewusst als Folgearbeit notiert statt übereilt eingebaut. Ebenso stehen gelassen: der dokumentierte Trade-off, dass ein geleerter Gildenbank-Tab nicht als leer verteilt wird (eine leere Abfrage ist von „lädt noch" nicht zu unterscheiden), und die vernachlässigbare Token-Kollision im Ausrüstungstransfer (~1/9000, selbstheilend).

### Nachtrag: nur die eingetragenen Wörter zählen

Aus dem Betrieb kam ein Fehlalarm: Eine englische Gildenwerbung stand als Bewerber im Postfach — „Looking for your people? Cereal Killers is a friendly, active guild … All classes/roles welcome!“. Ursache war die freie Erkennung: Sie entscheidet über die Wortreihenfolge (Suchwort vor Gildenwort → Bewerber), und „**Looking for** …“ stellt das Suchwort an den Anfang, obwohl hier eine Gilde sucht, nicht ein Spieler. Die deutsche Merkmalsliste, die das übersteuern würde, kennt diese englischen Wendungen nicht.

Die Frage des Besitzers war grundsätzlicher: Warum zählt überhaupt etwas mit, das nicht eingetragen wurde? Antwort ist der Umbau: **Die freie Erkennung ist ab Werk aus und der Hauptschalter der ganzen eingebauten Schicht.** Steht sie aus, zählt strikt, was in den Trigger-Feldern steht — ein leeres Feld erfasst nichts, es fällt nicht mehr still auf die Vorgabe zurück. Steht sie an, greift wie bisher die mitgelieferte Vorgabe (für ein leeres Feld) samt Reihenfolge-Erkennung.

Bewusst NICHT gewählt: die englischen Werbemerkmale einfach nachzutragen. Das hätte nur die freie Erkennung treffsicherer gemacht — die der Besitzer aber gar nicht will. Der Schalter ist die ehrlichere Antwort als immer neue Wortlisten. `GetRecruitmentWords` liefert die Vorgabe jetzt nur noch bei eingeschalteter Erkennung; die eigene Liste bleibt in jedem Fall maßgeblich. Regressionsanker in `smoke.lua`: genau die englische Zeile bleibt im strikten Modus draußen, ein Bewerber mit passendem eigenem Wort kommt weiter herein.

### Nachtrag: gelöschte Bewerber bleiben eine Weile gelöscht

Frage aus dem Betrieb: Wenn ich einen Interessenten aus dem Postfach lösche — wie wird verhindert, dass ihn ein anderer Client wieder zu mir synchronisiert? Antwort war bis 0.9.134: gar nicht. `RemoveLead` entfernte den Eintrag nur lokal, ohne Merker; `MergeRemoteLead` sperrte nur den eigenen Charakter, Gildenmitglieder und ausdrücklich Ignorierte. Ein gelöschter Bewerber, den ein Kollege noch hielt, kam beim nächsten Abgleich zurück. Das dauerhafte „Ignorieren“ verhinderte das zwar (es schreibt in `inboxFilters`, die auch den Empfang sperrt), aber ein schlichtes Löschen eben nicht.

Gewählt wurde: ein **rein lokaler Grabstein, der bis zur nächsten echten Nachricht hält**. `RemoveLead` legt einen Merker an (`inboxTombstones`, per Gilde, nie im Netz). Solange er steht, sperrt `MergeRemoteLead` diesen Spieler — egal wie oft ein Kollege seine alte Kopie schickt. Aufgehoben wird er durch genau ein Ereignis: `CaptureLead`, also eine direkte Flüster- oder Kanalnachricht, die dieser Client SELBST empfängt. Das ist ein echter neuer Kontakt; dann fällt der Merker und der Spieler darf wieder herein (auch per Sync). Eine fremde Sync-Kopie zählt ausdrücklich nicht als neue Nachricht — sonst wäre der Merker wertlos. Kein Zeitfenster als Hauptmechanik; gegen unbegrenztes Wachsen ist die Zahl der Merker gedeckelt (beim Überlauf fallen die ältesten weg, die längst weggeräumte Bewerber betreffen).

Ausdrücklich NICHT mit Merker: „Alles leeren“ (`ClearInbox`). Das ist ein Aufräumen der Ansicht; einen Merker über den ganzen Bestand zu legen, würde das gildenweite Postfach sieben Tage leer halten, obwohl Kollegen aktive Bewerber haben. Der Merker steht auch nicht in der Ignorierliste — er ist kein „dauerhaft ignorieren“, sondern ein „nicht sofort zurückspülen“. Regressionsanker in `smoke.lua`: löschen, Sync desselben Namens bleibt draußen, direkter Neukontakt kommt herein.

### Nachtrag: die Abmeldungskarte überlappte die Entscheidungen

Ein Layoutfehler in der Mitgliederpflege: „Aktuelle Abmeldungen“ hing an einer festen Position (`-880`), während die Karten darüber — Pflegevorschläge und Entscheidungen — mit der Zahl der Vorschläge nach unten wuchsen. Ab rund acht Vorschlägen schob sich die Entscheidungskarte über die feste Abmeldungskarte, und deren Leerzeile („Keine Ausnahmen hinterlegt …“) lag über der Überschrift der nächsten. `RefreshMemberCare` führte die Abmeldungskarte bisher gar nicht nach. Jetzt hängt sie unter der Entscheidungskarte und wandert mit ihr; die Inhaltshöhe rechnet bis zu ihr, statt sie zu ignorieren.

## 0.9.134 – Wessen Zahlen stehen da eigentlich?

Ausgelöst von einer Frage zum Abend des 16.08.: Warum zeigt die Raidauswertung neben der eigenen Fassung („Live, 28 Teilnehmer") eine zweite von Druidgard („27") mit durchweg kleineren Zahlen — und welche stimmt?

### Erst der Abgleich, dann die Änderung

Bevor irgendetwas angefasst wurde, drei Quellen desselben Abends nebeneinandergelegt: die eigene Live-Fassung, Druidgards Sync-Fassung und das rohe Kampflog (`WoWCombatLog-081626`, dieselbe Datei, die auch Warcraft Logs einliest). Mit denselben Spell-IDs geparst, die auch das Addon benutzt.

- Die eigene Fassung deckt sich **spielergenau** mit dem Kampflog: Tode, Unterbrechungen, Zauberbanne, Tränke, Trommeln — 28 von 28 Teilnehmern ohne eine einzige Abweichung.
- Getragene Güter (Fläschchen, Elixiere, Essen) liegen leicht höher als das Log, und zwar immer in diese Richtung. Das ist kein Fehler: Das Addon liest zusätzlich ab, was vor Log-Beginn schon auf dem Charakter lag — genau der Zweck des Eintritts-Scans.
- Druidgards Fassung ist keine andere Wahrheit, sondern eine **abgeschnittene**: Sie endet 21:55 statt 23:49. Gegen das Kampflog bis 21:55 gerechnet, stimmt sie 26 von 27 Spielern — sie hört nur zwei Stunden früher auf. Dabei fehlt ihm auch er selbst, daher 27 statt 28.

### Warum die Fremdfassung überhaupt dastand

Fremde Mitschnitte sind Reparaturmaterial: Hat der eigene Mitschnitt Lücken, füllt das Addon sie aus den Fassungen der Kollegen (je Spieler und Spalte der höchste Wert). Die eigene Fassung dieses Abends ist intern als lückenhaft markiert (`gaps=3`) — deshalb hielt das Addon Druidgards Kopie als Reparaturkandidaten. Nur ist sie abgeschnitten, jeder ihrer Werte also ≤ dem eigenen und als Reparaturquelle wertlos. Angeboten wurde sie trotzdem als gleichwertiger Reiter, weil die Oberfläche bis dahin bewusst jede gespeicherte Quelle zeigte.

### Die Änderung

`GetEvenings` liefert je Abend jetzt zusätzlich `visibleSources` — die anzeigbaren Quellen. Liegt eine eigene Fassung vor (Live, ergänzt, Warcraft Logs, Logdatei), fallen fremde `SYNC:<Name>` aus der Anzeige: aus den Quellenreitern, aus der Kopfzeile, aus dem Vergleich. Die vollständigste **sichtbare** Fassung führt den Abend an; eine fremde mit mehr Teilnehmern übernimmt die Kopfzeile nicht mehr. Fehlt jede eigene Quelle (man war nicht dabei), bleiben die fremden sichtbar — sonst wäre der Abend gar nicht lesbar.

Entscheidend ist, was **nicht** geändert wurde: Die Reparatur liest weiter `GetSummaries`, den vollen Bestand, nicht die gefilterte Liste. Fremde Fassungen bleiben gespeichert und ergänzen still weiter. Ein veralteter Auswahlschlüssel auf eine nun ausgeblendete Fremdfassung fällt über `VisibleSummaryKey` auf die eigene zurück, damit nicht nach einem `/reload` doch wieder Druidgards Zahlen im Detail stehen. Der Regressionstest deckt beide Seiten ab: Ausblenden, sobald eine eigene Fassung existiert, und Sichtbarbleiben, wenn nicht.

Das kehrt eine frühere Festlegung um („verborgen bleiben darf nichts") — bewusst, weil sie den Fall einer abgeschnittenen Fremdfassung neben einer vollständigen eigenen nicht bedacht hatte.

## 0.9.133 – Filter im Postfach, und was dabei auffiel

Gewünscht: „Kannst du noch Filters einbauen aber direkt ins Postfach zB Level, Klasse zum auswählen?"

Geliefert: **Klasse** und **Stufe**. Die Stufe brauchte einen Umweg — dazu unten.

### Der gefährliche Teil ist nicht das Ausblenden

Die Liste arbeitete durchgehend mit rohen Listenplätzen: `GetLeadIndexForSlot(slot)` rechnete `((seite - 1) * proSeite) + slot` und griff damit direkt in `GetGuild().inbox`. Löschen, Auswählen und Blättern hängen alle daran.

Sobald die Liste gefiltert ist, stimmt diese Rechnung nicht mehr — und der Fehler ist lautlos: Ein Klick auf das × der ersten sichtbaren Zeile löscht den ersten Eintrag des **Gesamtbestands**, nicht den, auf den man gezeigt hat.

Deshalb liegt jetzt eine Abbildung dazwischen. `RefreshInbox` baut `page.visibleLeads` — die echten Indizes in ihrer Reihenfolge — und `GetLeadIndexForSlot` geht darüber. Gezählt und geblättert wird ebenfalls über die sichtbaren Einträge; sonst zeigt die Seitenzahl den Gesamtbestand an, während die letzten Seiten leer sind.

Der Test dazu ist der eigentliche Zweck des Ganzen: Bei gesetztem Klassenfilter (Priester, echter Platz 3) muss `GetLeadIndexForSlot(1)` die 3 liefern, und der Löschknopf muss den Priester treffen — nicht den Krieger auf Platz 1. Gegenprobe mit der alten Rechnung: schlägt fehl, mit genau dieser Meldung.

### Zwei Entscheidungen an der Filterlogik

- **Unbekannte Klasse bleibt sichtbar.** Die Klasse steht nur an Einträgen, deren GUID der Client auflösen konnte. Ein Klassenfilter, der alles Unbekannte verbirgt, verliert Bewerber — und zwar unbemerkt, weil man ja gerade filtert. „Unbekannt" ist keine Aussage über die Klasse.
- **Dasselbe gilt für die Stufe.** Wer sie nicht dazugeschrieben hat, verschwindet nicht hinter „ab Stufe 70". Die Stufenauswahl sind deshalb Schwellen und keine Einzelwerte: Wer „68" schreibt, taucht bei „ab 60" auf.
- **Der Filter sagt, was er verbirgt.** Unter der Liste steht „*n* durch Filter ausgeblendet". Ein vergessener Filter sieht sonst aus wie ein leeres Postfach; das ist die häufigste Verwechslung bei Filtern überhaupt.

Gefiltert wird ausdrücklich die **Ansicht**. Ein ausgeblendeter Eintrag bleibt gespeichert und wird weiterhin gildenweit geteilt — sonst wäre ein Filter ein Löschknopf mit freundlichem Namen. Auch das prüft der Test: Filter zurücksetzen, alles wieder da.

Die Filterzeile kostet eine Listenzeile (acht statt neun je Seite). Die Karte ist 224 Pixel breit und sitzt bündig neben der Unterhaltung, beide zusammen füllen die 752 des Inhalts — breiter geht sie nicht.

### Die Stufe stand die ganze Zeit in der Nachricht

`lead.level` wurde **an keiner Stelle gesetzt** — es kam im Addon zweimal vor: kopiert in `MergeDuplicateLeads`, gelesen in der Postfachzeile. Geschrieben hat es nie jemand. Die README behauptete trotzdem „mit Klassenfarbe, Level und Empfangszeit".

Der erste Gedanke war eine `/who`-Abfrage: Sie liefert die Stufe, ist aber gedrosselt, braucht eine Warteschlange über alle Bewerber und lenkt mit `SetWhoToUI(true)` auch die **eigenen** manuellen `/who`-Ergebnisse ins Wer-Fenster. Ein spürbarer Nebeneffekt für eine Nebensache.

Der zweite Gedanke war der richtige, und er stand die ganze Zeit im Screenshot des Owners:

> **ENH** sucht Anschluss an Gilde zum Raiden

Bewerber schreiben selbst hin, was sie spielen. „70er Schurke sucht nette Gilde", „ich spiele ein Hexenmeister", „Stufe 70 Tauren Schamane". Keine Serveranfrage, keine Drosselung, keine Nebenwirkung — und es ist ohnehin genau der Text, der schon übertragen wird.

**Gelesen wird auf ganze Wörter** (`%f`-Grenzmuster). Ohne das findet „ele" auch „elegant" und „war" jedes „warum" — und Kürzel sind unvermeidlich, weil im Kanal so geschrieben wird. Eine Stufe **ohne Marker** gilt nur zwischen 58 und 70; sonst wird „suche noch **2** DDs" zu Stufe 2 und „ab **18** Uhr" zu Stufe 18. Mehrdeutige Kürzel sind bewusst nicht in der Tabelle: `resto` (Schamane oder Druide), `prot` (Krieger oder Paladin), `heal`, `dd`, `tank`. **Lieber keine Angabe als eine falsche** — eine falsche Klasse verbirgt den Bewerber hinter einem Filter, unter dem ihn niemand sucht.

Eine über die GUID aufgelöste Klasse wird nie durch die Textvermutung ersetzt: Die GUID ist Tatsache, der Text eine Vermutung. Auch das prüft der Test.

**Übertragen wird nichts davon.** Klasse und Stufe werden beim Empfänger aus demselben Text gelesen, der ohnehin ankommt. Das spart zwei Protokollfelder und hält beide Seiten automatisch gleich, sobald die Erkennung besser wird.

Gemessen an 16 Kanalzeilen, Fallstricke eingeschlossen: 16 von 16 richtig.

## 0.9.132 – Das Postfach gehört der Gilde

Aus dem Spiel: „Das Gildenpostfach wird aber nicht zwischen den Membern synchronisiert oder? Das sollte aber bitte so sein!"

Richtig geraten, und es war kein Versehen im Sync — es war nie vorgesehen. Geteilt wurde bisher nur `inboxSound`, also die Rangliste, wer den Bewerberton hört. Der Inhalt blieb bei dem, bei dem die Nachricht ankam. Wer angeflüstert wurde, sah den Bewerber; die anderen nicht.

### Was übertragen wird

Owner-Entscheidung, in dieser Reihenfolge gefallen:

- **Alles im Wortlaut, Flüstern eingeschlossen.** Die Alternative (Flüstern nur als Vermerk „hat geflüstert") war angeboten und wurde verworfen.
- **Nur die Ursprungsnachricht**, kein Chatverlauf. „Priester sucht Gilde" — die Zeile, mit der jemand aufgefallen ist.
- **Sonst nichts.** Ein erster Entwurf hatte den Bearbeitungsstand mitgesendet („Alex hat geantwortet", grün in der Zeile). Das war nicht verlangt und ist wieder entfallen: *„einfach nur so wie die nachrichten grade im postfach landen einfach synchronisieren sonst nix"*. Antworten bleibt eine lokale Angelegenheit und kostet kein Paket.

Die Beschränkung auf die Ursprungsnachricht ist nebenbei die technisch angenehmste Eigenschaft der ganzen Sache: **Sie ändert sich nie.** Ein Eintrag geht genau einmal raus. Ein Bewerber, der seinen Werbetext zum zehnten Mal in den Kanal schreibt, kostet kein zehntes Paket — der Test hält das fest.

Nicht übertragen werden: `unread` (ob *du* gelesen hast, ist deine Sache), der weitere Nachrichtenverlauf und die Ignorierliste.

### Form

Neuer Nachrichtentyp `I|`, aufgebaut wie die Gildenbank ihre Fächer verschickt:

```
I|<schema>|IL|<token>|<index>|<anzahl>|<teilstück>     ein Eintrag, gestückelt
I|<schema>|IQ                                          "wer hat was?"
```

Die Stückelung ist nicht optional: Eine Bewerbung darf im Spiel 255 Zeichen lang sein, dazu kommen Name, GUID, Klasse und zwei Zeitstempel — ein Eintrag passt selten in ein Chatpaket. Der Datensatz wird als Ganzes serialisiert, escaped und dann in Stücke geschnitten; der Empfänger setzt über den Token wieder zusammen. Doppeltes Escaping ist dabei unkritisch, `EscapeField`/`UnescapeField` sind sauber umkehrbar (`%` → `%25` zuerst, beim Auspacken zuletzt).

Die Anfrage läuft über den Gildenkanal, die Antwort **gezielt per Flüstern** und um 1–6 Sekunden gestreut. Sonst schiebt bei jedem Login die halbe Gilde denselben Bestand gleichzeitig in den Gildenkanal. Gesendet wird über `SendBulk`, pausiert also im Kampf wie alles andere.

### Die lokalen Sperren gelten auch für Fremdpakete

`MergeRemoteLead` wiederholt exakt die Prüfungen aus `CaptureLead`: kein eigener Charakter, kein Gildenmitglied, niemand von der Ignorierliste. Ohne das holt ein fremdes Paket zurück, was hier bewusst ausgeschlossen wurde — und die Ignorierliste, die lokal bleibt, wäre wertlos, sobald ein Kollege denselben Dauerschreiber erfasst.

Beim Zusammenführen gewinnt nicht der Absender, sondern der jeweils bessere Wert: früheste Ersterfassung, späteste Sichtung, vorhandene Klasse. Der Wortlaut wird nur übernommen, wenn hier noch keiner steht — die eigene Aufzeichnung ist die genauere, sie hat den ganzen Verlauf statt nur den Anfang. Ein übernommener Eintrag gilt als **ungelesen**, aber ohne Klang: Beim Nachreichen eines ganzen Postfachs wäre das ein Trommelfeuer.

### Geprüft

`tests/smoke.lua` spielt den Round-Trip zwischen zwei Clients durch — senden, Postfach leeren, dieselben Pakete einspielen: Wortlaut, Herkunftskanal und `unread` kommen an, der Verlauf bleibt bei einer Nachricht. Dazu ein Text über der Paketgrenze (die Stückelung läuft wirklich, und der Text kommt unverändert an), die Sperren gegen Ignorierte und den eigenen Charakter, die Anfrage-Antwort per Flüstern, dass man die eigene Anfrage nicht selbst beantwortet — und dass eine Antwort **kein** Paket erzeugt. Gegenprobe gegen die Fassung ohne Sync: schlägt fehl.

## 0.9.131 – Die Reihenfolge verrät, wer sucht

Aus dem Spiel gemeldet, mit Screenshot aus dem SucheNachGruppe-Kanal:

> ENH sucht Anschluss an Gilde zum Raiden, hc inis und alles was so dazu gehört^^

Nicht im Postfach. Kein Fehler im Erfassungsweg — über denselben Kanal lag ein Hexenmeister mit „Suche eine Gilde" ordentlich drin. Es lag an der Wendungsliste: Sie kannte nur die **Ich-Form**.

```
suche eine gilde · suche gilde · gilde gesucht · gildensuche · lf guild · looking for (a) guild
```

Die Nachricht steht in der **Er-Form** — „sucht **Anschluss an** Gilde". Verglichen wird auf zusammenhängende Zeichenketten, und „suche gilde" steht dort nicht, weil „Anschluss an" dazwischenliegt. Gegen die Vorgabe gemessen fielen außerdem durch: „Enhancer sucht Gilde", „Sucht eine Gilde für Kara", „Hunter sucht raidende Gilde", „Suche Anschluss an eine Gilde". Die dritte Person fehlte komplett — eine der häufigsten Formulierungen im Kanal überhaupt.

### Warum nicht einfach „gilde" als Trigger

Weil das gemessen die schlechteste Lösung ist. Mit „gilde" als Trigger gegen fünf typische Gildenwerbungen:

| Nachricht | mit Trigger „gilde" |
| --- | --- |
| Gilde sucht noch aktive Raider für SSC | ❌ im Postfach |
| Unsere Gilde sucht dich! Meldet euch bei mir | ❌ im Postfach |
| Raidgilde sucht Verstärkung, Invite über /w | ❌ im Postfach |
| Wir sind eine neue Gilde und suchen Mitglieder | ❌ im Postfach |

Vier von fünf. Das sind Konkurrenten, keine Bewerber, und sie kommen im Minutentakt — genau der „Müll aus dem ganzen Realm", vor dem der Kommentar über der Wendungsliste seit jeher warnt. Jede fehlende Wendung einzeln nachzutragen ist dagegen ein Spiel ohne Ende.

### Die Reihenfolge ist das Unterscheidungsmerkmal

Beide Fälle benutzen dieselben Wörter. Was sie trennt, ist die Stellung:

```
Bewerber:   "ENH   sucht  Anschluss an  GILDE"     Suchwort zuerst
Werbung:    "GILDE sucht  noch aktive Raider"      Gildenwort zuerst
```

Das ist keine Heuristik über Wortfelder, sondern die Satzstellung selbst, und sie hält im Deutschen wie im Englischen. Umgesetzt als `LooksLikeGuildSeeker` in `Chat.lua`, die Wortlisten in `Constants.lua`.

Drei Feinheiten, alle aus dem Testbestand entstanden:

- **Die passive Form fällt nebenbei richtig heraus.** In „Raider für unsere Gilde gesucht" steht „gilde" vor dem „sucht" in „ge**sucht**" — also Werbung, und das stimmt. Es brauchte dafür keine eigene Regel.
- **Deutsche Verbstellung.** „Möchte einer **Gilde beitreten**" setzt das Verb hinter das Objekt; die Reihenfolgeregel hätte daraus Werbung gemacht. `anschluss`, `beitreten`, `aufnahme`, `aufgenommen` gelten deshalb unabhängig von der Stellung — eine werbende Gilde sagt über sich selbst nicht „wir suchen Anschluss".
- **Werbemerkmale schlagen die Reihenfolge.** „<Nachtwache> sucht dich! Wir sind eine Gilde für entspanntes Raiden" sieht der Stellung nach wie ein Bewerber aus. `sucht dich`, `wir suchen`, `wir sind eine`, `verstärkung`, `rekrutier`, `unsere gilde` und ein Dutzend weitere heben das auf. Aufgenommen wurde nur, was eindeutig ist: `sucht noch` steht bewusst **nicht** dabei, sonst wäre „ENH sucht noch eine Gilde" verloren.

Ein Nebeneffekt der Werbemerkmale: Sie räumen eine alte Schwäche der **Vorgabe** mit weg. „Raider für unsere Gilde gesucht" enthält die Vorgabewendung „gilde gesucht" und kam bis hierher herein; jetzt sticht `unsere gilde` sie aus.

### Was unangetastet bleibt

Die eigene Wendungsliste ist eine **Zusage** und steht deshalb vor jeder Eigenintelligenz: Was der Nutzer selbst einträgt, wird erfasst, ohne Wenn und Aber — auch „wts adamantiterz", wenn er das so will. Ausschlusswörter schlagen weiterhin alles, auch die freie Erkennung.

Und die freie Erkennung bekam einen **eigenen Schalter** (`smartRecruitmentDetection`, ab Werk an). Das war keine Vorsicht, sondern die Folge eines Tests, der sofort ansprang: Ein bestehender Fall sicherte die Zusage „deine eigene Liste ERSETZT die Vorgabe" — mit immer laufender Freierkennung galt sie nicht mehr. Zwei verschiedene Versprechen gehören an zwei Schalter. Der bestehende entscheidet **ob** öffentliche Kanäle mitgelesen werden, der neue **wie genau** hingesehen wird; ohne den ersten wird der zweite abgeblendet.

### Kanäle

Geprüft, weil danach gefragt wurde: Es gibt **keinen** Kanalfilter. `CHAT_MSG_CHANNEL` wird für jeden Kanal ausgewertet, dem der Spieler beigetreten ist — SucheNachGruppe, Allgemein, Handel, Gildenrekrutierung inbegriffen. Der Herkunftskanal wird am Eintrag vermerkt (`source`). Das war schon vorher so, stand aber nirgends; jetzt steht es in der README.

### Gemessen statt vermutet

Der Regressionstest in `tests/smoke.lua` führt 32 echte Kanalzeilen in drei Gruppen: 15 Bewerber, 11 Gildenwerbungen, 6 Zeilen sonstiger Kanalverkehr („LF TANK MARAUDON", „WTS Adamantiterz 5g das Stück"). Alle 32 werden richtig eingeordnet. Er läuft gegen die **Vorgabe**, nicht gegen eine eigene Liste — sonst prüfte er die Einstellung des Entwicklers statt das ausgelieferte Verhalten. Dazu der ganze Weg vom Kanalereignis bis zum Eintrag im Postfach, die Zusage der eigenen Liste, und dass ein Ausschlusswort die freie Erkennung stoppt.

## 0.9.130 – Zwei Fassungen, ein Testweg

Diese Version räumt auf: eine Funktion, die nie eine war, wird ganz entfernt; das veröffentlichte Paket wird zu dem, was es sein muss; und die Tests werden zu etwas, das man mit einem Befehl ausführen kann.

### Der Gildenausschluss ist raus – ganz

0.9.124 bis 0.9.129 haben an einer verschlossenen Tür gerüttelt. `GuildUninvite` ist `#protected`, ein Addon kommt nicht daran vorbei. Was in 0.9.129 blieb, war ein Knopf „In WoW entfernen", der den Spieler in Blizzards Gildenfenster auswählte und es öffnete.

Owner-Entscheidung: weg damit. Ein Knopf, der aussieht wie eine Funktion und keine ist, kostet mehr, als er einbringt – er wird gesucht, gedrückt, gemeldet.

Entfallen sind damit:

- `Roster:OpenGuildRemoval`, `Roster:CanRemoveMember`, `Roster:CanRemoveFromGuild` und der lokale Helfer `HasBlizzardRemovePermission`;
- das Feld `rosterIndex` am Mitglied – es existierte ausschließlich für `SetGuildRosterSelection`;
- die Locale-Einträge zu „In WoW entfernen", „Entfernen nicht möglich: " und dem ausgegrauten Knopf;
- die zugehörigen Testblöcke in `tests/smoke.lua` und die Regeln in `tests/validate.mjs`, die auf ihre *Anwesenheit* prüften.

`CanAccessMemberCare` bleibt unverändert: An ihr hängen die Sitzungssteuerung des Raidmonitors und die Auftragsverwaltung, sie hat mit dem Ausschluss nichts zu tun.

Statt der alten Regeln steht in `tests/validate.mjs` jetzt die umgekehrte Prüfung – eine Liste verbotener Bezeichner (`GuildUninvite`, `C_GuildInfo.Uninvite`, `SetGuildRosterSelection`, `OpenGuildRemoval`, `CanRemoveMember`, `CanRemoveFromGuild`), gesucht im Addoncode ohne Kommentarzeilen. Kommentare dürfen die Namen nennen; dort steht die Begründung. Dazu kommt in `tests/smoke.lua` eine Stolperdraht-Fassung von `GuildUninvite`: Sie vermerkt jeden Aufruf, und der Lauf beanstandet ihn am Ende. Ein `error()` an der Stelle würde in einem `pcall` des Addons verschwinden.

**Was die Mitgliederpflege behält:** die Vorschlagsliste, die Prüfregeln, die Rangschutzliste – und den Knopf „Ausnahme". Der legt einen Vermerk in der Addon-Datenbank ab und teilt ihn gildenweit; er ist die einzige Aktion auf der Karte, die tatsächlich etwas bewirkt.

### Das CurseForge-Paket wird Standalone

CurseForge nimmt keine Archive mit ausführbaren Dateien an. Der Companion besteht aus einer `.cmd` und einer `.mjs`, der Installer aus einer `.exe`. Beides war ohnehin schon draußen bzw. nie drin – aber `WarcraftLogs.lua` war drin, und der Import dort braucht genau diese Helfer. Übrig blieb eine Seite, die zum Einfügen von etwas auffordert, das sich der Nutzer nirgends holen kann.

**Die Entscheidung:** Das Repository und die lokale Entwicklungsinstallation bleiben vollständig. Reduziert wird ausschließlich beim Paketbau.

Umgesetzt in `tools/curseforge-package.mjs` – der einzigen Stelle, die weiß, was ins Paket gehört:

- kopiert wird erst der ganze Ordner, dann wird weggenommen (`Companion/`, `WarcraftLogs.lua`). Andersherum – eine Auswahlliste beim Kopieren – vergisst man beim nächsten neuen Ordner;
- die reduzierte TOC wird aus der echten **abgeleitet**, nicht danebengelegt. Eine zweite gepflegte TOC-Datei wäre genau so lange richtig, bis jemand eine Lua-Datei hinzufügt und nur eine der beiden anfasst – und der Fehler fiele erst im Spiel auf;
- das Archiv baut JSZip mit festem Zeitstempel: zweimal bauen ergibt zweimal dieselben Bytes.

**Die Oberfläche wird optional.** In `UI.lua` trägt der Navigationspunkt jetzt ein Feld `requires = "WarcraftLogs"`. Die Punkte werden vor dem Zeichnen gefiltert; fehlt das Modul, entsteht weder der Reiter noch die Seite dahinter – Seiten werden in derselben Schleife angelegt. Dazu drei Absicherungen:

- `BuildWarcraftLogsPage` und `RefreshWarcraftLogs` steigen still aus, wenn Seite oder Modul fehlen;
- `SetLeadProfileLinks` (Profil-Links im Postfach) greift nicht mehr hart auf `GC.WarcraftLogs` zu – die Felder bleiben leer, der Hinweis darunter erklärt es;
- `ShowPage` weicht auf `ROSTER` aus, wenn die verlangte Seite nicht existiert. Ohne diesen Rückfall würde die Seitenschleife alles verstecken und nichts zeigen: ein leeres Fenster ohne Fehlermeldung.

`Sync.lua` musste nicht angefasst werden – dort war jeder `GC.WarcraftLogs`-Zugriff bereits geprüft. Wichtig fürs Schneeballprinzip: Die Gildenquelle von Warcraft Logs fährt in der Gildenprofil-Nutzlast mit und wird aus der **Datenbank** gelesen, nicht aus dem Modul. Ein Client ohne das Modul reicht sie also weiterhin unverändert weiter. Gespeicherte `warcraftLogs`-Zweige bleiben liegen; eine Migration gibt es bewusst nicht.

### Der Test, der am Sekundenzeiger hing

`tests/smoke.lua` prüfte, dass keine privaten Bestände ein Gildenbank-Paket verlassen – durch eine Textsuche nach `114` (der private Gesamtbestand: 5 Taschen + 9 Bank + 100 Twink) im **ganzen** Paket.

Ein Gildenbank-Paket trägt aber noch ganz andere Ziffern: einen Token aus Zeitstempel und Zufallszahl, den Änderungszeitpunkt des Tabs, einen Fingerabdruck. `1541146` enthält `114`. Der Test hätte jederzeit anschlagen können, ohne dass ein Byte privater Daten das Haus verlässt – und wer ihn dann „repariert", indem er die Zahl lockert, hat die Prüfung abgeschafft.

Jetzt wird das Paket mit `Util.SplitFields` zerlegt – demselben Splitter, den das Addon benutzt – und nur Feld 12 eines `BT`-Pakets geprüft, die Nutzlast. Sie wird je Token wieder zusammengesetzt (ein Tab geht als Folge von Teilstücken raus) und mit `DecodeCounts` decodiert. Geprüft wird dann doppelt: Die Nutzlast muss genau dem gespeicherten Tab entsprechen, den sie zu tragen behauptet, **und** keine rein private Menge darf darin vorkommen.

Dazu zwei Gegenproben im Test selbst: eine mit `114` in Zeitstempel, Tabname, Einleser und Fingerabdruck – die darf nicht anschlagen; und eine mit dem privaten Gesamtbestand wirklich in der Nutzlast – die muss anschlagen. Ohne die zweite wäre nicht zu unterscheiden, ob die Prüfung schweigt oder schläft.

### `GC.Perf:Measure` verändert nichts mehr

`/gcp debug` soll beobachten, nicht eingreifen. Die Messung reichte die Rückgabe der gemessenen Funktion über `{ fn(...) }` durch und packte sie mit `unpack(results)` wieder aus – also über `#results`.

`#` ist keine Antwort auf „wie viele Werte waren es?": `{ 1, 2, nil }` hat die Länge 2, das nachgestellte `nil` geht verloren; bei einer Lücke wie `{ 1, nil, 3 }` darf Lua sich zwischen 1 und 3 frei entscheiden – die Länge einer Tabelle mit Löchern ist ausdrücklich undefiniert. Eingeschaltete Messung, verändertes Ergebnis.

Gezählt wird jetzt mit: ein kleiner `PackResults`-Helfer liefert `select("#", ...)` zusammen mit der Tabelle, ausgepackt wird mit `unpack(results, 1, count)`. `table.pack` gibt es in WoWs Lua 5.1 nicht.

Der Regressionstest prüft sechs Formen – nur `nil`, nachgestelltes `nil`, zwei nachgestellte, eine Lücke in der Mitte, gar keine Rückgabe, `false` gefolgt von `nil` – jeweils mit ein- und ausgeschalteter Messung, und zusätzlich, dass die Argumente vollständig durchgereicht werden. Gegenprobe gegen die alte Fassung: schlägt fehl bei „nur nil".

### Ein Befehl, alle Tests – ohne installiertes Lua

Bisher lautete die Anweisung sinngemäß „installier dir LuaJIT". Das ist keine reproduzierbare Testanweisung, und auf einem CI-Läufer liegt gar nichts.

Jetzt genügt:

```bash
npm ci && npm test
```

`tools/run-tests.mjs` führt fünf Schritte aus und bricht beim ersten Fehler mit Exitcode 1 ab:

1. `tests/validate.mjs` – die statischen Regeln;
2. `tests/companion.mjs` – der Warcraft-Logs-Companion;
3. `tools/release-decision.test.mjs` – die Tag-Entscheidung (siehe unten);
4. `tools/check-package.mjs` – baut Staging und Archiv und prüft **beide** an ihrer tatsächlichen Dateiliste;
5. `tools/run-lua-tests.mjs` – `tests/smoke.lua` und `tests/reduced.lua`.

Die Lua-Tests laufen über **fengari**, eine Lua-Implementierung in JavaScript, festgeschrieben in `package-lock.json`. `node_modules/` und `build/` sind in `.gitignore`.

Zwei Unterschiede zu WoWs Lua 5.1 gleicht der Runner aus: fengari ist 5.3 und kennt `unpack` nur als `table.unpack`; und 5.3 trennt Ganzzahl und Fließkomma, sodass `tostring(1.0)` „1.0" ergäbe statt „1". Beides steht als kurzer Vorspann im Lua-Zustand. Außerdem hat fengari kein `io.open` – die Tests bekommen deshalb eine Lesefunktion `GC_ReadTextFile` gestellt; unter einem echten Lua nehmen sie weiterhin `io.open`.

**Strukturell:** Der Stellvertreter-Vorspann von `tests/smoke.lua` (765 Zeilen WoW-API) steht jetzt in `tests/wow-stubs.lua`, weil `tests/reduced.lua` dieselben braucht. Die zwölf Werte auf oberster Ebene sind dabei global geworden – ein aufrufender Chunk sähe ein `local` von dort aus nicht. Das entlastet nebenbei die Lua-5.1-Grenze von 200 lokalen Variablen, an der `smoke.lua` ohnehin stand.

Dazu geladen wird über `LoadAddonFrom(verzeichnis)`, das die **TOC** liest statt einer zweiten, von Hand gepflegten Dateiliste. Damit lädt derselbe Code auch die reduzierte Fassung, deren TOC eine Datei weniger nennt.

`tests/reduced.lua` prüft am gebauten Staging: dass die TOC keine fehlende Datei nennt, dass `GC.WarcraftLogs` nicht existiert, dass weder Seite noch Navigationspunkt entstehen, dass alle **übrigen** zwölf Punkte da sind, dass `ShowPage("WCL")` ausweicht statt ins Leere zu laufen, dass jede Seite sich aufschlagen lässt, dass der Sync in beide Richtungen arbeitet und dass gespeicherte `warcraftLogs`-Daten einen `Prune()` überleben.

### CI und die Force-Veröffentlichung

**Die Tests laufen jetzt bei jedem Push und jedem Pull Request** (`.github/workflows/tests.yml`), nicht erst unmittelbar vor einer Veröffentlichung. Vorher hingen sie ausschließlich im CurseForge-Workflow, der nur auf `main` und nur bei neuer Version läuft – ein Fehler auf einem Arbeitsbranch fiel damit an der teuersten Stelle auf. Beide Workflows rufen `npm test` auf; eine zweite Testlogik gibt es nicht mehr.

**Der Force-Fehler:** `force=true` durfte trotz vorhandenem Tag hochladen – und der Schritt danach versuchte, denselben Tag noch einmal anzulegen. `git tag` scheitert dann, der Lauf endete rot, **obwohl der Upload geklappt hatte**. Der naheliegende „Fix" wäre `-f` gewesen – und hätte einen bereits veröffentlichten Tag verschoben.

Die Regel lautet jetzt: Ein vorhandener Tag wird nie angefasst. Die Entscheidung steht in `tools/release-decision.mjs` als reine Funktion – kein git, kein Netz, keine Dateien – und wird von `tools/release-decision.test.mjs` in sieben Fällen geprüft, darunter zwei erschöpfende Runden über alle Eingabekombinationen („bei vorhandenem Tag wird nie getaggt", „ohne vollständige Zugangsdaten wird nie veröffentlicht"). Frühere Fassungen dieser Logik standen als Shell-Schnipsel im Workflow und ließen sich nur dadurch testen, dass man veröffentlicht hat.

| Tag steht | force | hochladen | Tag setzen |
| --- | --- | --- | --- |
| nein | – | ja | ja, neu |
| ja | nein | nein | nein |
| ja | ja | ja | **nein – bleibt unverändert** |

Die Zusammenfassung des Laufs sagt entsprechend „neu erstellt und gepusht" oder „bestand bereits und wurde unverändert beibehalten", und sie steht **nach** dem Upload – vorher wäre sie eine Ankündigung, keine Auskunft.

## 0.9.129 – Eine verschlossene Tür, fünf Versionen lang

„Vielleicht gehts auch garnicht mit einem Addon?! Google halt."

Der Owner hatte recht, und die Antwort steht seit Jahren im API-Verzeichnis. `GuildUninvite` trägt dort die Kennzeichnung `#protected`:

> This can only be called from secure code.

Ein Addon kann niemanden aus der Gilde entfernen. Nicht über die API, nicht über den Slash-Befehl, nicht über Blizzards eigenen Dialog per `StaticPopup_Show` – jeder dieser Wege läuft aus tainted Code heraus ins Leere, ohne Rückgabewert und ohne Fehler.

### Was fünf Versionen lang passiert ist

Der Weg hierher (0.9.124 bis 0.9.128) ist eine Kette von Diagnosen, die jede für sich richtig war und keine das Problem löste:

- **0.9.124** – `pcall` meldete Erfolg, wo keiner war. Die Nachprüfung im Roster kam dazu. *Richtig, und die Grundlage für alles Weitere: Ohne sie hätte das Addon bis heute „wurde entfernt" behauptet.*
- **0.9.126** – Die Nachprüfung meldete gar nichts, weil die Zwischenmeldung den einen Rückruf verbrauchte. *Richtig, und der Test hatte es verdeckt, weil Zeitgeber im Harness sofort feuern.*
- **0.9.127** – `/gkick` als besserer Weg, weil Blizzards Befehl den Namen gegen den Roster auflöst. *Der Gedanke stimmt, nur ist der Befehl übersetzt.*
- **0.9.128** – Nicht raten, sondern `SlashCmdList` fragen. *Sauber – und trotzdem wirkungslos, weil der Handler dieselbe geschützte Funktion aufruft.*

Jede Runde hat die Fehlermeldung geschärft und keine hat den Ausschluss näher gebracht. Der Fehler in der Vorgehensweise ist gut erkennbar: Es wurde immer die nächste Ursache gesucht, statt einmal zu prüfen, **ob das Vorhaben überhaupt möglich ist**. Fünf Minuten Nachschlagen hätten vier Versionen gespart.

Bemerkenswert bleibt, dass die Nachprüfung aus 0.9.124 die ganze Zeit die Wahrheit gesagt hat: „steht weiterhin im Gildenroster". Sie war die einzige Komponente, die nie gelogen hat.

### Was jetzt dasteht

Die gesamte Maschinerie ist gelöscht – Namensformen, Slash-Handler, Chat-Eingabezeile, Popup-Bestätigung, Nachprüfung mit Wiederholungen. Übrig bleiben zwei kleine Funktionen:

- `CanRemoveMember` – die Prüfungen, die weiterhin sinnvoll sind: Mitgliederpflege freigeschaltet, echte Blizzard-Berechtigung, niedrigerer Rang, kein geschützter Rang, nicht man selbst.
- `OpenGuildRemoval` – wählt den Spieler über `SetGuildRosterSelection` in Blizzards Gildenroster aus und öffnet das Fenster. Blizzards „Entfernen" bezieht sich immer auf die Auswahl; der Nutzer muss dort niemanden mehr suchen, sondern nur noch klicken und WoWs Rückfrage bestätigen.

Das ist die „Verknüpfung zum echten Kick", nach der der Owner gefragt hat – und sie ist genau so weit belastbar, wie die API es zulässt.

**Die eigene „Sicher?"-Stufe ist ersatzlos entfallen.** WoW fragt selbst nach; eine Rückfrage davor wäre die dritte für eine Sache, die dieses Fenster gar nicht ausführt.

### Zwei Prüfregeln haben sich mitgeändert

`tests/validate.mjs` verlangte `removeArmed` – die zweite Bestätigung. Diese Regel beschrieb einen Zustand, der nicht mehr gilt; sie ist durch zwei neue ersetzt (Ausschluss führt ins Gildenfenster, Mitglied wird dort vorausgewählt).

Die zweite Regel verbot jede Erwähnung von `GuildFrame` – ein Erbe aus der Zeit, als ein Guild-Copilot-Knopf im Blizzard-Gildenfenster klebte und dort Inhalte verdeckte. Das Fenster zu **öffnen** ist etwas anderes und jetzt zwangsläufig; `ToggleGuildFrame` und `ToggleFriendsFrame` sind ausgenommen, verboten bleibt, etwas an dieses Fenster zu hängen.

### Geändert

- `GuildCopilot/Roster.lua`: die Ausschluss-Maschinerie gelöscht, `OpenGuildRemoval` mit Vorauswahl im Blizzard-Roster, `rosterIndex` je Mitglied;
- `GuildCopilot/UI.lua`: ein Klick statt zweier, Knopf „In WoW entfernen", Hinweistext auf der Karte;
- `GuildCopilot/Locales.lua`: zwei englische Entsprechungen;
- `tests/smoke.lua`: Vorauswahl und Öffnen werden geprüft, samt Zusicherung, dass **kein** geschützter Ausschluss mehr versucht und kein Fall als erledigt vermerkt wird; die Attrappen für Popup und Slash-Befehle sind entfallen;
- `tests/validate.mjs`: die beiden oben genannten Regeln;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.129.

Quelle: [warcraft.wiki.gg – API GuildUninvite](https://warcraft.wiki.gg/wiki/API_GuildUninvite)

## 0.9.128 – Der Client sagt selbst, wie er heißt

Der Chat der Vorversion enthielt die Antwort, und zwar in einer Zeile, die auf den ersten Blick nach fremdem Rauschen aussieht:

```
(02:36) Guild Copilot: Noch einmal klicken, um Rhinô endgültig zu entfernen.
(02:36) Gebt '/hilfe' ein, um eine Übersicht über einige Befehle aufzurufen.
(02:36) Guild Copilot: Rhinô wird entfernt – wird gleich geprüft …
(02:36) Guild Copilot: Rhinô steht weiterhin im Gildenroster …
```

Die mittlere Zeile stammt nicht vom Addon. Es ist WoWs Antwort auf einen **unbekannten Befehl** – ausgelöst von genau dem `/gkick`, das 0.9.127 in die Eingabezeile geschrieben hat.

### Slash-Befehle sind übersetzt

Ein deutscher Client kennt `/gkick` nicht. Das war die stillschweigende Annahme hinter 0.9.127, und sie war falsch: Der Befehlsname ist lokalisiert wie jeder andere Text im Spiel. Ein geratener Name bewirkt nichts, ist aber nicht folgenlos – er landet als sichtbare Zeile im Chat jedes Nutzers und erzeugt ein Fehlerbild, das es ohne das Addon nicht gäbe.

Bemerkenswert ist, wo der Hinweis herkam: aus derselben Nachprüfung, die 0.9.124 eingeführt hat. Ohne sie stünde dort weiterhin „wurde entfernt", der Spieler bliebe in der Gilde, und niemand hätte je auf die `/hilfe`-Zeile geschaut.

### Nicht raten, sondern fragen

Der Client führt seine eigenen Befehle in `SlashCmdList`, und zwar unter einem **sprachunabhängigen Schlüssel**. Der Eintrag für den Gildenausschluss ist genau die Funktion, die beim Tippen des Befehls liefe – sie lässt sich direkt aufrufen. Keine Übersetzung, keine Eingabezeile, kein Chatfenster, keine sichtbare Zeile.

Muss es doch über die Eingabezeile gehen, dann ausschließlich mit einer Schreibweise aus den `SLASH_…`-Globalen dieses Clients. Was dort nicht steht, wird nicht getippt. Damit ist der Fehler dieser Version strukturell ausgeschlossen und nicht bloß für Deutsch behoben.

Die Reihenfolge: Blizzards eigene Funktion, dann die Eingabezeile mit der Schreibweise des Clients, dann die API mit Roster- und Kurznamen. Alle Wege enden beim Server; die Nachprüfung im Gildenroster entscheidet wie seit 0.9.124.

### Der Harness sprach Englisch

Der Test aus 0.9.127 prüfte auf `"/gkick Heiler"` – er hat die falsche Annahme mitgetragen, statt sie zu prüfen. Die Attrappe führt jetzt eine `SlashCmdList` samt einer **deutschen** Schreibweise, und geprüft wird:

- Der Ausschluss läuft über Blizzards eigene Funktion, mit dem Kurznamen.
- Getippt wird ausschließlich, was der Client selbst führt.

Die Gegenprobe – ein fest verdrahtetes `/gkick` statt der Client-Globalen – fällt an der zweiten Zusicherung durch, mit genau der Meldung, die das Problem beschreibt.

### Geändert

- `GuildCopilot/Roster.lua`: Aufruf über `SlashCmdList`, Eingabezeile nur mit Schreibweisen aus den `SLASH_…`-Globalen;
- `tests/smoke.lua`: Attrappe von `SlashCmdList` und einer deutschen Befehlsschreibweise, Zusicherung gegen getippte Fantasiebefehle;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.128.

## 0.9.127 – „In Wahrheit muss es nur /gkick ausführen"

Die Nachprüfung aus 0.9.126 hat getan, wofür sie gebaut war: Sie hat geantwortet.

```
Rhinô steht weiterhin im Gildenroster – WoW hat das Entfernen nicht ausgeführt
(versucht als Rhinô, Rhinô-Thunderstrike, Rhinô-Thunderstrike-Thunderstrike).
Prüfe deine Gildenberechtigung.
```

Zwei Erkenntnisse in einer Zeile, und die zweite ist peinlich.

### Der Schnitzer

`Rhinô-Thunderstrike-Thunderstrike`. Die zweite Namensform entstand als `target.name .. "-" .. GetNormalizedRealmName()` – an einem Namen, der den Realm bereits trug. Der dritte Versuch war damit von vornherein sinnlos.

Er ist ersatzlos gestrichen, und zwar nicht repariert: **Der Gildenausschluss braucht keinen Realmanteil.** Eine Gilde steht auf einem Realm; der Kurzname ist eindeutig. Der Owner hat es in einem Halbsatz gesagt – „du brauchst keinen Realm-Namen dazu" –, und er hat recht. Ein Test prüft jetzt, dass keine der versuchten Formen mehr als einen Bindestrich trägt.

### Der eigentliche Hinweis

„In Wahrheit muss es nur `/gkick Rhinô` ausführen, fertig."

Das ist der bessere erste Versuch, und der Grund ist kein Geschmack: `/gkick` läuft durch Blizzards eigenen Befehlszerleger, und der **löst den Namen gegen den Gildenroster auf**, bevor er ihn weiterreicht. Ein roher `GuildUninvite`-Aufruf tut das nicht – er nimmt die Zeichenkette, wie sie kommt. Bei „Rhinô" ist das keine akademische Frage: Ein einziges abweichend kodiertes Zeichen, und die Anfrage läuft ins Leere, ohne Rückgabewert und ohne Fehler. Genau dieses Fehlerbild lag vor.

Der Chatbefehl ist kein geschützter Aufruf und braucht kein Tastendruck-Ereignis. Ausgeführt wird er über die Eingabezeile des Chatfensters (`ChatEdit_SendText`); fehlt sie – Testumgebung, exotische Oberflächen-Addons –, fällt der Ablauf auf die API zurück.

Die Reihenfolge ist jetzt: `/gkick <Kurzname>`, dann die API mit dem Rosternamen, und beim zweiten Anlauf beides noch einmal mit dem Kurznamen. Alle Wege enden beim Server; wer zuerst durchkommt, gewinnt, und die Nachprüfung im Gildenroster entscheidet wie seit 0.9.124.

### Was der Test dazu sagt

Der Harness hat eine Attrappe der Chat-Eingabezeile bekommen, die mitschreibt, was tatsächlich abgeschickt wird. Drei Zusicherungen:

- Der erste Ausschluss geht als `/gkick Heiler` raus – Kurzname, kein Realm.
- Keine der API-Formen trägt mehr als einen Bindestrich.
- Kein Chatbefehl trägt einen Realmanteil.

Die Gegenprobe mit dem Rosternamen statt des Kurznamens fällt an der ersten durch.

### Geändert

- `GuildCopilot/Roster.lua`: `/gkick` als erster Weg, die zusammengebaute Realmform ersatzlos entfernt;
- `tests/smoke.lua`: Attrappe der Chat-Eingabezeile, Zusicherungen für Kurzname und Realmfreiheit;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.127.

## 0.9.126 – Der Test, der den Fehler versteckte

„Nö, kicken hat noch immer nicht funktioniert." Dazu ein Bildschirmfoto, dessen Chatfenster die Antwort schon enthielt:

```
Guild Copilot: Noch einmal klicken, um Rhinô endgültig zu entfernen.
Guild Copilot: Rhinô wird entfernt – wird gleich geprüft
Guild Copilot: Rhinô wird entfernt – wird gleich geprüft
```

Zweimal die Zwischenmeldung, danach **nichts**. Weder „wurde aus der Gilde entfernt" noch „steht weiterhin im Gildenroster". Die Nachprüfung aus 0.9.124 lief also – ihr Ergebnis kam nur nie an.

### Die Sperre fraß das Ergebnis

0.9.124 hatte einen Merker bekommen, damit der Rückruf genau einmal feuert:

```lua
local reported = false
local function Report(ok, message)
    if reported then return ok, message end
    reported = true
    ...
end
```

Richtig gedacht, falsch angewandt: Die Zwischenmeldung lief **mit durch Report**.

```lua
C_Timer.After(REMOVE_VERIFY_DELAY, function() Verify(1) end)
return Report(true, shortName .. " wird entfernt – wird gleich geprüft …")
```

Damit war `reported` gesetzt, bevor die Prüfung überhaupt anlief – und jede spätere Meldung fiel in die Sperre. Die doppelte Chatzeile ist derselbe Fehler von der anderen Seite: Rückruf und Rückgabewert trugen beide denselben Text und schrieben ihn beide in die Statuszeile.

Die Regel ist jetzt hart: **Der Rückruf meldet ausschließlich das geprüfte Ergebnis. Alles, was schon beim Aufruf feststeht, ist Rückgabewert und läuft nicht über `Report`.**

### Warum der Test das nicht gefunden hat

Das ist der lehrreichere Teil. Der Test war da, er prüfte beide Fälle, er war grün — und er konnte den Fehler prinzipiell nicht sehen.

Im Testharness feuern Zeitgeber **sofort**:

```lua
C_Timer = { After = function(delay, callback) ... callback() end }
```

`Verify(1)` lief damit vollständig durch, *bevor* die Funktion ihren Rückgabewert erreichte. Die Reihenfolge war genau umgekehrt zum Spiel: Erst das Ergebnis, dann die Zwischenmeldung — und weil `Report` das Ergebnis zuerst sah, kam es auch an. Im Spiel wartet der Zeitgeber wirklich 2,5 Sekunden, die Zwischenmeldung kommt zuerst, und ab da ist der Kanal zu.

Ein Test, der die Reihenfolge nicht nachstellt, prüft eine andere Funktion als die ausgelieferte. Der Harness kann das längst — `timerDelayThreshold` schiebt Zeitgeber oberhalb einer Schwelle in `pendingTimers`, statt sie zu feuern. Der Ausschlusstest benutzt das jetzt und ruft die wartenden Rückrufe ausdrücklich selbst auf. Dazwischen steht die Zusicherung, die vorher gefehlt hat: **Vor dem Ablaufen der Zeitgeber darf der Rückruf noch nicht gefeuert haben.** Die Gegenprobe mit dem alten Code fällt genau dort durch.

### Und die zweite Namensform

Bleibt die Frage, warum der Ausschluss überhaupt nicht durchging. Eine Ursache lässt sich ohne Blick ins Spiel abräumen: die Namensform. `GetGuildRosterInfo` liefert je nach Realm-Verbund „Name" oder „Name-Realm", und welche Form `GuildUninvite` annimmt, hängt an der Spielfassung. Die falsche Form ist der lautloseste aller Fehler — kein Rückgabewert, kein Lua-Fehler, keine Wirkung.

Versucht werden jetzt beide, aber nicht blind hintereinander: erst die Form aus dem Roster, und erst wenn die Nachprüfung den Spieler weiterhin findet, die andere. Ein doppelter Ausschluss ist dabei unmöglich — beim zweiten Versuch steht der Spieler entweder noch da (dann hat der erste nichts bewirkt), oder die Prüfung ist längst als Erfolg beendet.

Die Fehlermeldung nennt am Ende die versuchten Formen. Sie sind das Einzige, woran sich ein Namensproblem von einem Rechteproblem unterscheiden lässt.

### Geändert

- `GuildCopilot/Roster.lua`: `Report` trägt nur noch das geprüfte Ergebnis, zweite Namensform beim zweiten Anlauf, versuchte Formen in der Fehlermeldung;
- `tests/smoke.lua`: der Ausschlusstest lässt Zeitgeber warten und stellt damit die echte Reihenfolge nach, samt Zusicherung gegen einen zu früh gefeuerten Rückruf;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.126.

## 0.9.125 – Fünf Meldungen aus einer Sitzung

Fünf Punkte in schneller Folge aus dem Spiel, alle aus derselben halben Stunde vor dem Bildschirm. Sie hängen enger zusammen, als sie klingen: Vier davon beschreiben dieselbe überfüllte Zeile, und der fünfte erklärt, warum in dieser Zeile so wenig steht.

### Die Spec, die niemand gemeldet hat

„Das Roster wird quasi nur durch Addon-Nutzer aktuell – kann das Roster selber erkennen anhand von Raidauswertung und Gildenzugehörigkeit, welche Spec das ist?"

Der Befund dahinter steht im Bildschirmfoto: 86 Mitglieder, **2 bekannte Specs**. In der Übersicht stand bei allen anderen nur die Klasse.

Der naheliegende Weg wäre die Raidauswertung: Sie sieht `SPELL_CAST_SUCCESS` samt Zauber-ID für jeden im Kampflog. Daraus ließe sich eine Spec ableiten. Nur taugt das an zwei Stellen nicht. Es erfasst ausschließlich Leute, die **mit einem raiden** – in einer Gilde mit 86 Mitgliedern und einem Stammraid ist das die kleinere Hälfte. Und es bräuchte eine gepflegte Tabelle „Zauber-ID → Spec", deren Einträge einzeln belegt sein müssten; eine falsche ID schreibt eine falsche Spec in eine gildenweit sichtbare Anzeige, die in die Rekrutierungsvorschläge einfließt.

Es geht exakt und ohne jede Tabelle. Der Ausrüstungsabgleich inspiziert ohnehin die halbe Gilde (`GearAudit`, `NotifyInspect`, `INSPECT_READY`), und eine offene Inspektion liefert nicht nur die Ausrüstung, sondern auch den Talentbaum: `GetTalentTabInfo(tab, true)` – dieselbe Funktion, mit der das Addon seit jeher die **eigene** Spec bestimmt, nur mit gesetztem Inspect-Schalter. Kein einziges zusätzliches Paket, kein Raten.

Zwei Vorsichtsmaßnahmen:

- **Unter 20 verteilten Talentpunkten wird nichts gemeldet.** Ein Level-70-Charakter hat rund 60; deutlich weniger heißt, dass die Daten noch nicht da sind. Dann lieber nichts sagen als eine Spec erfinden.
- **Die erkannte Spec ist die schwächste Quelle.** Ein gepflegtes Profil oder ein Warcraft-Logs-Import bleibt stehen. Ein Talentbaum weiß, wie jemand geskillt ist – nicht, ob das sein Main ist und womit er raiden will. Angezeigt wird sie deshalb als „erkannt", ohne das Fragezeichen der unbestätigten Profile: Eine abgeleitete Angabe wird nie bestätigt, „erkannt ?" wäre schlicht falsch.

Gesendet wird sie nicht. Jeder Client inspiziert ohnehin selbst, und eine abgeleitete Angabe hat im gildenweiten Abgleich nichts verloren.

Der Test deckte dabei einen Fehler auf, den ich in derselben Sitzung schon einmal gemacht hatte: Ein Spieler steht in `remoteProfiles` unter zwei Schlüsseln, mit und ohne Realmanteil. Wer nur einen nachsieht, übersieht ein gepflegtes Profil unter dem anderen und legt daneben einen abgeleiteten Eintrag an. Dieselbe Falle wie bei `GetOnlinePeerNames` in 0.9.123.

### Die überfüllte Zeile

Die übrigen vier Meldungen beschreiben dieselbe Ursache aus vier Richtungen:

- „Das Abgeschnittene mag ich auch nicht" – `Lederverarbeitung / Verzauberku…` in der Übersicht, `Main/Twink…` in der Mitgliederpflege.
- „Hier wäre hilfreich, wenn man den Rang des jeweiligen Members sieht."
- „Diese Buttons eher in einem Dropdown machen?!"
- „Bei der Übersicht ‚zuletzt aktive Level-70-Spieler' ist nicht so klar und eindeutig, vielleicht das hervorheben."

**Platz.** In der Mitgliederpflege lagen vier Schaltflächen je Zeile, neun Zeilen – 36 Knöpfe auf einer Karte, die zusammen die halbe Zeilenbreite fraßen. Drei davon stecken jetzt in einem Aufklappmenü, und die Begründung daneben hat 54 Pixel mehr. `CreateChoiceDropdown` hat dafür einen optionalen Höhenparameter bekommen: Die Auswahlfelder der Einstellungen sind 32 Pixel hoch, in einer 27 Pixel hohen Listenzeile ragt das heraus.

**„Entfernen" bleibt ein eigener Knopf.** Es ist die einzige Entscheidung dieser Zeile, die sich nicht zurücknehmen lässt, und sie gehört nicht einen Klick tief in ein Menü, in dem der Zeiger ohnehin gerade steht. Er behält seine zweistufige Bestätigung. Das ist bewusst nicht ganz das, was gewünscht war.

**Die Berufsspalte** ließ sich nicht verbreitern, ohne den Nachbarn Platz zu nehmen – also wurden die Namen gekürzt, und zwar so, wie in WoW ohnehin jeder darüber redet: „Leder", „Verzauberer", „Ingi". Vollständig steht es weiter im Tooltip.

**Der Rang** steht jetzt in beiden Listen. In der Mitgliederpflege ist er nicht Zierde, sondern die Erklärung: Geschützte Ränge erscheinen nie als Vorschlag, und entfernen darf man nur einen niedrigeren Rang. Der Tooltip nennt zusätzlich den genauen Grund, wenn „Entfernen" grau ist.

**Die Sortierung** stand bisher als Nebensatz in einer Zeile mit drei weiteren Bedingungen. Sie steht jetzt hervorgehoben vorn und wiederholt sich in der Spaltenüberschrift „ZULETZT ONLINE". Der ursprünglich gesetzte Pfeil „↓" fiel dem projekteigenen Validator zum Opfer – die WoW-Schrift zeichnet dafür einen leeren Kasten. Ein Wort tut es auch.

### Geändert

- `GuildCopilot/Profile.lua`: `DetectTalentSpecForUnit` liest den Talentbaum eines inspizierten Spielers;
- `GuildCopilot/GearAudit.lua`: der laufende Inspect meldet die Spec mit;
- `GuildCopilot/Roster.lua`: `NoteInspectedSpec` legt sie als schwächste Quelle ab und prüft beide Namensschlüssel;
- `GuildCopilot/UI.lua`: Rangspalten in Übersicht und Mitgliederpflege, Kurzformen der Berufe, Aufklappmenü statt drei Knöpfen, optionale Höhe für `CreateChoiceDropdown`, hervorgehobene Sortierung, Grund im Tooltip;
- `GuildCopilot/Locales.lua`: die neuen englischen Entsprechungen;
- `tests/smoke.lua`: erkannte Spec wird abgelegt, weicht gepflegten Profilen unter beiden Schlüsseln und rührt den eigenen Charakter nicht an;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.125.

## 0.9.124 – Ein Erfolg, der keiner war

Aus dem Spiel: „Bei der Mitgliederpflege hat das aus der Gilde Kicken nicht funktioniert – er ist zwar aus der Mitgliederpflege geflogen, aber durch Entfernen aus der Gilde hat es nicht funktioniert."

### Eine Zeile, zwei falsche Schlüsse

```lua
local success = pcall(removeFunction, target.name)
if not success then
    return false, "WoW hat das Entfernen abgelehnt."
end
self:SetMemberCareDecision(target.name, "DONE")
return true, GC.Util.PlayerShortName(target.name) .. " wurde aus der Gilde entfernt."
```

`pcall` beantwortet genau eine Frage: Hat der Aufruf einen **Lua-Fehler** geworfen? Er sagt nichts darüber, ob er etwas bewirkt hat. `GuildUninvite` gibt nichts zurück und wirft nichts, wenn der Server ablehnt – fehlende Gildenberechtigung, unpassende Namensschreibweise, der Spieler ist gar nicht mehr in der Gilde. In all diesen Fällen ist `success` trotzdem `true`.

Daraus folgten zwei Behauptungen, die beide falsch sein konnten: die Meldung „wurde aus der Gilde entfernt" und – schlimmer – der Vermerk `DONE`. Der Fall verschwand aus der Mitgliederpflege, also aus dem Blickfeld. Der Spieler blieb in der Gilde. Genau so geschildert.

Das ist die unangenehmste Sorte Fehler: Er räumt die Anzeige auf, die ihn aufdecken würde.

### Beantwortet wird die Frage jetzt dort, wo sie beantwortbar ist

Nicht am Rückgabewert – den gibt es nicht –, sondern am **Gildenroster**. `RemoveMember` stößt den Ausschluss an und sieht danach nach: Ist der Spieler nach dem nächsten Einlesen weg, hat es geklappt; steht er noch da, hat es das nicht.

Dass das nicht sofort geht, liegt in der Sache: `GuildUninvite` schickt eine Bitte an den Server, und das Ergebnis kommt erst mit dem nächsten `GUILD_ROSTER_UPDATE`. Nachgesehen wird deshalb bis zu dreimal im Abstand von 2,5 Sekunden. Die Oberfläche meldet sich zweimal – erst „wird entfernt, wird gleich geprüft …", dann das, was der Roster sagt.

Der Vermerk `DONE` fällt jetzt **nur im Erfolgsfall**. Ein Fall, der nicht durchging, bleibt offen. Das ist der eigentliche Punkt: Eine Mitgliederpflege, die Fälle wegräumt, ohne dass etwas passiert ist, ist schlechter als gar keine.

### Und der ausgegraute Knopf

Der Knopf war schon immer an `CanRemoveMember` gekoppelt und damit korrekt ausgegraut, wenn WoW das Recht nicht hergibt. Nur sagte er nicht, warum – und ein ausgegrauter Knopf ohne Begründung ist eine Sackgasse. `Roster:CanRemoveFromGuild()` beantwortet die Frage jetzt ohne Bezug auf ein Ziel, und die Mitgliederpflege schreibt sie als Hinweis unter die Vorschläge. Kein Addon kann dieses Recht ersetzen, auch keine Rangfreigabe im Gildenprofil; das gehört an die Oberfläche und nicht in den Fehlerbericht des Nutzers.

### Der Test, der es nachstellt

Der Testaufbau beantwortet beide Fälle mit demselben Aufruf:

- **Server lehnt ab** – die Roster-Attrappe nennt den Spieler weiter. Erwartet: Fehlschlag, Meldung mit „weiterhin", **kein** `DONE`.
- **Server führt aus** – die Attrappe streicht ihn beim Ausschluss aus dem Roster. Erwartet: Erfolg und `DONE`.

Die Gegenprobe mit dem alten Code fällt im ersten Fall durch, und zwar genau an der Stelle, an der das Addon vorher Erfolg behauptet hat.

### Geändert

- `GuildCopilot/Roster.lua`: `RemoveMember` prüft den Ausschluss im Roster nach und meldet ihn über einen Rückruf, `CanRemoveFromGuild` als eigene Frage;
- `GuildCopilot/UI.lua`: die Mitgliederpflege zeigt das geprüfte Ergebnis und erklärt den ausgegrauten Knopf;
- `GuildCopilot/Locales.lua`: eine englische Entsprechung;
- `tests/smoke.lua`: abgelehnter und ausgeführter Ausschluss, beide mit ihrem Vermerk;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.124.

### Offen aus derselben Sitzung

Vom Owner gemeldet, noch nicht umgesetzt: der Gildenrang je Mitglied in Mitgliederpflege und Übersicht, abgeschnittene Texte in der Berufs- und Begründungsspalte, die vier Zeilenknöpfe der Mitgliederpflege als Aufklappmenü, die Hervorhebung der Überschrift „zuletzt aktive Level-70-Spieler" und die Frage, ob sich die Spec eines Mitglieds ohne Addon aus Raidauswertung und Gildendaten ableiten lässt.

## 0.9.123 – Was der eigene Datenbestand verriet

Nach 0.9.122 kam vom Owner die richtige Frage: „Wenn er geupdatet hat, soll es funktionieren? Warum?" Und dann der Satz, der die ganze bisherige Analyse umwarf: „Und mit dem in der anderen Gilde, nicht in Aftermath."

### Die falsche Gilde vermessen

Die Messung aus 0.9.122 – 852 Zeichen, fünf Pakete – galt **Aftermath**. Die betroffene Gilde ist eine andere. Der Blick in die SavedVariables, diesmal über alle drei Zweige:

| Gilde | Nutzlast | Pakete | `editorRanks` | Addon-Nutzer |
|---|---|---|---|---|
| `UNGUILDED@Thunderstrike` | 282 | 2 | – | 0 |
| `Aftermath@Thunderstrike` | 852 | 5 | `[0,1]` | 34 (0.9.3 bis 0.9.118) |
| `Capsule Corp@Thunderstrike` | 510 | 3 | `[0,1,2,3,4,5,6]` | 1 (Joringoh/0.9.120) |

Damit steht zweierlei fest. Erstens: Die Freigabe **ist** gesetzt, alle sieben Ränge, in Capsule Corp. Zweitens: Dort ist genau ein anderer Addon-Nutzer bekannt – der Kollege. Die Diagnose aus 0.9.122 bleibt gültig, denn drei Pakete ohne Quittung sind genauso alles-oder-nichts wie fünf.

Aber dieselbe Ausgabe zeigte etwas, womit nicht zu rechnen war.

### Der eigene Fehler aus 0.9.120

```
Strybank-Thunderstrike   guildKey=
```

Ein leerer Vermerk am eingeloggten Charakter. Der Gildenvermerk aus 0.9.120 sah so aus:

```lua
if GC:GetGuildName() ~= "" then
    profile.guildKey = GC:GetGuildKey()
elseif type(IsInGuild) == "function" and IsInGuild() == false then
    profile.guildKey = ""
end
```

Der zweite Zweig ist falsch, und zwar aus demselben Grund, aus dem der erste vorsichtig ist: **Direkt nach dem Anmelden weiß der Client seinen Gildenzustand noch nicht.** `GetGuildInfo` liefert dann nichts – daran war gedacht –, aber `IsInGuild()` antwortet in diesem Fenster ebenfalls mit „nein", und daran war nicht gedacht. `Profile:Get` läuft in genau dieser Zeit mehrfach: `Workshop:GetOwnData` und `Profile:Refresh` hängen beide am `PLAYER_LOGIN`.

Das Ergebnis war ein Gildenmitglied mit dem Vermerk „gildenlos". Und dieser Vermerk ist nicht folgenlos – er entscheidet in 0.9.120 zwei Dinge mit:

- `GetPublishableProfessions` hält den Charakter zurück (harmlos, eine Lücke);
- `PruneDepartedCrafters` zählt ihn zu den *fremden* Charakteren und **löscht seinen Bestand aus dem Gildenkatalog** (nicht harmlos).

Der eingeloggte Charakter war gegen das Löschen ausdrücklich geschützt. Ein Twink mit falschem Vermerk war es nicht.

Zwei Änderungen, an beiden Enden:

- **Geschrieben wird erst, wenn der Client es weiß.** `PLAYER_GUILD_UPDATE` ist genau dieses Signal; es setzt `GC.guildStateKnown`, und ohne das schreibt `StampGuildKey` gar nichts. Ein Vermerk, der nur vielleicht stimmt, ist schlimmer als keiner.
- **Ein leerer Vermerk löscht nichts.** Nur ein *namentlich anderer* Gildenschlüssel gilt beim Aufräumen als Beleg für „steht woanders". Zurückhalten reicht in jedem Zweifelsfall: Eine Lücke heilt beim nächsten Einloggen von selbst, ein gelöschter Bestand nicht.

### Warum der gezielte Versand die Fähigkeit abfragt

In Aftermath stehen 34 Addon-Nutzer, von 0.9.3 bis 0.9.118. Keiner von ihnen versteht ein geflüstertes Gildenprofil, keiner würde quittieren. Hätte 0.9.122 sie mit angeschrieben, wären für jeden acht vergebliche Versuche gelaufen, und der Knopf hätte am Ende „angekommen bei 1 von 8" gemeldet – ein Fehlschlag, den es nie gab.

Der Handschlag trägt für solche Fälle längst eine Fähigkeitsliste (`GC.Capabilities`). Neu darin: `guildprofile2`. Gezielt gesendet wird nur an einen Empfänger, der sie meldet; alle anderen bekommen den Rundruf wie bisher, und die Oberfläche sagt, wie viele das waren.

### Ein Zufallsfehler, den erst der Test sichtbar machte

`GetOnlinePeerNames` fragte die Fähigkeit am jeweiligen Eintrag ab – und derselbe Spieler steht in `addonUsers` unter zwei Schlüsseln, mit und ohne Realmanteil. Das sind nicht immer zwei Verweise auf dieselbe Tabelle: Wer einmal so und einmal so gemeldet wurde, hat dort zwei echte Einträge, und nur einer trägt womöglich die Fähigkeitsliste. Welcher gewann, entschied `pairs` – also der Zufall.

Aufgefallen ist es, weil derselbe Test einmal durchlief und beim nächsten Lauf nicht. Gesammelt wird jetzt erst je Spieler, entschieden danach: Gilt eine Fähigkeit an einem seiner Einträge, gilt sie für ihn. Fünf Läufe hintereinander grün.

### Geändert

- `GuildCopilot/Profile.lua`: `StampGuildKey` schreibt „gildenlos" erst bei bekanntem Gildenzustand;
- `GuildCopilot/Core.lua`: `GC.guildStateKnown` am `PLAYER_GUILD_UPDATE`;
- `GuildCopilot/Workshop.lua`: ein leerer Gildenvermerk gilt beim Aufräumen nicht mehr als fremde Gilde;
- `GuildCopilot/Sync.lua`: `HasCapability`, Fähigkeitsprüfung und Sammeln je Spieler in `GetOnlinePeerNames`, veraltete Nutzer werden gezählt statt angeschrieben;
- `GuildCopilot/Constants.lua`: Fähigkeit `guildprofile2`;
- `GuildCopilot/UI.lua`, `Locales.lua`: eigene Meldung für „online, aber ältere Fassung";
- `tests/smoke.lua`: unbekannter Gildenzustand schreibt nichts, leerer Vermerk löscht nichts, veraltete Nutzer werden gezählt statt angeschrieben;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.123.

## 0.9.122 – Der einzige Transfer ohne Quittung

Aus dem Spiel, mit Bildschirmfoto von beiden Seiten: „Ich bin in seiner Gilde Social und habe die Rechte freigegeben, bei ihm kommen die aber nicht an." Und kurz darauf: „Auf jeden Fall kommen die Rechte bei ihm nicht an, warum auch immer."

### Was die Bildschirmfotos verraten

Beim Kollegen standen in **allen drei** Rangkarten genau die Auslieferungswerte: „Gildenweite Einstellungen bearbeiten" und „Mitgliederpflege öffnen" jeweils nur Guild Master und GM Twink (`rankIndex <= 1`, die Vorgabe für `configured == false`), und „Aktive Raider" alle sieben Ränge – ebenfalls die Vorgabe, wenn `rankFilterConfigured` nicht gesetzt ist.

Das ist der entscheidende Hinweis, und er schließt einen halb angekommenen Stand aus: Sein Client hatte **noch nie ein einziges Gildenprofil-Paket verarbeitet**. Zum Vergleich der Stand des Owners aus denselben SavedVariables – `activeRaiderRanks = {0,1,2,3,6}`, `memberCare.accessRanks` mit `["3"] = false`, ein vollständig gepflegtes Profil mit Raidzeiten, Loot Council und Discord. Empfangen funktioniert bei ihm also; beim Kollegen kam nichts an.

### Drei Vermutungen, drei Fehlschläge

Der Reihe nach geprüft und jede einzelne widerlegt:

- **Zu viele Pakete?** Die echte Nutzlast dieser Gilde, mit den echten SavedVariables durch `BuildGuildProfilePayload` gemessen: 852 Zeichen, fünf Pakete, 2,3 Sekunden Sendedauer. Von der Obergrenze (26.250) meilenweit entfernt.
- **Die Antwortwahl?** `CollectResponderKeys` sammelt ausdrücklich nur Addon-Nutzer, die laut Roster **online** sind. Ein Gewählter, der offline ist, kommt gar nicht erst vor.
- **Versionsunterschied?** Beide Kopfzeilen zeigen v0.9.120, seine sogar ausdrücklich „gleiche Version".

### Was übrig blieb

Übrig blieb die Eigenschaft, die dieser Transfer als einziger im Addon hat: **er wird nicht quittiert.**

`SendGuildProfile` schickt seine Pakete mit `Send()` in den Gildenkanal, im Abstand von 0,45 Sekunden, und das war es. Keine Bestätigung, keine Wiederholung, kein Rückkanal. Auf der Empfangsseite steht in `ReceiveGuildProfileChunk` diese Schleife:

```lua
for chunkIndex = 1, total do
    if incoming.chunks[chunkIndex] == nil then
        return
    end
```

**Ein einziges fehlendes Teil, und die ganze Übertragung wird verworfen** – stillschweigend, und nach fünf Minuten räumt `PruneIncoming` den Rest weg. Der Gildenkanal verliert Pakete: Der eingebaute Ratenbegrenzer des Clients weist Nachrichten zurück, wenn mehrere Addons gleichzeitig senden, und zur Anmeldezeit tut das jeder Client der Gilde. Die Kopfzeile des Owners sagte im selben Bildschirmfoto „Abgleich unvollständig" – in dieser Gilde gingen nachweislich Pakete verloren.

Warum es den einen trifft und den anderen nicht, ist damit auch keine Frage mehr: Es ist Zufall, und wen es trifft, den trifft es **jedes Mal vollständig**. Fünf Pakete, von denen eines fehlt, sind null Rechte.

Das Addon hat für genau dieses Problem längst eine Lösung – `QueueReliable`: Fluster-Transfer, jedes Teil wird mit `A|`-Paketen quittiert, Unquittiertes läuft mit wachsendem Abstand bis zu acht Mal erneut an, am Ende steht ein Erfolgs- oder ein Fehlschlag-Rückruf. Werkstatt (`W`) und Warcraft Logs (`L`) benutzen ihn seit Langem. Das Gildenprofil war der letzte Transfer ohne ihn – ausgerechnet der, bei dem ein Ausfall Rechte kostet.

### Beide Wege, nicht einer statt des anderen

`Sync:PushGuildProfile` schickt jetzt beides:

- den **Rundruf** wie bisher – er erreicht auch die, von denen dieser Client noch gar nichts weiß;
- zusätzlich den **quittierten Fluster-Transfer** an jeden bekannten Addon-Nutzer, der laut Roster gerade online ist.

Der Rundruf bleibt, weil er das Einzige ist, was einen unbekannten Client erreicht. Der quittierte Weg kommt dazu, weil nur er eine Antwort auf „ist es angekommen?" hat.

Quittiert wird **sofort und je Teil**, noch vor jeder Prüfung: Die Bestätigung sagt „angekommen", nicht „gefiel mir". Ein Teil, das erst nach dem Zeitstempelvergleich quittiert würde, liefe beim Absender ewig als verloren, obwohl der Empfänger es längst hat und bloß einen neueren Stand behält.

Zwei Details aus der Umsetzung:

- `GetOnlinePeerNames` zählt je **Spieler**, nicht je Tabelleneintrag. Derselbe Charakter steht in `addonUsers` unter zwei Schlüsseln, und das sind nicht immer zwei Verweise auf dieselbe Tabelle – wer einmal mit und einmal ohne Realmanteil gemeldet wurde, hat dort zwei echte Einträge. Ein Vergleich auf Tabellengleichheit hätte denselben Transfer zweimal losgeschickt; im Test ist genau das passiert.
- Der Knopf merkt sich, ob der Rückruf schon gefeuert hat. Bei einem einzigen Empfänger mit sofortiger Quittung ist der Transfer fertig, **bevor** `PushGuildProfile` zurückkehrt – ohne den Merker hätte die Zwischenmeldung „warte auf Bestätigung" das Ergebnis wieder zugeschrieben.

### Und was der Knopf jetzt sagt

Statt „wurde gesendet" – was nie eine Aussage war – steht dort „Rechte bestätigt angekommen bei 2 von 2", oder bei wie vielen eben nicht. Ist niemand mit dem Addon online, sagt er auch das: ohne Empfänger keine Bestätigung, und ein Erfolg wäre gelogen.

### Geändert

- `GuildCopilot/Sync.lua`: `SendGuildProfileTo` (quittierter Einzeltransfer), `GetOnlinePeerNames`, `PushGuildProfile`, `BuildGuildProfileMessages` gibt die Kennung mit heraus, `G|` auch per Flüstern samt Quittung und Mitgliedersperre;
- `GuildCopilot/UI.lua`: der Knopf meldet das Ergebnis statt den Versand;
- `GuildCopilot/Locales.lua`: vier englische Entsprechungen;
- `tests/smoke.lua`: ohne Empfänger keine Erfolgsmeldung, mit Empfänger gezielter Transfer der Art `G`, geflüstertes Teil wird quittiert;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.122.

### Offen

Der Rundruf beim Anmelden (`PrimeGuildProfileSync` → `GQ` → `ReplyToGuildProfileRequest`) läuft weiterhin unquittiert. Er erreicht die Mehrheit und ist billig; ihn ebenfalls auf den bestätigten Weg zu heben hieße, bei jedem Login an jeden einzeln zu senden. Der Knopf deckt den Fall ab, in dem es wirklich darauf ankommt.

## 0.9.121 – Ein Knopf statt eines Slash-Befehls

Nachtrag zu 0.9.120. Dort war der Weg, einem Kollegen ohne anwesenden Offizier Rechte zu geben, in der lokalen Rechte-Überschreibung als Slash-Befehl gelandet. Rückmeldung des Owners: „Kannst du mir statt Slash-Befehlen auch Hardbuttons geben?"

### Die Knöpfe gab es schon

Der Blick in `UI.lua` zeigte, dass die Frage die richtige war und die Antwort schon im Addon stand: Die Einstellungsseite trägt seit Langem vier Rangkarten mit echten Schaltern – „Aktive Raider", „Gildenweite Einstellungen bearbeiten", „Mitgliederpflege öffnen" und „Bewerberton hören". Sie hängen alle an `CanEditGuildProfile()`, und genau diese Prüfung überschreibt die lokale Datei. Für den Owner sind sie also bedienbar; ein Slash-Befehl daneben war eine zweite Bedienoberfläche für dieselbe Sache.

Die Befehle sind deshalb wieder verschwunden. Die Überschreibung tut wieder genau eine Sache – die Schalter für den eigenen Charakter bedienbar machen – und sagt beim Anmelden, wo sie stehen.

### Was wirklich fehlte

Ein Punkt aus den Befehlen hatte kein Gegenstück in der Oberfläche, und er ist der eigentliche Grund, warum beim Kollegen nichts ankam: **das Nachschicken**.

Eine Rangfreigabe geht in dem Moment raus, in dem sie gesetzt wird (`GuildProfilePermissionsChanged` → `QueueGuildProfile(true)`). Der Gildenkanal erreicht nur, wer gerade online ist. Wer den Moment verpasst, fragt beim nächsten Anmelden zwar selbst nach (`PrimeGuildProfileSync` → `GQ`), aber das hilft nur, wenn dann jemand mit dem neueren Stand online ist und antwortet. Bei zwei Leuten in einer frischen Gilde ist der Regelfall genau der andere: Der eine setzt die Rechte, der andere steigt zwei Stunden später ein, wenn der erste längst weg ist.

Der Knopf „Rechte erneut senden" steht in der Karte „Gildenweite Einstellungen bearbeiten", direkt unter den Rangschaltern, und ruft `Sync:SendGuildProfile(true)`. Dieselbe Nutzlast wie bei jeder Änderung, derselbe Zeitstempelvergleich beim Empfänger – ein versehentlicher Druck kann nichts zurückdrehen. Gesperrt ist er, wenn der eigene Rang nicht setzen darf oder gar keine Gilde da ist; ein Knopf, der beim Drücken scheitert, ist schlechter als ein sichtbar gesperrter.

Beide Rangkarten sind dafür von 240 auf 280 Pixel gewachsen – beide, nicht nur die rechte, sonst stünde die linke wie abgeschnitten daneben. Die vier Karten darunter und die Inhaltshöhe sind um 40 Pixel nachgezogen.

### Geändert

- `GuildCopilot/UI.lua`: Knopf `guildProfilePushButton` samt Sperrlogik, Rangkarten auf 280 px, Folgekarten und Inhaltshöhe nachgezogen;
- `GuildCopilot/Locales.lua`: vier englische Entsprechungen;
- `tests/smoke.lua`: der Knopf sendet mit `force`, meldet den Versand und ist ohne Bearbeitungsrecht gesperrt;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.121.

Außerhalb des Repositories: `GuildCopilotLocalRights` ohne Slash-Befehle, mit Hinweis auf die Einstellungsseite.

## 0.9.120 – Zwei Gilden, ein Account – und ein Beitritt, den niemand bemerkte

Aus dem Spiel gemeldet: „Ich bin frisch in eine Gilde gejoint mit einem Char und habe jemandem das Addon weitergereicht, aber der Abgleich findet nicht statt" – und im selben Atemzug der Verdacht: „Will der meine Account-Craft-Daten in eine andere Gilde synchronisieren? Bin mit einem Account in zwei Gilden, das muss das Addon klar trennen."

Zwei Beobachtungen, zwei verschiedene Fehler. Der Verdacht war berechtigt.

### Der Beitritt, der nie ankam

Der gesamte Handschlag des Addons hing am `PLAYER_LOGIN`: Profil bei Sekunde 3, Gildenprofil-Anfrage bei 5, Versionsansage bei 7, Warcraft Logs bei 9, Versionsprüfung bei 12, Gildenaufträge bei 13 und 17, dazu die Werkstatt mit Bestandsanfrage bei 10 und Manifest bei 16. Einmal je Sitzung, fest verdrahtet in zwei `PLAYER_LOGIN`-Rückrufen.

`PLAYER_GUILD_UPDATE` hörten nur zwei Module ab: `Roster` liest den Roster neu, `Profile` seine Berufe. Beides ist sichtbar – der Gildenname stimmt, die Mitgliederliste stimmt, das Fenster sieht vollständig aus. Gesendet und angefordert wurde in der neuen Gilde aber nichts. Wiederkehrende Zeitgeber gibt es im Addon keine (`NewTicker` kommt nirgends vor), also blieb der Client bis zum nächsten `/reload` stumm.

Das ist die unangenehme Sorte Fehler: Er sieht nicht aus wie einer. Wer der Gilde im laufenden Spiel beitritt – und genau so tritt man einer Gilde bei –, hatte ein Addon, das lebendig wirkte und nichts tat.

Die Anlaufsequenz ist jetzt eine eigene Funktion (`Sync:RunStartupSequence`, `Workshop:RunStartupSequence`), und `Core.lua` meldet über den neuen Rückruf `GUILD_CHANGED`, wenn sich der Gildenschlüssel wirklich ändert. Zwei Wachen halten den Rückruf sauber:

- `RefreshGuildKey` meldet nur echte Wechsel. `PLAYER_GUILD_UPDATE` feuert auch bei jeder Rangänderung und mehrfach beim Anmelden; der erste gelesene Schlüssel einer Sitzung gilt ausdrücklich nicht als Wechsel.
- Ein Mindestabstand von 30 Sekunden fängt den einen Fall ab, in dem der Rückruf nicht gemeint ist: Direkt nach dem Anmelden liefert `GetGuildInfo` noch nichts, der Schlüssel springt eine Sekunde später von `UNGUILDED` auf die echte Gilde – und die Sequenz des Logins läuft da ohnehin schon, mit dem richtigen Gildenzweig, weil jeder ihrer Schritte den Schlüssel erst beim Senden liest. Ein echter Beitritt liegt immer weit hinter diesem Fenster.

Die Wartezeit-Erinnerungen der Werkstatt sind bewusst **nicht** Teil der Sequenz: Sie sind rein lokal und haben mit der Gilde nichts zu tun.

### Der Verdacht, der stimmte

Der Gildenzweig war immer sauber getrennt – `GuildCopilotDB.guilds["<Gilde>@<Realm>"]` hält Profil, Rechte, Postfach, Werkstattbestand, Aufträge, Raidabende und Gildenbank je Gilde, und der Gildenkanal des Spiels kann eine andere Gilde technisch gar nicht erreichen.

Die Quelle der Werkstattdaten war es nicht. `Workshop:GetAccountProfessions()` lieferte **jeden** Charakter des Accounts, und `GuildCopilotDB.characters` trug nirgends einen Gildenvermerk – es gab im ganzen Addon kein Feld dafür. Diese Liste ging als Manifest (`KM`) in den Gildenkanal, dazu Schlüssellisten, Rezeptdetails auf Nachfrage, Wartezeiten und die Twink-Regel beim Annehmen von Aufträgen. Wer mit einem Account in zwei Gilden spielt, kündigte damit Name und Rezepte seines Twinks aus Gilde A in Gilde B an.

Gebaut war das als Twink-Komfort – die Gilde soll sehen, dass der Zweitchar Verzauberer ist. Der Entwurf kannte den Fall „Twink ist in einer *anderen* Gilde" schlicht nicht.

Jeder Charakter hinterlässt jetzt beim Einloggen seinen Gildenschlüssel (`Profile.StampGuildKey`). Geschrieben wird nur, was belegt ist: ein bekannter Gildenname ergibt den Schlüssel, ein Client, der ausdrücklich „keine Gilde" sagt, den leeren Vermerk – und alles dazwischen lässt den bestehenden Vermerk stehen. Direkt nach dem Login liefert `GetGuildInfo` noch nichts, obwohl der Charakter in einer Gilde ist; ein falscher Vermerk wäre schlimmer als gar keiner, denn er verursachte genau den Übertritt, den er verhindern soll.

Getrennt wird an einer einzigen Stelle: `GetPublishableProfessions()` liefert den eingeloggten Charakter plus alle Twinks dieser Gilde. Alles, was sendet, fragt jetzt dort – Manifest, Schlüssellisten, Rezeptantworten, Wartezeiten, `Orders:GetOwnCrafters`. Alles, was nur lokal anzeigt oder erinnert, fragt weiterhin `GetAccountProfessions()`: Die eigene Berufsübersicht und die Wartezeit-Erinnerungen gehen alle eigenen Charaktere etwas an, gleich in welcher Gilde sie stehen.

**Ein Charakter ohne Vermerk bleibt draußen.** Das trifft nach dem Update jeden Twink genau so lange, bis er einmal eingeloggt war, und kostet in dieser Zeit einen unvollständigen Gildenkatalog. Die Gegenrichtung wäre, im Zweifel zu senden – und damit genau den Übertritt zu wiederholen. Eine Lücke, die sich von selbst schließt, ist das kleinere Übel als ein Leck, das niemand bemerkt. `Workshop:CountUnassignedCrafters()` sagt, wie viele es gerade sind.

### Die Altlast

Was früher übergetreten ist, steht bereits in fremden Gildenkatalogen. `PruneDepartedCrafters` hielt es dort sogar fest: Eigene Charaktere stehen nicht im Gildenroster und waren deshalb pauschal vom Aufräumen ausgenommen, und auf fremden Clients bürgte `sharedBy` für sie. Die Ausnahme gilt jetzt nur noch für Charaktere, die **wirklich** in dieser Gilde sind; wer nachweislich woanders steht, fliegt raus – auch gegen den Bürgen.

Auf dem eigenen Rechner ist die Altlast damit weg. Auf den Rechnern der anderen Gildenmitglieder läuft sie aus, weil sie nicht mehr aufgefrischt wird (`DB:Prune`, 180 Tage). Ein aktives Zurückziehen bräuchte ein neues Feld im Manifest, damit ein Empfänger ein vollständiges Manifest von einem abgeschnittenen unterscheiden kann – das steht bewusst nicht in dieser Version.

### Rechte für einen Kollegen ohne Offiziersrang

Aus derselben Sitzung: „Wir können darin nicht arbeiten, weil kein Offizier oder Gildenlead da ist." Die Rechte des Addons hängen am **Gildenrang** (`profilePermissions.editorRanks`, `memberCare.accessRanks`), nicht an der Person, und unkonfiguriert gelten nur Rang 0 und 1.

Die lokale Rechte-Überschreibung (`GuildCopilotLocalRights`, außerhalb dieses Repositories) half dabei nicht: Sie hängt sich vor `CanEditGuildProfile` und gibt nur für den **eigenen** Charakter `true` zurück. Der Client des Kollegen fragt seine eigene Kopie und kennt diese Datei nicht.

Nachgemessen im Testharness: Der Weg über die echten Einstellungen trägt bereits. Wer mit Überschreibung einen Rang einträgt, löst `GuildProfilePermissionsChanged` aus; das Gildenprofil geht mit `force` in die Gilde, und der Empfänger nimmt es an, weil es von einem Gildenmitglied kommt und neuer ist – der Rangunabhängigkeit des Abgleichs sei Dank, die seit 0.9.x ausdrücklich so gewollt ist. Sein eigener Rang entscheidet danach, ob er arbeiten darf. Das ist jetzt als Regressionstest festgehalten, damit dieser Weg nicht unbemerkt zuwächst.

Die Überschreibung selbst hat dafür Befehle bekommen (`/gclr` – Rangübersicht, `rang <index>`, `alle`, `push`). Sie bleibt außerhalb des Repositories.

### Geändert

- `GuildCopilot/Core.lua`: `GC:RefreshGuildKey` und der Rückruf `GUILD_CHANGED`, `PLAYER_GUILD_UPDATE` im Kernrahmen;
- `GuildCopilot/Sync.lua`: Anlaufsequenz als `RunStartupSequence`, `GUILD_CHANGED`-Rückruf mit Mindestabstand;
- `GuildCopilot/Workshop.lua`: `GetPublishableProfessions`, `CountUnassignedCrafters`, Werkstatt-Anlaufsequenz, gefilterte Sendepfade, `PruneDepartedCrafters` räumt eigene Charaktere fremder Gilden ab;
- `GuildCopilot/Profile.lua`: `StampGuildKey` schreibt den Gildenvermerk je Charakter;
- `GuildCopilot/Orders.lua`: die Twink-Regel nimmt nur Charaktere dieser Gilde;
- `tests/smoke.lua`: Trennung der Gilden im Manifest und in der Veröffentlichung, Gildenvermerk samt seiner drei Fälle, Gildenbeitritt startet die Anlaufsequenz genau einmal, gildenweite Freischaltung ohne Offiziersrang;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.120.

## 0.9.119 – Ein Fenster, das man im Blick behalten kann

Direkt nach dem Zeilenfehler aus 0.9.118 die nächste Meldung aus dem Spiel: „Jetzt wird mir der Tracker gar nicht mehr angezeigt."

### Es war kein Fehler, und das war das Problem

Der Blick in die gespeicherten Daten des Owners zeigte: `orderTracker.hidden` stand auf `false` – weggeklickt war er nicht. Von 37 gespeicherten Aufträgen lief genau einer, und dessen Lage erklärte alles:

- **11.08. 21:34** – Dæddykuhl stellt „Raketenstiefel Xtrem" ein, Materialmodell C. Der Owner nimmt an; er ist am Zug: „Materialien beschaffen und ‚vollständig' melden." Genau das zeigte das Bildschirmfoto aus 0.9.118.
- **12.08. 14:40** – dieser Auftrag wird abgebrochen.
- Übrig bleibt ein zweiter Auftrag, **Modell A**: Dort liefert der Auftraggeber die Materialien. Am Zug ist also der andere.

Der Tracker zeigte bis dahin ausschließlich „du bist dran"-Zeilen und verbarg sich sonst. Er tat damit genau das, was er sollte – und war trotzdem falsch: Ein Auftrag lief, der Bildschirm war leer, und aus Sicht des Nutzers war das Fenster kaputt.

Das ist die eigentliche Lehre: Ein Fenster, das ohne Zutun kommt und geht, behält niemand im Blick. Es beantwortet die Frage „ist da gerade was?" nur dann, wenn man ihm schon vertraut – und dieses Vertrauen entsteht nicht, solange es unangekündigt verschwindet.

### Was es jetzt zeigt

Owner-Entscheidung: **immer sichtbar**, weg nur über das ×.

- **Deine Aufgaben** oben, unverändert in der gewohnten Farbe, mit der Aufforderung darunter.
- **Wartezeilen** darunter, gedämpft: derselbe Auftrag, aber mit dem Namen dessen, auf den gewartet wird („Wartet auf Buffdæddy."). Ein offener Auftrag ohne Hersteller behält seine eigene Ansage.
- **Fußzeile** für das, was die drei Plätze nicht sagen können: „Zurzeit ist nichts offen." oder „… und 2 weitere.".
- Der **Titel** trägt die Zahl der eigenen Aufgaben („Gildenaufträge – du bist dran (2)") und fällt ohne solche auf „Gildenaufträge" zurück.

Die Sortierung kommt unverändert aus `GetBoard`: „du bist dran" zuerst, danach nach Änderungszeit. Die drei Plätze zeigen damit immer das Dringendste.

Ein Detail aus der Umsetzung: Die Dämpfung der Wartezeilen steht als Farbcode **im Text**, nicht an der Beschriftung. Ein Knopf setzt seine Textfarbe zurück, sobald die Maus ihn wieder verlässt – eine über `SetTextColor` gesetzte Farbe wäre nach dem ersten Überfahren weg gewesen.

**Nebenwirkung, bewusst in Kauf genommen:** Das Fenster erscheint jetzt bei jedem Gildenmitglied nach dem Anmelden, auch bei denen, die nie einen Auftrag haben. Ein × genügt, und es bleibt weg.

### Geändert

- `GuildCopilot/UI.lua`: `RefreshOrderTracker` zeigt alle Zeilen aus `GetBoard().mine`, dazu Fußzeile, Titelzahl und die gedämpfte Wartezeile;
- `GuildCopilot/Locales.lua`: drei neue englische Entsprechungen, der alte Titelschlüssel ohne Zahl entfällt;
- `tests/smoke.lua`: leerer Tracker bleibt stehen und sagt es, Wartezeile trägt Dämpfung und Namen, Titel ohne eigene Aufgabe nennt kein „du bist dran";
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.119.

## 0.9.118 – Zwei Zeilen, die sich nicht in die Quere kommen

Zwei Punkte aus derselben Sitzung: ein Bildschirmfoto vom Auftrags-Tracker, auf dem zwei Zeilen übereinander lagen, und der Wunsch „bau bitte so einen Hinweis auch gleich ein" – gezeigt am Update-Hinweis von Details!.

### Warum die Beschriftung nach unten rutschte

Der Tracker trägt zwei Texte in einem Knopf: den Rezeptnamen oben, die Aufgabe gedämpft darunter. Der Rezeptname ist die Beschriftung des Knopfes selbst, und die legt `CreateButton` auf **die volle Knopfhöhe** an – 40 Pixel bei 40 Pixel Knopf –, senkrecht mittig. Für einen gewöhnlichen Knopf ist das genau richtig.

Oben angeschlagen war sie schon. Nur half das nicht: Der zweite Anker lautete `SetPoint("RIGHT", row, "RIGHT", -8, 0)`, und `RIGHT` legt nicht nur die rechte Kante fest, sondern zugleich die **Mitte** der Beschriftung auf die Mitte des Knopfes. Zwei Anker, zwei Aussagen über die Senkrechte – der Text landete in der Knopfmitte, also genau dort, wo die Aufgabenzeile steht.

Die Beschriftung hat jetzt eine eigene Höhe (16 px), und beide Anker sitzen oben (`TOPLEFT`/`TOPRIGHT`). Damit steht der Rezeptname bei 4–20 px, die Aufgabe bei 22–36 px, beide in einer 40 px hohen Zeile.

`tests/validate.mjs` prüft das nach, weil ein Test im Spiel es nicht kann: Die Attrappe der Testumgebung rechnet keine Anker aus, ein Überlappen ist dort unsichtbar. Geprüft wird deshalb am Quelltext – eigene Höhe vorhanden, kein Anker in der Senkrechten, und der Rezeptname endet über dem Beginn der Aufgabenzeile. Die Gegenprobe mit dem alten Code fällt durch.

### Der Hinweis auf eine neuere Fassung

Ein WoW-Addon darf nicht ins Netz – „gibt es etwas Neueres?" kann deshalb nur die Gilde beantworten. Sie tut es längst: Jede Versionsmeldung (`V`, Feld 3) trägt die Addon-Version ihres Absenders, und die laufen bei jedem Login und bei jeder Versionsanfrage ohnehin über den Gildenkanal. Es kommt **keine einzige Nachricht** hinzu. Details! macht es genauso, und aus demselben Grund.

Verglichen wird zahlenweise statt als Zeichenkette – sonst stünde „0.9.9" hinter „0.9.10", und genau dieser Sprung steht hier ständig an. Gemeldet wird einmal je Fassung und Sitzung: Wer nicht sofort aktualisieren will, soll nicht bei jeder Anmeldung eines Gildenmitglieds erneut erinnert werden; ein noch höherer Stand meldet sich dagegen noch einmal.

Beim Anmelden steht die Antwort oft schon in der Datenbank: `addonUsers` merkt sich die Version jedes gesehenen Nutzers. Wer gestern mit der neuen Fassung online war, ist dort vermerkt, auch wenn er heute fehlt – ohne diesen Blick hinge der Hinweis daran, dass ausgerechnet jetzt jemand Aktualisierter online ist. Geprüft wird zwölf Sekunden nach dem Login, also nach den Antworten auf die eigene Anfrage aus Sekunde 7.

Die Chatzeile scrollt weg; die Zahl bleibt deshalb an zwei Stellen stehen: in der Kopfzeile unter dem Namen, wo ohnehin die eigene Version steht, und im Versionsprüfer über der Liste.

**Was bewusst offen bleibt:** Ein manipulierter Client kann eine Fassung melden, die es nicht gibt. Der Schaden wäre eine Chatzeile, die ins Leere zeigt. Der Preis einer Absicherung über zwei unabhängige Melder wäre höher: Der Erste mit der neuen Fassung bekäme nie einen Zweiten – niemand erführe je von einer Neuerung, und gerade in kleinen Gilden bliebe der Hinweis für immer stumm. Verlangt wird deshalb nur die genaue Form `Zahl.Zahl.Zahl`; alles andere wird still verworfen.

### Nebenbefund im Versionsprüfer

Der Prüfer kannte nur „gleich" und „ungleich": Wer eine **neuere** Fassung fuhr, stand rot unter „veraltet". Das sind aber genau die Zeilen, die den Aktualisierungshinweis erklären. Sie haben jetzt einen eigenen Zustand (gelb, eigene Zählung „n neuer") und fallen nicht mehr unter die Rückständigen.

### Geändert

- `GuildCopilot/UI.lua`: eigene Höhe und obere Anker für die Tracker-Rezeptzeile; `RefreshUpdateHint` in der Kopfzeile; Zustand `AHEAD` im Versionsprüfer;
- `GuildCopilot/Sync.lua`: `IsNewerVersion`, `NoteSeenVersion`, `CheckKnownVersions`, `GetAvailableUpdate`; Anschluss an jede eingehende Versionsmeldung und an den Login-Ablauf;
- `GuildCopilot/Locales.lua`: vier englische Entsprechungen für die neuen Texte;
- `tests/validate.mjs`: hält die beiden Tracker-Zeilen auseinander;
- `tests/smoke.lua`: Versionsvergleich, einmalige Meldung je Fassung, Bestandsprüfung beim Login, Kopfzeile und Versionsprüfer;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.118.

## 0.9.117 – Eine Zahl statt zweier

Aus der Gegenprüfung von 0.9.116 blieb ein einziger offener Punkt: Siebzehn von 175 Paaren waren nicht beweisbar, weil das Verbrauchsprotokoll gekappt war. Der Owner hat entschieden: „Limit hoch, ich will lückenlose Prüfungen."

### Der eigentliche Fehler war nicht die Höhe, sondern die Anzahl

Gekappt wurde an zwei Stellen, und zwar mit zwei verschiedenen Zahlen: **hundert** während des Abends (`RecordConsumable`), **vierzig** beim Ablegen der Auswertung (`BuildSummary`). Das zweite Kappen warf sechzig Einträge weg, die der Abend bereits sauber gesammelt hatte – ohne jeden Gewinn, denn im Speicher lagen sie ohnehin schon.

Beide rechnen jetzt mit **einer** Konstante, `CONSUMABLE_LOG_LIMIT = 200`. Und damit sie nicht wieder auseinanderlaufen, prüft `tests/validate.mjs` das nach: Die Konstante muss existieren, an mindestens zwei Stellen benutzt werden, und eine eingetippte Zahl an einer Kappstelle lässt den Lauf durchfallen.

### Warum 200

Gemessen statt geschätzt: Der höchste je gespeicherte Verbrauch eines einzelnen Teilnehmers liegt bei **70 Einträgen** an einem Sechsstundenabend (Attilus, 02.08.2026). 200 gibt also fast das Dreifache an Reserve.

Der Preis ist klein, weil nur eigene Mitschnitte ein Protokoll tragen – fremde Auswertungen kommen ohne über das Netz, das Feld wird nie gesendet. Von neunzehn abgelegten Abenden haben genau drei ein Protokoll, zusammen 77 KB in einer 1,16 MB großen Datei.

Was über 200 hinausgeht, fällt weiterhin vorn heraus und wird in `consumableLogDropped` gezählt. Ein Protokoll, das schweigend unvollständig ist, wäre schlimmer als ein gekapptes, das es sagt – und genau dieser Zähler hat die siebzehn Lücken in der Prüfung überhaupt erst sichtbar gemacht.

### Geändert

- `RaidMonitor.lua`: `CONSUMABLE_LOG_LIMIT` als einzige Quelle für beide Kappstellen, Wert 200;
- `tests/validate.mjs`: hält beide Stellen auf der Konstante;
- `tests/smoke.lua`: Ein Abend mit sechzig Einträgen kommt vollständig in der Auswertung an;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.117.

## 0.9.116 – Die vollständige Gegenprüfung gegen das Kampflog

Der Auftrag des Owners nach dem Fläschchen-Fund: „Schau, ob GCP jetzt alles exakt und richtig erfasst. Es muss wasserdicht sein, keine Fehler erlaubt." Und, nachgeschoben: „Vor allem, dass die Anzahl exakt stimmt und nichts doppelt gezählt wird."

Das ließ sich diesmal wirklich beantworten, und zwar strenger als über Warcraft Logs: Das Kampflog des 09.08. und die gespeicherte Auswertung stammen vom **selben Client desselben Abends**. Der Ereignisstrom ist identisch – jede Abweichung ist ein Befund, keine Messungenauigkeit.

### Wie geprüft wurde

Ein Prüfprogramm lädt `GC.Consumables` aus `Constants.lua` selbst (keine zweite Wahrheit), streamt die 734.689 Logzeilen und wendet exakt die Regeln aus `HandleCombatLogEvent` an: Tränke, Runen, Trommeln, Fläschchen und Elixiere nur aus `SPELL_CAST_SUCCESS` beim Wirkenden, Essen nur aus Aura-Ereignissen beim Ziel, mit derselben 60-Sekunden-Sperre gegen das Weiteressen.

Der erste Durchlauf verglich Summen und fand 24 Abweichungen – aber die Sitzung lief von 19:40 bis 23:28, das Log erst ab 19:48:59. Ein Vergleich von Summen über verschiedene Zeitfenster beweist nichts. Guild Copilot protokolliert jeden Verbrauch aber **mit Zeitstempel**; damit ließ sich seine Zählung auf genau das Logfenster einschränken. Erst dieser Vergleich ist ein Beweis:

**140 von 175 Paaren aus Teilnehmer und Kategorie stimmten exakt.** Bei 17 war das Protokoll gekappt (es hebt nur die letzten 40 Einträge auf) und damit nicht beweisbar. Blieben 14 Überschüsse und 4 Fehlbeträge.

### Der Überschuss: 23 Mahlzeiten, die niemand gegessen hat

Die Überschüsse waren fast alle Essen. Nebeneinandergelegt zeigte sich bei einem Spieler zwölf Einträgen in der Auswertung gegen zehn Aura-Ereignisse im Log – und die beiden Zusatzeinträge lagen zu Zeitpunkten, an denen sein Sattgegessen-Buff längst lief.

Die Gegenprobe über alle Teilnehmer machte es eindeutig: Um **21:42 und 21:43 bekamen 23 von 25 Teilnehmern gleichzeitig** je eine Mahlzeit gutgeschrieben. Das Kampflog kennt zwischen 21:40:01 und 21:43:35 **kein einziges Ereignis** – es ist die Pause, in der der Raid von der Höhle des Schlangenschreins ins Auge zog.

Gegessen hatte niemand. Der Eintritts-Scan lief erneut und zählte, was das Kampfprotokoll längst gezählt hatte.

### Warum der alte Merker nicht half – und der neue hilft

`participant.auraScanDone` saß am TEILNEHMER: „bei dem habe ich schon geschaut". Das ist die falsche Frage. Es kommt nicht darauf an, ob geschaut wurde, sondern ob **dieser Buff** schon gezählt ist – ein Fläschchen steht danach noch zwei Stunden auf dem Charakter, ein Sattgegessen eine halbe, und jeder weitere Blick sieht sie wieder.

Der Merker sitzt jetzt am ZAUBER (`participant.scanned[spellID]`), und beide Zählwege tragen dort ein: Der Scan zählt nur, was noch nicht drinsteht; das Kampfprotokoll zählt immer – ein echter Zauber ist ein echter Verbrauch – und vermerkt die Kennung zusätzlich.

Das behebt beide Richtungen desselben Fehlers auf einmal:

- **Zu viel** kann nicht mehr entstehen, egal wie oft der Scan läuft.
- **Zu wenig** auch nicht mehr: Weil Doppelzählung jetzt strukturell ausgeschlossen ist, darf der Scan bei **jedem** Anwesenheitsabgleich laufen statt nur einmal. Wer sein Fläschchen erst nach dem ersten Sichtkontakt aufmacht, wird jetzt gefunden – die Lücke, die in `docs/TODO-naechste-sitzung.md` als offener Punkt stand.

Gegen die echten Daten nachgerechnet: Bei **allen 19 überprüften Betroffenen** des 21:42-Scans war der Essenszauber vorher bereits gezählt. Der neue Merker hätte jeden dieser Zusatzzähler verhindert – ausnahmslos.

### Die Fehlbeträge: zwei weitere unbekannte Kennungen

Nach dem Eintrag des Fläschchens aus 0.9.115 blieben vier Fehlbeträge, und alle vier waren wieder fehlende Kennungen. Gefunden wurden sie über eine Signatur, die kein Klassenzauber haben kann: **derselbe Zauber, gewirkt von Spielern mehrerer Klassen, der sich selbst bufft** – das kann nur etwas aus der Tasche sein. Die Kategorie folgt der im Log gemessenen Wirkdauer:

| Kennung | Name | Klassen | Dauer | Kategorie |
|---|---|---|---|---|
| 17627 | Destillierte Weisheit | – | – | Fläschchen (0.9.115) |
| 17538 | Elixier des Mungos | 2 | 63 Min | Elixier |
| 28515 | Eisenschild | 2 | 2 Min | Trank |

Betroffen waren sieben Elixiere bei einem Spieler und vier Tränke bei zwei weiteren. Alle anderen Kandidaten dieser Signatur waren Schmuckstück-Procs (Segen des Silberwappens, Kampfeslust), Völkerfähigkeiten (Wille der Verlassenen, Kochendes Blut) oder Kurioses (Angeln, Arrrr!) – sie bleiben bewusst draußen.

### Was ehrlicherweise offen bleibt

- **17 Paare sind nicht beweisbar.** Das Verbrauchsprotokoll hebt je Teilnehmer die letzten 40 Einträge auf; bei sechs Vielverbrauchern wurden bis zu 16 verworfen. Die ZÄHLER sind davon unberührt und vollständig – nur die nachträgliche Beweisführung endet dort. Ein höheres Limit wäre möglich, kostet aber Platz in den SavedVariables; das ist eine Entscheidung des Owners.
- **Geprüft ist ein Abend.** Ein Kampflog liegt auf der Platte, die anderen Abende sind nicht gegenprüfbar.
- **Die Prüfung selbst ist kein Test der Auslieferung**, sondern ein Werkzeug im Scratchpad. Was daraus dauerhaft bleibt, sind die Regressionstests.

### Geändert

- `RaidMonitor.lua`: `MarkScanned` als Merker je Zauber, `ScanCarriedConsumables` ohne `auraScanDone` und damit wiederholbar, das Kampfprotokoll trägt gezählte Kennungen in den Merker ein;
- `Constants.lua`: `[17538]` Elixier des Mungos, `[28515]` Eisenschildtrank, beide mit Beleg;
- `Companion/WCL-Import.mjs`: dieselben Kennungen in der Übertragungsliste;
- `tests/smoke.lua`: Der Scan nach dem Kampfprotokoll zählt nicht doppelt, zehn Scans hintereinander ändern nichts, ein nachträglich aufgetragener Buff wird gefunden;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.116.

## 0.9.115 – Der Einzige von 25 ohne Fläschchen

„Mîasanmîa hat angeblich keine Cons genutzt, hatte er aber." Eine Meldung dieser Art ist die wertvollste, die ein Zählwerk bekommen kann – und die einzige Art, die sich nicht durch Nachdenken beantworten lässt, sondern nur durch Daten.

### Was die Ablage sagte

Fünf Manatränke über den Abend verteilt (20:04 bis 23:11), sonst nichts: keine Fläschchen, keine Elixiere, kein Essen. Bei 3,54 h gezählter Anwesenheit, und als **Einziger von 25** – die anderen 24 hatten alle mindestens eines der drei. Beide Fassungen des Abends, der eigene LIVE-Mitschnitt und die von Hottí synchronisierte, kamen unabhängig auf dieselben fünf Tränke.

Die verteilten Trankzeitpunkte schlossen die naheliegendste Erklärung sofort aus: Der Mitschreiber hatte ihn den ganzen Abend in Reichweite.

### Die falsche Fährte

Die erste Vermutung galt dem Eintritts-Scan aus 0.9.x, der einmal je Teilnehmer liest, was jemand schon an Buffs trägt (`participant.auraScanDone`). Ein Scan, der genau einen Augenblick sieht und diesen Augenblick beim ersten Sichtkontakt wählt, kann alles verpassen, was danach kommt – eine plausible Geschichte, und sie war falsch.

### Was das Kampflog sagte

Der Owner hatte die bessere Idee als der Umweg über Warcraft Logs, dessen Seite eine Bot-Prüfung verlangt: Das Kampflog des Abends lag noch auf der Platte, 210 MB, vom 09.08. 19:48 bis 23:32. Darin steht die Antwort in zwei Zeilen:

```
SPELL_CAST_SUCCESS ... 17627,"Destillierte Weisheit"
SPELL_AURA_APPLIED ... 17627,"Destillierte Weisheit",0x1,BUFF
```

Er hat das **Fläschchen der destillierten Weisheit** getrunken, zweimal, mitten in der Sitzung. Das ist ein Classic-Fläschchen (Item 13511), das in TBC weiter benutzt wird, weil es für Manaklassen billig und gut ist. `GC.Consumables` kannte die fünf TBC-Fläschchen – und dieses nicht. Eine unbekannte Kennung wird stillschweigend nicht gezählt; genau die Eigenschaft, die verhindert, dass falsche Zahlen entstehen, lässt hier eine richtige fehlen.

Alles andere, was die Auswertung über ihn sagte, war korrekt: Im ganzen Log steht bei ihm kein einziges Elixier und kein Essen. Der Gegencheck dazu war nötig, weil der deutsche Client zwei verschiedene Dinge „Satt" nennt – die Sattgegessen-Buffs (BUFF, 33254 ff.) und die Sättigung nach Kampfrausch (DEBUFF, 57724). Nur der Auratyp trennt sie, und er trug 476-mal den Debuff.

### Was daraus folgt

Eingetragen ist jetzt genau eine Kennung, belegt aus dem Spielclient selbst – nach derselben Regel, unter der auch die Verzauberungen und die englischen Namen stehen: keine Kennung ohne Beleg. Die drei Geschwister-Fläschchen aus Classic (Titanen, Höchste Macht, Chromatischer Widerstand) stehen bewusst **nicht** dabei: In diesem Log kommen sie nicht vor, und aus dem Gedächtnis eingetragene Zahlen sind genau die Art Datenmüll, den diese Tabelle vermeiden soll. Sie kommen dazu, sobald ein Log sie zeigt.

Dieselbe Kennung fehlte auch in der Filterliste des Warcraft-Logs-Companions, die entscheidet, was ein Import überhaupt überträgt. Ohne sie hätte der Import denselben Heiler erneut ohne Fläschchen gemeldet – und diesmal mit dem Anschein einer unabhängigen Bestätigung.

**Der Eintritts-Scan bleibt trotzdem eine schwache Stelle**, nur eben nicht diese: Er liest einmal und nie wieder. Wer beim ersten Sichtkontakt noch nicht gebufft ist, wird bis zum Sitzungsende nur noch über das Kampfprotokoll erfasst. Der Umbau wäre ein Merker je Zauber statt je Teilnehmer; er steht in `docs/TODO-naechste-sitzung.md`.

### Geändert

- `Constants.lua`: `[17627]` als Fläschchen, mit dem Kampflog als Beleg im Kommentar;
- `Companion/WCL-Import.mjs`: dieselbe Kennung in der Übertragungsliste;
- `tests/smoke.lua`: das Classic-Fläschchen zählt wie die TBC-Fläschchen;
- `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`, `tests/validate.mjs`: Stand 0.9.115.

## 0.9.114 – Zuklappen statt zumachen

„Es sollte irgendwie so einen Minimieren-Button geben, der quasi das Fenster ähnlich wie WeakAuras klein macht, dass man den Bildschirm frei hat, nur die oberste Zeile sozusagen."

Das Vorbild ist gut gewählt, denn es beschreibt genau den Unterschied zum Schließen: Ein geschlossenes Fenster ist weg, ein zugeklapptes ist da und im Weg-Sein sichtbar. Wer im Raid kurz Platz braucht, will nicht die Seite verlieren, auf der er gerade war.

### Was stehen bleibt

Die Kopfzeile, vollständig: Logo, Titel, Version, der Abgleichstand („29 Nutzer, Daten vollständig"), „Einrichtung", der neue Knopf und das ×. Sie ist zugleich der Griff zum Verschieben – das ganze Fenster reagiert auf Ziehen, der Balken also auch.

Weg klappen Seitenleiste, Seite und der Griff zum Größenziehen. Dass die Seiten sich verstecken, erledigt nebenbei etwas Zweites: Ihr `OnHide` schließt alle offenen Dialoge. Ein Erstellen-Dialog, der über einem 60 Pixel hohen Balken stehen bliebe, wäre genau die Art Bruchstelle, die man erst im Spiel sieht.

### Zwei Feinheiten

**Der Anker.** Das Fenster hängt in der Voreinstellung an der Bildschirmmitte. Ändert man dort die Höhe, wächst und schrumpft es symmetrisch – der Balken spränge beim Zuklappen nach oben und beim Aufklappen wieder zurück. Vor jeder Höhenänderung wird die obere linke Ecke deshalb festgenagelt; dieselbe Mechanik, die seit 0.9.113 die Ecke beim Ziehen dem Mauszeiger folgen lässt (`FreezeWindowTopLeft`, jetzt von beiden benutzt).

**Der Weg zurück von außen.** `ShowPage` klappt ein zugeklapptes Fenster auf. Ohne das zeichnete ein Klick auf den Auftrags-Tracker seine Seite in den Balken hinein – sichtbar wäre nichts, kaputt aber alles.

Der Zustand wird gemerkt. Wer zugeklappt ausloggt, findet den Balken wieder; verwechseln lässt er sich mit einem geschlossenen Fenster nicht, er trägt seinen Namen.

### Zwei Zahlen, die zusammenbleiben müssen

Die Fensterhöhe steht jetzt zweimal im Code: als feste Zahl beim Aufbau (dort liest `tests/validate.mjs` sie ab, um Seitenhöhen nachzurechnen) und als Konstante, weil das Aufklappen sie zurücksetzen muss. Der Test hält beide gleich und prüft zusätzlich, dass die zugeklappte Höhe die Kopfzeile samt ihrer beiden Randlinien wirklich trägt.

### Geändert

- `UI.lua`: `SetWindowMinimized` samt Knopf in der Kopfzeile und den beiden Symbolen (`CreateMinimizeMark`, `CreateRestoreMark`), `FreezeWindowTopLeft` als gemeinsame Grundlage von Minimieren und Größenziehen, `ShowPage` klappt auf, `WINDOW_HEIGHT` als Konstante;
- `Database.lua`: `settings.window.minimized`;
- `Locales.lua`: „Minimieren", „Wieder aufklappen";
- `tests/smoke.lua`: Zuklappen versteckt Seitenleiste, Seite und Ziehgriff, merkt sich den Zustand und tauscht das Symbol; das Aufschlagen einer Seite klappt auf;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.114.

## 0.9.113 – Der erste Blick im Spiel: vier Befunde

Der Owner hat 0.9.112 im Spiel aufgeschlagen und vier Dinge zurückgemeldet. Drei davon waren in keinem Test zu sehen – sie leben in Rahmenebenen, Textbreiten und in der Frage, wo das Auge zuerst hinschaut.

### „Beruf wählen" tat nichts

Der schwerste Befund, und ein lehrreicher. Das Aufklappmenü der Dropdowns hängt bewusst nicht unter seiner Karte, sondern unter dem Hauptfenster – Seiten liegen in einem Bildlauf, und ein Bildlauf beschneidet, was über seinen Rand ragt. Seine Rahmenebene wurde beim Aufbau einmal gesetzt: **Fenster + 60**.

Dialoge liegen bei **Fenster + 80**. Das Menü der Berufswahl öffnete sich also ordnungsgemäß – zwanzig Ebenen hinter dem Dialog, hinter dessen deckendem Hintergrund. Sichtbar passierte nichts, klickbar war nichts.

Die Ebene wird jetzt bei jedem Aufklappen gesetzt, und zwar relativ zum **Knopf** statt zum Fenster: `dropdown:GetFrameLevel() + 20`. Damit stimmt sie für ein Dropdown auf einer Seite genauso wie für eines in einem Dialog, und sie stimmt auch dann noch, wenn ein Dialog später seine Ebene ändert.

Der Regressionstest dafür brauchte einen ehrlicheren Rahmenmock: Bis 0.9.112 lieferte `GetFrameLevel` ohne ausdrücklich gesetzten Wert `nil`, in WoW liegt ein Rahmen ohne eigene Ebene aber eine über seinem Elternteil. Der Mock erbt jetzt genauso – und `CreateFrame` merkt sich endlich sein Elternteil.

### „Tracker einble…"

Der Knopf war 96 Pixel breit und trägt „Tracker ausblenden". Er ist jetzt 150 breit; die Statuszeile daneben gibt die Pixel her. Die Regel dahinter steht als Test: Die Breite richtet sich nach der längsten Beschriftung, nicht nach der kürzesten.

### Katalog und Gildenaufträge waren nicht zu finden

„Zu versteckt, nicht logisch, nicht intuitiv – die Buttons oben, die muss man erstmal wissen, dass sie da sind." Der Befund sitzt: Zwei Umschalter am rechten Rand der Kopfzeile, in derselben Zeile wie ein Hilfetext, sehen aus wie Aktionen und nicht wie Navigation. Wer die Gildenaufträge sucht, sucht sie in der **Seitenleiste** – dort steht alles andere auch.

Die Werkstatt hat deshalb einen zweiten Navigationspunkt bekommen: **Gildenwerkstatt** öffnet den Katalog, **Gildenaufträge** das Board. Beide zeigen dieselbe Seite; die Definition eines Navigationspunkts kennt dafür jetzt zwei optionale Felder (`page` und `view`). Welcher Punkt leuchtet, entscheidet bei geteilten Seiten zusätzlich die Ansicht – das übernimmt `RefreshTabHighlight`, aufgerufen aus `ShowPage` und aus `SetWorkshopView`.

Die Umschalter oben rechts bleiben, wo sie sind. Sie sind jetzt nicht mehr der einzige Weg, sondern die Anzeige „hier stehst du" – und wer schon auf der Seite ist, wechselt weiter mit einem Klick, ohne zur Seitenleiste zu greifen.

Platz war da: Die Seitenleiste trägt rechnerisch bis zu fünfzehn Punkte, mit dem neuen sind es vierzehn. `tests/validate.mjs` rechnet das bei jedem Lauf nach.

### Die Ecke ziehen

0.9.111 hatte die Fenstergröße als Regler in die Einstellungen gelegt und in dieser ROADMAP begründet, warum eine echte Größenänderung nicht in Frage kommt. Der Wunsch kam trotzdem wieder: „Das Fenster sollte rechts unten an der Kante per Drag and Drop kleiner oder größer gezogen werden können."

Die Begründung gegen eine ziehbare **Kante** gilt unverändert – dreizehn pixelgenau vermessene Seiten. Die Handbewegung ist davon aber gar nicht betroffen: Gezogen wird der Maßstab, und die Ecke folgt trotzdem dem Mauszeiger. Dafür wird das Fenster für die Dauer des Ziehens oben links verankert; ohne das wüchse es um seine Mitte und liefe dem Zeiger davon. Der neue Maßstab ist schlicht der Abstand des Zeigers zur linken Fensterkante, geteilt durch die Fensterbreite, begrenzt auf dieselben 70 bis 130 Prozent wie der Regler.

Zwei Kleinigkeiten, die den Unterschied zwischen „geht" und „fühlt sich richtig an" ausmachen:

- Gerundet wird auf ganze Prozent **vor** dem Anwenden. Sonst stünde das Fenster auf 78,43 % und der Regler in den Einstellungen auf 78 – der nächste Klick dort ließe es sichtbar springen.
- Beendet wird das Ziehen über den Zustand der Maustaste, nicht über `OnMouseUp`. Wer beim Ziehen aus dem kleinen Griff herausfährt, bekäme sonst nie ein Ende, und das Fenster bliebe am Zeiger kleben.

### Geändert

- `UI.lua`: `PlacePopup` setzt die Rahmenebene relativ zum Knopf; Navigationspunkte kennen `page`/`view`, neuer Punkt „Gildenaufträge", `RefreshTabHighlight`; Griff zum Ziehen samt `BeginWindowResize`/`StepWindowResize`/`EndWindowResize` und `CreateResizeMark`; `UIScale`/`CursorInUISpace` nach oben gezogen, weil sie jetzt zwei weit auseinanderliegende Stellen brauchen; Tracker-Knopf 150 statt 96 Pixel;
- `Locales.lua`: „Gildenaufträge" als Navigationspunkt, „Fenstergröße ziehen";
- `tests/smoke.lua`: Rahmenmock erbt Rahmenebenen und merkt sich das Elternteil, UIParent hat Maße; Aufklappmenü liegt über seinem Dialog, Navigationspunkt schaltet die Ansicht samt Leuchten, Ziehen rechnet und begrenzt richtig und zieht den Regler nach, Tracker-Knopfbreite;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.113.

## 0.9.112 – Was der Katalog nicht kennt, und was der Client selbst tun kann

Die letzten beiden Punkte der Gildenrückmeldung: „Freitext-Aufträge für nicht vorhandene Rezepte einbauen" und „Möglichkeit, aus dem Cockpit heraus Items herzustellen?". Beide sind Ja – mit Entscheidungen, die hier begründet stehen, weil der Owner den Fragedialog nicht beantwortet hat und die Arbeit weiterlaufen sollte.

### Der Beruf ist der Schlüssel

Ein Auftrag brauchte bisher einen Katalogeintrag: `Orders:Create` brach ohne ihn ab. Der Katalog kennt aber nur, was ein Addon-Nutzer einmal in seinem Berufsfenster hatte – was niemand gescannt hat, was ein Neuzugang mitbringt oder was der Hersteller erst lernen soll, war damit unbestellbar.

Der Rezeptschlüssel trägt beim Freitext deshalb den **Beruf** statt des Rezepts: `Fschneiderei`. Das ist Absicht und keine Notlösung.

- **Die Annahmeprüfung bleibt echt.** Ohne jede Prüfung wäre ein Freitext-Auftrag für jeden machbar und damit für niemanden – und der Filter „nur machbare" verlöre für diese Aufträge seine Bedeutung. So darf annehmen, wer den Beruf hat, geprüft gegen dieselbe Datenbasis wie sonst (eigene Twinks aus den SavedVariables, fremde Charaktere aus dem Gildenindex).
- **Der Schlüssel muss nicht eindeutig sein.** Aufträge unterscheidet ihre `id`; der Rezeptschlüssel beantwortet allein die Frage „wer kann das?". Zwei Schneiderei-Wünsche teilen sich denselben Schlüssel, ohne sich in die Quere zu kommen.
- **Kollisionsfrei.** Katalogschlüssel beginnen mit `I` (Item), `E` (Rezept-ID) oder `N` (Name). Das `F` war frei.

Am Protokoll ändert sich **nichts**: Der Wunschtext reist im vorhandenen Namensfeld, ein Altclient zeigt ihn als Rezeptnamen an. Die 30 Byte dieses Feldes sind die Grenze, und das ist keine Sparsamkeit, sondern Arithmetik – die Kernnachricht liegt voll ausgereizt bei etwa 213 der 255 zulässigen Bytes. Der Dialog sagt deshalb „kurz"; Einzelheiten gehören in die Notiz.

Zwei Felder fallen beim Freitext weg, weil sie ohne Rezept keine Grundlage haben: der **Wunsch-Hersteller** (es gibt keine Herstellerliste, aus der er zu wählen wäre) und die **Vorlage** (sie hängt am Rezept). Ihre Zeile im Dialog gehört jetzt Wunsch und Beruf – ein zweites Fenster wäre falsch gewesen, denn Materialmodell, Übergabeweg, Menge, Kostenrahmen, Trinkgeld und Notiz sind identisch.

Der Einstieg sitzt am **Board**, nicht am Katalog: Dort gibt es nichts auszuwählen – genau das ist ja der Fall, für den es ihn gibt.

### Herstellen: zwei Klicks, weil das Spiel zwei verlangt

Machbar ist es, aber mit zwei Grenzen, die kein Addon umgeht:

1. **Nur der eingeloggte Charakter.** Der Katalog kennt die Rezepte der ganzen Gilde; fertigen kann sie nur ihr Besitzer. Der Knopf erscheint deshalb ausschließlich, wenn `Workshop:GetOwnRecipe` das Rezept beim aktuellen Charakter findet.
2. **Nur bei offenem Berufsfenster.** Die Rezeptlisten aller drei APIs existieren ausschließlich, solange es offen steht. Gemerkt wird deshalb **nichts** – `FindOpenRecipe` sucht bei jedem Auftrag neu, denn ein gemerkter Index wäre schon nach dem nächsten Filterwechsel falsch. Drei Wege, dieselbe Schlüsselbildung wie beim Scan: `C_TradeSkillUI.CraftRecipe` (modern), `DoCraft` (Craft-API, Verzauberkunst) und `DoTradeSkill` (klassisch).

Daraus folgt der Zweischritt: Erster Klick öffnet das Fenster, zweiter fertigt. Das Öffnen ist ein Zauber, und Zauber lässt WoW nur bei einem echten Tastendruck zu – der Knopf ist deshalb ein **sicherer** Knopf (`SecureActionButtonTemplate`), wie die Berufszeilen im Einrichtungsassistenten. `CreateButton` kann das jetzt selbst; der eigene Handler hängt dort an `PostClick`, weil die Vorlage `OnClick` für sich braucht.

Eine Feinheit, die im Spiel den Unterschied macht: Der Zauber hängt nur am Knopf, solange das Fenster **zu** ist. Läge er immer an, unterbräche der zweite Klick die gerade laufende Herstellung – man kann nicht zwei Zauber zugleich wirken. Beim Schreiben dieser Umschaltung fiel prompt ein Lua-Fallstrick an: `ready and nil or spell` ergibt **immer** `spell`, weil `nil` im `and`-Zweig als falsch gilt. Ein Regressionstest hält das jetzt fest.

### Der Zähler zählt selbst

0.9.110 hat die Menge sichtbar gemacht; gezählt wurde sie weiter von Hand. Jetzt hört ein einzelnes Ereignisabo auf den erfolgreichen Herstellungszauber (`UNIT_SPELLCAST_SUCCEEDED`, Zauber-ID an letzter Stelle – das ist über alle Classic-Fassungen hinweg richtig, die Position davor nicht). Passt die ID zum Rezept eines laufenden eigenen Auftrags, steigt ein Zähler. Das gilt für **jede** Herstellung, auch die von Hand im Berufsfenster – genau darum ging es in der Rückmeldung.

Der Zähler bleibt **lokal** und geht nie ins Netz. Vierzig Urnen wären sonst vierzig Rundrufe über einen Kanal, der rund zehn Pakete je Sekunde und Absender zustellt; und ein Gildenauftrag ist eine Absprache zwischen Menschen, kein Sensor. Der Stand steht in der Auftragszeile („3 selbst gefertigt, noch nicht gemeldet") und füllt den Meldedialog vor – gemeldet wird auf Klick, so wie bisher. Über die bestellte Menge hinaus zählt er nicht: Wer nebenher für sich selbst fertigt, soll den Auftrag nicht überfüllt melden.

### Was offen bleibt

Der Herstellen-Knopf steht an der Rezeptkarte und im Meldedialog, **nicht** in der Auftragszeile: Dort ist zwischen Verlauf, Abbrechen und Primäraktion kein Platz, ohne den Rezeptnamen abzuschneiden. Ob er dort fehlt, zeigt der Gebrauch.

Ungeprüft im Spiel ist, ob der Client nach `TRADE_SKILL_CLOSE` tatsächlich eine leere Liste meldet. Tut er es nicht, hält der Knopf ein geschlossenes Fenster für offen, und der Herstellbefehl läuft ins Leere – ohne Schaden, aber mit einem Klick zu viel.

### Geändert

- `Orders.lua`: `FreeRecipeKey`/`GetFreeProfessionKey`/`GetFreeProfessionName`, `Create` nimmt Freitext-Aufträge an, `GetOwnCrafters` und `IsKnownCrafter` prüfen dort den Beruf; lokaler Mitzähler (`NoteCraftedSpell`, `GetPendingCraftCount`, `ClearPendingCrafts`) samt Ereignisabo und Aufräumen in `Prune`;
- `Workshop.lua`: `GetOwnRecipe`, `FindOpenRecipe` und `CraftOpenRecipe` für alle drei Berufsfenster-APIs, `TRADE_SKILL_CLOSE`/`CRAFT_CLOSE` frischen die Oberfläche auf;
- `UI.lua`: `CreateButton` kann sichere Knöpfe, `ProfessionWindowSpell` als gemeinsamer Helfer (der Assistent nutzt ihn mit), Herstellen-Knopf an der Rezeptkarte und im Gefertigt-Dialog samt `RefreshCraftButton`, Freitext-Felder im Erstellen-Dialog und der Knopf „Freier Auftrag" am Board, Mitzähler in der Auftragszeile und als Vorbelegung der Meldung;
- `Database.lua`: `settings.pendingCrafts`;
- `Locales.lua`: die neuen Beschriftungen;
- `tests/smoke.lua`: `SetAttribute`/`GetAttribute` im Rahmenmock, mitgeschriebene Herstellbefehle, Freitext von der Schlüsselbildung bis zur Fertigmeldung, Herstellen mit offenem und geschlossenem Fenster, im Kampf und bei fremdem Rezept, Mitzähler samt Obergrenze und Aufräumen;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.112.

## 0.9.111 – Ein Maßstab statt einer Fensterkante

Punkt drei der Gildenrückmeldung: „GCP-Fenster skalieren oder verkleinern nach Bedarf, oder die Möglichkeit der Transparenz". Das Hauptfenster war seit jeher auf 1020 × 690 festgenagelt – auf 1280 × 720 füllt das den halben Bildschirm, und im Raid verdeckt es, was man sehen will.

### Warum Maßstab und nicht Größe ziehen

Der naheliegende Weg – `SetResizable`, eine Ecke zum Ziehen – wäre der falsche. Jede der dreizehn Seiten ist pixelgenau vermessen: Karten stehen an festen Punkten, Textbreiten sind auf ihre Spalte abgestimmt, und `tests/validate.mjs` rechnet an sechs Stellen mit genau diesen Zahlen nach, dass sich nichts überlappt und nichts aus seiner Karte ragt. Eine ziehbare Kante hieße, dreizehn Seiten umbruchfähig zu machen – ein Umbau, der weit über die Rückmeldung hinausschießt und jede dieser Prüfungen ersatzlos verlöre.

Ein Maßstab erreicht dasselbe Ziel ohne eine einzige verschobene Karte: Das Fenster wird kleiner, alles darin bleibt im selben Verhältnis. 70 bis 130 Prozent in Schritten von fünf, dazu die Deckkraft von 40 bis 100 Prozent.

### Zwei Knöpfe statt eines Schiebereglers

Blizzards Schieberegler brächte sein Rahmenwerk in eine Oberfläche, die sich sonst alles selbst malt – dieselbe Überlegung wie beim goldenen Häkchen aus 0.9.x, das eigenen Symbolen gewichen ist. Ein Textfeld wie bei der Anzeigedauer der Bildschirmmeldung schied aus einem konkreten Grund aus: Wer „125" tippt, erzeugt unterwegs „1" und „12". Bei einer Zahl, die sofort wirkt, wäre das ein Springen des halben Bildschirms je Tastendruck.

Geworden ist es ein Zahlenregler aus „–", Anzeige und „+", der an seinen Grenzen den jeweiligen Knopf ausgraut. Er liegt als `CreateStepper` bei den anderen Bedienelementen und ist damit für die nächste Zahleneinstellung schon da.

### Was bewusst nicht mitskaliert

Tracker, Werbebalken und Bildschirmmeldung bleiben unverändert. Sie merken sich ihre Position als Versatz zur Bildschirmmitte; ein Maßstab würde diesen Versatz mitrechnen und die drei unter der Hand verschieben – ausgerechnet die Rahmen, die der Nutzer selbst dorthin gezogen hat, wo sie nichts verdecken. Groß ist ohnehin nur das Hauptfenster.

Die Deckkraft gilt für das ganze Fenster samt Schrift; darum ist bei 40 Prozent Schluss und die Karte sagt es dazu. Eine Halbtransparenz, die beim Überfahren mit der Maus auf 100 Prozent springt, wäre der nächste Schritt – erst einmal ist die Frage, ob der feste Wert reicht.

### Geändert

- `UI.lua`: `CreateStepper` als neues Bedienelement, Karte „Fenster" am Ende der Einstellungsseite (Größe, Deckkraft, Zurücksetzen), `ApplyWindowLook` beim Aufbau des Hauptfensters und bei jeder Änderung, `RefreshSettings` setzt die Regler stumm nach; Inhaltshöhe der Einstellungsseite auf 2516;
- `Database.lua`: `settings.window` mit `scale` und `alpha` in Prozent;
- `tests/smoke.lua`: Massstab und Deckkraft im Rahmenmock ablesbar, Regler samt Grenzen, Zurücksetzen, und dass das Zeichnen der Seite den gespeicherten Wert nicht überschreibt;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.111.

## 0.9.110 – Drei Zeilen waren nie eine Liste

Aus der Gilde kam eine Rückmeldung in fünf Punkten. Die ersten beiden betrafen dasselbe Fenster: „bei mehreren Aufträgen kann man nicht scrollen und einen expliziten Auftrag an- oder abwählen, es werden nur 3 angezeigt" und „Menge von hergestellten Items wird nicht getrackt". Beides stimmte, und beides hatte dieselbe Ursache: Das Board war als Ansicht gebaut, nicht als Liste.

### Der vierte Auftrag existierte, war aber unerreichbar

`ORDERS_ROWS_PER_SECTION = 3` – drei feste Zeilen je Abschnitt, gebaut beim Seitenaufbau, gefüllt beim Zeichnen. Was darüber hinausging, lag in der Datenbank, wurde synchronisiert, zählte in den Kennzahlen mit und war mit keinem Handgriff sichtbar zu machen. Kein Filter, kein Umblättern, kein Bildlauf. Der Speicher fasst sechzig Aufträge; gezeigt wurden neun.

Der Umbau folgt dem Muster, das die Spielerliste der Ausrüstungsseite schon trägt: ein Bildlauf mit wachsendem Zeilenvorrat. Eine Zeile entsteht erst, wenn es sie zu zeigen gilt, und wird danach wiederverwendet – bei zwei Aufträgen kostet das Board zwei Zeilen, nicht sechzig. Positioniert wird bei jedem Zeichnen neu, weil jeder Abschnitt mit seinem Inhalt wächst und alles darunter mitschiebt.

Unten bleiben Statuszeile, **Statistik** und **Tracker** stehen: Wer bis zum letzten Auftrag scrollt, soll den Tracker-Knopf nicht suchen müssen. Die beiden Knöpfe der Überschrift „offene Aufträge" liegen dagegen IM Bildlauf – sie gehören zu ihrem Abschnitt und wandern mit ihm.

### „Meine Aufträge" waren nicht meine

Beim Nachrechnen fiel ein Fehler auf, den niemand gemeldet hatte, der die drei Zeilen aber erst richtig eng machte: `GetBoard` schob **jeden** laufenden Auftrag in den Abschnitt „MEINE AUFTRÄGE" – auch die, an denen der eigene Account weder als Auftraggeber noch als Hersteller beteiligt war. Sortiert wurde nach „du bist dran", dann nach Änderungszeit; ein frisch bewegter fremder Auftrag verdrängte damit den eigenen, auf den man wartete.

Weggeworfen werden sie trotzdem nicht: Wer sieht, dass sein Wunschrezept gerade jemand anders fertigt, fragt nicht zum zweiten Mal danach. Sie stehen jetzt in einem eigenen Abschnitt **„LÄUFT IN DER GILDE"**, mit der Angabe, auf wen gewartet wird und seit wann sich nichts bewegt hat – statt einer Handlungsaufforderung, die an jemand anderen gerichtet ist.

### Ablehnen, ohne es der Gilde zu erzählen

Auf einen offenen Auftrag gab es genau eine Antwort: annehmen. Wer ihn nicht wollte, sah ihn bis zum Verfall nach vierzehn Tagen. Der neue „–"-Knopf blendet ihn aus – und zwar **nur lokal**. Der Auftrag bleibt für alle anderen unverändert offen, es geht kein Paket ins Netz, und niemand erfährt, wer weggeklickt hat. Gespeichert wird kontoweit, weil auch die Annahme dem Account gehört und nicht dem Charakter.

Nichts verschwindet dauerhaft: Sobald etwas abgelehnt ist, steht neben dem Filter „n abgelehnt"; ein Klick blendet alles wieder ein, ein zweiter Klick auf „+" nimmt die Ablehnung zurück. Der Vermerk lebt nur so lange wie sein Auftrag – `Prune` räumt ihn mit weg, sonst sammelte die Einstellungsdatei jede jemals weggeklickte ID.

Der Ablehnen-Knopf teilt sich bewusst **nicht** den Platz mit dem Abbrechen-×, obwohl die beiden sich nie auf derselben Zeile begegnen: Zwei verschieden folgenreiche Aktionen dürfen nicht am selben Ort stehen.

### Die Menge: halb da, unsichtbar, falsch gezählt

Die Rückmeldung „wird nicht oder nicht richtig gezählt" traf beides. Einen Teilfertigungszähler gab es seit 0.9.63 – er wurde sogar über Feld 19 synchronisiert. Nur stand er nirgends: Die Zeile zeigte „×10", ob null oder neun Stück fertig waren; der Stand lebte allein im Verlaufsdialog. Jetzt trägt die Zeile „×10 **3 fertig**", solange etwas aussteht, und schweigt wieder, sobald alles da ist.

Die Statistik zählte **Aufträge**. Vierzig Urnen und ein Ring waren beide „1 erledigt" – die Frage, wie viel eine Gilde eigentlich gefertigt hat, konnte sie nicht beantworten. Sie zählt jetzt zusätzlich Stücke, je Hersteller und je Auftraggeber, mit einer Gesamtzeile darüber.

Zwei bewusste Kanten:

- Gezählt wird die **vereinbarte** Menge, nicht die gemeldete. `craftedCount` kommt von Altclients als 0 an und würde die Zahl je nach Gegenüber verschlucken; ein Auftrag wird ohnehin erst abgeschlossen, wenn alle Stücke da sind.
- Die alten Zähler bleiben stehen, damit gesammelte Stände nicht verfallen. Die neuen fangen bei null an – deshalb sagt der Dialog es dazu, solange weniger Stücke als Aufträge gezählt sind. Eine 0 neben vier erledigten Aufträgen wäre sonst ein Rätsel.

Automatisch zählt weiterhin nichts: Wer im Berufsfenster fertigt, erzeugt für Guild Copilot kein Ereignis. Das gehört zum fünften Punkt der Rückmeldung („aus dem Cockpit heraus herstellen") und kommt mit ihm.

### Was die Layoutprüfung jetzt prüft

`tests/validate.mjs` rechnete bisher nach, ob der ganze Inhalt über der Statuszeile bleibt. Mit einem Bildlauf ist die Frage hinfällig – gescrollt wird ohnehin. Geblieben ist die Frage dahinter: Sieht man ohne Scrollen überhaupt etwas? Geprüft wird deshalb der schlechteste Fall, in dem alle vier Überschriften zugleich stehen: Darunter muss noch eine ganze Zeile der eigenen Aufträge passen, sonst begänne das Board mit einer reinen Überschriftenwand. Dazu zwei neue Prüfungen: dass die Zeilen nicht unter die Bildlaufleiste laufen und dass der Bildlauf die Höhe seines Inhalts überhaupt setzt – ohne sie bliebe die Leiste stehen, egal wie viele Zeilen darunter warten.

**Der Tracker bleibt bei drei Zeilen.** Er ist als Kompakt-Anzeige gedacht und nennt im Titel die Gesamtzahl, wenn mehr anliegt; das Board daneben zeigt jetzt alles.

### Geändert

- `UI.lua`: Auftragsboard im Bildlauf mit wachsendem Zeilenvorrat (`CreateOrderSection`, `LayoutOrderSection`), vierter Abschnitt „Läuft in der Gilde", Ablehnen-Knopf samt Tooltip in den offenen Zeilen, Knopf „n abgelehnt" neben dem Filter, leere Abschnitte mit Auskunftszeile, Teilfertigung in der Zeilenüberschrift, Statistikdialog nach Stücken mit Gesamtzeile, Bildlauf springt beim Reiterwechsel nach oben;
- `Orders.lua`: `GetDeclined`/`IsDeclined`/`SetDeclined`/`CountDeclined` (rein lokal, nie gesendet), `GetBoard` trennt beteiligte und fremde laufende Aufträge und meldet den nächsten Handelnden mit, `Prune` räumt Ablehnungen zu verschwundenen Aufträgen weg, `GetStats`/`CountCompletion` zählen zusätzlich Stücke;
- `Database.lua`: `settings.declinedOrders`;
- `Locales.lua`: die Abschnittsüberschriften laufen jetzt über `GC.LFormat` statt als zusammengesetzter deutscher Text an der Sprachschicht vorbei – dazu die neuen Leerzustände, „Nicht für mich" und die Zähler „{n} abgelehnt"/„{n} fertig";
- `tests/smoke.lua`: fünf eigene Aufträge in einem Abschnitt, fremder laufender Auftrag im Gildenabschnitt, Höhe des Bildlaufinhalts, Ablehnen samt Zurücknehmen und Aufräumen, Teilfertigung in der Zeile, Stückzähler der Statistik;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Installer/README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.110.

## 0.9.109 – Der Praxistest: was der Sprachschalter noch aufdeckte

Der Owner hat die Sprachwahl auf English gestellt und Screenshots aller Seiten geschickt: „da fehlt noch einiges". Der Befund zerfiel in drei Klassen, und jede hatte einen eigenen Grund:

**Erstens die SetText-Lücke.** Die zentrale Übersetzung sass in `CreateLabel` – der ERZEUGUNG. Texte, die eine Auffrischung später per `SetText` setzt („Gezielte Rezeptsuche", „Wonach suchst du?", „Von Hand gewählt …"), liefen daran vorbei, obwohl ihre Übersetzungen längst in der Tabelle standen. Ein Codemod hat alle 162 SetText-Stellen mit reinem String-Literal (auch verkettete) durch `GC.L` geführt – dieselbe Erntemechanik wie beim Harvesting, nur schreibend.

**Zweitens die Spiel-Stammdaten.** Klassen, Specs und Berufe standen als deutsche Datenfelder in `Constants.lua` und erreichten die Anzeige unübersetzt. Die englischen Gegenstücke sind die offiziellen Begriffe (Wowhead-Klassen-, Talent- und Berufsseiten): Vergeltung→Retribution, Verstärkung→Enhancement, Schneiderei→Tailoring – dazu alle 27 Rekrutierungs-Labels und die sieben Empfehlungsbegründungen. Eine bewusste Kante: Bei Klassen, deren deutsche Ein- und Mehrzahl gleich lauten (Krieger, Jäger, Priester, Magier, Hexenmeister), trägt der Schlüssel die Einzahl – die Klassenliste zeigt dann „Warrior" statt „Warriors", was verständlich bleibt, während die falsche Mehrzahl in „Mage Arcane" ein Fehler wäre.

**Drittens die Composites.** Zusammengesetzte Anzeigen treffen als Ganzes nie einen Schlüssel; sie brauchen `GC.LFormat` an der Baustelle: Kopfzeilen-Status („{n} Nutzer{chars}, Daten vollständig"), Werkstatt-Abgleichzeile, Ausrüstungs-Status samt Zählbausteinen, Funde-Zähler, die Bewertungsgründe aus `EvaluateEnchant`, Zeitangaben (AgeLabel, LastOnlineLabel) und die „Weitere {n} …"-Hinweise. `JoinGerman` übersetzt seine Bindewörter jetzt selbst („A und B" → „A and B").

**Die bleibende Grenze, ehrlich benannt:** Was der Spielclient selbst benennt – gescannte Rezeptnamen, die grünen Verzauberungszeilen, Zonennamen –, liefert die WoW-API nur in der Clientsprache. Auf einem deutschen Client mit englischer Addon-Sprache bleiben genau diese Namen deutsch; nur die per Wowhead belegten Verbrauchsnamen kommen aus der eigenen Tabelle und sind auch dort englisch.

### Geändert

- `UI.lua`: 162 SetText-Stellen per Codemod durch `GC.L`; Composite-Stellen auf `GC.LFormat` (Kopfzeilen-Badge, Werkstatt-Abgleich, Ausrüstungs-Status, Funde, Zeitangaben, „Weitere {n} …"); Spec-/Berufs-/Status-Zellen der Übersicht übersetzen einzeln vor dem Verketten;
- `GearAudit.lua`: `DescribeSpec`, Befundtexte und `EvaluateEnchant`-Begründungen über die Sprachschicht;
- `Core.lua`: `JoinGerman` mit übersetzten Bindewörtern;
- `Locales.lua`: ~150 neue Einträge (Stammdaten, Kennzahlen, Composites, Resttexte);
- `tests/smoke.lua`: Stichproben für Stammdaten, `DescribeSpec` in beiden Sprachen, Composite-Schlüssel, Bindewörter;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.109.

## 0.9.108 – Die Sprachwahl und der Rest der Texte

Die Frage des Owners „Wo stelle ich die Sprache um?" hat die Lücke benannt: Es gab keinen Schalter – die Sprache folgte stumm der Clientsprache, und ausgerechnet der deutschsprachige Owner konnte die englische Oberfläche nie sehen. Dazu kam der Auftrag, Teilschritt 4 gleich mitzuliefern.

### Die Sprachwahl

Neue Karte „Sprache / Language" am Ende der Einstellungsseite (ans Seitenende gehängt wie die Werkstatt-Karte – verschiebt nichts Vermessenes): ein Zyklus-Knopf Automatisch → Deutsch → English, daneben „Jetzt neu laden". Die Wahl liegt ÜBER der Client-Automatik und wird von der Datenbank direkt nach dem Laden der SavedVariables angewandt (`GC.ApplyLanguageSetting`) – also VOR dem Aufbau der Oberfläche, deren ADDON_LOADED-Rückruf später registriert wurde. Bereits gebaute Beschriftungen behalten ihre Sprache; deshalb sagt die Karte ehrlich dazu, dass die Umstellung erst nach dem Neuladen vollständig wirkt, und bietet den Knopf gleich an.

### Teilschritt 4: die restlichen Texte

Ein Ernteskript hat aus UI.lua alle verbliebenen statischen Texte gezogen – auch die über `..` zusammengesetzten Hilfetexte, denn die zentrale Übersetzung in `CreateLabel` sieht den fertig verketteten String und trifft ihn als ganzen Schlüssel. 91 Fundstellen, davon ~80 übersetzt (der Rest sind Eigennamen und sprachgleiche Wörter). Für Meldungen mit Namen und Zahlen kam `GC.LFormat` dazu: Der Schlüssel bleibt ein fester Satz mit {platzhaltern}, die Werte kommen zur Laufzeit, ersetzt wird wortwörtlich (ein Prozentzeichen im Spielernamen bleibt ein Prozentzeichen). Damit sind die meistgesehenen Chatmeldungen übersetzt: Login-Zeile, Sitzungsstart und -ende, Rezept-Scan, Wartezeit-Erinnerung. **Benannter Rest:** seltene Fehler- und Randmeldungen im Chat (Sync-Warnungen, Import-Diagnosen) bleiben deutsch – sie sind dutzendfach verkettete Einzelsätze, fallen sauber zurück und lassen sich bei Bedarf einzeln nachziehen.

### Geändert

- `Locales.lua`: `GC.ApplyLanguageSetting`, `GC.LFormat`, ~90 neue Tabellenzeilen (statische Resttexte, Platzhalter-Meldungen);
- `Database.lua`: Vorgabe `language = "AUTO"`, Anwendung der Wahl direkt nach dem Laden;
- `UI.lua`: Sprachkarte samt Zyklus- und Neuladen-Knopf, Anzeige der aktuellen Wahl in `RefreshSettings`;
- `Core.lua`/`RaidMonitor.lua`/`Workshop.lua`: Kernmeldungen über `GC.L`/`GC.LFormat`;
- `tests/smoke.lua`: Sprachwahl (Vorgabe AUTO, EN/DE erzwingen, AUTO folgt dem Client), Platzhalter mit und ohne Übersetzung, Resttext-Stichprobe;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.108.

## 0.9.107 – Englisch in drei Teilschritten: Sprachschicht, belegte Spielbegriffe, Bedienelemente

Die Sync-Ebene ist seit jeher locale-frei (Item- und Zauber-IDs statt Namen, englische Clients scannen korrekt) – aber die Oberfläche sprach nur Deutsch. Der Owner hat die Übersetzung beauftragt, in zwei bis drei Teilschritten, mit einer harten Vorgabe: **Spielbegriffe werden nie frei übersetzt.** Jeder Name eines Gegenstands, Zaubers oder einer Verzauberung muss aus einer offiziellen Quelle belegt sein (Wowhead über die Spell-/Item-ID, oder der Spielclient selbst) – dieselbe Belegdisziplin wie bei `GC.EnchantRecipeKeys`.

### Deutsch als Schlüssel

`Locales.lua` definiert `GC.L(text)`: Auf deutschen Clients (GetLocale `de*`) gibt es jeden Text unverändert zurück, auf allen anderen schlägt es in der englischen Tabelle nach – **der deutsche Text selbst ist der Schlüssel**. Das ist die bewusste Gegenentscheidung zum üblichen Schlüsselsystem (`PAGE_TITLE_GEAR`): Das Addon ist deutschsprachig gewachsen, jede Zeile trägt ihren Text schon; ein Schlüsselsystem hätte tausende Stellen angefasst, bevor die erste Übersetzung sichtbar wird. So genügt eine Tabellenzeile je Text, und was (noch) fehlt, fällt sichtbar und harmlos auf Deutsch zurück – es gibt keinen halben Zustand, der bricht.

Teilschritt 1 übersetzt die Rahmen: Seitenleiste (Abschnitte und Reiter) und alle dreizehn Seitentitel samt Untertiteln. Verdrahtet ist das zentral – `CreatePageTitle` und die zwei Render-Stellen der Navigation rufen `GC.L`, die Aufrufer bleiben unangetastet. Zusammengesetzte Untertitel treffen als GANZE Verkettung ihren Schlüssel (die Tests prüfen beide); der eine Untertitel mit eingebauter Zahl läuft über einen `{n}`-Platzhalter-Schlüssel. Das alles sind eigene Addon-Texte, keine Spielbegriffe – gewöhnliche Übersetzungsarbeit, die erlaubt ist.

### Teilschritt 2: Spielbegriffe, einzeln belegt

Die harte Vorgabe wurde woertlich umgesetzt. Alle ~50 Namen der Verbrauchsliste tragen jetzt ein `nameEN`, und **jeder einzelne ist belegt**: am 08.08.2026 über die Item-ID gegen Wowheads TBC-Datenbank geprüft (`nether.wowhead.com/tooltip/item/<id>?dataEnv=5&locale=0`), die Item-ID steht als Kommentar am Eintrag. Zwei Funde aus der Verifikation, die den Aufwand rechtfertigen: Meine ersten Kandidaten-IDs für die vier Zangarmarschen-Salben waren falsch (die IDs gehörten zu Bauplänen) – die richtigen kamen aus den „Used by“-Daten der Spell-Seiten (Items 32902–32905). Und Wowheads **deutsche** Locale weicht vom Anniversary-Client ab („Überragendes Zauberöl“, „Elixier der erheblichen Stärke“) – die deutschen Namen bleiben deshalb beim Client als Quelle (Owner-Ablesung), nur Englisch kommt von Wowhead. Hätte ich Deutsch „nach Wowhead korrigiert“, wäre es falsch geworden – genau das belegt die Regel, nichts frei zu übersetzen. Die Sattgegessen-Zeilen tragen den offiziellen Buffnamen „Well Fed“ von ihren Spell-Tooltips; nur der Werte-Zusatz in Klammern ist wie im Deutschen eine eigene Beschriftung aus dem jeweiligen Bufftext. `GC.ConsumableDisplayName` wählt zur Laufzeit die Clientsprache; Verbrauchsprotokoll und Warcraft-Logs-Details lösen dabei über die mitgespeicherte Spell-ID neu auf, statt den beim Dekodieren eingefrorenen Namen weiterzureichen (dasselbe Muster wie 0.9.105/0.9.106). Slots heißen wie auf Wowheads Itemseiten (Head, Wrist, Finger, Trinket, Main Hand, Off Hand, Ranged).

### Teilschritt 3: eine Stelle statt tausend

Karten, Knöpfe und Schalter bauen ihre Beschriftung alle über `CreateLabel` – **eine** `GC.L`-Zeile dort übersetzt sie zentral, dazu `button:SetText` für spätere Umbeschriftungen („Sitzung beenden“, „Wirklich löschen?“). Kein Aufrufer wurde angefasst; die Arbeit steckt in der Tabelle: ~270 Einträge für alle Kartentitel, Knöpfe, Schalter, Spaltenköpfe und die statischen Status- und Zustandsmeldungen, geerntet per Skript aus den Aufrufstellen. **Benannter Rest:** Längere Hilfetexte in den Karten, dynamisch zusammengesetzte Statuszeilen und die Chat-Ausgaben (`GC:Print`) bleiben deutsch – das sind hunderte verkettete Sätze, die einzeln verlegt werden müssen; sie fallen sauber auf Deutsch zurück und sind der Kandidat für einen vierten Teilschritt, wenn der Owner ihn will.

### Geändert

- `Locales.lua` (neu): `GC.L`, englische Tabelle (Navigation, Titel, Untertitel, Spielbegriffe, ~270 statische UI-Texte), Fahrplan im Dateikopf;
- `Constants.lua`: `nameEN` je Verbrauchseintrag samt Item-ID-Beleg, `GC.ConsumableDisplayName`;
- `UI.lua`: zentrale Übersetzung in `CreateLabel`/`button:SetText`/`CreatePageTitle`/Navigation; Kategorien-, Verdikt- und Slot-Beschriftungen laufen durch `GC.L`; Warcraft-Logs-Details lösen per Spell-ID in der Clientsprache auf;
- `GearAudit.lua`: Slot-Labels über `GC.L` (drei Stellen);
- `RaidMonitor.lua`/`WarcraftLogs.lua`: Verbrauchsprotokoll bzw. Import speichern sprachneutral (Spell-ID) und zeigen in der Clientsprache;
- `GuildCopilot.toc`: `Locales.lua` direkt nach `Constants.lua`;
- `tests/smoke.lua`: Sprachtests für alle drei Teilschritte (deutscher Client unverändert, englischer übersetzt, Fallback, belegte Namen, Stichproben der Bedienelemente); Gegenproben ohne `Locales.lua` bzw. mit altem `Constants.lua` schlagen fehl;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Constants.lua`: Stand 0.9.107.

## 0.9.106 – Elf Mahlzeiten, null Öle: was der Verbrauchszähler nicht wusste

Der Owner kam mit zwei Screenshots aus dem Karazhan-Abend vom 07.08.: elf gezählte Essen bei einem einzigen Tod („Ich hab sicher keine 11 Food verbraucht") und null Öle, obwohl das Hervorragende Zauberöl nachweislich auf der Waffe saß. Beides waren keine Zufallsfehler, sondern zwei blinde Flecken derselben Zähllogik – und dazu kamen die drei in der vorigen Sitzung beschlossenen Ausbauten (Wartezeit-Erinnerung, Rezept-Lücken, Anwesenheit).

### Elf Essen: der Refresh des Weiteressens

Das Verbrauchsprotokoll lieferte den Beleg gleich mit: „Sattgegessen"-Einträge um 21:31:59, :32:09, :32:19 – exakter Zehnsekundentakt. Das ist kein dreifaches Essen, das ist EIN Essen: Wer sitzen bleibt, dessen Sattgegessen-Aura wird vom Client bei jedem Zehnsekundentick des Essens erneut gemeldet (`SPELL_AURA_REFRESH`), und jede Meldung zählte als neue Mahlzeit. Der Refresh wurde seinerzeit bewusst mitgezählt, damit ein Nachessen bei noch laufendem Buff nicht verloren geht – dass das Weiteressen denselben Ereignistyp feuert, war der übersehene Fall.

Die Lösung ist ein Entprellfenster je Teilnehmer und Spell-ID (`AURA_RECOUNT_WINDOW`, 60 s): Dieselbe Aura innerhalb der Minute ist dieselbe Mahlzeit. Ein zweites Gericht (andere Spell-ID) zählt sofort, ein echtes Nachessen Minuten später auch – und der Eintritts-Scan setzt denselben Merker, damit „beim Betreten gerade am Essen" nicht doppelt zählt. Der alte Regressionstest hatte die Gegenannahme („dreimal gegessen ist dreimal Essen") ausdrücklich festgeschrieben und wurde mitsamt Begründung umgedreht.

### Null Öle: die Verzauberung, die keine Aura ist

Waffenöle und Wetzsteine sind temporäre Verzauberungen AUF DER WAFFE. Der Eintritts-Scan liest Auren, das Kampfprotokoll sieht nur das Auftragen selbst – ein Öl, das vor dem Sitzungsstart aufgetragen wurde (der Regelfall, es hält eine Stunde), war für beide Wege unsichtbar. Jetzt wird beim Sitzungseintritt zusätzlich die eigene Waffe gelesen: `GetWeaponEnchantInfo` sagt, OB eine temporäre Verzauberung sitzt, der Waffentooltip sagt WELCHE. Gezählt wird ausschließlich ein Treffer der Muster in `GC.WeaponOilPatterns` (Zauberöl/Manaöl/Wetzstein/Gewichtsstein, beide Sprachen) – Windzorn, Flammenzunge und Schurkengifte sind ebenfalls temporäre Verzauberungen und zählen ausdrücklich nie. Geraten wird nichts: Kein Treffer, kein Fund.

Zwei ehrliche Grenzen, beide dokumentiert: Fremde Waffen gibt die API nicht her (wer sein Öl WÄHREND der Sitzung neu aufträgt, zählt weiterhin über das Wirkereignis), und der Tooltip-Leser ist als eigene Methode herausgelöst, damit die Tests ihn mit festen Zeilen füttern können. Nebenbefund derselben Meldung: Die „Superior"-Öle hießen in der Verbrauchsliste „Überragend", der deutsche Client sagt „Hervorragend" – korrigiert, direkt am Client abgelesen.

### Wartezeit-Erinnerung: das Wissen bekommt seinen Moment

Die Werkstatt kennt die Sperren der eigenen Charaktere seit 0.9.97 – gemeldet hat sie deren Ablauf nie. Jetzt: beim Login gesammelt (nach 25 s, wenn das Login-Rauschen vorbei ist), während der Sitzung per Zeitgeber zum nächsten Ablauf, je Sperre genau einmal (der Merker hält den Ablaufzeitpunkt fest; eine neue Umwandlung ergibt einen neuen Zeitpunkt und wieder genau eine Meldung). Die Meldung sagt „abgelaufen", nicht „frei" – der gespeicherte Zeitpunkt bleibt eine Untergrenze, für eigene Charaktere ist er praktisch exakt. Abschaltbar in den Einstellungen (Werkstatt-Karte), Vorgabe an. Der Zeitgeber plant nur weiter, wenn die Zeit den Ablauf wirklich erreicht hat – in Umgebungen mit sofort feuernden Zeitgebern (Tests) liefe die Kette sonst endlos.

### Rezept-Lücken: die Umkehrung der Bestell-Brücke

`GetOrderableEnchant` (0.9.104) beantwortet „was kann ich mir bestellen?“. Die neue `GetMissingRecommendedRecipes` beantwortet die Offiziersfrage dahinter: Welche Empfehlungen des Regelsatzes kann NIEMAND herstellen? Regelsatz × `EnchantRecipeKeys` × Katalog, gefiltert auf die laufende Content-Phase, OPTIMAL vor SOLID, deterministisch sortiert. Sichtbar als Fenster hinter dem Knopf „Rezept-Lücken der Gilde" unten in der Spielerkarte der Ausrüstungsseite (dieselbe Bauweise wie „Sitzung löschen"); das offene Fenster zieht mit dem Rezeptabgleich mit (WORKSHOP_UPDATED). IMPROVABLE-Regeln fehlen bewusst – eine ausdrücklich schwache Verzauberung fehlt niemandem.

### Anwesenheit: das lange Gedächtnis neben der kurzen Ablage

Die Ablage der Auswertungen ist bewusst klein und kurzlebig (24+12 Plätze, 30 Tage) – für „wie zuverlässig ist jemand über die Saison?" taugt sie nicht. Die Anwesenheit bekommt deshalb ihr eigenes, dauerhaftes Aggregat (`guildData.attendance`): je Abend ein kleiner Eintrag (wer, welcher Anteil), gespeist aus JEDER eintreffenden Fassung – auch einer, die die Ablage gleich wieder aussortiert, denn der Höchstwert-Merge je Teilnehmer (dasselbe Argument wie bei der Reparatur: niemand war länger da, als er da war) kann durch eine zusätzliche Quelle nur vollständiger werden. Drei Regeln halten die Quote belastbar: nur Abende mit Bosskampf (Probesitzungen verdünnen sonst), nur echte Anwesenheitsquellen (Live/Sync/Reparatur ab Zählregel-Version 2 – Warcraft Logs und Logdatei messen Encounter-Zeit und zahlten systematisch zu niedrig ein), und ein verpasster Abend zählt mit null, sonst stünde der Einmalgast bei 100 %. Deckel 60 Abende (älteste weichen), „Abend gelöscht" räumt auch hier. Sichtbar hinter dem Knopf „Anwesenheit" auf der Raidauswertungsseite: je Spieler Abende, Ø-Anteil (grün ≥ 75 %, gelb < 40 %) und letzter Abend.

### Nachbesserung am selben Tag: „Verzauberung 3010" und die abgeschnittene Ausrüstungsseite

Der Owner zeigte die Ausrüstungsseite: Statuszeile endet auf „gilt au…", das Prüfalter heißt „vor 8157 Min.", und in den Slots stehen „Verzauberung 3010/1593/2564" – sogar im Tooltip. Der ID-Befund ist DASSELBE Muster wie die Item-Namen in 0.9.105, nur eine Ebene höher: `ResolveEnchantName` vergleicht den Tooltip des verzauberten Links mit der nackten Fassung; bei kaltem Item-Cache rendern beide identisch dünn, der Unterschied ist leer – und dieser Fehlversuch wurde als „kein Name" **für die ganze Sitzung gecacht**, während `audit.hydrated` jede spätere Neuauflösung verhinderte. Zwei Griffe schließen den Kreis: Ein Fehlschlag wird nur noch gemerkt, wenn der Gegenstand nachweislich geladen war (der `GetItemInfo`-Aufruf stößt das Nachladen zugleich an), und jedes Lesen eines hydrierten Audits trägt fehlende Namen nach (`HealEnchantNames`) – samt neu gebauter Bewertung und Begründung, sonst stünde der Satz mit der ID einfach weiter da. Dazu die Lesbarkeit: kürzere Regelsatz-Zeile statt abgeschnittener vierter Zeile, Prüfalter als Minuten/Stunden/Tage, HINWEIS-Spalte von 214 auf 240 Pixel (Slot und Sockel gaben Reserve ab).

### Geändert

- `GearAudit.lua`: negativer Namenscache nur bei geladenem Gegenstand, `HealEnchantNames` bei jedem Lesen hydrierter Audits;
- `RaidMonitor.lua`: `AURA_RECOUNT_WINDOW`/`MarkAuraCounted` (Kampfprotokoll UND Eintritts-Scan), `ScanWeaponConsumables`/`FindWeaponOilName`/`ReadWeaponEnchantLines`, `RecordAttendance`/`GetAttendanceOverview`, Anwesenheits-Aufräumen in `DeleteEvening`;
- `Constants.lua`: `GC.WeaponOilPatterns`, Öl-Namen nach deutschem Client;
- `Workshop.lua`: `CollectDueCooldownReminders`/`AnnounceDueCooldowns`/`ScheduleCooldownReminder` samt Login-Haken und Neuplanung nach jedem Scan;
- `GearAudit.lua`: `GetMissingRecommendedRecipes`;
- `Database.lua`: Vorgabe `cooldownReminder`, Merker `cooldownReminded`, Gildenzweig `attendance`;
- `UI.lua`: Erinnerungs-Schalter in der Werkstatt-Karte der Einstellungen, Fenster samt Knöpfen für Rezept-Lücken (Ausrüstungsseite) und Anwesenheit (Raidauswertungsseite); Ausrüstungsseite lesbar (kurze Regelsatz-Zeile, humanes Prüfalter, breitere HINWEIS-Spalte);
- `tests/smoke.lua`: fünf neue Blöcke (Weiteressen, Waffenöl samt Windzorn-Gegenprobe, Erinnerung einmal-je-Sperre samt Schalter, Lücke schließt sich mit Hersteller, Anwesenheits-Höchstwert samt Löschweg); der alte Dreifach-Essen-Test trägt jetzt die richtige Annahme; Gegenproben gegen den 0.9.105-Stand schlagen in allen drei Kerndateien fehl;
- `tests/validate.mjs`, `CHANGELOG.md`, `README.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.106.

## 0.9.105 – Der Platzhalter, der das Nachladen überlebte, und der Abend, der schon läuft

Der Owner hat das Addon zum Gesamtaudit gestellt: Synchronisation, Auswertung, Stabilität, das 250-Online-Prinzip – und zwei konkrete Befunde. Auf dem Screenshot der Werkstatt stand in den Materialien „16× Item #25708“ statt „Schweres Knotenhautleder“, und die Sitzungsliste kannte einen Raidabend erst, wenn er vorbei war.

### „Item #25708“: einmal falsch aufgelöst, für immer falsch angezeigt

Rezepte wandern locale-frei als Item- und Zauber-IDs durch die Gilde; den Namen löst jeder Client in seiner eigenen Sprache aus dem Item-Cache auf. Der Fehler saß im WANN: Aufgelöst wurde genau einmal, beim Dekodieren des empfangenen Pakets. Kannte der Cache den Gegenstand in dem Moment nicht – nach einem frischen Login der Normalfall –, wurde der Notbehelf „Item #25708“ als Name GESPEICHERT und danach bei jedem Katalogaufbau unverändert weiterkopiert. Das Nachladen des Gegenstands (`GET_ITEM_INFO_RECEIVED`) baute den Index zwar neu, aber der Neubau las ja nur den gespeicherten Platzhalter. Die Rezeptnamen selbst waren von diesem Fehler nie betroffen – sie werden seit jeher je Aufbau über `ResolveRecipeName` neu aufgelöst; genau deshalb stimmte auf dem Screenshot die Liste links, während rechts die Reagenzien kaputt waren.

Drei Dinge ändern sich, und zusammen schließen sie den Kreis:

- **Gespeichert wird kein Platzhalter mehr.** Was der Cache beim Dekodieren nicht kennt, bleibt `nil` – eine fehlende Antwort statt einer falschen.
- **Aufgelöst wird bei jedem Katalogaufbau erneut** (`ResolvedReagentCopies`): Der gespeicherte Name ist nur noch Fallback für den Fall, dass der Cache weiterhin schweigt – und ein gespeicherter Platzhalter aus früheren Versionen gilt dabei ausdrücklich NICHT als Name (`IsPlaceholderName`). Damit heilen sich auch Alt-Bestände von selbst.
- **Der Kreis ist geschlossen:** Der Auflösungsversuch selbst stößt das Nachladen beim Server an, `GET_ITEM_INFO_RECEIVED` → `ScheduleNameRefresh` verwirft den Index, der nächste Aufbau trägt den echten Namen ein. Bis dahin zeigt die Anzeige den Platzhalter als das, was er ist: ein Übergangszustand von Sekunden, kein Dauerzustand.

### Die laufende Sitzung gehört in die Liste

„Auswerten“ ging bisher erst nach „Sitzung beenden“: Die Liste zeigt gespeicherte Zusammenfassungen, und die entsteht erst beim Ende. Wer zwischendurch wissen wollte, wer wie lange da war und was eingeworfen wurde, sah nur die Statuszeile mit zwei Zahlen.

Jetzt baut `BuildLiveSummary` aus der laufenden Sitzung dieselbe Verdichtung wie das Sitzungsende – nur ohne irgendetwas anzuhalten oder abzulegen. Die Momentaufnahme führt die Sitzungsliste grün als „läuft“ an, ist wählbar wie jede Auswertung (Teilnehmerliste, Sortierung, Tooltip, Detailfenster) und zählt laufende Anwesenheitsuhren bis „jetzt“ hoch, ohne sie anzufassen. Das gilt für JEDEN, der den Abend mitschreibt – also auch für alle, die über Startruf (RS) oder Herzschlag (RH) eingestiegen sind: Bei denen erscheint der Abend in der Sekunde, in der ihr Client mitzuschreiben beginnt. Drei Kanten waren zu entgraten:

- Der Schlüssel der Momentaufnahme (Kennung + Quelle LIVE) ist derselbe wie der der späteren gespeicherten Auswertung – die Auswahl bleibt beim Beenden einfach stehen und zeigt nahtlos auf die Ablage.
- Die Momentaufnahme gruppiert keine gespeicherten Quellen unter sich: Sie verschwindet mit dem Ende, und was unter ihr hinge, fiele mit ihr aus der Liste.
- Löschen geht nicht – sie liegt nirgends. Vorher hätte der Löschknopf Erfolg gemeldet und nichts getan.

Nicht gebaut, bewusst: eine laufende Übertragung des Zwischenstands an Nicht-Teilnehmer. Wer nicht im Raid mitschreibt, bekommt die Auswertung wie bisher nach dem Ende (`DistributeSummary`) – ein Dauerstrom von Zwischenständen an 250 Online wäre genau der Kanaldruck, den das 250-Online-Prinzip verbietet.

### Das Audit: Befund gut, eine Lücke

Der Rest des Audits bestätigt die Bauweise: Alle gildenweiten Anfragen laufen über Wahl (`IsElectedResponder`), Streuung oder beides; alle Merklisten sind gedeckelt und verfallen; die Sendewege takten sich über ChatThrottleLib bzw. das eigene Budget; die beiden OnUpdate-Rahmen (Bulk, Herzschlag) schlafen, wenn nichts anliegt. EINE Empfangstabelle war noch ungedeckelt: die eingehenden Rekrutierungs-Teiltransfers in `WarcraftLogs.lua` – jede andere (Werkstatt 64, Ausrüstung 128, Raidauswertung 40) begrenzt die Zahl gleichzeitig offener Übertragungen. Sie bekommt dieselbe Regel (32, beim Überlauf weicht die älteste unfertige), womit die letzte Stelle geschlossen ist, an der ein Paketsturm Speicher binden konnte, der erst nach fünf Minuten verfiel.

### Geändert

- `Workshop.lua`: `LookupItemName`/`IsPlaceholderName`/`ResolvedReagentCopies`; Dekoder speichern `nil` statt Platzhalter; Katalogaufbau löst Reagenziennamen je Aufbau neu auf;
- `RaidMonitor.lua`: `BuildLiveSummary`; `BuildSummary` zählt offene Anwesenheitsuhren bis zum Stichtag; `GetEvenings`/`GetSummaryByKey` kennen die Momentaufnahme; `DeleteEvening` lehnt sie ab;
- `WarcraftLogs.lua`: `RECRUITMENT_MAX_INCOMING` (32) mit Verdrängung der ältesten unfertigen Übertragung;
- `UI.lua`: „läuft“-Markierung in Sitzungsliste und Kopfzeile (Textmarkierung statt Symbol – die WoW-Schrift zeichnet für U+25CF nur einen Kasten, die CI-Prüfung fängt das ab);
- `tests/smoke.lua`: Platzhalter wird nie gespeichert, nachgeladener Name erreicht die Details, Alt-Platzhalter heilt; Live-Eintrag ab Start, Anwesenheit im Zwischenstand ohne Anhalten der Uhr, kein Löschen, nahtloser Übergang beim Beenden – beide Gegenproben gegen den 0.9.104-Stand schlagen fehl;
- `CHANGELOG.md`, `Constants.lua`, `GuildCopilot.toc`: Stand 0.9.105.

## 0.9.104 – Pro-Enchanters-Gedanken, gildenfest gemacht

Der Owner fragte, ob sich aus dem Addon Pro Enchanters (GPLv3, 211.000+ Downloads) etwas für Guild Copilot gewinnen lässt – „natürlich selbst gebaut statt kopiert“. Die Antwort nach Sichtung der CurseForge-Beschreibung: Das Workorder-System hat Guild Copilot längst (Gildenaufträge), und die statische Rezeptdatenbank mit eigenen Lokalisierungen wäre ein Rückschritt – unser Scan liest live und verschlüsselt locale-frei über Item-/Zauber-IDs. Vier Dinge lohnten sich, alle nach dem 0.9.101-Muster (Prinzip übernehmen, Code nicht – GPLv3 passt ohnehin nicht in ein MIT-Repository):

### Die Brücke: Regelsatz trifft Werkstatt

Das Beste an der Idee „Verzauberungs-Addon“ ist im Gildenkontext etwas, das Pro Enchanters gar nicht kann: Die Ausrüstungsprüfung weiß je Slot und Archetyp, WAS optimal wäre (EnchantRuleSet); die Werkstatt weiß, WER es herstellen kann. Verbunden waren die beiden nie, weil zwei ID-Welten – Regeln hängen an der Enchant-ID auf dem Gegenstand, Rezepte an der Zauber-ID des Crafts, und keine WoW-API übersetzt dazwischen. Die Übersetzung ist jetzt eine kuratierte Tabelle (`GC.EnchantRecipeKeys`): 27 Zuordnungen, jede einzeln am 07.08.2026 auf der Wowhead-TBC-Zauberseite belegt (die Effektzeile nennt die Enchant-ID). Nach dem Vorbild des Regelsatzes gilt: Geraten wird nichts – sechs Verzauberungen und die Beinrüstungen/Zauberfäden ließen sich nicht im Budget belegen und stehen als benannte Lücke im Tabellenkommentar; sie machen einfach keinen Vorschlag.

Sichtbar wird die Brücke als ein Knopf auf der Ausrüstungsseite, nur am EIGENEN Charakter: Der erste verbesserbare Slot mit bestellbarer Empfehlung bekommt „Bestellen: <Slot>“, der Tooltip nennt Empfehlung und Hersteller, der Klick öffnet den üblichen Auftragsdialog mit dem Rezept. `GearAudit:GetOrderableEnchant` wählt OPTIMAL vor SOLID und bei Gleichstand deterministisch die kleinste Enchant-ID – jeder Aufruf nennt dieselbe Empfehlung.

### Handelsfenster-Helfer

In TBC werden Verzauberungen im Handelsfenster gewirkt, und auch Übergaben laufen dort – exakt der Lieferweg „TRADE“ der Gildenaufträge. Beginnt ein Handel mit jemandem, mit dem Aufträge offen sind (beide Richtungen, `GetOrdersWithCounterpart`), erscheint daneben ein kleines Fenster mit bis zu drei Aufträgen und ihrer üblichen Primäraktion – derselben, die auch das Board zeigt (`OrderPrimaryAction` wird wiederverwendet, es gibt keinen zweiten Begriff von „dran sein“). Bewusst übernommen aus Pro Enchanters: im Kampf kein Fenster. Bewusst anders: kein automatischer Statuswechsel – markiert wird per Klick, wie überall.

### Flüsterbefehl „!rezept“

Pro Enchanters beantwortet „!enchant boots - stamina“ mit einer Matsliste. Bei uns antwortet der Katalog: Name, Reagenzien, bis zu drei Hersteller, ein Flüstern, höchstens 255 Bytes. Drei Grenzen, die dort so nicht existieren: Der Schalter steht in den Einstellungen und ist AUS, bis ihn jemand setzt – Guild Copilot hat bis heute nie ungefragt geflüstert, und das bleibt eine ausdrückliche Entscheidung („Datenschutz und Fairness“). Es antwortet nur Gildenmitgliedern – der Katalog ist Gildenwissen. Und je Absender greift eine Drossel. Ein erkannter Befehl gilt außerdem IMMER als behandelt und landet nie im Bewerber-Postfach, sonst stünde jeder Rezeptfrager als Interessent da.

### Zweisprachiger Suchindex

Die eigentliche Sprachlücke nach 0.9.102: Der Katalog löst Namen über Item-/Zauber-ID in der Sprache DES BETRACHTERS auf – im Suchtext stand deshalb nur eine Sprache. Ein englischer Gildie sucht „Boar's Speed“, der deutsche Client hat „Ebergeschwindigkeit“ indiziert, nichts trifft. Jetzt trägt der Suchtext zusätzlich die Schreibweise des Scanners (`scannedName`), wenn sie von der aufgelösten abweicht – beide Sprachen finden denselben Eintrag, und der Flüsterbefehl erbt das automatisch.

### Geändert

- `Constants.lua`: `GC.EnchantRecipeKeys` (27 belegte Zuordnungen samt benannter Lücken);
- `GearAudit.lua`: `GetOrderableEnchant` (Slot als Eintrag mit `.key`, wie `RuleApplies` es erwartet);
- `Workshop.lua`: `scannedName` im Katalog und Suchtext, `AnswerRecipeWhisper` mit Schalter, Gildengrenze und Drossel;
- `Orders.lua`: `GetOrdersWithCounterpart` (beide Richtungen, nur übergabefähige Status);
- `Chat.lua`: Werkstattbefehle laufen vor der Bewerbererfassung;
- `UI.lua`: Handelsfenster-Helfer (TRADE_SHOW/TRADE_CLOSED, Auffrischung über ORDERS_UPDATED), Bestellknopf samt Tooltip auf der Ausrüstungsseite, Einstellungs-Karte „Werkstatt“ am Seitenende (verschiebt keine vermessene Karte);
- `tests/smoke.lua`: beide Sprachen treffen denselben Eintrag, Flüsterbefehl aus/an/Drossel/Gildenfremde, Handelspartner-Aufträge samt Helfer und Primäraktion, Brücke wählt OPTIMAL und schweigt ohne Hersteller; Gegenprobe gegen den 0.9.103-Stand schlägt fehl;
- `tests/validate.mjs`: Muster für alle vier Bausteine;
- `README.md`, `CHANGELOG.md`: Stand 0.9.104.

## 0.9.103 – Der Botendienst: Daten Dritter, aber nie der ganze Raum

0.9.102 hatte die Lücke sichtbar gemacht und die Entscheidung offengelassen, ob sie auch aus zweiter Hand gefüllt werden soll. Der Owner hat sie noch am selben Tag getroffen: ja – Offline-Spieler werden über andere synchronisiert. Mit einer Vorgabe, die er als Grundsatz formuliert hat: Es muss auch gut gehen, wenn in einer 500er-Gilde 250 Leute online sind. Einer fragt in die Klasse, ein, zwei antworten – nicht 250, die durcheinanderreden.

### Warum das die Autoritätsregel nicht bricht

Die Sorge aus 0.9.102 war, dass Daten aus zweiter Hand die klare Regel „jeder meldet nur den eigenen Account“ aufweichen. Sie bleibt in dem Punkt bestehen, auf den es ankommt: Ein Bote erfindet keinen Stand, er reicht den STAND DES BESITZERS weiter – Hersteller (craftedBy), Zeitstempel und Fingerabdruck stammen unverändert aus dessen letztem Manifest. Die Übernahme beim Empfänger entscheidet damit nach derselben `ProfessionWins`-Regel wie immer, und ein Bote kann einen neueren Stand nie zurückdrehen; schlimmstenfalls liefert er einen älteren, der beim Empfänger schlicht verliert (die Katalogdetails nimmt der trotzdem mit, Reagenzien hängen nicht am Spieler). Genau dafür trägt jeder Transfer seit 0.9.26 das craftedBy-Feld – der Botendienst verallgemeinert nur, was für Twinks längst galt. Alte Clients verstehen die Lieferung deshalb ohne jede Änderung.

### Drei Wege, alle mit genau einem Sprecher

- **Adressierte Schlüssellisten-Anfrage.** Das KR-Paket trägt ein sechstes Feld: den Namen des Boten. Es antwortet GENAU der Genannte, aus seinem Herstellerindex (`BuildKeyListMessages` liest jetzt `recipeKeys` wie `recipes`); alle anderen setzen wie bisher nur ihre Unterdrückung. Ein alter Client liest das Feld nicht und bleibt stumm – deshalb wird nur adressiert, wer `workshop6` meldet, sonst endete der Zyklus grundlos als „unvollständig“.
- **Die Lücke fragt sich selbst.** Ein Bestandsmanifest kommt von einem, der die Stände nachweislich hat und nachweislich online ist. Aus jeder gemerkten Lücke wird deshalb sofort eine Vormerkung samt adressierter Anfrage an den Absender – der Besitzer muss nicht mehr online kommen. Die 60-Sekunden-Unterdrückung sorgt dafür, dass von 250 Clients mit derselben Lücke nur der Schnellste fragt; die Antwort läuft über den Gildenkanal und heilt alle auf einmal.
- **Rezeptdetails von Gewählten.** Eine Nachforderung („N“) beantworten neben dem Besitzer höchstens zwei Gewählte aus ihrem Katalog – nur Einträge mit vollständigen Reagenzien, nur Rezepte, die der Hersteller laut Index wirklich kann, und nur, wenn der Besitzer nicht selbst als Addon-Nutzer online ist. Gestreut über dasselbe Fenster wie die Manifestantworten, mit Doppelantwort-Dämpfung: Schon das erste Teilpaket einer fremden Lieferung setzt einen Vermerk (`NotePeerAnswer`, dieselbe Bauweise wie beim Gildenprofil), und wer ihn sieht, schweigt. In aller Regel liefert damit genau einer.

Die Bestandsmanifest-Antwortenden selbst sind von drei auf zwei zurückgenommen – derselbe Grundsatz, und zwei reichen: In einer eingeschwungenen Gilde kennt jeder länger laufende Client den vollen Bestand.

### Der Knopf, der nichts zu tun schien

Aus demselben Gespräch: „Daten anfragen“ gab keine Rückmeldung. Die gab es dem Code nach – „der Erfolg steht im Balken darunter“ (0.9.86) –, nur sprang der Balken erst an, wenn die ERSTE Antwort eintraf, und die kommt mit bis zu 31 Sekunden Streuung. Eine halbe Minute sichtbares Nichts ist keine Rückmeldung. Der Balken trägt jetzt sofort die Quittung („Anfrage gesendet – die Antworten treffen gestreut ein“), der Knopf zählt sie herunter und sperrt sich solange; echter Fortschritt löst die Quittung ab, sobald er da ist. Dazu eine Drossel in `RequestGuildData` selbst: Ein Doppelklick löst keine zweite gildenweite Antwortwelle aus – die Antwortenden drosselten denselben Frager zwar schon (requestReplies), aber die Pakete gingen trotzdem raus.

### Geändert

- `Constants.lua`: Fähigkeit `workshop6`;
- `Workshop.lua`: sechstes KR-Feld samt Botenantwort aus dem Herstellerindex, `BuildKeyListMessages` liest `recipeKeys` wie `recipes`, Bestandslücken aus „CM“ erzeugen Vormerkung und adressierte Anfrage (`relayTarget` bis in `SendKeyListRequest`), Detail-Boten (`ScheduleRelayedRecipeAnswer`/`SendRelayedRecipeAnswer`) mit Besitzer-Stand, Wahl und Dämpfung (`NotePeerAnswer`-Vermerk „WDETAIL“ beim Empfang), Bestandsmanifest-Antwortende von drei auf zwei, Anfrage-Drossel `lastGuildRequestAt`;
- `UI.lua`: Quittung des Anfrage-Knopfs im Balken (`workshopRequestAckAt`, Countdown, Sperre), Lücken-Texte nennen den Boten statt „warten auf den Besitzer“;
- `tests/smoke.lua`: adressierter Bote liefert mit Besitzer-Stand, Nicht-Adressierte schweigen, „CM“ erzeugt die adressierte Anfrage, Detail-Bote liefert nur Vollständiges und schweigt nach fremder Lieferung, Knopf quittiert, sperrt und drosselt; Gegenprobe gegen den 0.9.102-Stand schlägt fehl;
- `tests/validate.mjs`: Muster für Botendienst, Dämpfung und Quittung;
- `README.md`, `CHANGELOG.md`: Stand 0.9.103.

## 0.9.102 – „Vollständig synchronisiert“ war zweimal gelogen

Ausgangspunkt war ein Screenshot-Vergleich des Owners vom 07.08.2026: Sein Client zeigt 1181 Rezepte von 25 Herstellern aus 16 Berufen und 25 bekannte Nutzer – Brooklees Client 767 Rezepte von 7 Herstellern aus 11 Berufen und 4 bekannte Nutzer. Beide Statuszeilen behaupteten dasselbe: „Vollständig synchronisiert • Stand: gerade eben.“ Zwei Ursachen, beide in dieser Fassung behoben – und die 16 Berufe im GRÖSSEREN Bestand waren gleich der Beleg für die dritte.

### Warum die Zeile log, obwohl jede einzelne Zahl stimmte

Rezepte wandern nur vom besitzenden Account zu dem, der gerade zuhört; niemand leitet Daten Dritter weiter. Der Status maß aber ausschließlich die eigene Warteschlange: ausgehende Pakete, eingehende Transfers, bekannte Lücken aus empfangenen Manifesten. Von den 21 Nutzern, die Brooklee nie gleichzeitig online gesehen hat, kam nie ein Manifest – was der Client nicht weiß, konnte er nicht vermissen, also war „nichts offen“, also stand da „vollständig“. Der Kommentar in `GetSyncStatus` benannte das Problem wörtlich („Belegbar ist nur ‚nichts offen‘“); die Oberfläche zog nur bei NULL je gesehenen Peers die Konsequenz und kippte ab dem ersten auf die Vollaussage.

Dazu kam ein handfester Zähler-Fehler: Ein per Manifest angekündigter Beruf galt 120 Sekunden als „kommt noch“ – und verschwand danach ersatzlos aus der Rechnung, ohne als Fehlschlag verbucht zu werden. Der Zyklus endete mit leerer Fehlbilanz, stempelte „zuletzt vollständig: jetzt“ und über dem nachweislich bekannten Loch stand wieder die Vollaussage. Der Kommentar an der Frist behauptete „der Balken sagt das“ – es gab keine Stelle, die es sagte.

### Die Bestandslücke: Wissen weitergeben, nicht Daten

Neu ist das Bestandsmanifest („CM“): Auf eine Werkstatt-Anfrage antworten bis zu drei gewählte Clients zusätzlich mit den Kenndaten der ihnen bekannten FREMDEN Hersteller – Hersteller, Beruf, Zeitstempel, Anzahl, Fingerabdruck; dieselben Datensätze wie im eigenen Manifest, nur eben aus zweiter Hand. Ausdrücklich NICHT übernommen wird der Inhalt: Die Rezeptdaten liefert weiterhin allein der Besitzer, wenn er das nächste Mal online ist. Aus dem fremden Manifest entsteht beim Empfänger nur eine **Bestandslücke** – ein Eintrag „diesen Beruf gibt es, seine Daten fehlen hier“. Sie zählt bewusst nicht als offene Arbeit (anfordern ließe sich nichts, der Balken drehte sonst ewig), sondern hält die Statuszeile ehrlich: „Nichts offen, aber unvollständig • Rezepte von N Herstellern fehlen noch (…) – sie kommen, sobald deren Besitzer wieder online sind.“ Erst ohne bekannte Lücke, mit mindestens einem echten Vergleichspartner, steht wieder „Vollständig synchronisiert“ da – jetzt mit Reichweite („abgeglichen mit N weiteren Nutzern“), denn genau die war vorher der stille Vorbehalt. Lücken leben in den SavedVariables, räumen sich beim Eintreffen der Daten (`ClaimRecipes`), beim Gildenaustritt des Herstellers oder nach dreißig Tagen selbst weg; Ausgetretene prüft dieselbe Bleiberegel wie beim Herstellerindex, mit dem Melder als drittem Bürgen.

Die abgelaufene Vormerkung wandert jetzt in beide Richtungen: als Fehlschlag in die Zyklus-Bilanz („Abgleich unvollständig • ein angekündigter Beruf blieb aus (Hersteller offline?)“) und als Bestandslücke in den Dauerzustand. Die Frist stieg von 120 auf 180 Sekunden – wer sichtbar „unvollständig“ meldet, sollte nicht an einer knappen Uhr scheitern: Manifestantwort (bis 31 s Streuung), Schlüssellisten-Anfrage und ein voller Sendepuffer brauchen zusammen schon mal länger.

### Englische Clients: ein Beruf, ein Schlüssel

Der lokalisierte Berufsname war zugleich Speicher- und Vergleichsschlüssel. Ein englischer Client legt „enchanting“ ab, ein deutscher „verzauberkunst“ – dieselbe Verzauberkunst zählte doppelt (daher die 16 „Berufe“), der Filter fand nur die eigene Schreibweise, und die Eigenberuf-Erkennung lief komplett ins Leere: Das Profil trägt den deutschen Namen aus dem Dropdown, der Scan legte den englischen Schlüssel ab, also mahnte die Statuszeile auf ewig „Verzauberkunst – Berufsfenster einmal öffnen“ an – exakt Brooklees zweite Zeile im Screenshot, sein Fenster war längst geöffnet.

Kanonisch ist jetzt die gefaltete deutsche Schreibweise – nicht aus Vorliebe, sondern weil aller Bestand bereits so verschlüsselt ist: Deutsche Daten brauchen keine Wanderung, nur englische werden zugeordnet. Die Tabelle (`GC.ProfessionDefinitions` in Constants.lua) trägt je Beruf deutschen Namen, englischen Namen, Fensterzauber in beiden Sprachen und Altschreibweisen; der bisherige Alchemie/Alchimie-Sonderfall in `NormalizeKey` ist darin aufgegangen, genauso der Fenstername des Bergbaus („Schmelzen“/„Smelting“ zählen als Bergbau – womit nebenbei der deutsche Dauerhinweis „Bergbau fehlt noch“ trotz geöffneten Schmelzen-Fensters fällt). Kanonisiert wird an jeder Grenze: beim eigenen Scan (gespeichert und angezeigt wird der deutsche Name – das Addon ist deutschsprachig), im Empfangspfad für Transfers und Manifeste alter englischer Clients, in `ClaimRecipes` als zweiter Verteidigungslinie, und einmalig als Wanderung über eigene Berufe, Twink-Bestände, Herstellerindex und Katalog (bei doppelten Ständen desselben Herstellers gewinnt nach derselben Regel wie überall `ProfessionWins`). Angefragt wird beim Absender dagegen mit DESSEN Schlüssel („requestKey“): Ein Altclient englischer Sprache findet „verzauberkunst“ in seinen Daten nicht, seinen eigenen Schlüssel versteht er immer. Die Berufserkennung aus den Fähigkeitszeilen versteht jetzt beide Sprachen, und der Assistenten-Knopf wählt den ersten Fensterzauber, den das Zauberbuch kennt – `CastSpellByName("Verzauberkunst")` tut auf einem englischen Client schlicht nichts.

### Was bewusst offen bleibt

Die Rezeptdaten eines Offline-Spielers liegen bei anderen Clients vollständig vor und würden sich über Zeitstempel und Fingerabdruck sogar konfliktfrei weiterreichen lassen. Das bleibt ausgelassen: Daten Dritter zu verteilen vervielfacht den Kanalverkehr genau dann, wenn viele online sind, und bricht die bisher klare Autoritätsregel „jeder meldet nur den eigenen Account“. Erst einmal muss die Lücke sichtbar sein; ob sie auch aus zweiter Hand gefüllt werden soll, ist eine eigene Entscheidung. Schemaversion 7 bleibt: „CM“ ist additiv, Altclients werfen das Paket stumm weg und bekommen es dank `workshop5`-Fähigkeit gar nicht erst geschickt.

### Geändert

- `Constants.lua`: `ProfessionDefinitions` samt Alias-Tabelle und Helfern (`CanonicalProfessionKey`, `CanonicalProfessionName`, `ProfessionEnglishName`, `ProfessionWindowSpellCandidates`), Fähigkeit `workshop5`; `ProfessionWindowSpells` ist darin aufgegangen;
- `Workshop.lua`: `NormalizeKey` über die Alias-Tabelle, Kanonisierung in Scan, Empfangspfad und `ClaimRecipes`, Wanderungen für eigene Berufe, Twinks, Herstellerindex und Katalog, ausgebliebene Vormerkungen (`GetLostWantCount`/`ResetLostWants`), Bestandslücken (`NoteCoverageGap`, `ClearCoverageGapIfCovered`, `GetCoverageGapSummary`, `GetCoverageGapNames`), Bestandsmanifest (`BuildCoverageManifestMessages`, gewählte Antwort auf „Q“, „CM“-Empfang), gemeinsamer Manifest-Zerleger, `WANT_TTL` 180 s, Lücken-Aufräumen in `PruneDepartedCrafters`;
- `Sync.lua`: Fehlbilanz samt ausgebliebener Berufe (`status.lostWants`), Bestandslücken im Status (`status.coverage`), Zyklusbeginn leert auch die ausgebliebenen Berufe;
- `Profile.lua`: englische Berufsnamen in der Fähigkeitszeilen-Erkennung;
- `UI.lua`: Werkstatt-Statuszeile mit drei ehrlichen Ausgängen (vollständig samt Reichweite / lückenhaft mit Namen / unvollständig mit Grund), Kopfzeilen-Badge „Bestand lückenhaft“, Kopfzeile veraltet mit `WORKSHOP_UPDATED`, Assistenten-Knopf mit sprachrichtigem Fensterzauber, Eingelesen-Vergleich kanonisch;
- `tests/smoke.lua`: kanonische Schlüssel und Anzeigenamen, Wanderung beider Bestände, englisch verschlüsselter Empfang, ausgebliebener Beruf endet „unvollständig“ und hinterlässt eine Lücke, Bestandsmanifest erzeugt und räumt Lücken, eigene Charaktere bleiben draußen, Statuszeile und Badge in beiden Zuständen; Gegenprobe gegen den alten Stand schlägt fehl;
- `tests/validate.mjs`: Muster auf die neue Mechanik (Alias-Tabelle, Fensterzauber-Kandidaten, kanonische Schlüssel);
- `README.md`, `CHANGELOG.md`: Stand 0.9.102.

## 0.9.101 – Automatisch wiederholen: Werbung auf Tastendruck

Gewünscht vom Owner nach einem Blick auf die CurseForge-Addons AutoFlood („Flooder") und MessageQueue: Kann der Werbebalken das auch — Werbung wiederholen, ohne dass jemand jedes Mal klickt?

### Was die beiden Addons vormachen

Seit Patch 8.2.5 (Classic 1.13.3) erlaubt WoW `SendChatMessage` in öffentliche Kanäle nur noch im unmittelbaren Kontext einer echten Eingabe (Hardware-Event); ein Timer darf nie selbst posten, genau dagegen richtet sich die Sperre. MessageQueue (GPLv3, LenweSaralonde) arbeitet damit statt dagegen: Nachrichten warten in einer Warteschlange, ein unsichtbarer Vollbildrahmen fängt die nächste Eingabe ab und sendet in deren Kontext. AutoFlood (Public Domain, derselbe Autor) setzt darauf den Timer — alle N Sekunden eine Zeile in einen Kanal.

Übernommen ist das Prinzip, nicht der Code: MessageQueue steht unter GPLv3, dieses Repository unter MIT, und gebraucht werden ohnehin nur wenige Zeilen. Zwei Dinge sind bewusst anders:

- **Nur Tastatur, keine Maus.** MessageQueues mausempfindlicher Vollbildrahmen schluckt genau den Klick, der das Posten auslöst — die im eigenen README dokumentierte Schwäche. Ein Rahmen mit `EnableKeyboard` und `SetPropagateKeyboardInput(true)` reicht Tasten dagegen ungestört durch, und beim Spielen fällt ständig ein Tastendruck an, schon das W beim Laufen. `SetPropagateKeyboardInput` ist für Addons im Kampf gesperrt und wird deshalb genau einmal beim Laden gesetzt, nie danach. Fehlt eine der Tastaturmethoden, bleibt die Automatik dauerhaft aus: Ein Lauscher, der Tasten nicht durchreichen kann, würde die Steuerung schlucken.
- **Keine Nachrichten-Warteschlange, ein Merker.** Eingereiht wird nichts. Der Auffrisch-Takt des Werbebalkens schärft den Lauscher genau dann, wenn jetzt auch ein Klick posten würde (bestätigter Text, beigetretener Kanal, kein Cooldown), und der Tastendruck ruft dasselbe `StartSearch` wie der Knopf. Das prüft alles erneut und setzt `lastPosts` erst beim echten Versand — die Automatik kann nie einen veralteten Text posten, und der Cooldown zählt ab dem Moment, in dem die Nachricht wirklich rausging. AutoFloods Pixel-Trigger (ein externes AutoHotkey-Skript erzeugt Tastendrücke, sobald ein Signalpixel die Farbe wechselt) ist ausdrücklich nicht übernommen: Das wäre Eingabe-Automation außerhalb des Spiels.

### Sichtbar statt heimlich

Die Automatik läuft nur, solange der Werbebalken eingeblendet ist. Der Balken ist die Anzeige: Seine Statuszeile sagt in jedem Zustand, was als Nächstes passiert („der nächste Tastendruck postet", „nächster Post in 87s", „wartet auf einen bestätigten Text") und sechs Sekunden lang, was gerade passiert ist. Balken zu heißt Automatik entschärft; der Schalter bleibt gesetzt und greift beim nächsten Öffnen wieder. Nach einem /reload ist immer erst einmal entschärft — der Zustand lebt nur im Rahmen selbst und wird nicht gespeichert.

Der Schalter steht an beiden Orten, die ihn brauchen — im Balken selbst und auf der Seite „Werbung posten" neben dem Werbebalken-Knopf. Beide schreiben denselben Wert, und ein gemeinsamer Tooltip erklärt die Regeln, damit die beiden Orte nie Verschiedenes behaupten. Einschalten auf der Postseite blendet den Balken ein, sonst wäre der Schalter wirkungslos. Welche Taste gedrückt wird, liest Guild Copilot nicht; der Rahmen erfährt nur, dass gedrückt wurde.

Der Grundsatz „keine automatische Werbung" unter „Datenschutz und Fairness" ist damit präzisiert, nicht aufgegeben: Gepostet wird weiterhin nie ohne echte Eingabe und nie ohne ausdrücklich gesetzten Schalter — neu ist nur, dass die Eingabe nicht mehr der Klick auf genau diesen Knopf sein muss. Einladung und Entfernung von Mitgliedern bleiben ohne jede Automatik.

### Nachgebessert nach dem ersten Blick im Spiel

Die zweizeilige Einschalt-Erklärung der Postseite wuchs von ihrem unteren Anker nach oben und schob sich unter die Knopfreihe — derselbe Fehlertyp, der laut `CreateLabel`-Kommentar schon viermal unabhängig entstanden ist: Umbrechen ohne festen Kasten. Die Rückmeldung ist jetzt ein Kasten für genau zwei Zeilen (`height = 34`, `vertical = TOP`), die Knopfreihe sitzt 18 Pixel höher, und ein Test misst die Kastenhöhe nach und schaltet über den echten Schalter statt über die API. Die Seitenbeschreibung nennt seither auch die Automatik, denn „mit einem echten Klick senden" war nicht mehr die ganze Wahrheit.

### Geändert

- `Chat.lua`: der Tastatur-Lauscher `GuildCopilotAutoPostFrame` samt `IsAutoPostSupported`, `IsAutoPostArmed`, `SetAutoPostArmed` und `RunAutoPost`;
- `Database.lua`: `settings.postBar.autoRepeat` (Vorgabe: aus);
- `UI.lua`: Schalter in Balken und Postseite, gemeinsamer Tooltip (`AttachAutoRepeatTooltip`), die Automatik-Statuszeile, Schärfen im Auffrisch-Takt (`RefreshPostBar`), Entschärfen beim Schließen (`SetPostBarShown`), `SetAutoRepeat`; der Balken ist 26 Pixel höher;
- `tests/smoke.lua`: ein eigener Block — Einschalten blendet den Balken ein, der Tastendruck bedient alle bereiten Kanäle und setzt den Cooldown ab Versand, Cooldown, unbestätigter Text und geschlossener Balken entschärfen, Ausschalten räumt auf; die Gegenprobe gegen den Stand ohne Automatik schlägt fehl;
- `README.md`, `CHANGELOG.md`: die Funktion ist erklärt.

## 0.9.100 – Der Einrichtungsassistent

Gewünscht vom Owner: ein Onboarding-Wizard, der dem Spieler die Einrichtung abnimmt und das Addon einmal kurz und prägnant vorstellt — was kann es, und wo finde ich was. Jederzeit abbrechbar oder überspringbar, nicht aufdringlich.

### Warum jetzt doch ein Wizard-Fenster

Die Checkliste „Erste Schritte" war die bewusste Entscheidung *gegen* ein Wizard-Fenster: Die drei Schritte leben auf der Profilseite, also führt die Liste dorthin, statt die Karten zu verdoppeln. An dieser Begründung hat sich nichts geändert — aber sie beantwortet nur die halbe Aufgabe. Eine Checkliste kann sagen, was noch zu tun ist; sie kann nicht erklären, was das Addon alles kann und wo es liegt. Wer zum ersten Mal einloggt, sieht dreizehn Navigationspunkte und eine Liste mit drei Zeilen — das WAS und das WO bleiben ihm verborgen, bis er alles einmal angeklickt hat.

Der Assistent ergänzt die Checkliste deshalb, statt sie zu ersetzen. Beide sind Gesichter desselben Zustands: Die Schrittseiten des Assistenten fragen denselben `GetStepState` wie die Checklistenzeilen, sein „Überspringen" setzt denselben Merker, sein Bestätigen ruft dieselbe echte Aktion. Der Assistent hat keinen eigenen Begriff von „erledigt" und kann darum nie etwas anderes behaupten als die Checkliste. Wer ihn zuklappt — ×, Escape, „Später" —, verliert nichts: Die Checkliste trägt denselben Stand weiter, und der Punkt am Minimap-Symbol erinnert an den Rest.

### Sechs Seiten

1. **Logo.** Wie das alte Willkommensfenster: Schriftlogo, ein großer Knopf. Wer hier schon alles erklärt bekommt, überblättert es.
2. **Funktionstour.** Ein Eintrag je Abschnitt der Seitenleiste, in deren Reihenfolge — das WAS steht im Text, das WO ergibt sich daraus, dass die Liste die Seitenleiste selbst ist. Die Inhalte stehen als Tabelle in `Onboarding.lua`; `tests/validate.mjs` prüft in beide Richtungen, dass Tour und Seitenleiste dieselben Abschnitte nennen.
3. **Raidprofil.** Die aus den Talenten erkannte Spec ist vorgewählt, ein Klick bestätigt. Die Feinheiten (Dual-Spec, Main/Twink, Abmeldung) bleiben bewusst draußen — sie haben auf der Profilseite ihre Karte, und ein Assistent, der alles fragt, ist ein Formular.
4. **Rezepte.** Je erlerntem Beruf eine Zeile mit Stand und einem Öffnen-Knopf. Das ist der eine Handgriff, den kein Addon abnehmen darf: Ein Berufsfenster öffnet nur das Wirken des Berufszaubers, und das verlangt Blizzard als Hardware-Klick auf einen sicheren Knopf (`SecureActionButtonTemplate`). Alles danach läuft von selbst — `Workshop.lua` lauscht ohnehin auf `TRADE_SKILL_SHOW`/`CRAFT_SHOW`, und die Zeile springt über `WORKSHOP_UPDATED` auf Grün, während das Fenster noch offen ist.
5. **Ausrüstung.** Der einzige Schritt ohne Handgriff. Liegt noch kein Ergebnis vor, stößt die Seite die Selbstprüfung an, statt auf den nächsten Login zu warten — sie verspricht „hier musst du nichts tun", also darf sie nicht heimlich doch warten.
6. **Fundorte.** Minimap-Symbol, `/gcp`, der Knopf „Einrichtung" im Fensterkopf. Der Knopf öffnet jetzt den Assistenten (und holt per `Reopen` zugleich die Checkliste zurück); `/gcp welcome` tut dasselbe.

Die Seitennummer ist reiner Sitzungszustand. Gespeichert wird weiterhin nur, was sich aus den Daten nicht ablesen lässt — der Assistent hat keine neuen Merker dazubekommen.

### Zwei Funde am Rande

- **Reine Sammler hingen für immer im Rezeptschritt.** Kräuterkunde und Kürschnerei haben kein Rezeptfenster; „Rezepte einlesen" war für einen Charakter mit zwei Sammelberufen unerfüllbar und stand auf ewig offen. Die Liste der fensterlosen Berufe stand dafür längst in `Workshop.lua` — sie ist nach `Constants.lua` gewandert (`GC.RecipelessProfessions`), Werkstatt und Einrichtung lesen jetzt dieselbe. Aufgefallen ist das beim Bau der Berufszeilen: Welche Zeile bekommt einen Öffnen-Knopf, und was verspricht der Schritt dem, der keinen bekommen kann?
- **Bergbau heißt am Fenster „Schmelzen".** Der Scan speichert den Fensternamen; die Berufszeile muss ihn dem Beruf zuordnen, sonst bliebe sie trotz eingelesener Rezepte offen. Der Öffnen-Knopf wirkt dort auch den Zauber „Schmelzen", nicht „Bergbau" (`GC.ProfessionWindowSpells`).

### Nachgeschärft nach dem ersten Blick im Spiel

Fünf Punkte aus dem Owner-Feedback, alle an der Oberfläche des Assistenten:

- **Die Tour war oben zusammengeschoben.** Kopf und Zeilen sind jetzt auf die Seitenhöhe verteilt, Überschrift und Erklärsatz zentriert, und jede Zeile trägt das Symbol ihrer Seite — dieselben Symbole wie in der Seitenleiste, denn die Tour soll das Wiedererkennen vorbereiten, nicht ein zweites Bildvokabular einführen.
- **Die Gildenwerkstatt hat eine eigene Zeile.** Mitgliederpflege und Werkstatt sind zwei verschiedene Dinge; eine gemeinsame GILDE-Zeile beschrieb beide nur halb, und ausgerechnet die Werkstatt — das Modul mit dem größten Alltagsnutzen — ging darin unter. Der Abschnittsname steht an jeder Zeile, auch doppelt: Der erste Wurf ließ ihn bei Wiederholungen weg wie die Seitenleiste, aber dort trägt die Einrückung die Gruppe — hier sah die Zeile schlicht unfertig aus („da fehlt ein Text"). `tests/validate.mjs` erlaubt seither mehrere Tourzeilen je Abschnitt, prüft die Abdeckung aber weiter in beide Richtungen und verlangt je Zeile ein Symbol.
- **Keine Zeile wird mehr stumm abgeschnitten.** Die REKRUTIERUNG-Seitenzeile zählte alle fünf Seiten auf, 64 Zeichen in einer Zeile, in die etwa 56 passen — im Spiel stand „Postfa…". Die Seitenzeile ist jetzt eine Überschrift, keine vollständige Aufzählung, und `tests/validate.mjs` misst alle Seitenzeilen (≤ 56 Zeichen) und Beschreibungen (≤ 120 Zeichen, zwei Zeilen) nach.
- **Warcraft Logs steht nicht mehr in der Tour.** Wer frisch installiert, hat nur das Addon — der Import ist ein Werkzeug für Fortgeschrittene und kein Verkaufsargument der ersten fünf Minuten. Die Seite selbst bleibt in der Seitenleiste; nur die Tour verschweigt sie bewusst, und eine Prüfung hält das fest.
- **„Fertig“ klingt nach Stufenaufstieg** (`PlaySuccessSound("LEVEL_UP")`) — unabhängig vom eingestellten Bestätigungston, denn das ist keine Bestätigung, sondern ein „geschafft“.
- **Das erste vorzeitige Schließen erklärt den Weg zurück.** Ein kleines Hinweisfenster nennt `/gcp welcome` und den Knopf „Einrichtung“ — genau einmal je Charakter (`NoteLaterPressed`, Merker `laterHintShownAt`), denn wer es gelesen hat, weiß es, und ein Fenster nach jedem Schließen wäre Drängeln. „Später“ und das × gehen dafür durch denselben Schließweg (`HideWelcomeWithHint`): Welche der beiden Knöpfe jemand erwischt, darf keinen Unterschied machen. „Fertig“ und „Guild Copilot öffnen“ gehen bewusst nicht hindurch — wer durch ist, verabschiedet sich nicht auf später.
- **Unten rechts steht in kleiner Schrift der Autor** (Owner-Wunsch): Nexarius - Thunderstrike, unterhalb der Navigationsknöpfe, damit die Zeile auf keiner Seite etwas verdeckt.
- **Dual-Spec und „flexibel einsetzbar“ stehen mit auf der Profilseite des Assistenten** (Owner-Wunsch — der erste Wurf verwies dafür auf die Profilseite, aber beides gehört zum Raidprofil, und die Seite hatte sichtbar Platz übrig). Gespiegelt sind die Regeln der Profilkarte: Der Knopf der gewählten Primär-Spec ist in der Dual-Reihe gesperrt, gleiche Primär- und Dual-Spec wählen die Dual-Spec ab, „Keiner“ nimmt sie heraus. Beim Öffnen startet beides auf dem gespeicherten Stand des Profils — der Assistent ergänzt, er setzt nicht stillschweigend zurück. Main/Twink und die Abmeldung bleiben draußen: Ein Assistent, der alles fragt, ist ein Formular.
- **Schräge Striche sind keine Treppen mehr.** Die selbst gezeichneten Symbole bauten einen schrägen Strich als Reihe überlappender Quadrate — dem Irrtum geschuldet, eine gedrehte Fläche gebe die Oberfläche nicht her. Ab etwa 20 px Kantenlänge war die Treppe sichtbar; gemeldet wurde sie am grünen Haken neben „Bestätigen“ („verpixelt“). Der Client kann die vier Ecken einer Fläche einzeln versetzen (`SetVertexOffset`), und vier versetzte Ecken sind ein glatter Balken in beliebiger Richtung — mit eckigen Kappen, damit die beiden Hakenstriche im Knick ohne Kerbe aneinanderstoßen. Die Quadratreihe bleibt als Rückfall für Clients ohne `SetVertexOffset`.
- **Der Berufsknopf tat im Spiel nichts — zwei Ursachen, beide behoben.** Erstens war der sichere Knopf nur auf `LeftButtonUp` registriert; der Anniversary-Client sitzt auf der modernen Engine, und die führt geschützte Aktionen je nach Einstellung (`ActionButtonUseKeyDown`) beim Drücken ODER Loslassen aus — genau einmal je Klick. Registriert sind jetzt beide Flanken (`AnyDown`, `AnyUp`). Zweitens wurde im Spiel auf Symbol und Namen geklickt, nicht auf den Knopf daneben: Die ganze Zeile ist jetzt der sichere Knopf und bleibt es auch nach dem Einlesen — das Fenster zu öffnen ist ja weiter erlaubt, nur der Aufforderungs-Knopf verschwindet. Der Fensterzauber steht als `windowSpell` auch lesbar an der Zeile, damit der Test ihn prüfen kann.
- **„Fertig“ meldet sich wie ein neuer Gildenauftrag** (Owner-Wunsch): zusätzlich zum Stufenaufstieg läuft der Auftragsbanner mit „Guild Copilot is ready for takeoff“ — zusammengeschrieben, denn „takeoff“ ist hier das Substantiv; getrennt wäre es das Verb („ready to take off“).
- **Die Berufsspalte der Gildenübersicht nennt nur noch Namen.** Die Fertigkeitspunkte standen nur an automatisch erfassten Berufen — von Hand eingetragene haben schlicht keine Zahl —, und eine Spalte, in der dieselbe Angabe mal mit und mal ohne Zahl steht, sieht nach einem Fehler aus. Wer die Punkte braucht, findet sie an der eigenen Berufskarte im Profil; `tests/validate.mjs` hält die Spalte zahlenfrei.
- **Die Autorenzeile bekam Luft:** Die Navigationsleiste sitzt ein Stück höher, der Streifen darunter gehört der Zeile — vorher klebte der Name am „Weiter“-Knopf („zu gequetscht“).

### Geändert

- `Onboarding.lua`: Seitenmodell (`WIZARD_PAGES`, `GetWizardPage`, `WizardGo`, `SkipWizardStep`, `StartWizard`) und die Tour-Tabelle (`GC.Onboarding.TOUR`, mit Symbol je Zeile); `HasAnyScannableProfession` ersetzt `HasAnyProfession`; `NoteLaterPressed` für den einmaligen Später-Hinweis;
- `UI.lua`: das Willkommensfenster ist der Assistent geworden (gleicher Rahmenname, `ShowWelcome`/`HideWelcome` unverändert); sechs Seitenbauer, `ShowWizardPage`, `RefreshWizard` samt Unterfunktionen je Schrittseite; der sichere Berufsknopf; das Hinweisfenster `ShowWizardLaterHint`; der Kopfzeilen-Knopf „Einrichtung" und `/gcp welcome` führen zum Assistenten;
- `Constants.lua`: `GC.RecipelessProfessions` und `GC.ProfessionWindowSpells`;
- `Workshop.lua`: `GetMissingOwnProfessions` liest die Sammlerliste aus Constants;
- `tests/smoke.lua`: ein eigener Block — Seitenfolge, Blättern an den Rändern, Überspringen setzt den Checklistenmerker (und ein erledigter Schritt wird nicht rückwirkend übersprungen), der Bestätigen-Knopf ruft die echte Aktion, Berufszeilen mit und ohne Öffnen-Knopf, reine Sammler, Bergbau/Schmelzen, folgenloses Schließen;
- `tests/validate.mjs`: der Abgleich Tour ↔ Seitenleiste in beide Richtungen und die neuen Pflicht-Implementierungen.

## 0.9.99 – Der Unterschied zwischen „passiert" und „erfahren"

Gemeldet als Alltagsärgernis: Bei jedem Login und jedem `/reload` spielte Guild Copilot Töne und schrieb Meldungen für Gildenaufträge, die längst abgeschlossen waren. Gewünscht war das Offensichtliche — Klang nur dann, wenn *jetzt gerade* etwas passiert.

### Ein Auftrag erreicht dich nicht, wenn er sich ändert

Die Ursache steckt in einer Annahme, die im Code nirgends ausgesprochen war: dass der Moment des Empfangs der Moment der Änderung ist. Für lokale Aktionen stimmt das. Für alles, was über die Gilde hereinkommt, stimmt es nicht.

Seit 0.9.55 ist jeder Client Kurier: Beim Login beantwortet **jeder** deine Abfrage mit allen ihm bekannten laufenden Aufträgen, und Dritte reichen fremde Stände weiter. `ReceiveState` nahm jeden davon entgegen und rief unmittelbar `NotifyRemoteChange` und `NoteStatusChanged` — ohne je zu fragen, wann die Änderung war. Dasselbe bei neuen Aufträgen in `ReceiveCore`. Der Auftrag wurde vor drei Tagen fertig; für deinen Client war es der Augenblick, in dem er es erfuhr.

Das ist derselbe Denkfehler wie in 0.9.94 („Zeitüberschreitung ist nicht Verlust") und 0.9.95, nur an anderer Stelle: Ein Zustand wird mit dem Ereignis verwechselt, das ihn bekannt macht.

### Die Frist, und warum sie tragfähig ist

Gemeldet wird nur noch, was jünger als zwei Minuten ist. Der Vergleich ist zwischen zwei Rechnern zulässig, weil `changedAt` aus `GetServerTime()` stammt — dieselbe Uhr für alle auf dem Realm, kein Geräteversatz, den ein absoluter Zeitstempel sonst unbesehen übernähme. Genau aus demselben Grund überträgt die Werkstatt ihre Wartezeiten als *Restzeit*; hier ist es umgekehrt richtig, weil die Serverzeit gemeinsam ist.

Zwei Minuten sind bewusst großzügig gewählt. Die Frist muss den Weg über die Sendewarteschlange und eine Kampfpause aushalten, ohne eine echte Änderung zu verschlucken. Ein Nachholstand ist dagegen nie um Minuten alt, sondern um Stunden oder Tage — zwischen beiden liegt keine Grauzone, die eine feinere Grenze bräuchte.

### Was still bleibt und was nicht

Getrennt wurden zwei Dinge, die bisher an derselben Stelle hingen. `NoteStatusChanged` machte Klang **und** Statistik in einem Aufruf. Nur der Klang bekommt die Frist; `CountCompletion` läuft weiter für jeden Stand, der hereinkommt. Sonst zählte ein Auftrag je nachdem mit, ob man zufällig online war, als er fertig wurde — eine Statistik, die von der Anwesenheit des Betrachters abhängt, ist keine.

Unberührt bleiben die eigenen Aktionen: Wer selbst annimmt, Material meldet oder abschließt, hört das weiter sofort. Diese Aufrufe kennen die Frist gar nicht, denn sie sind per Definition von jetzt.

### Geändert

- `IsFreshChange` in `Orders.lua`, eine Frist von 120 Sekunden auf `changedAt` beziehungsweise `createdAt`;
- `ReceiveState` meldet Fremdänderungen nur noch, wenn sie frisch sind — Klang und Chatzeile gemeinsam;
- `ReceiveCore` kündigt einen neuen Auftrag nur an, wenn er gerade erst erstellt wurde;
- `NoteStatusChanged` nimmt ein `announce`-Argument; ohne Angabe wird gemeldet, damit die lokalen Aufrufer unverändert laut bleiben;
- ein Regressionstest über beide Fälle am selben Kanal: eine frische Fremdänderung klingt, eine einen Tag alte bleibt stumm und wird trotzdem verbucht. Er schlägt gegen 0.9.98 fehl.

## 0.9.98 – Die Wartezeit, die genau dort fehlte, wo sie jeder sucht

0.9.97 hat die Wartezeiten eingeführt und dabei ausgerechnet den Beruf ausgelassen, an dem sie zuerst auffallen. Gemeldet wurde es am Tag nach der Veröffentlichung, mit dem denkbar knappsten Beleg: das Berufsfenster zeigt „Verbleibende Abklingzeit: 21 Std. 20 Min." auf der Sphäre der Leere, die Rezeptkarte daneben zeigt am selben Hersteller nichts.

### Verzauberkunst ist kein Berufsfenster

In TBC gibt es zwei Berufsoberflächen, und Verzauberkunst hängt an der anderen. Was Alchimie oder Schneiderei über `GetNumTradeSkills` und `GetTradeSkillInfo` melden, meldet Verzauberkunst über `GetNumCrafts` und `GetCraftInfo` — eine eigene API mit eigenen Funktionsnamen, sichtbar schon am Knopf des Fensters: dort steht „Verzaubern", nicht „Herstellen".

Guild Copilot weiß das seit 0.4.0 und hat dafür einen dritten Scanzweig, `ScanClassicCraftProfession`. Die Wartezeiten aus 0.9.97 wurden in die anderen beiden eingebaut — den modernen und den klassischen Berufsfenster-Zweig — und in diesen nicht. Er las keine Sperre mit und gab sein Ergebnis außerdem direkt an `StoreProfession` zurück, an `FinishScan` vorbei; dort erst werden gelesene Sperren gemerkt und in die Gilde geschickt. Beides zusammen heißt: Für einen Verzauberer war die Anzeige nicht etwa falsch, sondern unerreichbar.

Bemerkenswert ist, wie leise das war. Kein Fehler, keine Meldung, kein leeres Feld — die Rezepte kamen vollständig an, der Abgleich stand auf 100 %, und die Herstellerliste sah genau so aus wie vorher. Ein nicht gebauter Zweig sieht aus wie ein Beruf ohne laufende Sperre, und beides zeigt das Addon aus gutem Grund identisch an: Es behauptet nie, jemand sei frei.

### Warum der Test es nicht gefunden hat

Der Regressionstest aus 0.9.97 stellt eine laufende Sperre auf der Mondstofftasche und prüft sie über den ganzen Weg bis in die Rezeptkarte. Er tut das an Schneiderei — also über `GetTradeSkillCooldown`, im Zweig, der schon funktionierte. Die Craft-API war in der Testumgebung längst vorhanden und wurde an anderer Stelle auch benutzt; die Wartezeiten hat dort niemand angefasst.

Das ist der übliche Zuschnitt eines Tests nach dem Bild der Implementierung statt nach dem Bild des Problems: Geprüft wurde der Pfad, den man gerade geschrieben hatte. Der neue Test läuft deshalb über den Craft-Zweig und endet an derselben Stelle wie sein Vorbild — bei „frühestens" in der Rezeptkarte.

### Geändert

- `ScanClassicCraftProfession` liest die laufende Sperre über `GetCraftCooldown` mit, in derselben Schleife, die ohnehin jede Zeile anfasst — ein zusätzlicher Aufruf je Rezept, wie in den beiden anderen Zweigen;
- er gibt sein Ergebnis über `FinishScan` zurück statt über `StoreProfession`, womit gelesene Sperren gemerkt und bei einer Änderung in die Gilde geschickt werden;
- dieselbe Unterscheidung wie überall sonst gilt jetzt auch hier: keine Abfrage in dieser Spielfassung heißt „nicht abgelesen" und lässt den gemerkten Stand stehen, eine leere Antwort heißt „abgelesen, nichts gesperrt";
- ein Regressionstest über den Craft-Zweig, vom Scan bis zur Rezeptkarte, samt der Prüfung, dass ein Scan ohne Cooldown-Abfrage den gemerkten Stand nicht abräumt. Er schlägt gegen 0.9.97 fehl.

## 0.9.97 – Wer es kann, kann es noch lange nicht heute

Die Werkstatt beantwortet seit 0.4.0 die Frage „wer kann das?". Die Frage danach hat sie nie beantwortet, obwohl sie in TBC die eigentlich knappe ist: **wann darf er wieder?** Umwandlungen, Spezialtuche und Sphären hängen an einer Wartezeit, und der Wochenauftrag über fünfzehn Sphären — das Beispiel, mit dem die README die Auftragsvorlagen erklärt — hängt an nichts anderem.

Bis hierher konnte ein Auftrag an jemanden gehen, dessen Sperre längst verbraucht war. Niemand hat das gemerkt, bis drei Tage später jemand nachfragte.

### Abgelesen, wo es ohnehin passiert

Der Client nennt eine Wartezeit nur, solange das Berufsfenster offen ist. Genau dort steht Guild Copilot schon: `ScanOpenProfession` läuft beim Öffnen ohnehin einmal über jede Zeile. Die Sperre kommt aus derselben Schleife, mit einem zusätzlichen Aufruf je Rezept — kein zweiter Durchlauf, kein neues Ereignis, keine zusätzliche Arbeit im laufenden Spiel.

Damit hat dieser Punkt etwas, das dem Filter nach Skill-Stufe fehlt (Punkt 6 der TODO-Liste, genau daran gescheitert): **kein Datenproblem.** Es braucht keine mitgelieferte Tabelle, welche Rezepte eine Wartezeit haben. Die API meldet eine, wo es eine gibt; was das für Rezepte sind, muss das Addon nie wissen und nie pflegen.

### Warum die Zahl nicht altert

Jede andere Zahl der Werkstatt ist eine Momentaufnahme und wird mit der Zeit unrichtiger. Eine Restzeit nicht. Sie lässt sich in einen Zeitpunkt umrechnen, und der bleibt stehen.

Die verbleibende Unschärfe hat nur **eine Richtung**: Hat der Hersteller nach dem Ablesen erneut hergestellt, ist er später frei — früher nie. Der gespeicherte Zeitpunkt ist damit eine Untergrenze, und genau so ist er überall beschriftet: „frühestens 21:40", dazu unter der Herstellerliste der Satz, dass Sperrzeiten Mindestangaben aus dem zuletzt geöffneten Berufsfenster sind.

Aus derselben Überlegung folgt, was das Addon **nicht** sagt. Die API schweigt bei einem freien Rezept — und sie schweigt genauso bei einem Rezept, das überhaupt keine Wartezeit kennt. Beides ist von außen nicht zu unterscheiden. Also wird auch nichts behauptet: Es gibt „gesperrt bis", es gibt kein „frei". Dieselbe Linie wie bei den unbewerteten Verzauberungen, die nie als schlecht gelten.

### Ein Nachrichtentyp, der nichts zusammensetzen muss

Die Sperren wandern als eigene Operation `W|…|CD|…` durch den Gildenkanal, getrennt von den Rezeptdaten. Das hat drei Gründe, und jeder einzelne hätte gereicht:

- Der Rezeptkatalog ist seit 0.9.30 **herstellerunabhängig** — jedes Rezept steht dort genau einmal. Eine Wartezeit gehört dagegen zu genau einem Charakter.
- Der Fingerabdruck eines Berufs darf sich nicht ändern, nur weil eine Umwandlung läuft. Sonst gälte jeder Scan als geänderter Rezeptstand und zöge einen vollständigen Abgleich nach sich.
- Sperren sind **einzelne Tatsachen**, keine Liste, die vollständig ankommen müsste. Jede Nachricht steht deshalb für sich: kein Token, keine Teilzähler, kein Zusammensetzen beim Empfänger. Was ankommt, gilt; was fehlt, kommt beim nächsten Mal.

Übertragen wird die **Restzeit, nicht der Zeitpunkt**. Zwei Rechner können verschieden gehen, und ein absoluter Zeitstempel würde diesen Fehler unbesehen übernehmen — ausgerechnet bei einer Angabe, die nur als Zeitpunkt etwas wert ist. Der Empfänger rechnet mit seiner eigenen Uhr um; die Sekunden Übertragungsweg fallen bei Wartezeiten von Stunden nicht ins Gewicht.

Beim Zusammenführen gewinnt der **spätere** Zeitpunkt. Beide Angaben sind Untergrenzen, und die größere ist die belastbarere — ein im Gildenkanal verspätetes Paket dreht einen frischeren Stand damit nicht zurück. Aus demselben Grund braucht es kein Löschen: Eine Sperre verschwindet, indem sie abläuft.

Ältere Clients verwerfen die unbekannte Operation an der Stelle, an der sie das schon immer getan haben (`operation ~= "D" and ~= "C" and ~= "K"`). Die Schemaversion bleibt deshalb bei 7; gemeldet wird die neue Fähigkeit als `cooldown1`.

### Zwischengespeichert wird der Index, nicht die Uhrzeit

Der Rezept-zu-Hersteller-Index behält bewusst auch abgelaufene Einträge. Würde beim Bauen nach der Uhr gefiltert, wäre das Ergebnis eine Momentaufnahme, die im Zwischenspeicher liegen bleibt und mit jeder Minute unrichtiger wird — ein Fehler, den die Fortschrittsanzeige in 0.9.95 auf ihre Weise schon einmal gemacht hat. Gefiltert wird deshalb erst bei der Abfrage, und der Zwischenspeicher hängt nur an den Daten.

### Ein Fund nebenbei

`StoreProfession` baut den Berufsdatensatz bei jedem Scan vollständig neu auf. Alles, was nicht aus den Rezepten stammt, fiel dabei heraus — die frisch eingebauten Wartezeiten inbegriffen. Mit vorhandener Cooldown-Abfrage war das unsichtbar, weil sie unmittelbar danach neu geschrieben wurden. Sichtbar wurde es erst an einer Spielfassung **ohne** diese Abfrage: Dort gibt es nichts, was den Stand ersetzt, und der Scan hat ihn schlicht gelöscht.

Der Unterschied, um den es dabei geht, steht jetzt im Code: `nil` heißt „nicht abgelesen" und lässt den gemerkten Stand stehen, eine leere Tabelle heißt „abgelesen, nichts gesperrt" und räumt ihn ab. Der Unterschied zwischen einer fehlenden und einer verneinenden Antwort.

### Was die Tests dazu sagen

Neu geprüft wird: dass der Scan eine laufende Sperre mitliest und ein Rezept ohne Sperre nicht als gesperrt merkt; dass derselbe laufende Cooldown beim zweiten Blick **keine** Änderung ist (ohne das Runden auf die Minute schickte jeder Scan ein Paket in die Gilde, nur weil Sekunden vergangen sind); dass die Rezeptkarte die Sperre als Mindestangabe ausweist; dass ein verspätetes Paket den frischeren Stand nicht zurückdreht; dass eine absurd lange Wartezeit nicht übernommen wird; dass dreizehn Sperren auf zwei eigenständige Pakete gehen; dass eine abgelaufene Sperre schweigt statt „frei" zu sagen; und dass ein Scan ohne Cooldown-Abfrage den gemerkten Stand stehen lässt.

## 0.9.96 – Was die Sperre abräumt und was sie nur behauptet

0.9.95 hat die Stillstandssperre daran gehindert, wartende Pakete auszubuchen. Dabei blieben zwei Fehler stehen, die älter sind als diese ganze Reihe.

### Eine Abschreibung, die sich selbst wiederholt

Die Sperre addierte den gesamten offenen Sendezähler zum Fehlerzähler und räumte danach `bulkOutstanding` und `serialPending` ab. `GetReliablePendingCount()` ist aber ebenfalls Teil dieses Werts und hängt an einer eigenen Liste, die hier nicht angefasst wird.

Die Folge ist eine Schleife, die niemand vorgesehen hat: Der Gesamtwert sinkt nicht, weil die Flüsterteile weiterzählen. Damit greift auch die Zuweisung `outboundChangedAt = now` nicht, die nur bei einer Änderung erfolgt. Beim nächsten Statusabruf ist die Frist immer noch überschritten, und dieselbe Abschreibung läuft erneut – bei einem Anzeigetakt von einer halben Sekunde zweimal pro Sekunde, unbegrenzt. Die Nachprüfung hat den Zähler von 0 auf 2 und sofort auf 4 steigen sehen.

Der Fehler ist alt; er brauchte nur einen ausstehenden Flüstertransfer zum Zeitpunkt eines Stillstands, um sichtbar zu werden. Behoben ist er an der Wurzel: Abgeschrieben wird ausschließlich, was hier auch abgeräumt wird. Die bestätigten Flüsterteile haben mit `GiveUpReliablePart` ihre eigene Aufgabe-Logik und gehen die Sperre nichts an. Zusätzlich rückt `outboundChangedAt` nach einer Abschreibung ausdrücklich weiter, statt sich auf eine Wertänderung zu verlassen – eine Bedingung, die genau dann nicht greift, wenn man sie braucht.

### Pausiert ist nicht verloren

`status.waiting` kannte nur den einen Fall: ein Paket liegt bei ChatThrottleLib. Pakete, die wegen der Kampfpause noch in der eigenen Warteschlange stehen, haben diesen Vermerk nicht – sie wurden ja bewusst nicht übergeben.

Dauert ein Kampf länger als zwei Minuten, und das ist bei einem Bosskampf mit Wipe der Normalfall, hat die Sperre sie deshalb als verloren gebucht und den Zähler abgeräumt. Nach dem Kampf gingen sie ordnungsgemäß raus, aber der Fehlerzähler stand. Es ist derselbe Denkfehler wie in 0.9.94 und 0.9.95, zum dritten Mal an einer neuen Stelle: **Ein Paket, das noch bei uns liegt, ist nicht verloren, sondern wartet.**

Die Sperre prüft jetzt beides – kein übergebenes Paket *und* eine leere eigene Warteschlange. Nur dann ist ein stehender Zähler wirklich ein Leck.

Und weil ein Balken, der zehn Minuten „noch 12 Pakete" sagt, während im Raid gekämpft wird, keine Auskunft ist: Die Anzeige nennt die Kampfpause jetzt beim Namen.

### Dreimal derselbe Satz

Diese Reihe hat sechs Anläufe gebraucht, und ab 0.9.94 stand in jedem einzelnen derselbe Satz in einem anderen Gewand:

- 0.9.94 – ein Paket bei ChatThrottleLib ist nicht verloren, es wartet
- 0.9.95 – dasselbe Paket ist auch für die Anzeige nicht verloren
- 0.9.96 – ein Paket in der eigenen Warteschlange erst recht nicht

Der Grundsatz war ab 0.9.94 formuliert. Was fehlte, war die Frage, **an wie vielen Stellen** er noch nicht gilt – dieselbe Lücke wie bei der Gildenbank- und Werkstatt-Konvergenz in 0.9.91. Eine Regel einzuführen ist die kleinere Hälfte der Arbeit; die größere ist, jede Stelle zu finden, die noch nach der alten verfährt.

## 0.9.95 – Derselbe Denkfehler, eine Ebene höher

0.9.94 hat in der Warteschlange festgehalten: Wartezeit ist kein Verlust. Die Fortschrittsanzeige wusste davon nichts und machte weiter wie bisher.

**Die Anzeige buchte Wartende als Verluste.** Kam der Sendezähler zwei Minuten nicht voran, räumte `GetSyncStatus` ihn ab und verbuchte alles als fehlgeschlagen. Die Sperre stammt aus einer Zeit, in der ein ausbleibender Rückruf tatsächlich der einzige Grund für einen stehenden Zähler war. Seit 0.9.92 liegt aber immer genau ein Paket bei ChatThrottleLib, und auf einem ausgelasteten Kanal kann das ohne Weiteres länger als zwei Minuten dauern. Der Normalfall unter Last lief damit in eine Sperre, die für den Ausnahmefall gebaut war.

Bemerkenswert ist die Folge, weil sie nicht wieder verschwand: Trafen die Rückmeldungen danach ein, senkten sie zwar `bulkOutstanding`, aber der Fehlerzähler war längst gesetzt. Der Abgleich blieb bis zum Ausloggen „unvollständig", obwohl jedes einzelne Paket angekommen war. Eine falsche Aussage über einen erfolgreichen Vorgang, die sich selbst nicht mehr korrigieren konnte.

Die Sperre setzt jetzt aus, solange `bulkInFlight` gesetzt ist — das ist der Beleg dafür, dass gewartet und nicht gehangen wird. Sie greift weiterhin, wenn der Zähler ohne ein Paket in der Leitung stehen bleibt; das war ihr eigentlicher Zweck und bleibt geprüft.

**Und die Anzeige sagt jetzt, was los ist.** Ein Balken, der sich zehn Minuten nicht bewegt, ist auch dann unbrauchbar, wenn er nicht lügt. Wartet dasselbe Paket länger als die Sperrfrist, steht in der Zeile darunter, dass der Chatkanal ausgelastet ist und es weitergeht, sobald er frei wird. Das ist die Auskunft, die der frühere Watchdog geben wollte — nur ohne den Zustand dafür zu verfälschen.

**Die letzte Ausnahme beim Warten ist entfallen.** 0.9.94 gab den Platz frei, wenn `_G.ChatThrottleLib` verschwunden war, und nannte das „eine Tatsache statt einer Uhr". Das war es nicht. Die Bibliothek hält ihre eigene Referenz und einen laufenden Zeitgeber; eine eingereihte Nachricht geht weiter hinaus und meldet zurück, ganz gleich, ob die globale Variable noch existiert. Der eigene Regressionstest hat das sogar vorgeführt — er ließ den alten Rückruf nach der Freigabe eintreffen, ohne dass jemandem auffiel, was das über die Annahme aussagt.

Damit bleibt: Es gibt keinen beobachtbaren Zustand, aus dem sich „dieses Paket kommt nie an" ableiten lässt. Also wird ohne Ausnahme gewartet. Der Preis ist bekannt und wird bewusst getragen — verliert ChatThrottleLib wirklich einmal einen Rückruf, steht der Abgleich bis zum nächsten `/reload`. Dafür gilt die Zusicherung „im Kampf höchstens ein Paket" ohne Einschränkung, und das ist die Aussage, auf die sich eine Einstellung berufen können muss.

Vier Anläufe hat diese eine Zusicherung gebraucht. Jeder einzelne scheiterte nicht an der Umsetzung, sondern an einer Annahme über fremden Code, die niemand nachgeprüft hatte: dass ein Rückruf asynchron kommt (0.9.93), dass eine Frist Verlust bedeutet (0.9.94), dass eine verschwundene Referenz Stillstand bedeutet (0.9.95).

## 0.9.94 – Zeitüberschreitung ist nicht Verlust

Die Kampfpause zum vierten Mal, und diesmal ging es nicht um die Umsetzung, sondern um eine falsche Annahme im Entwurf.

0.9.92 hat den Grundsatz „bei ChatThrottleLib liegt höchstens ein Paket" eingeführt und gleich eine Sicherung dazu: Bleibt die Rückmeldung fünfzehn Sekunden aus, gilt das Paket als verloren und das nächste geht raus. Der Gedanke dahinter war, dass ein einziger ausbleibender Rückruf sonst den gesamten Abgleich anhält – ein berechtigtes Anliegen, mit einer unbelegten Annahme darunter: **dass eine Zeitüberschreitung Verlust bedeutet.**

ChatThrottleLib v31 kennt für eingereihte Nachrichten weder eine Ablaufzeit noch einen Abbruch. Eine Nachricht, die dort liegt, bleibt liegen und wird gesendet, sobald der Kanal es zulässt; der Rückruf kommt dann. Fünfzehn Sekunden ohne Rückmeldung heißen also nicht „weg", sondern „Kanal ist voll" – und das ist genau die Lage, in der ein Abgleich läuft.

Die Folge war das Gegenteil des Gewollten: Nach der Frist ging ein zweites Paket raus, während das erste weiter in der fremden Warteschlange lag. Nach der nächsten Frist ein drittes. Die Nachprüfung hat drei gleichzeitig offene Pakete gemessen. Ausgerechnet unter Last – wenn die Fristen überschritten werden – fiel die Zusicherung, die während eines Kampfes gelten soll.

**Und der eigene Test schrieb das fest.** Er prüfte, dass nach dem Ablauf ein weiteres Paket rausgeht, und beschrieb das als „ein ausgebliebener Rückruf hält die Warteschlange dauerhaft an". Das ist dieselbe Sorte Fehler wie der „unberechtigte Anfrager" in 0.9.91: ein Test, der die Wirkung eines Fehlers als gewünschtes Verhalten festhält. Ein grüner Test beweist, dass der Code tut, was der Test erwartet – nicht, dass die Erwartung stimmt.

**Zurückziehen geht nicht, also wird gewartet.** Der Platz bleibt belegt, bis ChatThrottleLib zurückmeldet. Es gibt keine Frist, nach der er von selbst frei wird, weil es keine Information gibt, die eine solche Frist rechtfertigen würde. Dass der Abgleich hängt, meldet die Fortschrittsanzeige über ihre eigene Sperre – das ist die richtige Stelle dafür, denn sie sagt es, ohne den Zustand zu verfälschen.

**Die eine Ausnahme hängt an einer Tatsache, nicht an einer Uhr.** Ist die ChatThrottleLib gar nicht mehr geladen, kann sie auch nichts mehr zustellen. Erst dann ist das Paket wirklich verloren und der Platz darf frei werden. Dieser Weg kann keine Pakete anhäufen: Wo keine Bibliothek ist, liegt auch nichts in ihrer Warteschlange.

Damit ist auch das ursprüngliche Anliegen von 0.9.92 gedeckt – der Abgleich steht nicht für den Rest der Sitzung –, nur eben über eine belegbare Bedingung statt über eine geratene Frist. Die Konstante `BULK_IN_FLIGHT_TIMEOUT` ist ersatzlos entfallen.

## 0.9.93 – Der Test, der den echten Fall nicht kannte

0.9.92 hat die Kampfpause vollständig gemacht und dabei zwei neue Fehler eingebaut, einen davon schwerwiegend. Beide wurden vor der Veröffentlichung gefunden. Interessant ist, **warum der eigene Regressionstest sie nicht gefunden hat**.

### Ein Attrappen-Test beweist nur, was die Attrappe kann

Der Test zu 0.9.92 baut eine ChatThrottleLib nach. Sie sammelt die Rückrufe ein, und der Test löst sie später von Hand aus – asynchron also. Damit prüft er genau die Annahme, unter der er geschrieben wurde.

Die echte ChatThrottleLib v31 hat einen Schnellweg: Ist der Kanal frei, sendet sie sofort und ruft den Rückruf **synchron** auf, noch innerhalb von `SendAddonMessage`. Dieser Weg kam in der Attrappe nicht vor, und der Code fiel genau dort um:

```lua
local ok = pcall(throttle.SendAddonMessage, ..., function(...)
    self.bulkInFlight = nil        -- läuft SYNCHRON, hier ist noch nichts gesetzt
    ...
end, nil)
if ok then
    self.bulkInFlight = entry      -- ... und das trägt ein erledigtes Paket ein
end
```

Der Rückruf räumte ein Feld auf, das noch gar nicht belegt war; danach schrieb sich das längst gesendete Paket als „unterwegs" ein. Ein Geist, den nur der Watchdog auflöst – fünfzehn Sekunden, **je Paket**. Ein Abgleich mit dreißig Paketen hätte über sieben Minuten gebraucht. Aus einer Korrektur, die den Durchsatz ausdrücklich nicht antasten sollte, wäre der Stillstand geworden.

Die Lehre ist nicht „mehr testen", sondern: Eine Attrappe für fremden Code muss dessen **Vertragsspielraum** abbilden, nicht das eine Verhalten, das man sich vorgestellt hat. Ein Rückruf, dessen Zeitpunkt nicht zugesichert ist, kann synchron kommen – also gehört dieser Fall in den Test. Beide Fassungen der Attrappe stehen jetzt nebeneinander, die sammelnde und die sofort zurückrufende.

### Und ein Vermerk ohne Identität

Der zweite Fehler ist stiller. Der Rückruf löschte `bulkInFlight`, ohne zu prüfen, ob der Vermerk noch zu ihm gehört. Hat der Watchdog Paket A aufgegeben und läuft längst B, gibt A's verspäteter Rückruf B's Platz frei – und C startet, während B noch bei ChatThrottleLib liegt. Womit wieder zwei gleichzeitig unterwegs sind und die Zusicherung aus 0.9.92 dahin ist.

Der Vermerk trägt jetzt eine laufende Nummer, und aufgeräumt wird nur bei Übereinstimmung. Der Watchdog dreht sie beim Aufgeben ebenfalls weiter, damit ein danach eintreffender Rückruf zu keinem laufenden Vorgang mehr gehört.

Bemerkenswert daran: Dieser Fehler war erst **durch** die Korrektur aus 0.9.92 möglich. Vorher gab es keinen In-Flight-Vermerk, den ein fremder Rückruf hätte löschen können. Jede eingeführte Zustandsvariable bringt die Frage mit, wer sie unter welchen Umständen wieder zurücksetzen darf – und bei Rückrufen aus fremdem Code lautet die Antwort selten „jeder".

## 0.9.92 – Die Kampfpause, dritter und letzter Anlauf

Derselbe Punkt zum dritten Mal, und diesmal stimmt auch die Beschreibung. Das ist die eigentliche Geschichte dieses Eintrags: Zweimal hintereinander wurde eine Korrektur als vollständig ausgegeben, die es nicht war.

**0.9.88** hat die Übergabe an ChatThrottleLib von der Kampfprüfung abhängig gemacht. Richtig, aber es verhindert nur, dass *während* des Kampfes übergeben wird.

**0.9.91** hat die Übergabe von `SendBulk` nach `PumpBulk` verlagert, damit die eigene Warteschlange maßgeblich bleibt. Im Änderungseintrag stand daraufhin: „an ChatThrottleLib geht immer nur das nächste Paket". Das beschrieb die Absicht, nicht den Code. `PumpBulk` hat eine `while`-Schleife, und die lief weiter, solange das Sendebudget reichte — rund vier Kilobyte, also etwa achtzehn Pakete auf einen Schlag. Die Nachprüfung hat es mit 30 Paketen ausgemessen: 18 sofort bei ChatThrottleLib, 12 in der eigenen Warteschlange. Anhalten lässt sich nur das Zweite.

Der Fortschritt gegenüber 0.9.88 war real — vorher konnte ein vollständiger Rezeptkatalog übergeben werden, jetzt waren es höchstens vier Kilobyte. Aber „begrenzt" ist nicht „pausiert", und die Formulierung im Änderungseintrag hat einen Rest als erledigt ausgegeben.

**Jetzt** liegt bei ChatThrottleLib höchstens ein Paket. `bulkInFlight` hält fest, welches; die Schleife bricht nach einer erfolgreichen Übergabe ab, und freigegeben wird das nächste erst vom Rückruf des vorigen. Weil der Weg von dort wieder durch `PumpBulk` führt, kommt er an der Kampfprüfung vorbei — beginnt der Kampf, ist höchstens noch dieses eine Paket unterwegs. Weniger geht nicht, ohne eine bereits übergebene Nachricht zurückzuziehen, und das kann ChatThrottleLib nicht.

**Warum das nichts kostet.** Der naheliegende Einwand gegen „eines nach dem anderen" ist Durchsatz. Hier ist keiner zu erwarten: Getaktet wird ohnehin auf 800 Byte pro Sekunde, bei rund 270 Byte je Paket also gut drei Pakete pro Sekunde. Die Serialisierung fügt je Paket ein Einzelbild hinzu — bei 60 Bildern je Sekunde etwa 16 Millisekunden gegen 300 Millisekunden Wartezeit aus der Drosselung. Der Engpass ist die Rate, nicht die Reihenfolge.

**Was dabei neu entstehen konnte.** Wenn immer nur ein Paket unterwegs ist, hält ein einziger ausbleibender Rückruf ab sofort den *gesamten* Abgleich an — vorher wäre nur dieses eine Paket hängen geblieben. Der Rückruf kommt aus einer fremden Bibliothek, auf deren Zuverlässigkeit dieses Addon sich nicht verlassen sollte. `BULK_IN_FLIGHT_TIMEOUT` gibt ihm 15 Sekunden; danach gilt das Paket als verloren und die Warteschlange läuft weiter. Eine Härtung, die es ohne diese Änderung nicht gebraucht hätte.

Der Regressionstest baut eine ChatThrottleLib nach und misst genau das nach, was die Durchsicht gemessen hat: 30 Pakete, davon genau eines übergeben; ohne Rückruf bewegt sich nichts; der Rückruf gibt genau eines frei; im Kampf gibt auch ein eintreffender Rückruf nichts mehr frei; nach dem Kampf läuft es weiter; und ein ausbleibender Rückruf blockiert nicht dauerhaft.

## 0.9.91 – Nachprüfung: fünf Befunde, zwei davon aus der eigenen Vorwoche

Eine zweite Durchsicht gegen `v0.9.89`. Von fünfzehn Befunden der ersten Runde waren dreizehn geschlossen; geblieben sind fünf neue. **Alle fünf wurden am Code nachgeprüft, alle trafen zu** – und zwei davon stecken in Code, der in derselben Sitzung entstanden ist. Das ist der interessantere Teil, also steht er zuerst.

### Die Reparatur band sich an die falsche Zuordnung

`CanRepairFrom` endete mit `IsSameEvening` – überlappender Zeitraum plus halbe Teilnehmerdeckung. Für die Abendliste ist das richtig: Ein Warcraft-Logs-Report und ein Dateiimport haben gar keine gemeinsame Kennung, dort muss geschätzt werden. Für die **Reparatur** ist es falsch, denn dort werden Zahlen verrechnet, und die Kennung liegt vor – seit 0.9.89 einigen sich alle Mitschreiber eines Abends über den Herzschlag auf dieselbe.

Der Befund zeigte es am nachgestellten Fall: Eine lückenhafte Karazhan-Sitzung ließ sich aus einer gleichzeitig laufenden Gruul-Sitzung „reparieren", weil beide Gruppen sich ein paar Leute teilten.

Beim Nachprüfen kam heraus, dass dieselbe Zeile auch in die **andere** Richtung falsch lag, und das wiegt schwerer: Die Deckungsschwelle von 50 % scheitert ausgerechnet dann, wenn der eigene Mitschnitt sehr lückenhaft ist. Wer den halben Abend weg war, kennt zu wenige Teilnehmer, um auf die Hälfte zu kommen – und bekam damit in genau dem Fall keine Reparatur, für den sie gebaut wurde. Kennungsgleichheit ersetzt beides und ist dabei einfacher als das, was sie ablöst.

### Eine Anfrage für alle, eine Drossel für alle

`RequestRepair` bekam die betroffene Auswertung übergeben und ignorierte sie: Hinaus ging ein pauschales `RQ|7`, und darauf antwortet jeder mit bis zu fünf vollständigen Auswertungen. Für eine einzelne Lücke ein Vielfaches an Funkverkehr.

Schlimmer war die Drossel auf der Antwortseite: **ein** Zeitstempel für alle Anfragenden. Fliegen nach einem Serverruckler drei Leute gleichzeitig raus – der Regelfall, für den die Reparatur existiert –, stellt jeder seine Anfrage, und nur der erste bekam eine Antwort. Die anderen liefen 30 Sekunden ins Leere.

Die Anfrage nennt jetzt die Kennung des Abends, die Antwort schickt nur diesen einen, und gedrosselt wird je Anfragendem. Der Router im Sync musste dafür mitziehen: Er verglich die Nachricht auf **Gleichheit** mit `"RQ|7"` und hätte die längere Form gar nicht durchgelassen. Ein Musterausdruck (`^RQ|7`) wäre die naheliegende Lösung gewesen und hätte auch auf `RQ|77` gepasst – also eine fremde Schemaversion durchgelassen; die Prüfung vergleicht deshalb ausdrücklich Kopf und Trennzeichen.

**Ein Test hat dabei jahrelang das Falsche bewiesen.** In `smoke.lua` stand: „Einem unberechtigten Anfrager wurde die Auswertung geschickt". Er war grün – aber nicht, weil ein Recht geprüft wurde. Geblockt hat immer nur die globale Drossel, weil die vorige Anfrage Sekundenbruchteile vorher lief. Der Test hat also die Wirkung eines Fehlers als Sicherheitsmerkmal festgeschrieben. Er prüft jetzt, was tatsächlich gilt: dieselbe Person zweimal hintereinander wird gedrosselt, eine zweite Person nicht.

### Dieselbe Bugklasse, ein Modul weiter

In 0.9.88 wurde die Gildenbank-Konvergenz repariert: Das Manifest forderte bei gleicher Sekunde und abweichendem Fingerabdruck an, und der Empfang verwarf genau das wieder – eine Endlosschleife, gelöst durch **eine gemeinsame Gewinnregel** für beide Seiten.

Der Werkstatt-Abgleich hat exakt dieselbe Struktur, und dort wurde die Regel nicht nachgezogen. `ClaimRecipes` verwarf nur strikt ältere Stände (`>`), während der Kommentar direkt darüber „Gleichstand zählt als schon da" behauptete – Code und Kommentar widersprachen einander, und der Code gewann. Zwei verschiedene Rezeptstände derselben Sekunde überschrieben einander, wer zuletzt eintraf, hatte recht. Auf der Manifestseite stand eine reine Ungleichheitsprüfung, die auch nachweislich ältere Stände als „fehlt" meldete, an zwei Stellen.

Das ist die Lehre aus diesem Befund: Eine Klasse von Fehlern ist erst behoben, wenn alle Stellen erfasst sind, die sie teilen. `ProfessionWins` steht jetzt neben `WinsOverKnown` und wird von allen drei Stellen benutzt. Die Rezeptanzahl fällt als Kriterium weg – sie steckt im Fingerabdruck und erzeugte nur zusätzliche Fehlanforderungen.

### Die Kampfpause war eine halbe

In 0.9.88 wurde die Übergabe an ChatThrottleLib von der Kampfprüfung abhängig gemacht. Das war richtig und trotzdem nicht genug: Es verhindert nur, dass **während** des Kampfes übergeben wird. Ein Paket, das eine Sekunde vor dem Pull übergeben wurde, liegt nicht mehr in der eigenen Warteschlange und lässt sich nicht mehr anhalten.

Und genau so arbeitet die Werkstatt: `PumpSyncQueue` reicht ihre **gesamte** Warteschlange in einem Durchlauf weiter. Ein vollständiger Rezeptkatalog war damit außer Reichweite, sobald danach der Kampf begann. Pausiert wurde nur, was zufällig währenddessen eingereiht wurde.

Die Konsequenz ist eine Umkehr der Zuständigkeit: Die eigene Warteschlange ist jetzt die maßgebliche, und ChatThrottleLib bekommt in `PumpBulk` immer nur das nächste Paket. Sie behält damit ihre eigentliche Aufgabe – sie kennt den Verkehr anderer Addons und teilt den Kanal fair auf –, ohne die Kontrolle über die Reihenfolge zu übernehmen. Nebenwirkung, bewusst in Kauf genommen: Das eigene Sendebudget gilt jetzt auch für diesen Weg. Es drosseln also beide, und es gilt die vorsichtigere Schranke. Der Kanal gehört diesem Addon nicht allein.

### Gewinnen mit einer Angabe, die die Daten nicht tragen

Der letzte Befund ist Protokollhärtung und im normalen Ablauf unauffällig: Bei der Gildenbank entscheidet der **übertragene** Fingerabdruck den Konflikt, gespeichert wurde danach der **nachgerechnete** – ohne die beiden zu vergleichen. Passen sie nicht zusammen, hat sich ein Absender mit einer Angabe durchgesetzt, die seine Daten nicht belegen, und der Tab stand anschließend mit einem anderen Fingerabdruck da als dem, der die Entscheidung gewonnen hatte. Beim nächsten Manifest wurde er prompt wieder angefordert. Stimmen die beiden nicht überein, wird der Stand jetzt verworfen.

## 0.9.90 – Ein Balken, der nur eine Richtung kennt

**Die Meldung:** „Wenn das Addon Berufe synchronisiert, dann ist der Fortschrittsbalken sehr sprunghaft, zb 80 % → 40 % → 90 % → 10 %, und das sehr schnell, so dass man nie weiß, wie weit der Fortschritt eigentlich ist."

Der Balken hat dabei nie falsch gerechnet. Er hat eine Frage beantwortet, die niemand gestellt hat.

**Der Nenner ist der Umfang, und der wächst.** In `GetSyncStatus` stand:

```lua
status.total = math.max(status.total, status.done + outstanding)
status.done  = math.max(0, status.total - outstanding)
status.percent = math.floor((status.done / status.total) * 100)
```

`total` ist der Umfang des Durchlaufs und wächst mit, sobald neue Arbeit auftaucht – das war Absicht und steht so im Kommentar seit 0.9.86. Übersehen wurde die Folge für die Anzeige: Der *Anteil* fällt genau dann, wenn der Umfang steigt. Acht erledigte von zehn Paketen sind 80 %. Kommen zehn Pakete dazu, sind dieselben acht 8 von 20 und damit 40 %. Verloren gegangen ist nichts, die Bezugsgröße hat sich verdoppelt.

Nachgerechnet ergibt das exakt die gemeldete Folge:

| Takt | erledigt | offen | Umfang | Balken |
|---|---|---|---|---|
| 1 | 8 | 2 | 10 | 80 % |
| 2 (zehn neue) | 8 | 12 | 20 | 40 % |
| 3 | 18 | 2 | 20 | 90 % |
| 4 (achtzehn neue) | 18 | 18 | 36 | 50 % |

Der Berufsabgleich ist dafür der ungünstigste Fall überhaupt, weil die Arbeit dort in Wellen eintrifft: Jedes fremde Manifest hebt `GetPendingWantCount`, danach trudeln die Rezepte ein, dann kommt das nächste Manifest. Bei `PROGRESS_TICK` von einer halben Sekunde sieht man jede einzelne Welle.

**Warum kein ehrlicherer Anteil hilft.** Der naheliegende Gedanke – `done` richtig zählen statt zurückzurechnen – ändert nichts. `done` ist bereits monoton: Wächst der Umfang um zehn, während zehn Pakete dazukommen, bleibt `done` stehen. Das Problem liegt nicht im Zähler, sondern darin, dass ein Anteil an einer **unbekannten Gesamtmenge** grundsätzlich nicht monoton sein kann. Solange nicht feststeht, wie viel Arbeit noch kommt, ist jede Prozentangabe eine Momentaufnahme, die der nächste Fund entwertet.

Also wird die Frage geändert. Der Balken beantwortet ab jetzt nicht mehr „welcher Anteil des aktuell bekannten Umfangs ist erledigt", sondern „wie weit bin ich mindestens gekommen". Erledigtes bleibt erledigt, der Balken steigt nur. Technisch ist das eine Zeile – `status.percent` wird gegen seinen bisherigen Höchststand geklemmt –, dazu ein Zurücksetzen auf null beim Zyklusbeginn: Ohne das bliebe er auf den 100 % des vorigen Durchlaufs stehen, eben weil er nicht mehr zurückfällt.

**Was dabei nicht verschwiegen wird.** Ein geklemmter Balken kann stehen bleiben, wenn viel Neues auftaucht – und genau dann soll er stehen bleiben, statt zurückzuspringen. Die Auskunft über den gewachsenen Umfang steht weiterhin daneben: „Abgleich läuft • noch N Pakete". Dort ist ein Sprung nach oben eine Information und keine Irritation, weil eine absolute Zahl keine Vollständigkeit behauptet.

Die 99-Prozent-Deckelung bleibt, solange etwas offen ist. Ein Balken, der 100 % zeigt, während noch Pakete unterwegs sind, wäre die einzige Aussage, die schlimmer wäre als ein springender.

## 0.9.89 – Der eigene Abend gehört einem selbst

**Die Meldung war ein Satz:** „Letztens hat jemand die Sitzung gestartet und ich hatte die Sitzung nicht in meinen Einträgen drin." Dahinter steckten ein handfester Fehler und eine Grundsatzfrage, und die Grundsatzfrage ist die wichtigere.

### Der Fehler: eine Berechtigung auf der falschen Seite

`RaidMonitor:OnMessage` verwarf **jede** Sitzungsnachricht, wenn `CanControlSession(sender)` falsch war. Das klingt nach einer Zugriffskontrolle, ist aber eine auf der Empfangsseite – und geprüft wurde der Gildenrang des Absenders **in der eigenen Sicht**: Er musste im lokalen Rosterabbild stehen und einen Rang aus `memberCare.accessRanks` halten (Vorgabe: Rang ≤ 1).

Diese Einstellung wird zwar gildenweit abgeglichen, aber sie muss angekommen sein. Wen sie nicht erreicht hat, oder wessen Rosterabbild den Absender nicht kennt, der verwarf den Startruf – **und jeden der 60-Sekunden-Herzschläge gleich mit**. Genau der Herzschlag ist die Reparatur für einen verpassten Startruf; er lief in dieselbe Sperre. Damit war der Ausfall nicht flüchtig, sondern dauerhaft, und er meldete sich mit keiner Zeile. Auf der einen Seite lief eine ganz normale Sitzung, auf der anderen existierte der Abend nicht.

Eine Berechtigung gehört auf die **Sendeseite**. Entschieden wird jetzt danach, was eine Nachricht bewirkt: `RS` und `RH` sind Mitteilungen und setzen beim Empfänger nur das Etikett seines eigenen Mitschnitts – dafür braucht niemand einen Rang. `RE` beendet die Sitzung auch bei allen anderen, ist also ein Befehl und bleibt rangbeschränkt.

### Die Grundsatzfrage: wem gehört ein Raidabend?

Bis 0.9.88 gehörte eine Sitzung dem **Raid**. Startete jemand früher, gewann seine Kennung, und `AdoptForeignSession` warf den eigenen Mitschnitt weg. Eine Schonfrist von zwei Minuten milderte das ab: Danach blieb der eigene stehen, und es liefen zwei Auswertungen nebeneinander.

Das war die falsche Richtung. Der eigene Mitschnitt ist das, was dieser Client mit eigenen Augen gesehen hat – und genau der ist die belastbare Quelle, wenn bei jemand anderem eine Lücke zu füllen ist. Ihn wegzuwerfen, um eine Kennung aufzuräumen, verliert Substanz für Kosmetik.

Der Wunsch des Owners war entsprechend: *„Ich möchte für mich meine eigene Sitzung starten, die mit anderen zwar geshared wird und abgeglichen wird"* – Abgleich als **Backup gegen Datenverlust**, nicht als Eigentumsübergang.

Umgesetzt ist das als Trennung von **Etikett** und **Inhalt**. Übernommen wird nur noch die Kennung des Abends samt Startzeit und Eröffner, nach der schon vorhandenen deterministischen Regel (frühere Startzeit gewinnt, bei Gleichstand die kleinere Kennung). Weil die Regel auf jedem Client dasselbe Ergebnis liefert, einigen sich am Ende alle auf dieselbe Kennung – ohne dass jemand etwas verliert. `SESSION_MERGE_GRACE` und `DiscardSession` sind damit ersatzlos entfallen: Beide gab es nur, um zu entscheiden, wann weggeworfen wird.

Dass die Architektur das trägt, war schon vorbereitet: `SummaryKey` identifiziert eine Auswertung über Kennung **und** Quelle, und `GetEvenings` fasst denselben Abend aus mehreren Quellen zu einem Eintrag zusammen. Was fehlte, war die Quelle selbst – alle empfangenen Auswertungen hießen `SYNC` und überschrieben sich damit gegenseitig. Von zwei Gildenmitgliedern, die denselben Abend mitgeschrieben hatten, blieb genau eins übrig. Die Quelle heißt jetzt `SYNC:Name`.

### Lücken sind messbar, und zwar ohne neue Buchführung

Eine Sitzung überlebt einen Reload bereits: `SaveSessionForResume` schreibt sie samt `savedAt` in die SavedVariables, `ResumeSession` holt sie zurück und hält die Anwesenheitsuhren **ohne Gutschrift** an – die Zeit dazwischen wurde ja nicht gespielt. Damit lag die Lücke längst vor, sie wurde nur nirgends festgehalten.

`NoteGap` schreibt sie jetzt an die Sitzung, aus drei Anlässen: beim Fortsetzen nach einem Reload (`savedAt` bis jetzt), nach einem Absturz (ohne `savedAt` ist die Länge unbekannt – dass etwas fehlt, ist die wichtigere Auskunft) und beim späten Einstieg in einen laufenden Abend. Daraus folgt `SessionIsComplete`, und das wandert als `complete` in jede geteilte Auswertung.

Der Herzschlag-Zweig lief dabei in eine Falle: Er rief bei fehlender eigener Sitzung direkt `StartSession` statt `AdoptForeignSession` und hätte einen Nachzügler damit als **lückenlosen** Mitschnitt geführt – der wäre dann sogar zum Reparieren fremder Lücken herangezogen worden. Beide Wege gehen jetzt über dieselbe Stelle.

### Reparieren, ohne fremde Fehler zu importieren

Verrechnet wird der **Höchstwert** je Teilnehmer und Zähler, nicht die Summe. Eine Summe zählte doppelt, was beide gesehen haben; der höhere Wert dagegen stammt von dem, der mehr vom Abend mitbekommen hat – und niemand kann mehr Tode gesehen haben, als es gab.

Dieses Argument trägt aber nur unter Bedingungen, und die entscheidende kam vom Owner als Rückfrage: **„Was ist, wenn jemand eine alte Version hat, wo doppelt gezählt wird?"** Damit fällt die naive Höchstwert-Regel. Ein Client vor 0.9.87 schreibt Trommeln jedem Beschenkten gut – im Vergleichslog 68 statt 28 – und meldet Essen zu niedrig. Der Höchstwert übernähme also nicht den vollständigeren, sondern den kaputten Zähler. Dasselbe gilt für die Anwesenheit vor 0.9.88, die Offlinezeit mitzählte.

`SCHEMA_VERSION` hilft dagegen nicht: Sie beschreibt das Nachrichtenformat, und das war bei 0.9.86 und 0.9.88 identisch – die Pakete kommen also durch. Gebraucht wird eine Angabe darüber, ob zwei Zahlen **dasselbe bedeuten**. `GC.Constants.RAID_RULES_VERSION` ist genau das und steigt bei jeder Bedeutungsänderung, auch wenn das Format gleich bleibt. Das Muster gab es im Haus schon: `GC.EnchantRuleSet.version` hängt seit jeher als `ruleVersion` an jeder Ausrüstungsprüfung.

Verrechnet wird deshalb nur, was **beide** Bedingungen erfüllt: dieselbe Regelversion, und die Quelle meldet sich selbst als lückenlos. Eine selbst lückenhafte Quelle liefert nur die bessere Untergrenze, nicht belegbar den richtigen Wert. Warcraft-Logs- und Dateiimporte scheiden ohnehin aus – ihre Anwesenheit ist reine Encounter-Zeit. Alles Untaugliche bleibt sichtbar nebeneinander stehen, statt still einzufließen.

Das Ergebnis ist eine eigene Quelle (`REPAIR`). Der eigene Rohmitschnitt und die fremde Fassung bleiben unverändert daneben – die Reparatur ist damit nachvollziehbar und umkehrbar.

### Beobachtungen teilen, nicht Urteile

Aus der Rückfrage folgt ein allgemeiner Grundsatz, und es lohnt sich, ihn zu benennen: **Über den Kanal gehören Beobachtungen, keine fertigen Urteile.**

Die Ausrüstungsprüfung macht das schon richtig. Übertragen werden `itemID`, `enchantID` und leere Sockel; `BuildSyncedAudit` fällt jedes Urteil lokal mit den **eigenen** Regeln neu. Ein alter Client kann dort keine falschen Befunde einschleusen – der Weg ist von Bauart sicher, ganz ohne Versionsprüfung.

Die Raidauswertung ist die Ausnahme: Sie überträgt fertige Zähler. Das lässt sich nicht ohne Weiteres ändern – Ereignisse einzeln mit Zeitstempel zu übertragen wäre ein Vielfaches an Datenverkehr –, und deshalb braucht genau sie die Regelversion. Wo künftig ein berechneter Wert den Client verlässt, gilt dieselbe Frage: Kann der Empfänger ihn selbst herleiten? Wenn nein, muss dabeistehen, nach welchen Regeln er entstanden ist.

### Was die Tests dazu sagen

Drei bestehende Erwartungen in `smoke.lua` hielten das alte Modell fest und mussten umgedreht werden – jede davon ist jetzt ein Test **für** das neue Verhalten:

- Ein Herzschlag ohne Steuerungsrecht des Absenders wurde bisher verworfen. Genau das war der gemeldete Fehler; der Test prüft jetzt, dass er ankommt **und** eine Lücke hinterlässt.
- Ein seit einer Stunde laufender Mitschnitt behielt seine Kennung. Jetzt wechselt das Etikett, und geprüft wird, dass Teilnehmer und Versuche dabei erhalten bleiben.
- Ein einfaches Raidmitglied durfte keine Auswertung einspielen. Jetzt darf es – unter seinem Namen, und ohne den eigenen Mitschnitt zu berühren.

Dazu ein neuer Block für die Reparatur, der ausdrücklich den Fall des Owners abbildet: Ein Mitschnitt mit 68 Trommeln aus Regelversion 1 liegt vor, ist vollständig und hat den höheren Wert – und darf trotzdem nirgends einfließen.

## 0.9.88 / Installer 1.0.7 – Eine Durchsicht und ihre Befunde

Anlass war eine vollständige Durchsicht der Codebasis durch ein zweites Modell. Sie meldete drei schwerwiegende Korrektheitsprobleme und sieben weitere. **Alle fünfzehn Punkte wurden am Code nachgeprüft, alle waren zutreffend** – keine Falschmeldung. An vier Stellen war die Darstellung ungenau oder der vorgeschlagene Weg untauglich; das steht jeweils dabei, weil die Abweichung die eigentliche Entscheidung ist.

### Der Offline-Importer hatte den Fehler, den 0.9.87 live abgestellt hat

0.9.87 hat vier Ursachen für falsch gezählte Verbrauchsgegenstände beseitigt – **in der Livesitzung**. Der Importer aus der `WoWCombatLog.txt` hat sie weiter gemacht: `Classify` zählte `SPELL_CAST_SUCCESS` **und** `SPELL_AURA_APPLIED`/`SPELL_AURA_REFRESH` aus einer einzigen flachen ID-Liste, und die Aura wurde dem **Ziel** gutgeschrieben. Damit war exakt das wieder da, was der Vergleichslog vom 02.08.2026 gezeigt hatte: die Trommel bei jedem, der den Buff bekam, der Hasttrank doppelt, Fläschchen mehrfach über Auffrischungen.

Bemerkenswert ist, wie gut das versteckt war. Der Docstring der Methode behauptete wörtlich, gezählt werde „genau das, was die Livesitzung auch zaehlt" – und erklärte darunter ausführlich die Doppelzählung bei Wiederbelebungen, die dort tatsächlich behoben ist. Dieselbe Überlegung war für Verbrauchsgegenstände nie angestellt worden. Auch die Prüfung „die 50 Spell-IDs stimmen zwischen Lua, C# und Companion überein" ging glatt durch, weil nicht die **Liste** abwich, sondern die **Regel**.

Die Trennung liegt jetzt in `SpellIds`: `Consumables` sind die Gegenstände mit Wirkereignis, `FoodAuras` die Sattgegessen-Buffs. `ConsumableSet` bleibt die Vereinigung, denn abgefragt und übertragen wird weiterhin alles – unterschieden wird nur beim **Zählen**. Das entspricht `GC.ConsumableCategories` im Addon (`track = "AURA"` allein für Essen). Der Warcraft-Logs-Weg hatte übrigens von Anfang an eine eigene, ebenfalls richtige Regel: Gibt es zu einer ID überhaupt Zauber, gewinnt der Zauber. Drei Wege, drei Auslegungen, von denen zwei stimmten.

Abgesichert ist das jetzt mit einem Selbsttest, der ein kleines Kampfprotokoll von Hand baut: Eine Trommel, geworfen von Alex und als Buff bei Bea angekommen, muss bei Alex mit 1 und bei Bea mit 0 stehen; ein Hasttrank mit Zauber und eigener Aura zählt einmal; Essen zählt allein über den Buff.

### Ein zu großer Import kam halb an und sah wie ein Erfolg aus

Das Importfeld im Addon nimmt 60.000 Zeichen (`SetMaxLetters` in `UI.lua`). WoW schneidet längeren Text beim Einfügen stillschweigend ab, und der Parser nimmt den Rest als gültigen Teilimport – der Abend fehlt halb, ohne dass irgendwo ein Fehler steht. Der Warcraft-Logs-Bereich prüfte das seit jeher und beschrieb die Falle sogar im Kommentar; der Companion prüfte sie; der Offline-Import kopierte ungeprüft.

Die Zahl stand an zwei Stellen und steht jetzt an einer: `AddonImport.Limit`. Wichtiger ist, was bei Überschreitung passiert. Eine Fehlermeldung wäre hier nutzlos – eine `WoWCombatLog.txt` sammelt oft viele Abende, und der Nutzer kann daran nichts ändern. Der Importer schneidet deshalb **an der Abendgrenze** zu und behält die neuesten Abende: Das ist der Stand, den man importieren will. Ein halber Abend käme dagegen einem vollständigen zum Verwechseln ähnlich. Wie viele Abende weggelassen wurden, steht in der Statuszeile und nicht nur im Protokoll darunter, wo es zu leicht zu übersehen ist. Passt nicht einmal der letzte Abend allein, bricht der Import mit klarer Begründung ab.

### „raid7" ist kein Spieler

Der schärfste Befund. Die Warteschlange der Ausrüstungsprüfung merkte sich den Unit-Token („raid7") und den Namen beim Einsammeln, die **GUID aber erst unmittelbar vor dem Inspizieren**. Zwischen beidem liegen `INSPECT_INTERVAL` = 1,5 Sekunden je Eintrag, bei 24 Spielern also gut eine halbe Minute. Wechselt in dieser Zeit jemand die Gruppe oder verlässt den Raid, verschieben sich alle dahinter – und „raid7" meint einen anderen Spieler.

Die vorhandene GUID-Prüfung schützte davor **nicht**, und der Grund ist subtil: Sie vergleicht die GUID aus `INSPECT_READY` mit der, die kurz zuvor gelesen wurde. Beide gehören dann zum *neuen* „raid7“ und stimmen überein. Die Prüfung beantwortet also nur „gehört diese Antwort zu meiner Anfrage", nicht „ist das noch derselbe Spieler". Gespeichert wurde anschließend die Ausrüstung des neuen Spielers unter dem beim Einsammeln gemerkten **Namen des alten**.

Die Durchsicht empfahl, „Spieleridentität und GUID beim Einsammeln festzuhalten" – der Name wurde bereits beim Einsammeln festgehalten, nur die GUID nicht. Die Diagnose der Ursache war exakt richtig. Jetzt wird die GUID mit eingesammelt, und `ResolveUnit` prüft vor jedem Zugriff, ob der Token noch denselben Spieler meint; wenn nicht, wird der Spieler in der aktuellen Aufstellung gesucht. Geprüft wird an drei Stellen: vor der Reichweitenprüfung (die auf einem verschobenen Token die Frage für den Falschen beantwortet), vor `NotifyInspect` und noch einmal beim Eintreffen der Antwort. Wer den Raid ganz verlassen hat, wird übersprungen statt falsch gespeichert.

### Die Gildenbank lief im Kreis

Der Manifest-Empfänger forderte einen Tab an, wenn die Zeitstempel gleich, die Fingerabdrücke aber verschieden waren. Der Transfer-Empfänger verwarf genau diesen Stand, weil er „nicht neuer" war. Anfordern, senden, verwerfen – und beim nächsten Manifest von vorn. Das ist keine theoretische Möglichkeit: `updatedAt` kommt aus `GetServerTime()` und kennt nur ganze Sekunden.

Behoben ist das nicht durch eine zusätzliche Bedingung an einer der beiden Stellen, sondern durch **eine gemeinsame Regel**: `WinsOverKnown` – der neuere Stand gewinnt, bei gleicher Sekunde der mit dem größeren Fingerabdruck. Beide Seiten rufen dieselbe Funktion auf, und damit fordert das Manifest nur noch an, was der Empfang auch annimmt. Dass die Regel bei Gleichstand willkürlich wirkt, ist Absicht: Sie muss nicht „richtig" sein, sondern **auf allen Clients gleich**.

Dazu ein zweiter Punkt aus der Durchsicht: Der Fingerabdruck wurde vom Absender übernommen statt nachgerechnet. Passt er nicht zu den empfangenen Beständen, steht ab dann ein falscher Fingerabdruck im eigenen Manifest – und alle anderen fordern den Tab dauerhaft neu an. Er wird jetzt aus den dekodierten Beständen selbst berechnet. Das ist sicher, weil eine Übertragung entweder vollständig ankommt oder ganz verworfen wird; ein halber Tab kann nicht entstehen.

Der Leistungsbefund im selben Modul war ebenfalls zutreffend und ließ sich exakt nachrechnen: Erledigte Fächer wurden nicht aus `pendingTabs` genommen, und der Ereignishandler las das offene Fach plus alle noch ausstehenden. Acht Fächer plus das offene, mal 98 Slots, ergibt die genannten **882 Abfragen je Bankereignis** – und nebenbei neun Oberflächen-Aktualisierungen. Ein Fach wird jetzt beim Lesen aus der Liste genommen, ein nicht einsehbares ebenfalls.

### Die Kampfpause, die von der Addon-Umgebung abhing

`SendBulk` übergab an ChatThrottleLib, **bevor** `InCombat()` überhaupt geprüft wurde – die Prüfung stand erst weiter unten in `PumpBulk`. Wer eine globale ChatThrottleLib geladen hatte, und das ist bei Raidern die Regel, für den war die Einstellung „Bulk-Sync im Kampf pausieren" wirkungslos. Ohne die Bibliothek pausierte der Versand zwar, der Antriebsrahmen blieb aber sichtbar und lief den ganzen Kampf über bei jedem Einzelbild an, nur um sofort wieder auszusteigen.

Beim Verschieben der Prüfung nach oben lauerte eine Lua-Eigenheit, die einen stillen Totalausfall bedeutet hätte: `local function InCombat()` stand **hinter** `SendBulk`. Ein Aufruf von dort wäre zur Übersetzungszeit kein Zugriff auf die lokale Funktion gewesen, sondern auf eine gleichnamige **globale** – die es nicht gibt. Der Aufruf hätte immer `nil` ergeben und die Pause wäre weiterhin wirkungslos geblieben, nur diesmal ohne erkennbaren Grund. Die Funktion steht deshalb jetzt oben bei den Bulk-Konstanten, mit einem Kommentar, der genau das festhält.

Der Rahmen legt sich im Kampf schlafen und wird von `PLAYER_REGEN_ENABLED` wieder geweckt – ein verstecktes Frame bekommt weiterhin Ereignisse, nur kein `OnUpdate`. Die Kampfdauer wird beim Aufwachen auf das Sendebudget angerechnet, dieselbe Verrechnung wie nach einer Leerlaufpause.

### Werkstatt: kein Rückschritt, ein Schlüssel

`ClaimRecipes` übernahm eingehende Rezeptlisten ohne Blick auf den vorhandenen `updatedAt`. Der Aufrufer hatte den bestehenden Eintrag sogar schon in der Hand – für die Prüfung auf eine Teillieferung – und verglich die Zeitstempel trotzdem nicht. Die Durchsicht nannte das etwas breiter, als es zutraf: Der Schutz gegen Teillieferungen fängt den Fall ab, dass ein verspätetes Paket die Liste **kürzt**. Voll trifft der Befund die vollständigen Schlüssellisten („K"), für die dieser Schutz bewusst abgeschaltet ist – dort konnte ein alter Stand die seitdem gelernten Rezepte entfernen. Der Zeitstempel wurde in jedem Fall zurückgedreht. Ein älterer Stand gewinnt jetzt nicht mehr; Gleichstand zählt als „schon da".

Beim Namensschlüssel war der Befund technisch richtig, aber anders gelagert als beschrieben: Nicht „mehrere Bereiche entfernen den Realmanteil", sondern **die Werkstatt als einzige behielt ihn**, während Raidauswertung und Ausrüstungsprüfung längst kürzen. Da `GC:GetPlayerFullName()` den Realm immer anhängt, fremde Clients einen Charakter aber ohne melden, stand derselbe Spieler unter zwei Schlüsseln. Der Owner hat entschieden: **Cross-Realm gibt es hier nicht.** Damit ist `GC.Util.PlayerKey` die eine Stelle, die aus einem Namen einen Tabellenschlüssel macht – Kurzname, kleingeschrieben. Die Werkstatt benutzt sie durchgehend, und eine einmalige Migration führt vorhandene Einträge mit Realmanteil zusammen; bei doppelten Berufen gewinnt der neuere Stand.

Nebenbei geprüft und ausdrücklich **in Ordnung**: `StoreAudit` schlüsselte ohne Kürzung, `GetAudit` mit. Das sieht nach einem Schlüsselbruch aus, ist aber folgenlos, weil beide Erzeuger den Namen vorher kürzen. Beide benutzen jetzt `PlayerKey`, damit die Symmetrie sichtbar ist – eine Verhaltensänderung ist es nicht.

### Verlernen, Adds und ein Abo, das nicht aufhörte

Ein **verlernter Beruf** blieb für immer stehen: Eine bestätigt leere Berufsliste setzte nur die Quelle auf „EMPTY" und kehrte zurück, ohne zu räumen und ohne zu synchronisieren. Die Vorsicht dahinter ist berechtigt – direkt nach dem Login ist die Liste oft nur noch nicht geladen. Sie braucht aber ein Ende. Der Ausweg ist kein Zeitfenster und kein Zähler, sondern ein Beleg: Geräumt wird, wenn **derselbe Spielstart die Berufe vorher schon einmal gelesen hat**. Dann gibt der Client die Liste nachweislich heraus, und leer heißt leer. Wer einen Beruf verlernt, hat ihn in derselben Sitzung vorher gesehen; wer nie welche hatte, verliert nichts.

Die **Kill-Heuristik** griff, wenn `ENCOUNTER_END` fehlt – und wertete jeden toten Gegner als Sieg, weil sie nur auf „irgendein NPC ist gestorben" sah. Der erste gestorbene Add machte damit aus einem abgebrochenen Versuch einen Kill. Gewertet wird jetzt der Tod des **Bosses**: entweder löst der gestorbene Gegner in `GC.RaidBosses` auf, oder sein Name entspricht dem bereits erkannten Boss des Abschnitts. Abschnitte ohne erkannten Boss wurden ohnehin nie gewertet.

Das **Item-Cache-Abo** der Selbstprüfung blieb nach dem letzten Versuch bestehen. Danach löste jedes nachgeladene Item eine neue Vollprüfung aus – auch eines aus der Bank, dem Auktionshaus oder einem Chatlink –, die am selben Limit sofort wieder scheiterte. Das Abo hält jetzt nur noch, solange auch wiederholt wird; ein Ausrüstungswechsel setzt den Zähler zurück und gibt neue Versuche.

### Anwesenheit: eine Entscheidung, kein Fehler

Die Durchsicht hat richtig erkannt, dass getrennte Raidmitglieder als anwesend zählten, und ebenso richtig offengelassen, ob das ein Fehler ist – das hängt davon ab, was „Teilnahme" bedeuten soll. Der Code war sich darin selbst uneins: Die Ausrüstungsprüfung fragte `UnitIsConnected` ab, der Raidmonitor nicht.

Die Entscheidung des Owners: **Die Anwesenheitsuhr pausiert bei Verbindungsverlust.** Wer rausfliegt, bleibt Teilnehmer des Abends – er war ja da –, sammelt aber keine Zeit mehr. Beim Wiedereinloggen läuft die Uhr weiter, das bis dahin Gesammelte bleibt. Vorher stand ein Spieler, der nach zwanzig Minuten rausflog und nicht wiederkam, am Ende mit der vollen Abenddauer da, solange ihn niemand aus dem Raid nahm.

### Installer: Rollback statt Verzeichnistausch

Der Befund zur nicht-atomaren Installation war zutreffend: Es wurde direkt über die laufende Installation kopiert, und ein Abbruch mittendrin hinterließ eine Mischung zweier Versionen. Der **vorgeschlagene Weg** – in ein Staging-Verzeichnis kopieren und die Verzeichnisse atomar tauschen – war es nicht. Der Kommentar an genau dieser Stelle begründet seit jeher, warum nicht gelöscht wird: Ein offenes Explorer-Fenster oder eine laufende Datei im Companion-Ordner sperrt das Löschen. Ein Verzeichnistausch braucht dasselbe Umbenennen des Live-Ordners und scheitert an derselben Sperre. Der Vorschlag hätte das Problem zurückgeholt, das der Code bewusst umgeht.

Gewählt ist deshalb der Weg, der beides kann: Jede Datei wird daneben geschrieben und dann mit `File.Replace` in einem Schritt an ihren Platz gesetzt, wobei die vorherige Fassung in eine Sicherung wandert. Eine halb geschriebene Datei kann so nie live werden. Scheitert etwas mittendrin, werden die bereits ersetzten Dateien aus ihren Sicherungen zurückgeholt. Das Aufräumen verwaister Dateien läuft erst **nach** dem Erfolg – was dort gelöscht wird, holt kein Rollback zurück.

Dazu der Doppelklick: `SetBusy` griff erst in `InstallAsync`, also lange nach dem Klick. Der erste Schritt von „Nach Updates suchen" ist aber eine Netzabfrage, und währenddessen blieb der Knopf bedienbar – zwei Durchläufe konnten gleichzeitig in denselben Ordner installieren. Zusammen mit der nicht-atomaren Installation war das die gefährlichere Hälfte des Befundes. Ein Wiedereintrittsschutz deckt jetzt den gesamten Durchlauf ab, auch den beim Programmstart.

### Der Jahreswechsel

Alte Spielfassungen schreiben kein Jahr in den Zeitstempel; bis 1.0.6 galt für jede Zeile das Jahr der Datei. Ein Raidabend über Silvester bekam damit durchgehend das Jahr des 1. Januar, und der Dezemberteil sprang um ein Jahr nach vorn. Im Log zeigt sich der Wechsel als Monatsrücksprung (12 → 1); die Datei endet im Jahr ihres Zeitstempels, fängt also im Jahr davor an, wenn ihr erster Monat hinter dem letzten liegt. Nachgezogen werden ausschließlich selbst gesetzte Jahre – steht das Jahr im Log, ist es richtig.

### Was die Tests dazugelernt haben

Vier Regressionstests in `smoke.lua` (Add-Tod ist kein Sieg, Anwesenheitsuhr bei Verbindungsverlust, kein Rückschritt im Werkstatt-Abgleich, Verlernen wird sichtbar) und einer im Installer-Selbsttest (Verbrauchsgegenstände und Jahreswechsel an einem gebauten Kampfprotokoll). Jeder von ihnen schlägt gegen den Stand vor dieser Version fehl.

Drei bestehende Erwartungen in `smoke.lua` mussten mitgezogen werden: Sie schrieben die Werkstatt-Schlüssel **mit** Realmanteil fest und hätten die Vereinheitlichung sonst blockiert. Das ist die beabsichtigte Änderung, kein Nachgeben gegenüber dem Test – die Erwartung prüft jetzt zusätzlich, dass der alte Schlüssel verschwunden ist.

## 0.9.87 – Verbrauchsgegenstände: gegen einen echten Log gerechnet

Die Meldung war knapp: „Die Auswertung der Consumables hat gar nicht funktioniert", dazu ein Warcraft-Logs-Bericht vom 02.08. als Vergleich und der Hinweis „ich hatte mehr als 1 Bufffood". Der Vergleich hat nicht einen Fehler gezeigt, sondern **vier voneinander unabhängige**, die sich gegenseitig verdeckt haben. Deshalb steht hier jede Ursache einzeln mit ihrem Beleg.

**1. Trommeln wurden dem Beschenkten gutgeschrieben.** Der Livemitschnitt zählte einen Verbrauch sowohl beim `SPELL_CAST_SUCCESS` des Benutzers als auch beim `SPELL_AURA_APPLIED` des Ziels. Für alles Selbstbenutzte fällt das nicht auf – für Trommeln schon: Sie buffen die ganze Gruppe. Der Beleg aus dem Log ist eindeutig: **Trommeln der Schlacht wurden von genau fünf Spielern geworfen** (Attilus 28, Buffdæddy 16, Midgart 15, Hümäh 2, Zewâ 1). Die Auswertung zeigte Trommeln bei mindestens acht, darunter zwei, die im ganzen Abend keine einzige geworfen haben (Rúmpel 20, Neynmanyo 19), und Attilus mit 68 statt 28.

Dieselbe Doppelzählung traf jeden Trank mit Buff. Ignatdust hat laut Log **vier Hasttränke** benutzt; angezeigt waren **acht** – Zauber und eigene Aura, sauber verdoppelt. Manatränke blieben unauffällig, weil „Mana wiederherstellen" keine Aura setzt; genau deshalb stimmte Zewâs 22 und niemandem ist aufgefallen, dass die Spalte kaputt ist.

Die Lösung ist keine Heuristik, sondern eine Eigenschaft je Kategorie. `GC.ConsumableCategories` trägt jetzt `track`: `CAST` für alles, was benutzt wird (Tränke, Runen, Trommeln, Fläschchen, Elixiere, Öle), `AURA` für Essen. Essen ist der einzige Fall ohne Wirkereignis – gegessen wird, der Sattgegessen-Buff erscheint Sekunden später von selbst. Damit ist die Regel statisch und nicht mehr davon abhängig, ob in einem Zeitfenster zufällig ein Zauber mitgeschnitten wurde.

Nebenbei entfallen ist der Namensvergleich auf „Sattgegessen"/„Well Fed". Er hätte auf dem deutschen Client ohnehin nie getroffen: Die Aura heißt dort **„Satt"** – und genauso heißt der Kampfrausch-Debuff. Ein Namensvergleich hätte also entweder nichts gefunden oder das Falsche.

**2. Die geläufigsten Tränke standen nicht in der Liste.** Was die Liste nicht kennt, wird nicht gezählt, und was der Companion nicht kennt, filtert die Abfrage schon serverseitig weg. Im Log stehen **41617 und 41618** – die Manasalben und -flaschen aus Zangarmarschen und Netherstrum. Allein auf sie kommen **146 Anwendungen**. Nexarius hat 24 Manatränke benutzt und stand mit **1** da; Attilus hat 23 benutzt und stand mit **0** da.

Nachgetragen sind außerdem 41619/41620 (die Heilvarianten derselben Reihe), **28506 Heldentrank** sowie die Elixiere **17539** (Großes Arkanelixier), **33720** (Elixier des Ansturms) und **33721** (Elixier des Adepten) – alle im Vergleichslog belegt. Zwei bestehende Einträge waren schlicht falsch beschriftet: 28511 und 28512 hießen „Heldentrank" und „Eisenschildtrank", sind aber der **Feuer-** und der **Frostschutztrank**. Der echte Heldentrank fehlte deshalb ganz. Beide Namen sind gegen die TBC-Spelldatenbank geprüft, wie es der Kommentar an der Wiederbelebungsliste seit dem 25235-Vorfall verlangt.

**3. Dauerbuffs zählten je Abend einmal.** Fläschchen, Elixiere und Essen waren als „nicht wiederholbar" markiert und wurden je Spell-ID einmal gezählt – live über ein `seenConsumables`-Merkfeld, beim Import über eine zweite Zählung, die die vom Companion gelieferte Anzahl auf eins stutzte. Der Companion zählt **Verbräuche**, keine Zustände; die Kappe hat seine richtigen Zahlen wieder eingeebnet. Genau das steckte hinter „ich hatte mehr als 1 Bufffood". Gezählt wird jetzt in allen Kategorien der Verbrauch. Auf der Companion-Seite zählt zusätzlich `refreshbuff` mit: Wer nach einem Wipe dasselbe Gericht isst, während der Buff noch läuft, erzeugt eine Auffrischung statt einer neuen Anwendung – ohne sie war ein ganzer Raidabend Essen ein einziges Essen.

**4. Was vor dem Sitzungsbeginn getrunken wurde, war unsichtbar.** Fläschchen und Elixiere kommen vor dem Raid auf den Charakter, oft lange vor dem ersten Pull und damit vor „Sitzung starten". Im Kampfprotokoll steht davon nichts, und ein vollständig gebuffter Raid stand mit lauter Nullen da – **23 von 25 Teilnehmern ohne Fläschchen**. Beim Anwesenheitsabgleich wird jetzt **einmal je Teilnehmer** abgelesen, was er schon trägt (`ScanCarriedConsumables`), und zwar erst, wenn er wirklich sichtbar ist: In einer anderen Zone liefert die Abfrage nichts, und ein leeres Ergebnis darf nicht als „hat nichts dabei" durchgehen. Abgelesen werden nur die Kategorien mit `scan` – Fläschchen, Elixiere, Essen. Ein laufender Trommelbuff ist ausdrücklich **kein** mitgebrachter Verbrauch; genau diese Verwechslung war Ursache 1. Das Merkfeld liegt am Teilnehmer und überlebt damit `/reload`, sonst zählte jeder Neustart die Buffs erneut.

**Sitzungsliste.** Die Beschriftung „02.08. 19:37 Höhle des Schlangenschreins +Logs" passte nicht in die 206 Pixel breite Zeile, brach um und legte sich über den nächsten Eintrag. Ursache war die Vorgabe in `CreateButton`: Die Beschriftung bekam keine feste Höhe und durfte deshalb umbrechen. Ein Knopf ist aber ein Kasten fester Höhe – eine zweite Zeile wächst immer darüber hinaus. Beschriftungen in Knöpfen brechen jetzt grundsätzlich nicht mehr um; zu lang heißt abgeschnitten statt ineinandergeschoben. Dazu zwei Kürzungen, damit es gar nicht erst so weit kommt: lange Instanznamen stehen in ihrer geläufigen Kurzform („Serpentinhöhle"), und jede Quellenart wird nur einmal genannt – „+Sync+Logs+Sync" nannte dieselbe Herkunft zweimal, weil zwei Gildenmitglieder denselben Abend geliefert hatten.

**Was bewusst offen bleibt:** Der **Meisterliche Gesundheitsstein** (27235/27236/27237) taucht im Log bei fast jedem auf, ist aber nicht aufgenommen. Er wird vom Hexenmeister gestellt und kostet den Empfänger nichts; ihn mitzuzählen würde die Frage „bringt jemand seine Verbrauchsgegenstände mit" verwässern. Die Kategorie „Öle/Steine" meint Waffenöle und Schleifsteine.

## 0.9.86 – „Bin ich vollständig?" – ein Balken statt einer Paketzahl, und die Schleife, die niemand gesucht hat

**Der Auftrag war die Statuszeile.** Unten in der Gildenwerkstatt stand „Abgleich: 110 Berufspakete empfangen". Die Zahl ist richtig und trotzdem nutzlos: Sie sagt, wie viel angekommen ist, nicht wie viel fehlt. Wer unten in der Werkstatt hinsieht, will genau eine Auskunft – **bin ich vollständig, und wenn nein, wie weit noch**. Gewünscht war ein Ladebalken; herausgekommen ist zuerst die Frage, was er eigentlich messen soll.

**Ein ehrlicher Balken braucht einen Nenner.** „Empfangene Pakete" hat keinen. Gezählt wird deshalb die **offene Arbeit**, und zwar aus drei Quellen, die vorher nirgends zusammenkamen:

- **ausgehend** – jedes Paket, das über `SendBulk` eingereiht wurde und dessen Zustellung noch nicht bestätigt ist. Der Zähler sitzt jetzt in `Sync.lua` und deckt beide Sendewege ab, die eigene Warteschlange **und** ChatThrottleLib; vorher zählte nur die Werkstatt ihre eigenen Pakete, Gildenbank, Aufträge und Ausrüstung liefen unsichtbar nebenher. Dazu kommen die selbst getakteten Übertragungen (Gildenprofil, Raidauswertung), die gar nicht über die Warteschlange gehen;
- **eingehend** – die noch fehlenden Teile jeder angefangenen Übertragung, über alle sechs Module hinweg. Eine Übertragung, zu der seit 30 Sekunden nichts mehr kam, gilt als verloren statt als „läuft noch": Sonst behauptet der Balken minutenlang Betrieb, obwohl der Absender längst offline ist;
- **bekannte Lücken** – und das ist der Teil, der aus „gerade ist nichts unterwegs" erst „vollständig" macht. Ein fremdes Manifest sagt, welche Berufe es in der Gilde gibt. Was davon hier fehlt, wird beim Empfang des Manifests vorgemerkt und beim Eintreffen wieder gestrichen. Ohne diese Liste hätte ein Client, dem drei Berufe nie geliefert wurden, sich für vollständig gehalten, sobald die Leitung ruhig ist.

**Ein Zyklus, eine Hochwassermarke.** Er beginnt, sobald das Erste unterwegs ist, und endet, wenn nichts mehr aussteht. Der Nenner wächst mit, wenn währenddessen Neues dazukommt, fällt aber nie zurück – ein Balken, der rückwärts läuft, ist schlimmer als keiner. **100 Prozent gibt es ausschließlich bei null offener Arbeit**; solange etwas läuft, ist bei 99 Schluss. Endet ein Zyklus mit verlorenen Paketen, heißt er *unvollständig* und bekommt **keinen** Zeitstempel „zuletzt vollständig" – sonst stünde „Stand: gerade eben" über lückenhaften Daten. Und wenn ein Zyklus zwei Minuten lang nicht vorankommt, wird er abgeräumt und als unvollständig gemeldet: Ein einziger ausgebliebener Rückruf hätte den Balken sonst für den Rest der Sitzung bei achtzig Prozent festgehalten.

**Der Takt kostet nichts, wenn nichts läuft.** Dieselbe Bauweise wie die Bulk-Warteschlange und der Raid-Herzschlag: ein Rahmen, der nur sichtbar ist, solange es etwas zu tun gibt – ein verstecktes Frame bekommt kein `OnUpdate`. Der Balken selbst hängt an der Werkstattseite und lebt nur, solange man ihn sieht; er zeichnet sich außerdem nur neu, wenn sich am Zustand wirklich etwas geändert hat, nicht viermal je Sekunde. Der Zyklus läuft trotzdem im Hintergrund weiter – sonst wäre „zuletzt vollständig abgeglichen" eine Zahl, die davon abhängt, ob das Fenster gerade offen war.

**Nebenbei ein Wort zurechtgerückt.** Im Fensterkopf stand „alle synchron". Gemeint war „alle haben dieselbe Addon-Version"; gelesen wurde „die Daten sind vollständig". Beides steht jetzt getrennt da, und das Wort *synchron* gehört dem Balken.

---

**Und dann die Suche, die eigentlich eine Durchsicht war.** Der Auftrag lautete, das Addon von A bis Z auf Performance und Stabilität durchzugehen. In `Profile.lua` stand seit 0.9.45 dieser Ablauf: Um die Berufe aus den Classic-Fähigkeitszeilen lesen zu können, klappt das Addon eingeklappte Kategorien kurz auf und danach wieder zu – das Fähigkeitenfenster soll aussehen wie vorher.

**Auf- und Zuklappen löst `SKILL_LINES_CHANGED` aus.** Also genau das Ereignis, an dem die Erfassung hängt. Jeder Durchlauf erzeugte damit den nächsten, und der wieder den übernächsten: eine sich selbst tragende Schleife, bei jedem Spieler, der mindestens eine Kategorie zugeklappt hat – und das sind die meisten. Sichtbar wurde sie nicht, weil sie nichts anzeigt; sie kostet nur Bildrate. **Das ist der bislang plausibelste Kandidat für die seit 0.9.48 offenen Meldungen aus der Gilde.** Belegt ist er damit nicht – dafür braucht es eine Messung bei einem Betroffenen –, aber die Schleife ist unabhängig davon falsch.

Drei Sperren, jede für sich ausreichend, zusammen dicht:

- **erst nachsehen, ohne etwas anzufassen.** Bei den allermeisten Charakteren stehen die Berufe offen sichtbar in der Liste; dann wird nichts geklappt, kein Ereignis erzeugt, und der teure Teil entfällt ganz;
- **das eigene Klappen wird vermerkt** und ein `SKILL_LINES_CHANGED` innerhalb der nächsten fünf Sekunden übergangen. Die Sperre läuft in Echtzeit und nicht über einen Zähler, weil die Ereignisse erst im nächsten Bild eintreffen;
- **entprellt.** `SKILL_LINES_CHANGED` feuert in TBC für jeden Fertigkeitspunkt, auch für Waffenfertigkeit – also mitten im Kampf im Sekundentakt, und jeder Durchlauf las Talente, Berufe und die komplette Fähigkeitsliste neu. Zehn Punkte in drei Sekunden ergeben jetzt einen Durchlauf. Der Handler ist dafür eine Methode geworden statt eines anonymen Zweigs: Was sich nicht aufrufen lässt, lässt sich auch nicht prüfen.

**Aus der Gilde gemeldet, während diese Version entstand: „Den Kalender bei den Abmeldungen kann man NICHT öffnen – es geht nur rechts unten in der Ecke."** Das Symbol war da, der Klick lief ins Leere, und ein schmaler Rand funktionierte doch. Diese Beschreibung ist bereits die halbe Diagnose.

Der Knopf war ein Kind der Karte und wurde nur *über* das Eingabefeld gelegt. Knopf und Feld waren damit Geschwister auf derselben Rahmenebene – wer bei Gleichstand den Klick bekommt, legt WoW nicht fest, und in der Praxis nahm ihn die EditBox. Anklickbar blieb genau das, was die EditBox nicht bedeckt: ihr Innenabstand von zehn Pixeln rechts und sechs oben und unten. Rechnet man das nach, ergibt sich ein sechs Pixel breiter Streifen am rechten Rand und je zwei Pixel oben und unten – **eine L-Form, deren Ecke unten rechts liegt.** Genau die, die gemeldet wurde.

Der Knopf zieht deshalb ins Feld um: als Kind der Umrandung, mit eigener Rahmenebene darüber, und die EditBox endet vor ihm, damit getippter Text nicht darunter hindurchläuft. Weil das kein Einzelfall ist, steckt es in `AttachEditButton` – **das `×` der Rezeptsuche hatte denselben Fehler** und ist mit derselben Zeile behoben. `validate.mjs` lässt ab jetzt nur noch eine einzige Stelle zu, die einen Knopf an den rechten Rand eines Eingabefelds setzt; jede weitere von Hand gesetzte fällt durch. Der Testrahmen merkt sich dafür neu Elternrahmen und Rahmenebene – gegengeprüft, indem die Reparatur einmal zurückgenommen wurde: Der Test schlägt dann fehl.

Das ist übrigens die dritte Variante derselben Familie innerhalb von zwei Versionen. 0.9.85 hatte das Häkchen der Ankreuzkästchen, das hinter dem Kasten lag; hier fängt eine Fläche den Klick statt ihn zu verdecken. Die Lehre ist dieselbe: **Wer etwas übereinanderlegt, muss die Ebene ausdrücklich sagen** – der Standardwert ist in beiden Fällen der falsche.

---

**Ebenfalls aus der Gilde, ebenfalls während dieser Version: „Was passiert, wenn mehrere Offis gleichzeitig auf Sitzung starten drücken?"** Die Antwort war unangenehmer als die Frage.

Beide Clients sahen `self.session == nil`, beide legten eine Sitzung an, beide riefen ihren Start in den Raid. Und der Empfänger übernahm eine fremde Sitzung nur, wenn er selbst noch keine hatte – hatte er eine, verwarf er die Meldung stillschweigend. Ergebnis: **zwei Sitzungen mit zwei Kennungen, und der Raid verteilte sich auf beide**, je nachdem, wessen Startruf zuerst ankam. Am Ende des Abends schloss „Sitzung beenden" immer nur eine davon – die andere lief weiter, bis ihr Starter sie von Hand beendete oder sich ausloggte. In der Raidauswertung standen zwei Abende mit je einem Teil der Teilnehmer.

**Gelöst wird das ohne Rückfrage.** Ein Dialog „Sitzung läuft schon, trotzdem starten?" verlagert die Entscheidung an den Falschen: Er weiß in dem Moment nicht mehr als der Client. Stattdessen eine **totale Ordnung, die jeder Client für sich ausrechnet und die überall dasselbe ergibt**: Die früher gestartete Sitzung gewinnt; bei gleicher Sekunde die lexikografisch kleinere Kennung. Die Startzeit kommt aus `GetServerTime()` und ist damit für alle auf dem Realm dieselbe – die lokale Systemuhr hätte genau hier versagt. Der Gleichstand ist häufig (zwei Klicks in derselben Sekunde), deshalb ist die Kennung als zweites Kriterium kein Beiwerk: Sie trägt einen Zufallsanteil und entscheidet eindeutig.

Wer verliert, wird nicht ausgewertet, sondern **verworfen** – ausdrücklich nicht über `FinishSession`. Es gibt dort nichts abzulegen: Die Sitzung ist Sekunden alt und war von Anfang an derselbe Abend. Abgelegt würde sonst ein leerer Raidabend, der in der Liste steht und niemandem gehört.

**Eine Grenze hat die Regel.** Wird die Spaltung erst nach einer Stunde entdeckt – zwei Gruppen, die getrennt gestartet und sich später zusammengeschlossen haben –, hängt an der unterlegenen Sitzung ein halber Abend. Der wiegt schwerer als eine aufgeräumte Kennung. Nach zwei Minuten wird deshalb nicht mehr verworfen: Dann bleiben beide bestehen, und es gibt einmalig eine Warnung im Chat. **Stillschweigend Mitgeschriebenes zu löschen wäre der schlimmere Fehler.**

Dieselbe Prüfung hängt am Herzschlag, nicht nur am Startruf – so heilt sich auch eine Spaltung, die dem Start entgangen ist, weil jemand gerade im Ladebildschirm war. Und ein Nebenfund: Der alte Code stempelte bei **jedem** fremden Startruf den eigenen Herzschlag, auch bei einer wildfremden Sitzung. Das brachte die eigene Sitzung für einen Takt zum Schweigen, obwohl niemand für sie geredet hatte.

**Sichtbar wird das an drei Stellen**, denn eine Regel, die man nicht bemerkt, ist von einem Fehler nicht zu unterscheiden: Die Absage nennt jetzt den Starter („Die Raidsitzung läuft bereits – gestartet von Nexarius."), das Fenster „Raidinstanz betreten" verschwindet nicht mehr wortlos, sondern sagt beim Schließen, wer schneller war, und der unterlegene Offizier liest, dass seine Sitzung zusammengeführt wurde – nicht, dass sein Klick wirkungslos war.

---

**Zwei weitere Funde derselben Art.**

- `ROSTER_UPDATED` kommt aus zwei sehr verschiedenen Quellen: aus dem entprellten Gildenscan (selten) und aus **jedem eingehenden Profilpaket** (zur Prime Time mehrfach pro Sekunde). Der Handler rief `Refresh()`, und das zeichnet die offene Seite **sofort und synchron** neu. Der Sammel-Timer aus 0.9.49 war genau dagegen gebaut – dieser eine Pfad lief an ihm vorbei. Er tut es nicht mehr; der Fensterkopf wird im selben Takt mitgeführt statt eigens;
- die Merkliste unterdrückter Rezeptanfragen wuchs unbegrenzt – ein Eintrag je je angefragtem Rezept, über einen Raidabend hinweg mehrere tausend. Sie wird jetzt aufgeräumt, sobald sie zu groß wird.

**Zwei Befunde zur Datensynchronität.**

- **Ein älteres Profil konnte ein neueres überschreiben.** Pakete desselben Absenders können sich überholen – eine Antwort auf eine Versionsanfrage und eine gerade gespeicherte Änderung laufen parallel –, und beim Empfang gewann schlicht das zuletzt eingetroffene. Jetzt gewinnt der neuere Zeitstempel, dieselbe Regel, die das Gildenprofil und der Warcraft-Logs-Import schon anwenden;
- **der Zeitstempel des eigenen Profils sprang bei jedem Spielereignis nach vorn**, auch ohne jede Änderung. Gildenweit stand damit „gerade aktualisiert" an Profilen, an denen seit Wochen nichts passiert war – und ein Vergleich zweier Stände war wertlos. Er wandert jetzt nur bei einer echten Änderung mit. Erst dadurch ist der Punkt darüber überhaupt wirksam.

---

**Aufbau.** Die Seitenleiste soll einen Ablauf erzählen. Zwei Punkte taten das nicht: Der Abschnitt hieß „ROSTER" und trug damit denselben Namen wie der Seitenschlüssel der **Profil**-Seite – zwei verschiedene Dinge, ein Wort. Und „Warcraft Logs" stand darin, obwohl es weder Roster noch Gilde betrifft, sondern die **Datenquelle des Raidteils** ist: Der Import erzeugt Raidsitzungen und Profile, die Raidauswertung liest sie. Der Abschnitt heißt jetzt **Gilde** (Mitgliederpflege, Gildenwerkstatt), und **Raid** liest sich von oben nach unten als Kette: Warcraft Logs liefert, die Raidauswertung wertet aus, die Ausrüstungsprüfung zieht die Konsequenz. Der Rekrutierungstrichter bleibt, wie er war – Eckdaten, Bedarf, Auswahl, Werbung, Antworten –, denn er ist einer, und „Gildenprofil speichern" springt selbst auf „Vorschläge".

**Gildenübersicht: 35 statt 25 Plätze.** 25 war exakt die Größe eines Schlachtzugs und damit zu knapp – Ersatzleute, Twinks und gerade offline gegangene Stammspieler fielen hinten heraus, und die Liste sah kleiner aus als die Gilde ist. Die Zahl steht jetzt an **einer** Stelle in `Constants.lua`; verstreute 25er in Zeilenzahl, Scrollbereich und Seitentitel waren der Grund, warum die drei überhaupt auseinanderlaufen konnten. `validate.mjs` lehnt eine wieder fest verdrahtete Zeilenzahl ab.

## 0.9.85 – Die Oberfläche zeichnet ihre Symbole selbst

**„Die Symbole passen nicht."** In den Abmeldefeldern Von und Bis stand ein leerer Kasten, wo 0.9.84 ein Kalendersymbol versprochen hatte. Kein Installationsfehler – der Kasten steckte im ausgelieferten Code.

**Die Ursache ist alt und dreimal dokumentiert.** Die Spielschrift kennt nur den WinANSI-Vorrat: ASCII, Latin-1 und die Satzzeichen aus Windows-1252. Alles darüber hinaus zeichnet der Client als leeres Rechteck. An drei Stellen in `UI.lua` steht deshalb seit Längerem der Hinweis „kein Pfeilzeichen, nimm ein Wort“, und `validate.mjs` verbot seit 0.9.45 ausdrücklich „☆“ und „★“. Nur war das eine Liste bekannter Ausrutscher, keine Regel – und `📅` stand nicht darauf. Für einen Fließtext taugt „nimm ein Wort“ ohnehin, für einen Knopf von 26 Pixeln nicht.

**Der zweite Weg war Blizzards Bildmaterial**, und der hat neben „Bestätigen“ ein goldenes, gemaltes Häkchen hinterlassen: `Interface\Buttons\UI-CheckBox-Check`. Es fehlt nie, aber es bringt seine eigene Farbe und seinen eigenen Stil mit und steht in dieser flachen, cyanfarbenen Oberfläche als Fremdkörper.

**Beides fällt jetzt weg.** Die paar Zeichen, die diese Oberfläche braucht, malt sie selbst – aus derselben weißen Fläche, aus der schon Rahmen, Karten und Knöpfe bestehen:

- `CreateMark` ist ein kleiner eigener Rahmen. Beschrieben wird jede Form im Feld `0..1` der Kantenlänge, damit sie in jeder Größe dieselbe bleibt. Schräges entsteht als **Treppe aus Quadraten** – eine gedrehte Fläche gibt die Oberfläche nicht her, und der Abstand ist die halbe Strichstärke: weiter auseinander zerfällt die Linie sichtbar in Punkte;
- **Rahmen und nicht Textur**, und das ist zugleich der zweite Fehler dieser Version. Ein Kindrahmen liegt in WoW immer über den Flächen seines Elternteils, gleich welche Zeichenebene die Textur angibt. Das Häkchen der Ankreuzkästchen lag als Textur auf dem Schalter, der farbige Kasten darüber ist ein Kindrahmen – **das Häkchen war damit in der gesamten Oberfläche unsichtbar**, in jedem Kanalkästchen, jedem Rangschalter, bei „Main“ und „Twink“. Angekreuzt erkannte man nur noch an der Füllung. Es sitzt jetzt im Kasten und wird dunkel gezeichnet – die Füllung eines angekreuzten Kastens ist hell, ein helles Häkchen darauf wäre wieder eins, das man suchen muss;
- gezeichnet werden drei Formen: **Haken** (zwei Striche), **Kalenderblatt** (zwei Ösen, Kopfleiste, Rahmen, drei mal zwei Tagesfelder – weniger ist nicht wiederzuerkennen, mehr läuft bei 17 Pixeln ineinander) und **Dreieck** (waagerechte Streifen; die Spitze bleibt ein kurzer Stummel, sonst verschwindet sie ganz);
- damit verschwinden auch die verbliebenen Schriftzeichen: der Monatswechsel im Kalenderblatt trug „‹ ›“, die Postfach-Blätterknöpfe „◀ ▶“ – geometrische Formen, also derselbe leere Kasten;
- das goldene Häkchen neben „Bestätigen“ und in der Checkliste „Erste Schritte“ ist jetzt ein **grüner Haken** in `THEME.success`, der Farbe, in der das Addon überall „erledigt“ meldet;
- ein Knopf mit Symbol blendet beim Sperren mit ab. Vorher hing das allein an der Beschriftung – ein gesperrter Seitenwechsel hätte bedienbar ausgesehen.

**Die Prüfung deckt jetzt den ganzen Zeichenvorrat ab.** `validate.mjs` liest jede Lua-Zeile und lehnt jedes Zeichen außerhalb von WinANSI ab, statt eine Liste bekannter Fälle zu führen. Reine Kommentarzeilen sind ausgenommen: Dort steht ein solches Zeichen genau deshalb, weil erklärt wird, warum es nicht in die Oberfläche gehört. Gegengeprüft mit einem eingeschmuggelten `📅`, das die Prüfung mit Datei, Zeile und Codepunkt meldet.

## 0.9.84 – Abmeldung: Eingaben bleiben stehen, Datum per Kalender

Aus der Gilde kamen zwei Rückmeldungen zum selben Feld, und die zweite erklärt die erste.

**„Sobald er im zweiten Fenster ein Datum eingibt, löschen sich die Daten im ersten."** Das Auffrischen der Profilseite füllte jedes Abmeldefeld, das gerade **keinen Fokus** hatte, mit dem gespeicherten Stand nach. Solange man in einem Feld tippt, ist genau dieses eine geschützt – alle anderen nicht. Wer also das Von-Datum einträgt und ins Bis-Feld klickt, verliert das Von-Datum beim nächsten Auffrischen, denn gespeichert war dort noch nichts.

Warum es beim Owner lief und beim Gildenmitglied nicht: Das Auffrischen hängt an eintreffenden Daten – Rosteraktualisierung, Profilantworten, Werkstattverkehr. Wer gerade wenig hereinbekommt, tippt in Ruhe zu Ende; wer in einer aktiven Gilde sitzt, bekommt mitten in der Eingabe ein Auffrischen. Derselbe Code, zwei völlig verschiedene Erfahrungen.

Die drei Felder sind **ein Formular**, kein Trio von Einzelfeldern. Sobald der Nutzer tippt, gehört es ihm; nachgefüllt wird erst wieder nach Speichern oder Löschen. Unterschieden wird über das `userInput`-Flag von `OnTextChanged` – dasselbe Mittel, mit dem die Postfach-Entwürfe seit 0.9.82 arbeiten, denn unser eigenes `SetText` darf das Formular gerade **nicht** sperren, sonst stünde es nach dem ersten Auffrischen für immer. Der Regressionstest bildet genau den gemeldeten Ablauf ab und schlägt gegen den Stand von 0.9.83 fehl.

**„Viele haben Probleme mit englischem Datumsformat, und tippen ist immer naja."** Beides ist jetzt beantwortet:

- ein **Kalenderblatt** an den Feldern Von und Bis: deutsche Monatsnamen, Mo–So, Monatswechsel über ‹ ›, ein Knopf für heute. Der heutige Tag ist umrandet, der gewählte gefüllt – über den Rahmen und nicht über die Textfarbe, weil ein Knopf beim Verlassen mit der Maus Hintergrund und Beschriftung selbst zurücksetzt, den Rahmen aber nicht anfasst;
- bewusst **kein** Blizzard-Kalender: Der ist ein vollständiges Fenster mit Gildenereignissen, lädt auf Anforderung nach und lässt sich nicht als Auswahlfeld einspannen;
- der **Wochentag wird gerechnet, nicht erfragt.** `date()`/`time()` hängen an Zeitzone und Sommerzeit, und ein Kalenderblatt, das je nach Uhrzeit um einen Tag verrutscht, wäre schlimmer als keins. Gerechnet wird über die fortlaufende Tagesnummer, die es für den Abmeldevergleich ohnehin gibt, mit dem 1. Januar 2000 als Anker – einem Samstag. Gegengeprüft gegen alle 36.525 Tage von 2000 bis 2099;
- getippt wird zusätzlich **`15.08.2026`** angenommen, ebenso einstellige Tage und zweistellige Jahre. Gespeichert und synchronisiert wird weiterhin ausschließlich ISO: Nur damit bleibt „liegt zwischen von und bis" ein simpler Stringvergleich. Ein unmögliches Datum wie `30.02.2026` wird nicht stillschweigend verbogen, sondern abgelehnt.

## 0.9.83 – Die Raidsitzung überlebt den Verbindungsabbruch

Bisher lag der laufende Abend ausschließlich im Arbeitsspeicher genau des Clients, der ihn führt. Ein Disconnect beim Offizier – und die halbe Auswertung war weg, ohne Vorwarnung und ohne Rest.

**Die Sitzung liegt jetzt in den SavedVariables.** Und zwar als *dieselbe Tabelle*, nicht als Kopie: Während des Raids kostet das Sichern damit exakt nichts, weil nichts umgerechnet und nichts umkopiert wird. Geschrieben wird die Datei ohnehin erst beim Ausloggen. Zwei Dinge zieht `SaveSessionForResume()` in diesem letzten Moment gerade:

- ein offener Kampfabschnitt wird geschlossen, damit ein laufender Pull nicht als Fragment stehen bleibt;
- alle Anwesenheitsuhren werden angehalten und gutgeschrieben. Ohne das zählte die fortgesetzte Sitzung die Auszeit als Anwesenheit mit – bei einer Nacht Pause wären das zweistellige Stunden je Teilnehmer;
- die Namenszuordnung des Kampflogs fliegt raus. Sie ist ein reiner Zwischenspeicher, kann tausende Rohschreibweisen enthalten und gehört nicht in eine gespeicherte Datei.

**Beim nächsten Login läuft derselbe Abend weiter** – gleiche Kennung, gleiche Zahlen, gleiche Teilnehmer. Ist die Unterbrechung länger als acht Stunden, wird die Sitzung *nicht* fortgesetzt, aber auch nicht weggeworfen: Sie wird mit ihrem letzten bekannten Stand ausgewertet und abgelegt. Eine unvollständige Auswertung ist mehr wert als gar keine.

**Ein Herzschlag hält die Sitzung im Raid zusammen.** Alle Addon-Nutzer im Raid schreiben denselben Abend ohnehin parallel mit; wer aber später dazustößt oder nach einem Abbruch zurückkommt, hat den Startruf verpasst und schriebe den Rest gar nicht mit. Der Herzschlag ist für diese Clients ein nachgereichter Startruf. Er ist bewusst sparsam gebaut:

- gesendet wird höchstens alle 60 Sekunden, nur innerhalb der eigenen Gruppe und nur, solange eine Sitzung läuft;
- gesendet wird von genau **einem**: Wer einen fremden Herzschlag zur eigenen Sitzung hört, schweigt bis zum nächsten Takt. Wer zuerst spricht, spricht für alle – fällt der aus, übernimmt beim nächsten Takt der Nächste, ganz ohne Absprache. Der Raidleiter wartet dabei am kürzesten, dann die Assistenten, dann der Rest, jeder mit einem zufälligen Aufschlag gegen Gleichstand;
- getrieben wird der Takt von einem Rahmen, der nur während einer Sitzung sichtbar ist – dieselbe Bauweise wie die Bulk-Warteschlange in `Sync.lua`. Außerhalb einer Sitzung kostet der Herzschlag keinen einzigen Handleraufruf pro Bild. Ein wiederholender Timer kam dafür ausdrücklich nicht in Frage; `tests/validate.mjs` verbietet `C_Timer.NewTicker` im ganzen Addon;
- eine fremde Sitzung verdrängt die eigene nie. Nur der Herzschlag zur *eigenen* Kennung gilt als „es redet schon jemand".

**Sitzungen steuern jetzt ausschließlich Offiziere.** Bis 0.9.82 genügte zusätzlich der Raidrang – jeder Assistent konnte eine Sitzung starten und beenden. Das war zu weit gefasst: Assistent ist im Pull-Chaos schnell vergeben, und ein versehentliches „Sitzung beenden" schneidet den Abend mittendrin ab. Es entscheidet jetzt allein der Gildenrang, nämlich derselbe einstellbare Kreis, der auch die Mitgliederpflege öffnet (Vorgabe: Rang 0 und 1). Dieselbe Prüfung entscheidet über **eingehende** Sitzungspakete, und dort ist der Gildenrang ohnehin die belastbarere Angabe – der Raidrang eines fremden Absenders steht gar nicht fest.

Abgedeckt durch vier neue Testblöcke in `tests/smoke.lua`: Sichern und Fortsetzen mit unveränderten Zahlen und ohne mitgezählte Auszeit, der liegengebliebene Neun-Stunden-Abend, der Herzschlag samt Unterdrückung durch einen fremden, der Einstieg eines Nachzüglers – und die Ablehnung eines Herzschlags ohne Steuerungsrecht.

## 0.9.82 – Nachprüfung der Fremdanalyse: fünf Restbefunde, drei davon aus 0.9.81

Eine zweite Analyserunde gegen 0.9.81 hat fünf Punkte gemeldet. Alle bestätigt, alle umgesetzt. Drei davon waren **in 0.9.81 neu entstanden** – die Korrektur des Falschempfänger-Falls war unvollständig, und die richtige Abdeckungsrechnung war teuer erkauft.

**Der Falschempfänger war nicht behoben, nur die halbe Ursache.** 0.9.81 hat den Entwurf an den Interessenten gebunden, die *Auswahl* aber weiter als Listenplatz gehalten. Ein eingehender Flüsterer legt einen neuen Eintrag **vorne** an, alles darunter rückt eine Position weiter: Wer gerade an Nummer drei schrieb, hatte danach jemand anderen ausgewählt, der Entwurf blieb stehen, und der Antwortknopf meinte den verschobenen Platz. Genau der Fall, den 0.9.81 verhindern sollte – nur asynchron statt per Klick:

- gemerkt wird jetzt der **Name** des gewählten Interessenten, nicht seine Zeile. `GC.UI:GetSelectedLead()` löst ihn bei jedem Zugriff auf und rückt erst nach, wenn er wirklich verschwunden ist;
- der Listenplatz entsteht nur noch zum Markieren der aktiven Zeile und wird nirgends gespeichert;
- `tests/smoke.lua` bildet den Fall ausdrücklich ab: Entwurf schreiben, neuen Interessenten eintreffen lassen, prüfen, dass Auswahl **und** Entwurf beim Gemeinten bleiben. Gegen den Stand von 0.9.81 schlägt der Test fehl;
- `tests/validate.mjs` lehnt ein `GC.UI.selectedLead` ohne `Key` wieder ab.

**Das Ausblenden löschte den Entwurf eines anderen.** Nach dem Entfernen wurde die Auswahl umgesetzt und **danach** das Textfeld geleert – die Leerung feuerte `OnTextChanged` und wurde dem inzwischen gewählten nächsten Interessenten zugeschrieben. Dessen gemerkter Text war weg, bevor `LoadLeadDraft()` ihn holen konnte. Das überflüssige `SetText("")` ist raus; auch dieser Fall steht als Test.

**Die korrigierte Abdeckung war ein neuer Hotpath.** `CountsAsActiveRaider` und `CountsForCoverage` holten sich je Mitglied den Gildendatensatz, und `GC.DB:GetGuild()` fährt bei **jedem** Aufruf rekursiv den kompletten Vorgabenbaum ab. Bei 200 Mitgliedern waren das mehrere hundert zusätzliche Durchläufe pro Ansicht:

- `Roster:GetRaiderRules()` sammelt Rangfilter und Inaktivitätsgrenze einmal je Durchlauf ein und wird durchgereicht;
- `Roster:GetProfile()` nimmt den Gildendatensatz optional entgegen – das spart in `GetSummary` einen weiteren Aufruf je Mitglied;
- die Vorschlagsseite berechnete die Zusammenfassung **zweimal** (einmal selbst, einmal über `GetSuggestions`). Sie nimmt jetzt die mitgelieferte. Unterm Strich läuft der Roster einmal statt zweimal, und der Vorgabenbaum ein- statt mehrhundertfach.

**Antwortvorlagen meldeten „synchronisiert“ ohne Größenprüfung.** Der Gildenprofil-Speicher prüfte seit 0.9.81, der separate Vorlagen-Speicher nicht – bei ohnehin großer Nutzlast stand dort Erfolg, während der verzögerte Sender danach ablehnte. Beide fragen jetzt dasselbe `GC.UI:GuildProfileTooLargeMessage()`.

**Der Werkstatt-Cache wurde bei reinen Statusmeldungen verworfen.** Das Sicherheitsnetz an `WORKSHOP_UPDATED` griff auch bei Synchronisierungszählern: Bei geöffneter Werkstatt entstand der Katalog während eines Transfers dutzendfach neu – genau der Aufwand, den der Cache vermeiden soll. Das Netz ist raus, verworfen wird an den Schreibstellen. Die eine, die dabei fehlte, ist ergänzt: `DB:Prune()` entfernt Hersteller ohne Werkstatt-Ereignis. `tests/validate.mjs` bewacht jetzt beide Richtungen – kein pauschales Verwerfen am Ereignis, aber ein Verwerfen im Aufräumen.

Nicht geändert: Der Katalog-Cache hält einen zusätzlichen Index im Speicher (bei mehreren tausend Rezepten einige MB). Das ist der bewusste Preis dafür, ihn nicht mehr je Tastendruck neu zu bauen.

## 0.9.81 – Fremdanalyse abgearbeitet: Sync-Grenze, Postfach, Abdeckung, Werkstattsuche

Eine externe Codeanalyse hat fünfzehn Punkte gemeldet. Geprüft wurden alle; zwei waren in 0.9.67 und 0.9.49 längst behoben, einer (leerer Verzauberungs-Regelsatz) hatte sich mit dem ausgelieferten T4/T5-Satz erledigt, einer (fehlende Signatur des Selbstupdates) ist für ein Ein-Personen-Repository kein sinnvoll behebbares Risiko. Der Rest ist hier umgesetzt.

**Das Gildenprofil kam ab einer gewissen Größe bei niemandem an.** Der Sender zerlegte die Nutzlast in beliebig viele 175-Byte-Blöcke, der Empfänger verwarf jede Übertragung mit mehr als 30 – über 5250 Bytes verschwand alles kommentarlos, während lokal „Gespeichert" stand. Allein die Spec-Verzauberungsregeln dürfen rund 4300 Bytes groß werden, die Grenze war also im Alltag erreichbar:

- Blockgröße und Höchstzahl stehen als `GUILD_PROFILE_CHUNK_BYTES` und `GUILD_PROFILE_MAX_CHUNKS` in `Constants.lua`; Sender und Empfänger lesen dieselbe Zahl. Die Grenze liegt jetzt bei 26 250 Bytes und damit über dem, was sich über die Oberfläche überhaupt eintragen lässt;
- passt es trotzdem nicht, wird **nichts** gesendet und es steht rot am Speichern-Knopf, wie viele Zeichen zu viel sind – statt lokal Erfolg zu melden;
- auch ein nach fünf Versuchen abgebrochener Versand meldet sich jetzt im Chat, statt still zu enden.

**Ein Antwortentwurf konnte an den falschen Interessenten gehen.** Beim Wechsel in der Liste blieb der Text stehen, der Senden-Knopf meinte aber schon den neu gewählten Spieler. Entwürfe gehören jetzt zum Interessenten: Sie werden nach Namen gemerkt, wechseln mit der Auswahl mit und verschwinden nach dem Senden. Zusätzlich war **ab dem zehnten Interessenten Schluss** – die Liste zeigte neun Knöpfe, ohne Hinweis und ohne Blättern; ältere Einträge waren weder sicht- noch einzeln löschbar. Jetzt gibt es eine Seitennavigation mit Gesamtzahl.

**Rekrutierungsvorschläge zählten jedes Gildenmitglied.** Ein Stufe-12-Twink oder ein seit einem Jahr abgemeldeter Spieler ließ eine gesuchte Spec als abgedeckt gelten. Die Raiderliste filterte längst richtig (Stufe 70, freigegebener Rang) – die Abdeckung fragte nur nie danach. Beide benutzen jetzt `Roster:CountsAsActiveRaider`; für die Abdeckung kommt über `CountsForCoverage` die eingestellte Inaktivitätsgrenze dazu. Wessen letzte Onlinezeit unbekannt ist, fällt ausdrücklich **nicht** heraus.

**„Flüstern nur während einer Suche" endete nie.** Der Zustand wurde beim ersten erfolgreichen Post gesetzt und bis zum nächsten Neuladen nie zurückgenommen; der mitgeschriebene Startzeitpunkt wurde nie gelesen. Eine Suche läuft jetzt nach einer Stunde ab.

**Raidsitzungen in einer normalen Party erreichten niemanden.** Start, Ende und Auswertung gingen fest über den Raidkanal, obwohl Sitzungen ausdrücklich auch in einer Gruppe laufen können und der Empfänger beide Kanäle längst annimmt. `Sync:GroupChannel()` wählt jetzt RAID oder PARTY nach der tatsächlichen Gruppe.

**Die vollständigere Auswertung des Raidleiters wurde bei Teilnehmern verworfen.** Jeder Teilnehmer speichert beim Sitzungsende seine eigene LIVE-Fassung; die danach eintreffende SYNC-Fassung trug dieselbe Kennung und wurde als „andere Quelle" abgelehnt. Quellen bleiben getrennt – aber eine Auswertung wird jetzt durch **Kennung und Quelle** identifiziert, beide stehen nebeneinander und der Quellenvergleich hat endlich zwei Seiten.

**Verbrauchsmaterial zählte je nach Quelle anders.** Live ergaben Kampf- und Wächterelixier zwei Einträge, derselbe Abend aus Warcraft Logs nur einen – der Kommentar dort behauptete Gleichstand. Beide zählen jetzt einmal je Zauber.

**Unvollständige Inspect-Daten galten als erledigt.** Sobald `INSPECT_READY` eintraf, wurde gespeichert und mitgezählt, auch wenn Item-Daten noch fehlten; den Wiederholungslauf gab es nur für die eigene Prüfung. Fremdspieler werden jetzt bis zu zweimal erneut gelesen, und was danach noch Lücken hat, steht getrennt als „nur unvollständig lesbar" in der Meldung. Nebenbei behoben: Die Zeitüberschreitung verglich die Einheit und hätte damit den eigenen Wiederholungslauf abgeräumt – jeder Anlauf hat jetzt eine eigene Nummer.

**Zeitstempel des Gildenprofils.** Sie haben Sekundengenauigkeit, und bei Gleichstand gewann schlicht die zuletzt eingetroffene Fassung – auf jedem Rechner also möglicherweise eine andere. Entschieden wird jetzt über die Nutzlast selbst; dieselbe Regel führt überall zum selben Ergebnis, ohne ein zusätzliches Feld im Protokoll. Außerdem liest `Util.Now()` die **Serverzeit**, wo der Client sie anbietet, und ein Stand mit mehr als einem Tag Vorsprung wird weder übernommen noch verteidigt – eine falsch gestellte Uhr konnte sonst jede spätere Änderung der ganzen Gilde dauerhaft blockieren.

**Werkstattsuche (Performance).** Der Katalog wurde bei **jedem Tastendruck zweimal** komplett neu aufgebaut – einmal über die Kennzahlen, einmal für die Suche – inklusive Kopie jeder Reagenzienliste. Bei mehreren tausend Rezepten ist das der teuerste Vorgang des Addons:

- der Katalog wird einmal aufgebaut und gehalten; verworfen wird er nur bei echten Datenänderungen (die vier schreibenden Funktionen und `WORKSHOP_UPDATED` als Sicherheitsnetz);
- Suchtext und Berufsschlüssel entstehen beim Aufbau, nicht je Zeichen und Eintrag;
- die Kennzahlen hängen am selben Zwischenstand;
- die Eingabe wird um 250 ms entprellt – „Verzauberung" löste vorher zwölf vollständige Suchläufe aus;
- Auftragsdialog und Auftragsanlage suchen ein Rezept über einen Schlüsselindex statt linear durch den ganzen Katalog.

**Kleinigkeiten.** Für synchronisierte Ausrüstung wurde `EvaluateEnchant` mit `nil` als Namen aufgerufen, obwohl der Kommentar eine lokale Auflösung behauptete – dadurch standen oft nur IDs da; der Name wird jetzt über Gegenstands- und Verzauberungs-ID aufgelöst. Der Installer prüft vor dem Kopieren, ob der Warcraft-Logs-Importcode in das Addon-Feld passt (60 000 Zeichen): Zwölf Reports eines 40er-Raids überschreiten das, WoW schnitt beim Einfügen ab und der Parser nahm den Rest als gültigen Teilimport an.

**Tests.** `tests/smoke.lua` läuft über fengari und deckt die neuen Zusicherungen ab; `tests/validate.mjs` prüft die neuen Bausteine statisch. Installer 1.0.6.

## 0.9.80 – Preisrahmen bleibt sichtbar, wenn man am Zug ist

Gildenwunsch aus dem Versandschritt: „Man möchte auch nochmal den Preisrahmen sehen, den der Auftraggeber angegeben hat." Bisher ersetzte die Handlungsaufforderung („An Nexarius versenden.") genau die Zeile, in der Kostenrahmen und Trinkgeld standen – wer versandbereit war, sah die Absprache nur noch über den Verlauf.

- **Die eigenen Aufträge tragen jetzt drei Zeilen:** Rezept, Aufgabe beziehungsweise Bedingungen und darunter neu **„Preisrahmen: bis 50g · Trinkgeld 5g"**. Sie steht in jedem Schritt, nicht nur beim Versenden;
- **gemeldete Materialkosten** erscheinen daneben („gemeldet 60g") und werden **rot**, sobald sie den Kostenrahmen überschreiten – dieselbe Aussage wie im Verlaufsdialog;
- hat der Auftraggeber nichts angegeben, steht das ausdrücklich da („keine Angabe des Auftraggebers") statt einer leeren Zeile;
- Bedingungen (Materialmodell, Übergabeweg, Notiz) und Preis stehen damit in den eigenen Aufträgen in getrennten Zeilen; doppelt genannt wird nichts. Das offene Board der Gilde bleibt unverändert einzeilig;
- **die Maße des Boards stehen als benannte Konstanten beisammen**, der Aufbau läuft mit einem mitlaufenden Abstand von oben nach unten. `tests/validate.mjs` rechnet nach, dass die drei Abschnitte einander nicht überlappen und über der Statuszeile bleiben – das Board hat keine Bildlaufleiste;
- **Kompakt-Tracker:** Der Schließen-Knopf steht in derselben Spalte wie die Zeilen darunter und sitzt auf der Höhe des Titels, statt vier Pixel weiter rechts und drei tiefer.

## 0.9.79 – Verbrauchsnamen wie im deutschen Client

Owner-Korrektur an der Gegenstandstabelle: Die „Super"-Tränke heißen im deutschen Client **„Erstklassig"** (Erstklassiger Heil-/Manatrank), die Major-Elixiere **„übermächtig"** (Elixier der übermächtigen Stärke/Beweglichkeit/Frostmacht/Feuermacht/Verteidigung/Schattenmacht, Elixier des übermächtigen Magierbluts, Elixier der übermächtigen Seelenstärke) – und es heißt **„Elixier der draenischen Weisheit"**, nicht „Draeneiweisheit". Die Öle heißen „Überragendes Zauberöl/Manaöl". Nur Anzeige-Kosmetik: Gezählt wird über Spell-IDs, an den Zahlen ändert sich nichts.

## 0.9.78 – Gegenstandsliste: unbekannte IDs verschwinden nicht mehr

Owner-Verwirrung am echten Export geklärt: Die „exakten Gegenstände" stehen im Export als Zauber-IDs (`28499:4` = 4× Übermächtiger Manatrank) – das Addon übersetzt sie beim Import in Namen. Alle IDs des konkreten Karazhan-Exports waren bereits in der Tabelle. Zusätzlich abgesichert:

- **IDs außerhalb der eigenen Tabelle werden nicht mehr verschluckt:** Sie erscheinen jetzt trotzdem in der Gegenstandsliste – benannt über den Spielclient (GetSpellInfo), notfalls als „Zauber 46837" mit Art „?". In die Spaltenzähler fließen sie weiterhin nicht ein (keine falschen Zahlen);
- Merkhilfe: Die Detailliste eines alten Abends erscheint in der **Logs-Quelle** nach einem erneuten Import; die Live-Quelle alter Abende bleibt bei Kategoriezählern.

## 0.9.77 – Verbrauchsprotokoll je Spieler; „Auswertung anfordern" wirkt sichtbar

**Klick auf einen Teilnehmer der Raidauswertung öffnet sein Verbrauchsprotokoll** (Owner-Frage: „was hat der Spieler alles eingeworfen? Maybe mit Timestamp?"):

- **Live-Sitzungen schreiben ab jetzt mit, WAS WANN eingeworfen wurde:** jeder gezählte Einwurf mit Uhrzeit und Gegenstandsnamen („21:26:33 · Hasttrank · Tränke"). Kappe bei 100 Einträgen je Spieler (gegen Trommel-Spam), Verworfenes wird ausgewiesen statt verschwiegen; in die Aufbewahrung wandern die letzten 40. Das Protokoll bleibt rein lokal und wird nie gesendet;
- **Warcraft-Logs-Quellen** zeigen die exakten Gegenstände mit Anzahl („3× Zerstörungstrank") – Uhrzeiten kennt der Export nicht;
- fremde Zusammenfassungen fallen auf die Kategoriezähler zurück. Der Zeilen-Tooltip weist auf den Klick hin.

**„Auswertung anfordern" hat jetzt sichtbaren Effekt** (Owner: „der hat gar keinen Effekt?!") – zwei echte Mängel:

- Antworter schickten nur ihre **allerneueste** Zusammenfassung – die hatte der Anfragende fast immer selbst, die Speicherung lehnte ab, nichts passierte. Jetzt antworten Mitglieder mit **bis zu fünf Abenden, Bossabende zuerst**, zeitlich gestaffelt;
- es gab **keinerlei Rückmeldung**. Jetzt zählt die Seite live mit: „Auswertung angefragt – warte auf Antworten …" → „3 Antworten empfangen, davon 1 neu oder vollständiger übernommen." Auch „0 neu" ist eine Antwort: Du weißt, dass du auf Stand bist.

## 0.9.76 – TIME-Spalte raus, „Allgemein" nach oben, grünes „ok"

- **TIME ist keine Spalte mehr** (Owner: unnötig): Die Anwesenheit steht weiterhin im Tooltip jeder Zeile („Dabei: 1h 33m von 1h 33m, 100 %") und im Detailfenster – dafür wachsen alle acht Wertespalten von 40 auf 46 Pixel. Alte gespeicherte Spaltenordnungen mit TIME bereinigen sich beim Lesen von selbst;
- **Einstellungen:** Die Karte „Allgemein" steht jetzt direkt unter den Chat-Befehlen, vor den Gildenaufträgen;
- **Ausrüstungsliste:** „ok" hinter geprüften Spielern ist grün, die Fundzahl rot – der Zustand der Gruppe ist damit auf einen Blick lesbar.

## 0.9.75 – Einstellungen neu sortiert: Alltag oben, Verwaltung unten

Die Einstellungsseite folgt jetzt der Owner-Ordnung, in logischen Blöcken:

1. **Chat-Befehle** (ganz oben – das Nachschlagewerk);
2. **Gildenaufträge** (Klänge, Banner, Übergabetext);
3.–5. **der Rekrutierungsblock:** „Postfach-Erkennung: eigene Wörter", „Bewerberton hören" und die Karte **„Rekrutierung: Meldungen & Töne"** – so heißt „Benachrichtigungen & Zugriff" jetzt, denn genau das steckte drin: Erfolgssound und die beiden Erkennungs-Schalter. Der Name sagt endlich, worum es geht;
6. **„Allgemein"** (neue Karte): Minimap-Symbol und Profilbestätigungston – die steckten vorher fälschlich in der Rekrutierungskarte;
7. **Ausrüstung – Hintergrundabgleich**;
8.–9. **der Verwaltungsblock ganz unten:** „Aktive Raider" und „Gildenweite Einstellungen bearbeiten" nebeneinander, darunter „Mitgliederpflege öffnen" – alle drei sind Rang-Häkchenkarten und stehen jetzt beieinander.

## 0.9.74 – Spalten-Feinschliff: gleichmäßig, fühlbar, Proviant-Standard

Drei Rückmeldungen aus der ersten Runde Spalten-Schieben:

- **Gleichmäßiges Raster:** Jede Spalte hatte ihr eigenes Maß (ELIXIR 48, INT 32) – nach dem Umsortieren wirkten die Abstände krumm. Jetzt sind alle Wertespalten einheitlich 40 breit (TIME 46 für „1h 33m"), mit fester 2-Pixel-Fuge; ELIXIR heißt wie im Detailfenster kurz ELIX;
- **Anfass-Feedback:** Unter der Maus leuchtet der Spaltenkopf auf – vorher gab es kein Zeichen, dass man ihn packen kann; beim Ziehen dimmt er wie gehabt;
- **Proviant-Standard:** Die vom Owner eingerichtete Reihenfolge ist jetzt die Standardordnung für alle: TIME, ELIX, FOOD, FLASK, DRUM, DEATH, POT, DISP, INT – Proviant direkt neben der Anwesenheit. Das Detailfenster zeigt dieselbe Reihenfolge;
- der abgeschnittene Einleitungstext der Seite ist gekürzt und erklärt jetzt Klick (sortieren) und Ziehen (umordnen).

## 0.9.73 – Spalten verschieben statt Zeilen ziehen

Owner-Urteil über das Zeilen-Ziehen: „Blödsinn" – raus damit, ersatzlos (samt Handordnung je Auswertung). Stattdessen das, was wirklich fehlte:

- **Spalten am Kopf packen und verschieben:** TIME, DEATH, INT, DISP, POT, FLASK, ELIXIR, FOOD, DRUM lassen sich per Ziehen des Spaltenkopfs in eine eigene Reihenfolge bringen. Kurzer Klick bleibt Sortieren (WoW feuert den Drag erst ab einer Schwelle), NAME bleibt fest vorn;
- **ordentlich per Raster:** Beim Loslassen rasten alle Spalten auf berechnete Positionen ein – nichts überlappt, keine krummen Abstände, die Zellen aller 40 Zeilen wandern mit;
- **die Ordnung bleibt gespeichert** (kontoweit, gilt für jede Auswertung); unbekannte Alt-Einträge repariert das Lesen stillschweigend, neue Spalten künftiger Versionen hängen hinten an;
- der Hinweis unten heißt jetzt „Spaltenköpfe ziehen ordnet die Spalten".

## 0.9.72 – Raidauswertung: klare Quellen, roter Proviant, löschbare Sitzungen

Feinschliff nach dem ersten Abend mit Live+Logs nebeneinander:

- **Quellenknöpfe eindeutig:** Die gerade angezeigte Quelle ist als aktiv markiert statt ausgegraut („ausgegraut" las sich wie „nicht verfügbar"). Kurze Namen („Logs (11)" statt „Warcraft Logs (11)"), rechtsbündig – und der Hinweis „Zeilen ziehen ordnet von Hand" wandert nach unten, statt sich mit den Knöpfen zu quetschen;
- **„Vergleich" direkt auf der Seite:** Ein Knopf neben den Quellen öffnet das Detailfenster sofort im Vergleichsmodus Live gegen Logs (gelb, wo die Quellen sich widersprechen);
- **Sitzungsliste einzeilig:** „31.07. 21:26 Karazhan +Logs" statt eines zweizeilig umbrechenden „[Live+Logs]";
- **Roter Proviant** (Owner-Wunsch): In der Teilnehmertabelle färben sich FLASK und ELIXIR rot, wenn **beides** null ist (ein Fläschchen ersetzt beide Elixiere – wer eines von beiden hat, ist versorgt); FOOD färbt sich rot, sobald es null ist. Gilt auf der Seite und im Detailfenster;
- **Sitzungen löschen:** Der Knopf unter der Sitzungsliste löscht den gewählten Abend mit allen Quellen – mit Scharfschalt-Klick („Wirklich löschen?") und entschärft sich beim Wechsel der Auswahl. Löschen dürfen nur die Ränge mit Mitgliederpflege-Zugriff (Standard: Offiziere oder höher) – **einstellbar in den Einstellungen**, die Karte heißt es jetzt ausdrücklich. Gelöscht wird nur lokal; „Auswertung anfordern" kann Gelöschtes bewusst zurückholen.

## 0.9.71 – Die wahre Import-Ursache: WoW verdoppelt Pipes; Ränge echt wählbar

**Die eigentliche Ursache des Import-Dramas, endlich bewiesen** (durch die neue Diagnosezeile): Der WoW-Client verdoppelt beim Einfügen jede Pipe – aus `S|code|…` wird `S||code||…`. Der Parser las dann ein leeres Feld und verwarf Sitzungs- wie Teilnehmerzeilen stumm; nur die Profilzeilen (Semikolons statt Pipes) überlebten. Daher immer „11 Profile, keine Raidauswertung", und daher auch die ominöse „|1"-Zeile (der abgerissene Rest der verdoppelten Kopfzeile).

- **Der Import entschärft das Escaping jetzt selbst:** Erkennt er den doppelten Trenner direkt nach dem Zeilentyp (`S||`, `P||`, Kopfzeile), halbiert er alle Pipe-Paare – aus `||||` (leeres Feld, escaped) wird korrekt `||`. Echte Daten haben an diesen Stellen nie leere Felder, der Erkenner kann also nicht fehlgreifen;
- die Speicher-Fixes aus 0.9.70 (Aufbewahrung nach Wert, ehrliche Zählung) bleiben die zweite Verteidigungslinie.

**Rangfilter neu: echte Auswahl statt „bis Rang X".** Die Schwelle setzte eine Wertigkeit der Rangreihenfolge voraus, die es in echten Gilden nicht gibt (Owner: der Twink-Rang steht mitten zwischen Raidrängen). Der Knopf öffnet jetzt eine **Häkchenliste aller Gildenränge** – jeder Rang einzeln an- und abwählbar, „Alle anzeigen" setzt zurück, der Knopf zählt („Ränge: 3 von 6"). Der erste Eingriff hakt automatisch alle übrigen Ränge an, damit nicht beim ersten Klick alles verschwindet.

## 0.9.70 – Import-Rätsel gelöst, Prüfliste mit Rangfilter, Berufe-Nachlese

**Das „keine Raidauswertung"-Rätsel ist gelöst.** Der Import funktionierte die ganze Zeit – aber die Aufbewahrung hielt nur 12 Sitzungen und warf beim Aufräumen strikt nach Alter hinaus. Zwölf in der Stadt gestartete Probe-Sitzungen (Orgrimmar, Shattrath …) waren „neuer" als der Raidabend: Der frisch importierte Report wurde gespeichert, einsortiert – und als Nummer 13 sofort wieder gelöscht, während der Import Erfolg meldete.

- **Aufbewahrung nach Wert:** Beim Aufräumen fliegen zuerst Abende ohne einen einzigen Bosskampf. Ein echter Raid überlebt jetzt jede Stadt-Mini. Kappe von 12 auf 24 (ein Abend kann drei Quellen belegen);
- **der Import zählt nur, was hinterher wirklich da ist** – und meldet ausdrücklich, wenn die Aufbewahrung etwas verworfen hat, statt still Erfolg zu behaupten;
- **Kopfzeilen-Bruchstück toleriert:** Beim Einfügen riss „GCPWCL3|1" gelegentlich in „GCPWCL3" und „|1" auseinander; die Zahlzeile wird jetzt erkannt statt als „unlesbar" gemeldet.

**Ausrüstungsseite** (Owner-Wünsche):

- **Rangfilter:** Der Knopf über der Liste schaltet durch („Ränge: alle" → „bis Offizier" → …) und blendet alle darunter aus – der eigene Charakter bleibt immer sichtbar;
- **„Leeren":** wirft die komplette Dauerliste weg; „Eigene Ausrüstung" und Gruppenprüfungen füllen sie neu;
- **kein Sprung-Scrollen mehr:** Der Klick auf einen Spieler scrollte die Liste automatisch „mit" – weg damit, die Liste bleibt stehen;
- Detailfenster der Gruppenprüfung: „←"/„└"/„↔" gibt es in der WoW-Schrift nicht (Kästchen) – ersetzt durch Text; leere Befundzellen zeigen „–", die Fußzeile kürzt „keine Funde".

**Berufe-Nachlese beim Login:** Die Fähigkeitsliste ist beim Einloggen oft noch leer, und auf fertig geskillten Charakteren feuert das Nachlade-Ereignis nie – darum wirkten die Berufe „nie automatisch gewählt". Jetzt liest das Addon 5 und 20 Sekunden nach dem Login nach.

## 0.9.69 – Berufe-Karte: Werkstatt-Stand statt Übernehmen-Knopf

Der Knopf „Aus Fähigkeiten übernehmen" ist weg – er verwirrte nur, denn die Übernahme läuft ohnehin automatisch (bei jedem Fähigkeiten-Update und beim Öffnen des Berufsfensters). An seiner Stelle zeigt die Karte jetzt etwas Nützliches:

- **Werkstatt-Stand je Beruf:** eine Zeile pro Hauptberuf mit Skillstand („Schneiderei 375/375"), der Zahl der in der Gildenwerkstatt geteilten Rezepte (grün) und dem Alter des letzten Einlesens („vor 12 Min." / „vor 3 Std." / „vor 2 Tagen");
- **fehlen Rezepte, steht der nächste Schritt daneben:** „Rezepte fehlen – Berufsfenster einmal öffnen." (gelb) – genau die eine Handlung, die WoW fürs Einlesen wirklich verlangt;
- **Rückweg zur Automatik ohne Knopf:** Wer von Hand einen Beruf gewählt hat, wählt einfach den leeren Eintrag im Dropdown – das schaltet die automatische Erkennung wieder ein. Der Statustext erklärt das an Ort und Stelle.

## 0.9.68 – Auswertungsfenster, Gruppenprüfung mit Verzauberungs-Details, Import-Rettung

Drei Owner-Wünsche aus dem laufenden Raidabend:

- **Raidauswertung im eigenen Fenster:** Der neue Knopf „Detailfenster" auf der Raidauswertungsseite öffnet den gewählten Abend groß (720 Pixel breit, verschiebbar, legt sich vor das Addon). Elf Spalten je Teilnehmer – TIME, DEATH, RES, INT, DISP, POT, FLASK, ELIX, FOOD, DRUM – nach Anwesenheit sortiert, TIME färbt sich unter 85 % bzw. 50 %. Liegt der Abend aus mehreren Quellen vor (Live, Warcraft Logs, Combat Log), schaltet je ein Knopf die Quelle um – und der Knopf **„Vergleich"** stellt zwei Quellen gegenüber: je Spieler zwei Zeilen (oben Live, unten Logs), gelb markiert, wo die Quellen sich widersprechen (TIME auf Minutenbasis verglichen). Wer nur in einer Quelle auftaucht, bekommt auf der anderen Seite Striche;
- **Gruppenprüfung:** Das Fenster legt sich beim Öffnen jetzt vor das Addonfenster (und holt sich per Klick wieder nach vorn). Ein Klick auf einen geprüften Spieler öffnet die Detailansicht mit allen Slots – Bewertung (Optimal/Solide/Verbesserbar/Fehlt), Verzauberungsname und leere Sockel je Slot, wie auf der Ausrüstungsseite. „← Zur Gruppe" führt zurück;
- **WCL-Import verliert keine Raidauswertung mehr stumm:** Beim Owner kamen Teilnehmerzeilen ohne ihre Sitzungszeile an („keine Raidauswertung", obwohl es ein Raid war). Der Import rettet solche verwaisten Zeilen jetzt in die erste Sitzung des Imports, statt sie zu verwerfen. Bleibt wirklich keine Sitzungszeile übrig, erklärt die Fehlermeldung das ausdrücklich und zeigt die **erste unlesbare Zeile** des Pastes – damit ist beim nächsten Mal sichtbar, was beim Einfügen kaputtging, statt nur „keine Raidauswertung".

## 0.9.67 – „8 Versuche" nach dem ersten Boss: Trash zählte mit

Owner-Meldung live aus Karazhan: ein Boss lag, die Kopfzeile behauptete 8 Versuche. Ursache: Als Versuch galt bisher **jeder** Kampfabschnitt ab 15 Sekunden – in einer Raidinstanz ist das jede zweite Trashgruppe.

- **Nur erkannte Bosskämpfe zählen noch als Versuch.** Reine Trashkämpfe werden verworfen statt gespeichert;
- **der Client meldet Bosse jetzt selbst:** Der Anniversary-Client kennt `ENCOUNTER_START`/`ENCOUNTER_END` (dieselben Ereignisse, auf die sich DBM stützt). Start benennt den Abschnitt – auch bei Bossen, die in der eigenen Liste fehlen –, Ende liefert den Ausgang: Sieg ist Sieg, Fehlschlag ist Wipe, egal was die Todeszählung sagt. Ein bestätigter Encounter zählt auch unter 15 Sekunden – eine überlegene Gruppe legt Attumen schneller. Die Namensheuristik über die Bossliste bleibt als Rückfallebene, falls ein Client-Build die Ereignisse nicht kennt (Registrierung per `pcall` abgesichert);
- **alte Sitzungen rechnen sich sauber:** Zusammenfassung und Live-Kopfzeile zählen nur noch Boss-Versuche – eine unter älterer Version gestartete oder gespeicherte Sitzung zeigt damit ebenfalls korrigierte Zahlen, ohne dass Daten angefasst werden.

## 0.9.66 – Raidabend-Komfort: Instanzfenster, Gruppenprüfung, Sitzungs-Banner

Vier Owner-Wünsche rund um den Raidstart:

- **Instanz-Begrüßungsfenster:** Wer eine Raidinstanz betritt und Sitzungen steuern darf (`CanControlSession` – nur Leiter/Assistenten/freigegebene Ränge), bekommt ein kleines Fenster: „Du bist in ‚Karazhan'. Auswertung mitschreiben? Ausrüstung checken?" mit **[Sitzung starten] [Gruppe prüfen] [Nicht jetzt]**. Nur einmal je Instanzbesuch, draußen setzt sich der Merker zurück, keine Automatik – gestartet wird nur per Klick;
- **„Gruppe prüfen" hat jetzt ein eigenes Fenster:** Statt der großen Dauerliste aller je geprüften Spieler zeigt es NUR die aktuelle Gruppe – je Zeile Name (Klassenfarbe), Datenstand (Addon/Inspect, Alter) und Befund (grün „ok", rot mit Funden, gedämpft „keine Daten"), Funde sortieren nach oben, Zusammenfassung unten, „Erneut prüfen" im Fenster. Eintreffende Inspects und Addon-Daten füllen es live. Die Ausrüstungsseite mit der Dauerliste bleibt unverändert bestehen;
- **Sitzungsstart poppt bei allen auf:** Startet jemand die Raidsitzung, erscheint bei den übrigen Addon-Nutzern die Bildschirmmeldung „Raidsitzung gestartet von X" – derselbe Banner wie bei den Gildenaufträgen, mit demselben Schalter und derselben Position;
- **die „Geprüfte Spieler"-Liste beginnt oben:** Beim frischen Aufschlagen der Ausrüstungsseite steht der Scroller jetzt am Anfang statt auf der gemerkten Altposition – bewusst nur beim Anzeigen, nicht bei jeder Datenauffrischung.

## 0.9.65 – Werkstatt: „110 Berufe" waren Pakete, „13 Berufe" ein Duplikat

Owner-Screenshot: Die Statuszeile meldete „Empfangen: 110 Berufe mit 4003 Rezepten", direkt neben der Karte mit ehrlichen 885 Rezepten und 13 Berufen. Zwei getrennte Zählfehler:

- **Die Statuszeile zählte Pakete, nannte sie aber Berufe:** Jeder Abgleich liefert dieselben Berufe derselben Hersteller erneut, der Zähler summiert je Paket. Die Zeile heißt jetzt ehrlich „Abgleich: X Berufspakete empfangen • zuletzt Y" – ohne die sinnlose Rezeptsumme;
- **die Berufe-Karte zählte nach Namens-String:** Die Alt-Schreibweise „Alchemie" neben „Alchimie" und der „Unbekannt"-Platzhalter zählten als eigene Berufe – daher 13, wo TBC höchstens 12 kennt. Gezählt wird jetzt nach normalisiertem Schlüssel, Alchemie→Alchimie zusammengeführt, „Unbekannt" außen vor. Ein Test hält fest, dass ein weiterer Alt-Eintrag die Zahl nicht mehr erhöht.

## 0.9.64 – Gildenaufträge: Klang-Feinschliff, Übergabetext, Herstellerliste

Fünf Owner-Wünsche in einer Runde:

- **Die Annahme klingt wie eine angenommene Quest** – neues Klangereignis „Auftrag angenommen" (Vorgabe „Quest angenommen", Kit 618) mit eigener Zeile in den Einstellungen; der übrige Fortschritt pingt weiter wie die Karte;
- **Anflüstern legt einen fertigen Übergabetext vor:** „Hallo {name}! Dein Auftrag ‚{rezept}' ist fertig – ich wäre bereit für die Übergabe." Die Platzhalter werden ersetzt, der Text steht in den Einstellungen zum Anpassen, gesendet wird erst mit Enter;
- **Wunsch-Hersteller als Auswahlliste statt Freitext:** Der Knopf öffnet die Liste der bekannten Hersteller des Rezepts („(keiner)" zuoberst) – vertippte Namen sind damit ausgeschlossen;
- **der Wunsch-Hersteller bekommt seine eigene Meldung:** „Gildenauftrag für dich von X" samt Klang und Banner, während alle anderen nur die Reserviert-Chatzeile sehen;
- **× im Werkstatt-Suchfeld** leert die Suche mit einem Klick; es erscheint nur, wenn etwas drinsteht.

## 0.9.63 – Gildenaufträge: Stufe 2 komplett, plus alles Zurückgestellte

Owner: „Bau alles ein, auch die stufenlosen Sachen." Sechs Bausteine in einem Wurf:

- **Anflüstern (Übergabe vereinbaren):** Bei fertiger persönlicher Übergabe ist „Anflüstern" die Primäraktion des Auftragnehmers, und im Verlauf-Dialog gibt es den Knopf für beide Seiten. Vorbelegt wird der beste Empfänger der Gegenseite – bevorzugt ein gerade online sichtbarer Charakter ihres Accounts (über den accountTag), sonst der benannte;
- **Erstattung mit Restbetrag und Teilzahlungen:** „Erstattet" öffnet einen Dialog mit dem offenen Rest vorbelegt; Teilzahlungen sind erlaubt, der Verlauf vermerkt „x gezahlt, offen y", und erst bei null Rest wandert der Auftrag zur Bestätigung des Auftragnehmers;
- **Wunsch-Hersteller (gerichteter Auftrag):** Optionales Feld im Erstellen-Dialog, validiert gegen die bekannten Hersteller des Rezepts. 24 Stunden lang darf nur er annehmen (empfangsseitig geprüft), danach ist der Auftrag offen für alle. Die Frist wird nie gesendet – jeder Client rechnet „erstellt + 24 h" selbst; andere sehen „Reserviert für X" und bekommen keinen Neuer-Auftrag-Klang;
- **Teilfertigung bei Stückzahlen > 1:** Der Gefertigt-Dialog fragt den Gesamtstand ab; unter der vollen Menge bleibt der Auftrag „in Arbeit" mit Zähler („Fertigen (2/3) …"). Bewusst nur Fertigungs-, keine Lieferlogistik – übergeben wird am Ende einmal;
- **Vorlagen:** „Als Vorlage merken" im Erstellen-Dialog speichert die Einstellungen je Rezept (lokal im Account); das nächste Öffnen für dasselbe Rezept ist vorausgefüllt – der Wochenauftrag „15 Sphären" ist ein Klick;
- **Auftragsstatistik:** Der Statistik-Knopf auf dem Board zeigt je Spieler erledigte und erstellte Aufträge. Gezählt wird beim Übergang auf „abgeschlossen", je Auftrag genau einmal (Kurierpakete zählen nicht doppelt). Auf Owner-Wunsch trotz des Konzept-Vorbehalts zum sozialen Druck;
- außerdem (eigener Owner-Wunsch nebenbei): Die **Chat-Befehle stehen jetzt als Karte auf der Einstellungsseite**, gespeist aus derselben Tabelle wie `/gcp help` und die Addon-Optionen;
- Wire-Detail: Kern +Wunsch-Hersteller (Feld 16), Zustand +Teilzahlung/Teilfertigung (Felder 18/19) – Altclients ignorieren die Felder. Damit die Kernnachricht ausgereizt unter 255 Bytes bleibt, ist die Notiz auf 48 Bytes gekürzt.

## 0.9.62 – Kompakt-Tracker: zwei Zeilen je Auftrag

Owner-Screenshot: „Materialien an Silverssoul li…" – Rezept und Aufgabe in einer Zeile schnitten die Aufgabe ab. Jeder Auftrag hat jetzt zwei Zeilen (Rezept ×Menge oben, Aufgabe gedämpft darunter), der Tracker ist etwas breiter und wächst weiterhin nur so hoch wie sein Inhalt.

## 0.9.61 – Ranggeschütztes trägt ein Schloss statt zu verschwinden

Owner-Entscheidung: Sichtbar-aber-gesperrt schlägt unsichtbar. Ein verstecktes Feature sieht aus, als gäbe es das Addon ohne es; ein Schloss sagt „gibt es, braucht Rang".

- Der Navigationspunkt **Mitgliederpflege** – bisher der einzige komplett versteckte – bleibt jetzt für alle sichtbar: gedimmt, mit Schloss-Symbol rechts und einem Tooltip, der erklärt, dass berechtigte Ränge die Freigabe in den Einstellungen festlegen. Ein Klick auf den gesperrten Punkt leitet wie bisher zur Profilseite um, mit klarer Meldung;
- alle übrigen ranggebundenen Stellen (Raidauswertungs-Knöpfe, Gildenprofil-Felder, Pflege-Entscheidungen) nutzten bereits das Ausgrau-Muster mit Erklärtext und bleiben unverändert.

## 0.9.60 – Versionsprüfer: Luft in der Fußzeile

Owner-Screenshot: Zwischen den Knöpfen wurde die Zusammenfassung zerquetscht und „ohne Addon" abgeschnitten. Sie steht jetzt in voller Breite auf einer eigenen Zeile über den Knöpfen; das Fenster ist entsprechend höher, die Knöpfe etwas breiter.

## 0.9.59 – /gcp ver: der Versionsprüfer

Owner-Wunsch nach dem Vorbild des RCLootCouncil-Versionsprüfers, im eigenen Design:

- **`/gcp ver`** öffnet ein verschiebbares Fenster mit Name (Klassenfarbe), Gildenrang und Version. **Grün** ist der eigene Stand, **rot** ist älter, **gelb „Warte auf Antwort …"** bis zur Antwort, nach acht Sekunden **„Nicht installiert"**. Rot steht oben – wer prüft, sucht die Veralteten. Unten die Umschalter **Gilde** (alle Online-Mitglieder) und **Gruppe** (Raid/Party) samt Zusammenfassung „x aktuell · y veraltet · z ohne Addon";
- dafür zwei Lücken im Handshake geschlossen: **V-Nachrichten über RAID/PARTY** wurden vom Raid-Sammelzweig verschluckt und erreichen jetzt den Empfänger, und **Antworten gehen auf dem Anfragekanal zurück** statt in die eigene Gilde – erst damit sehen sich auch Gruppenmitglieder fremder Gilden. Deren Antworten bleiben im Sitzungsspeicher und landen nicht im Gildenbestand;
- **`/gcp phase` ist entfallen** (Owner: „komplett unnötig"). Die Content-Phase läuft intern mit Voreinstellung und Gildenabgleich weiter; der Befehl war ihr einziger Handschalter.

## 0.9.58 – Raidauswertung: Teilnehmer von Hand ordnen

Owner-Wunsch: Die Teilnehmerliste soll sich zusätzlich zur Spaltensortierung per **Ziehen mit der Maus** frei ordnen lassen (etwa nach Gruppen fürs Besprechen).

- Eine Zeile greifen und über einer anderen loslassen verschiebt sie dorthin. Die gerade angezeigte Reihenfolge wird dabei zur **Handordnung dieser Auswertung** und bleibt an ihr gespeichert (lokal, wandert nicht durch die Gilde);
- Handordnung und Spaltensortierung wechseln sich sauber ab: Ziehen schaltet die Spaltensortierung ab, ein Klick auf einen Spaltenkopf sortiert wieder nach Spalte – die Handordnung bleibt gemerkt und gilt erneut, sobald keine Spalte aktiv ist;
- nachträglich empfangene Teilnehmer, die in der Handordnung noch nicht vorkommen, hängen hinten an, statt zu verschwinden;
- ein kleiner Hinweis „Zeilen ziehen ordnet von Hand" steht an der Karte; zwei Testblöcke sichern Verschieben und Anwendung der Ordnung ab.

## 0.9.57 – Gildenaufträge: das Kuriernetz

Owner-Frage: „Wenn nur einer alleine online ist und Aufträge reinstellt, empfängt die ja keiner – oder hättest du da noch eine Lösung?" Die Antwort in drei Teilen:

- **Verloren geht nie etwas:** Ein allein erstellter Auftrag liegt in den eigenen SavedVariables und verteilt sich beim nächsten gemeinsamen Online-Moment (Login-Push und Abgleich seit 0.9.52);
- **jeder Client ist jetzt Kurier:** Der Login-Push sendet nicht mehr nur die eigenen, sondern **alle bekannten laufenden Aufträge**. Wer einen Auftrag einmal empfangen hat, trägt ihn zu jedem weiter, mit dem er online ist – ein Auftrag braucht damit nicht mehr den Ersteller online, sondern irgendeinen Träger. Dabei behoben: Der Empfang verlangte bisher „Absender = Auftraggeber" und verwarf genau solche Kurierpakete – auch in den Abgleich-Antworten, die deshalb nur eigene Aufträge durchbrachten. Kerne von Dritten gelten jetzt, mit derselben Vertrauensbasis wie beim Werkstatt-Sync (Absender sind immer Gildenmitglieder);
- **der Einsam-Hinweis:** Erstellt man einen Auftrag, während laut Roster kein anderes Gildenmitglied mit Guild Copilot online ist, sagt der Dialog es vorab und die Erfolgsmeldung wiederholt es – gespeichert ja, verteilt erst beim nächsten gemeinsamen Login.

Ausdrücklich verworfen: ein externer Umweg (Companion lädt Aufträge zu GitHub o. ä. hoch). Das wäre echte Offline-Zustellung, hieße aber Gildendaten im Internet und einen laufenden Zweitprozess – für ein WoW-Addon die falsche Abwägung.

## 0.9.56 – Feinschliff aus dem laufenden Test

Sechs Owner-Rückmeldungen in einer Runde:

- **„Meldung testen" spielt jetzt auch den Klang** – Klang und Meldung zusammen, wie im Ernstfall;
- die Meldung nennt wieder den Auftraggeber: **„Neuer Gildenauftrag von xyz"** (gleicher Absender wird hochgezählt, verschiedene stapeln);
- **Anzeigedauer einstellbar** (1–30 Sekunden, Vorgabe 3) – damit ist alles am Feature einstellbar: Klang je Ereignis, Dauer, Ein/Aus, Position;
- neuer Knopf **„Position zurücksetzen"**, falls die Meldung einmal unauffindbar hängt;
- **das „C" unten links aufgeklärt:** Das frei platzierte Minimap-Symbol trug noch den goldenen Minimap-Ring – der offene Ring sah losgelöst wie ein Buchstabe aus. Frei platziert zeigt der Knopf jetzt nur das Wappen, mittig und etwas größer; am Minimap-Ring bleibt alles beim Alten. (Die Logo-Textur selbst war in Ordnung – geprüft durch Dekodieren der TGA.);
- **der Hinweis „Bitte den aktuellen Werbetext zuerst bestätigen" ist jetzt sichtbar:** Er existierte schon, stand aber klein rechts neben dem Werbebalken-Knopf. Jede Rückmeldung von „Suche starten" steht nun in voller Breite direkt unter dem Knopf.

## 0.9.55 – Bildschirmmeldung nach Owner-Geschmack, und weiches Scrollen

Rückmeldung mit Screenshot zur 0.9.54er-Meldung („man kann es kaum lesen"):

- **Kein Kasten mehr:** Die Meldung ist reiner Text mit dicker Kontur und Schatten, darüber und darunter eine **dünne Linie** – die klassische Raidwarnungs-Optik. Der Kasten erscheint nur noch im Positionier-Modus über „Meldung testen", damit sich der Anker greifen lässt;
- **drei Sekunden stehen, dann anderthalb Sekunden ausblenden** statt hartem Verschwinden;
- **nur noch „Neuer Gildenauftrag"** – Rezept und Auftraggeber stehen im Chat und auf dem Board, die Meldung sagt nur, dass es etwas Machbares gibt (Owner: „der Name ist gar nicht relevant"). Sie erscheint unverändert nur, wenn ein eigener Charakter das Rezept kann, und bleibt über die Einstellungen abschaltbar;
- **mehrere auf einmal:** Gleiche Meldungen werden zu „Neuer Gildenauftrag ×2" zusammengefasst; unterschiedliche rücken wie beim Scrolling Combat Text nach oben und verblassen dort;
- **nebenbei gemeldet und behoben:** Das Mausrad scrollte alle Seiten in harten 24-Pixel-Schritten – auf der 1700 Pixel hohen Einstellungsseite fühlte sich das stockend an. Jetzt setzt das Rad ein Ziel und ein kurzlebiges OnUpdate nähert sich ihm exponentiell; im Leerlauf hängt kein Handler am Rahmen (0.9.49-Prinzip).

## 0.9.54 – Gildenaufträge: Klang und Bildschirmmeldung

Owner-Wunsch mit Präzisierung während der Umsetzung (Stufenaufstieg statt Raidwarnung für neue Aufträge):

- **Drei Klänge, drei Ereignisse:** Stufenaufstieg bei einem neuen Auftrag, den ein eigener Charakter fertigen kann, Karten-Ping bei jedem Fortschritt an eigenen Aufträgen (Annahme bis Erstattung), Questabschluss beim Abschluss. Zurücklegen und Abbrechen bleiben stumm – sie sind kein Fortschritt;
- **alles einstellbar:** neue Karte „Gildenaufträge" in den Einstellungen mit je einem Klangmenü pro Ereignis (die bekannte Klangliste plus „Aus") und einem Schalter für die Bildschirmmeldung;
- **eigene Bildschirmmeldung statt der eingebauten Raidwarnung:** Die Standardposition oben-mittig ist erfahrungsgemäß von WeakAuras belegt und schlecht lesbar. Die Meldung zu neuen machbaren Aufträgen ist ein eigener, gut lesbarer Balken mit dunklem Hintergrund, frei verschiebbar (Position wird gespeichert), verschwindet nach fünf Sekunden von selbst und lässt sich über „Meldung testen" in den Einstellungen zum Platzieren aufrufen.

## 0.9.53 – Kompakt-Tracker: Höhe nach Inhalt

Der Tracker hielt immer Platz für drei Zeilen vor – mit einem einzigen Auftrag sah das nach kaputtem Fenster aus, und lange Zeilen brachen in die 26-Pixel-Zeile um. Jetzt: Höhe = Titelzeile plus sichtbare Zeilen, Text einzeilig mit hartem Abschnitt statt Umbruch (`SetWordWrap(false)`, `SetMaxLines(1)`).

## 0.9.52 – Gildenaufträge: der Abgleich war ein Konstruktionsfehler

Aus dem Zwei-Spieler-Test: Beide hatten Aufträge erstellt, keiner sah die des anderen. Drei Ursachen, alle im Abgleich:

- **Der Zeitstempel-Filter der Login-Anfrage maskierte fremde Aufträge.** „Schick mir alles, was neuer ist als meine letzte Änderung" klingt sparsam, ist aber falsch: Die letzte Änderung ist nach dem Erstellen eines eigenen Auftrags *der eigene Auftrag* – und Zeitstempel verschiedener Absender sind ohnehin nicht vergleichbar. Eine Anfrage wird jetzt immer mit dem **kompletten Stand** beantwortet; Revisionen und der Verlaufs-Dedup machen Doppeltes wirkungslos. Die Drossel gilt je Anfragendem statt global, damit zwei kurz nacheinander Einloggende beide ihre Antwort bekommen;
- **es gab nur Pull, keinen Push.** Wer zur Erstellzeit offline oder auf einer älteren Version war (die den `O`-Typ verwirft), konnte einen Auftrag nur über die eigene Anfrage nachladen – die einmalig 13 s nach dem Login feuert. Jetzt drückt jeder Client 17 s nach dem Login zusätzlich die **eigenen laufenden Aufträge** als Kern+Zustand in den Gildenkanal;
- **ein verlorenes Kernpaket blieb verloren.** Ein Zustandswechsel zu einem unbekannten Auftrag wurde stillschweigend verworfen. Jetzt löst er eine **Nachforderung** aus (höchstens eine pro Minute), und die nächste Antwort bringt den ganzen Stand.

Die Tests bilden den gemeldeten Fall jetzt wörtlich ab: Eine Anfrage mit Zeitstempel in der Zukunft bekommt trotzdem den vollen Stand; ein unbekannter Zustandswechsel fordert nach und ist gedrosselt; der Login-Push sendet je eigenem Auftrag Kern und Zustand.

## 0.9.51 – Gildenaufträge: erste Runde Spielpraxis

Vier Funde aus dem ersten echten Blick ins Spiel, gemeldet vom Owner mit Screenshots, dazu sein Wunsch nach Farbkennzeichnung:

- **Texte liefen hinter die neuen Knöpfe:** Der Seiten-Hilfetext verschwand hinter den Unterreiter-Knöpfen, der Rezeptname hinter „In Auftrag geben". Beide Beschriftungen sind jetzt schmaler und brechen vor den Knöpfen um;
- **der dritte Materialmodell-Knopf stand außerhalb des Dialogs:** Die x-Position wurde aus der Breite des jeweiligen Knopfs statt der Summe der vorherigen gerechnet. Jetzt läuft ein Cursor mit, und der Dialog ist minimal breiter (452);
- **die Dialoge waren durchscheinend und lagen im Seiten-Scrollbereich:** Wie bei den Aufklappmenüs dokumentiert, mischen sich Kinder der Seite mit deren Karten und werden beschnitten. Die Dialoge hängen jetzt am Hauptfenster, mit eigener hoher Ebene und voll deckendem Hintergrund; Seitenwechsel und Fensterschluss schließen sie mit;
- **Farbkennzeichnung** (Owner-Wunsch): Das Statuswort trägt jetzt Farbe (gelb wartet, türkis läuft, grün fertig, rot abgebrochen – dieselben Hexwerte, die das Addon in Texten ohnehin nutzt), der Kartenrahmen wird türkis, wenn du dran bist, und grün bei offenen Aufträgen, die ein eigener Charakter fertigen kann; die Aufgabenzeile steht in Warnfarbe statt grau.

## 0.9.50 – Gildenaufträge: die Werkstatt nimmt Bestellungen an

Stufe 1 des abgenommenen Konzepts (`docs/KONZEPT-werkstatt-gildenauftraege.md`), umgesetzt in einem neuen Modul `GuildCopilot/Orders.lua` plus Board, Dialogen und Kompakt-Tracker in `UI.lua`:

- **Aufträge auf Katalogrezepte:** „In Auftrag geben" sitzt direkt an der Rezeptkarte der bestehenden Suche. Menge, Materialmodell (A: Auftraggeber liefert / B: Gildenbank / C: Beschaffung mit Kostenrahmen), Übergabeart (persönlich/Post), Trinkgeld und Notiz werden beim Erstellen festgelegt – die Annahme ist die Zustimmung zu genau diesen Bedingungen;
- **Auftragnehmer ist der Account, nicht der Charakter:** Angenommen werden darf vom Twink, gefertigt wird mit dem Charakter, der das Rezept laut geteiltem Katalog kann; bei mehreren fragt ein Dialog. Wer das Rezept nirgends hat, bekommt keinen Annehmen-Knopf. Fremde Clients prüfen Annahmen gegen den Katalog und spätere Schritte gegen den `accountTag` aus dem Handshake;
- **genau einer gleichzeitig:** Die Doppelannahme löst dieselbe deterministische Regel wie überall im Addon – frühester Zeitstempel gewinnt, bei Gleichstand die kleinere Kennung; der Unterlegene bekommt eine klare Meldung;
- **Statusmodell mit Verlauf:** Offen → angenommen → in Arbeit → gefertigt → (versandt) → erhalten → abgeschlossen, bei gemeldeten Kosten mit zweiseitigem Abschluss (erst „erstattet", dann „Erstattung erhalten"). Jeder Schritt steht mit Zeit, Charakter und optionaler Notiz im Verlauf (12 Einträge je Auftrag); an jedem Auftrag steht, wer als Nächstes dran ist;
- **Board als zweiter Werkstatt-Reiter:** „Du bist dran" oben, offene Aufträge der Gilde mit „nur machbare"-Filter, Abgeschlossenes darunter. Offiziers-Abbruchrecht über die Mitgliederpflege-Rangfreigabe, Rückfall-Knopf nach 3 Tagen Stillstand oder Gildenaustritt des Auftragnehmers;
- **Kompakt-Tracker** nach dem Werbebalken-Muster (Owner-Entscheidung: Stufe 1): frei verschiebbar, zeigt bis zu drei „du bist dran"-Zeilen und nur dann sich selbst; Klick öffnet das Board;
- **Synchronisierung als `O`-Familie:** Jede Änderung sendet Kern + Zustand (jede Nachricht ≤ 255 Bytes, ein Test wacht darüber), beim Login gleicht eine Anfrage mit Zeitstempel ab, Antworten laufen gedrosselt und gezielt per Flüstern über die Bulk-Warteschlange. Alte Clients ignorieren die Familie einfach;
- **Grenzen aus dem Konzept:** höchstens 5 offene Aufträge je Account, offene verfallen nach 14 Tagen, Historie 20, Gesamtdeckel 60;
- abgesichert durch zwei neue Testblöcke: der komplette Modell-C-Lebenslauf über die echte Sync-Weiche, Twink-Annahme, Doppelannahme, Rechteprüfung (Fremd-Actor, Offiziers-Abbruch), Drosselung, Verfall und Deckel sowie Board-/Tracker-Sichtbarkeit.

**Abweichungen vom Konzept, bewusst:** Der Flüster-Knopf zur Übergabe-Vereinbarung und die Vorbelegung des Chatfensters fehlen noch (Stufe 2); die Notiz ist auf 60 statt 120 Bytes begrenzt, damit jede Zustandsnachricht sicher in eine Chatnachricht passt; ein automatischer Sprung von „angenommen" zu „in Arbeit" bei vollständigen eigenen Materialien entfiel zugunsten eines einheitlichen Ablaufs – „Materialien vollständig" ist immer ein bewusster Klick.

## 0.9.49 – Performance von Grund auf: Schuebe sammeln statt pro Ereignis zeichnen

Die systematische Durchsicht aller Ereignispfade nach den Meldungen aus der Gilde. Geprueft wurde jede Ereignisregistrierung, jeder OnUpdate-Handler und jeder Callback-Trichter; vieles war bereits richtig geloest (Roster-Entprellung, Taschen-Scans, Chat-Gates, Fremdpraefix-Verwurf im Sync). Fuenf Stellen waren es nicht:

- **Der teuerste Fund: `GET_ITEM_INFO_RECEIVED` zeichnete die offene Seite pro Item neu.** Der Client meldet beim Login jeden nachgeladenen Gegenstand einzeln - tausende Ereignisse, und jedes feuerte `WORKSHOP_UPDATED`; bei offener Werkstatt- oder Rosterseite zeichnete jedes einzelne die komplette Seite. Jetzt sammelt `ScheduleNameRefresh` auf hoechstens zwei Auffrischungen pro Sekunde;
- **Datenschuebe zeichnen die sichtbare Seite einmal, nicht pro Paket.** `Invalidate` wird nur von Datenaenderungen gerufen, nie von Klicks - ein kurzer Sammel-Timer (0,25 s) fasst den Schub zusammen. Ein Gildenabgleich zur Prime Time bei offenem Fenster kostet damit einen Neuaufbau statt einem pro Paket. Klicks zeichnen unveraendert sofort;
- **Das Item-Daten-Abo des Gear Audits ist zustandsgetrieben.** `GET_ITEM_INFO_RECEIVED` ist nur noch registriert, solange die letzte Selbstpruefung unlesbare Slots hatte - vorher fragte jeder der tausenden Login-Treffer die Datenbank nach dem eigenen Audit;
- **Die Bulk-Warteschlange legt ihren Antrieb schlafen.** Ihr OnUpdate lief jeden Frame, auch mit leerer Warteschlange. Der Rahmen versteckt sich jetzt bei Leerlauf (versteckte Frames bekommen kein OnUpdate) und bucht beim Aufwachen die verstrichene Pause als Sendebudget nach;
- **Der Sitzungspfad spart sich Stringarbeit.** Die Sattgegessen-Erkennung prueft Namen nur noch bei Aura-Ereignissen (Essen ist nie ein Cast), und ein Namens-Memo je Sitzung ersetzt die zweifache Normalisierung pro Kampfereignis; Fehltreffer werden verworfen, sobald ein neuer Teilnehmer auftaucht.

**Bewusst nicht angefasst:** die Bank-Scans (ein verzoegerter Scan koennte nach dem Schliessen des Bankfensters eine leere Bank lesen und den Bestand ausloeschen), `GetGuild()`-Caching (Semantikrisiko ohne belegten Engpass) und die Mengenobergrenzen der Datenbank (weiter Messfrage, siehe TODO Punkt 4). Fuenf neue Testbloecke sichern das Sammelverhalten ab, darunter die Zusicherung, dass ein Nachzuegler den Namens-Memo verwirft.

Zur Ursachensuche bei den Betroffenen: **`/gcp debug`** schaltet die eingebaute Messung ein; sie protokolliert die schlimmste Einzeldauer je Vorgang und gehoert zuerst zu den Spielern mit Einbruechen.

## 0.9.48 – Zwei Ereignisse, die zu oft zugestellt wurden

Aus der Gilde gemeldet: Performance-Einbrüche bei einzelnen Spielern, dazu ein Fall, in dem nach dem Aktivieren von Guild Copilot alle übrigen Addons deaktiviert waren. Die Ursache beider Meldungen ist **nicht** gefunden – die Suche danach hat aber zwei Stellen zutage gefördert, die unabhängig davon falsch waren:

- **`COMBAT_LOG_EVENT_UNFILTERED` ist nur noch während einer laufenden Raidsitzung abonniert.** Es ist das häufigste Ereignis im Spiel und wurde bisher dauerhaft entgegengenommen, auch wenn gar nichts mitgeschrieben wurde. Der Handler stieg zwar sofort wieder aus, aber schon die Zustellung kostet bei jedem einzelnen Ereignis Zeit. Registriert wird jetzt in `StartSession`, abgemeldet in `FinishSession`;
- **`UNIT_INVENTORY_CHANGED` wird über `RegisterUnitEvent` auf den eigenen Charakter begrenzt.** Das Ereignis feuert für jede Einheit in der Gruppe; gefiltert wurde erst in Lua. Im 25er-Raid lief der Handler damit fünfundzwanzigmal so oft wie nötig. Der Client filtert das billiger, als Lua es je könnte;
- zwei Tests halten fest, dass das Combat-Log-Abo mit der Sitzung kommt und mit ihr wieder geht.

**Ehrlich zum Umfang:** Beide Änderungen sind Hygiene, kein spürbarer Sprung. Wer eine merkliche Verbesserung der Bildrate erwartet, wird enttäuscht – die gemeldeten Einbrüche sind damit sehr wahrscheinlich **nicht** erklärt. Die eigentliche Ursache braucht Messwerte aus dem Raid (AddonProfiler) und Fehlerprotokolle der Betroffenen (BugSack/BugGrabber), nicht weitere Vermutungen.

## 0.9.47 – Befehle, die man auch findet

Das Willkommensfenster aus 0.9.46 ließ sich nach dem ersten Login nicht wieder aufrufen – wer es noch einmal sehen wollte, kam nur über `/run` daran. Und die Befehlsliste stand in der README, also genau dort nicht, wo man sie sucht.

- **`/gcp welcome`** zeigt das Willkommensfenster jederzeit, unabhängig davon, ob dieser Charakter es schon gesehen hat;
- **`/gcp recruite`** blendet den Werbebalken ein und aus. `/gcp werbung` und `/gcp balken` bleiben gültig – niemand soll sich umgewöhnen müssen –, und `/gcp recruit` fängt den naheliegenden Vertipper mit ab;
- **`/gcp help`** listet alle Befehle im Chat;
- **dieselbe Liste steht unter Optionen → AddOns → Guild Copilot.** Diese Seite schlägt man auf, wenn einem der Chatbefehl gerade nicht einfällt – dort nach ihm zu suchen ist der naheliegende Weg, und bis jetzt stand da nur `/gcp`;
- **beide Aufzählungen kommen aus einer einzigen Tabelle** im Code. Zwei getrennte Listen laufen auseinander, sobald ein Befehl dazukommt, und die ungepflegte ist dann die falsche. Ein Test prüft, dass die Hilfe jeden Befehl nennt.

## 0.9.46 – Ein Willkommensfenster, und die Berufe wurden nie erkannt

Aus der Gilde gemeldet: „Aus WoW-Berufen übernehmen“ sei irreführend, das Addon erkenne die Berufe ja gar nicht selbst. Die Vermutung stimmte, der Grund war ein anderer als angenommen:

- **`GetProfessions()` gibt es im Anniversary-Client nicht.** Es ist eine Retail-API; Classic führt die Berufe als Zeilen im Fähigkeitenfenster. `RefreshProfessions` stieg deshalb in der ersten Zeile wortlos aus – seit es die Funktion gibt. Die ROADMAP führte das als „nicht verifizierbare Annahme, fällt still aus“; still fiel sie aus, nur sah es aus wie Erfolg: Was von Hand eingetragen war, blieb stehen, und darunter meldete die Statuszeile „Automatische Synchronisierung aktiv“;
- gelesen wird jetzt über `GetNumSkillLines`/`GetSkillLineInfo`, mit `GetProfessions` als Rückfall, falls es doch einmal da ist. **Eine zugeklappte Kategorie zählt ihre Zeilen nicht mit**, wird deshalb kurz aufgeklappt und danach wieder geschlossen – rückwärts, weil jedes Zuklappen die Zeilen darunter verschiebt. Sekundäres wie Kochkunst und Erste Hilfe bleibt draußen, im Profil stehen die beiden Hauptberufe;
- **„nichts gefunden“ und „kann nicht nachsehen“ sind zwei Antworten**, und nur die erste heißt, dass dieser Charakter keinen Beruf hat. Die Statuszeile nennt jetzt beide beim Namen und behauptet keinen Erfolg mehr, den es nicht gab. Kann der Client nichts liefern, steht dort die Aufforderung, von Hand zu wählen;
- **die Karte „Deine Berufe“ trennt Namen und Rezepte.** Beides hieß „Berufe“ und ist verschieden: Die Namen kommen von selbst, die Rezepte für die Gildenwerkstatt gibt WoW nur bei geöffnetem Berufsfenster heraus. Der Knopf heißt entsprechend **Aus Fähigkeiten übernehmen**;
- derselbe Denkfehler steckte in der Checkliste aus 0.9.45: Schritt 2 prüfte auf **Berufsnamen** und hakte sich damit beim Login von selbst ab, ohne dass jemand etwas getan hätte. Er heißt jetzt **Rezepte einlesen** und meint den Werkstattscan. Wer keinen Beruf erlernt hat, dem gilt er als erledigt statt auf ewig offen zu stehen.

Dazu die aktive Einführung, die bis dahin fehlte:

- **ein Willkommensfenster beim ersten Login je Charakter**: das Schriftlogo und genau ein Knopf, **Einrichtung starten**, der auf die Profilseite führt. Kein Text, keine zweite Wahl – was zu tun ist, steht danach als Checkliste da, und die ist der eigentliche Inhalt. Ein Fenster, das schon hier alles erklärt, wird überblättert. Vorher sprang das ganze Addon auf: dreizehn Navigationspunkte als erster Eindruck;
- **ein Punkt am Minimap-Symbol**, solange die Einrichtung offen ist; der Tooltip nennt den nächsten Schritt. Er war die eigentliche Lücke: Wer das Fenster einmal schloss, hatte danach kein Zeichen mehr, dass überhaupt etwas aussteht. Er verschwindet von selbst, wiederholt sich nie im Chat und ist mit „Nicht mehr anzeigen“ endgültig weg. Das `×` der Karte lässt ihn dagegen stehen – sonst wäre der Weg zurück unsichtbar.

## 0.9.45 – Erste Schritte, und „geändert“ heißt wieder „unbestätigt“

Ein neuer Charakter stand bisher vor dreizehn Navigationspunkten und musste selbst herausfinden, womit er anfängt. Der Assistent dafür ist bewusst **kein eigenes Fenster** geworden:

- **eine Checkliste „Erste Schritte“ oben auf der Profilseite.** Alle drei Schritte – Raidprofil bestätigen, Berufe einlesen, Ausrüstung ansehen – leben ohnehin genau dort. Ein Wizard-Fenster hätte dieselben Karten entweder verdoppelt oder überdeckt, und weil die echte Aktion der Übergang sein soll, hätte es sie trotzdem beobachten müssen. Dann kann es auch gleich dorthin führen;
- **es gibt keinen „Weiter“-Knopf.** Das Bestätigen des Profils *ist* der Übergang zum zweiten Schritt, der erkannte Beruf *ist* der Übergang zum dritten. Ein Knopf daneben hätte nur behauptet, was ohnehin passiert;
- **der Zustand wird aus den echten Daten abgeleitet, nicht aus Merkern.** Ein Merker, der behauptet, was noch zu tun sei, läuft der Wirklichkeit hinterher, sobald jemand seinen Beruf auf einem anderen Weg einträgt. Nebenbei beantwortet sich damit die offene Frage „kontoweit oder pro Charakter?“ von selbst: Spec, Berufe und Ausrüstung gelten pro Charakter, also sieht ein frischer Twink die Liste und ein fertiger Charakter nicht. Gespeichert wird nur, was sich aus den Daten nicht ablesen lässt – Übersprungenes, Ausgeblendetes und zwei einmalige Ereignisse. Es gibt dafür keinen Sendeweg;
- **jeder Schritt ist einzeln überspringbar, die ganze Karte jederzeit abbrechbar** (`×` für diese Sitzung, „Nicht mehr anzeigen“ dauerhaft). **Übersprungen heißt „nicht drängeln“, nicht „nicht wahrnehmen“:** Passiert die echte Aktion später doch, gewinnt sie und die Zeile steht auf erledigt;
- **„Einrichtung“ oben rechts im Fensterkopf** holt die Liste jederzeit zurück – auch nach „Nicht mehr anzeigen“ und auch, wenn längst alles erledigt ist. Der Knopf fängt sie neu an, statt sie nur einzublenden: Wer sie ausdrücklich aufruft, will sie durchgehen, und eine Liste aus lauter übersprungenen Zeilen wäre dafür nutzlos. Ein eigener Navigationspunkt kam nicht in Frage, die Seitenleiste hat keine Bildlaufleiste und ist voll;
- **beim ersten Login je Charakter öffnet sich das Fenster einmal von selbst.** Der Merker wird beim tatsächlichen Öffnen gesetzt und nicht davor – dadurch kann es nie zweimal aufspringen, und ein Login mitten im Kampf verschiebt es auf das nächste Mal, statt es zu verbrauchen. Wer sein Profil längst bestätigt hat, wird gar nicht erst behelligt;
- **die Zustandszeichen sind Texturen, keine Schriftzeichen.** Die Spielschrift kennt weder Haken noch Pfeil und zeichnet dafür leere Kästen – dieselbe Lektion wie bei der Profilbestätigung in 0.9.39. `tests/validate.mjs` hält Haken, Pfeil und Kreis aus der Karte heraus;
- **die Karten darunter wandern mit.** Die Checkliste kommt und geht, alle Karten der Profilseite verschieben sich um denselben Betrag – ihre Maße stehen deshalb in einer Tabelle statt verstreut im Aufbau, und `tests/validate.mjs` prüft sie wie die Einstellungsseite auf Überlappung. Genau der Fehler aus 0.9.44, nur eine Seite weiter.

Dazu ein zweiter Fund aus derselben Karte:

- **„geändert“ heißt wieder „unbestätigt“.** Der Haken der letzten Bestätigung blieb stehen, auch wenn Spec, Dual-Spec, Main/Twink oder „flexibel“ längst umgestellt waren – gespeichert und gildenweit geteilt war aber weiter der zuletzt bestätigte Stand. Weicht die Auswahl davon ab, weicht der Haken jetzt einem Hinweis, der genau das sagt. Verglichen wird gegen dieselben Werte, mit denen die Karte auch vorbelegt wird, sonst gälte ein frisch aufgeschlagenes Profil schon als geändert;
- **die Schalter frischen die Karte auf.** „Main“, „Twink“ und „flexibel einsetzbar“ änderten bisher nur eine Variable; die Rückmeldung daneben blieb bis zum nächsten Seitenwechsel auf dem alten Stand;
- **die Rückmeldung steht über dem Knopf statt daneben.** Neben ihm blieb eine 210 Pixel schmale Spalte, die über den Kartenrand hinausragte und in der jeder erklärende Satz abgeschnitten wurde – ausgerechnet der Fehlschlag, der sagen muss, was zu tun ist.

Drei Regressionstests halten das fest, jeder gegengeprüft, indem die zugehörige Sperre absichtlich entfernt wurde: Erledigt überstimmt Übersprungen, eine geänderte Auswahl nimmt den Haken weg, und der Scrollbereich wächst mit der Checkliste. Beim Schreiben der Tests fiel nebenbei auf, dass sich der zweite Schritt im Spiel meist mit dem ersten erledigt: `Confirm` ruft `Refresh`, und `Refresh` liest die WoW-Berufe ein. Das ist richtig so – im Test steht die automatische Übernahme deshalb ausdrücklich still, damit jeder Übergang einzeln geprüft wird.

Die Testbasis selbst hat gefehlt: Auf dem Entwicklungsrechner war kein Node und kein Lua mehr vorhanden. `tests/smoke.lua` lief über eine portable Node-Fassung und **fengari**, wie in `docs/TODO-naechste-sitzung.md` beschrieben – die Lua-5.1-Ergänzungen (`unpack`, `loadstring`) gehören dabei in den Runner und nicht in `smoke.lua`, sonst verfälschen sie den echten Zielinterpreter.

## 0.9.44 – Der Rückholknopf lag auf der Beschriftung

- **„Symbol zurück an die Minimap" bekommt eine eigene Zeile.** In 0.9.43 stand er neben dem Schalter „Minimap-Symbol anzeigen" – und damit mitten auf dessen Beschriftung, weil rechts daneben schon die Profilbestätigung sitzt. Die Karte „Benachrichtigungen & Zugriff" ist dafür 36 Pixel höher geworden, alle Karten darunter sind mitgewandert;
- **`tests/validate.mjs` prüft die Einstellungsseite jetzt auf Überlappungen**, nicht mehr nur auf die Gesamthöhe. Genau dieser Fehler – eine Karte wächst, die darunter bleibt stehen – fällt sonst erst im Spiel auf. Gegengeprüft, indem eine Karte absichtlich zurückgeschoben wurde;
- neben dem Knopf steht jetzt, was das Ziehen überhaupt kann: nahe der Minimap am Ring entlang, weiter weg überall hin. Vorher stand das nur im Tooltip des Symbols selbst – also genau dort, wo es niemand sucht, der das Symbol gerade nicht findet.

## 0.9.43 – Das Minimap-Symbol darf endlich weg von der Minimap

- **frei platzierbar statt nur auf dem Ring.** Bisher fuhr das Symbol beim Ziehen ausschließlich im Kreis um die Minimap. Jetzt entscheidet die Bewegung selbst: Wer in der Nähe bleibt, fährt wie gewohnt am Ring entlang; wer weiter als 130 Pixel wegzieht, löst es ab und legt es hin, wo er will. Kein Schalter, kein Menü – der Abstand zum Ring ist bewusst deutlich größer als der Ring selbst (78), damit ein Verrutschen beim Ausrichten nichts ablöst;
- frei gesetzt hängt das Symbol an `UIParent` statt an der Minimap. Sonst gälten die gespeicherten Koordinaten im Maßstab der Minimap, und bei abweichender Skalierung läge es woanders. Gerechnet wird durchgehend in UIParent-Einheiten: `GetCursorPosition` liefert Bildschirmpixel, `GetCenter` dagegen Koordinaten im Maßstab des jeweiligen Rahmens – wer beides ungerechnet vergleicht, misst Unsinn;
- **„Symbol zurück an die Minimap"** in den Einstellungen. Wer es hinter einem anderen Fenster oder am Bildschirmrand ablegt, kommt sonst nicht mehr heran. Der Knopf ist nur bedienbar, wenn das Symbol tatsächlich frei steht und sichtbar ist;
- ein Regressionstest zieht das Symbol durch alle drei Zustände – am Ring, abgelöst, wieder eingerastet – und prüft den Rückweg. Er wurde gegengeprüft, indem die Ablösung absichtlich abgeschaltet wurde.

## 0.9.42 – Ruckler beim Ein- und Ausloggen

Aus der Gilde gemeldet: Es ruckelt, wenn viele Leute gleichzeitig ein- und ausloggen; vermutet wurde die Synchronisierung. Die Vermutung war falsch – die Ursache lag lokal, noch bevor eine einzige Addon-Nachricht im Spiel ist.

- **der Roster-Scan sammelt jetzt.** `GUILD_ROSTER_UPDATE` feuert bei jedem Ein- und Ausloggen eines beliebigen Gildenmitglieds und zusätzlich, sobald irgendein anderes Addon `GuildRoster()` ruft. Jedes Mal wurden alle Mitglieder neu eingelesen, für jedes Offline-Mitglied zusätzlich die letzte Onlinezeit. Zehn Ereignisse in drei Sekunden ergeben jetzt einen Scan;
- **gezeichnet wird nur die aufgeschlagene Seite.** `GC.UI:Refresh` baute alle dreizehn Seiten neu auf – Werkstatt, Raidauswertung, Ausrüstung, alles –, und zwar auch **bei geschlossenem Fenster**. Rund 1100 Schleifendurchläufe je Ereignis, für niemanden sichtbar. Die übrigen Seiten merken sich jetzt, dass sie veraltet sind, und holen es beim Aufschlagen nach; die Daten liegen ohnehin in der Datenbank;
- dasselbe gilt für die Rückmeldungen aus der Synchronisierung: Ein eingehendes Profil zog vorher vier Seiten nach sich, ein Gildenprofil sieben. Bei einer Login-Welle summierte sich das, ohne dass jemand hinsah;
- **große Übertragungen pausieren im Kampf.** Werkstattkataloge und Gildenbankbestände sind die einzigen wirklich großen Pakete; im Bosskampf haben sie nichts verloren. Die Warteschlange bleibt stehen und läuft danach weiter, verworfen wird nichts. Handshakes, Profile und Raidauswertungen laufen bewusst nicht darüber – sie sind wenige Bytes und teils zeitkritisch;
- **`/gcp debug` misst mit.** Einschalten, eine Weile spielen, erneut aufrufen: Dann stehen die schlimmsten Einzelmessungen im Chat. Standardmäßig aus, und ausgeschaltet kostet die Messung einen Tabellenzugriff. Gemessen wird mit `debugprofilestop()`, weil es das in jeder Spielfassung gibt;
- die Streuung der Handshake-Antworten war entgegen der ersten Vermutung längst vorhanden (0,5–4,5 s für die Versionsantwort, für das Profil abhängig von der Zahl bekannter Nutzer) und blieb deshalb unverändert;
- drei Regressionstests halten das fest: fünf Rosterereignisse ergeben einen Scan, eine unsichtbare Seite wird nicht gezeichnet, und im Kampf geht kein großes Paket raus. Alle drei wurden gegengeprüft, indem die jeweilige Sperre absichtlich entfernt wurde – ohne sie schlagen sie fehl;
- **die Kachel „Mit Addon“ läuft nicht mehr aus dem Fenster.** Ihre Beschriftung hatte keine feste Breite, und eine FontString ohne Breite wächst einfach weiter: „MIT ADDON • 20 CHARAKTERE • 4 ABWEICHEND“ stand quer über dem halben Bildschirm. Die Überschrift bleibt jetzt kurz, der Zusatz steht in einer eigenen, ebenfalls begrenzten Zeile – ausgeschrieben stand er ohnehin schon in der Titelzeile und im Tooltip. Der Test prüft die Breitengrenze aller vier Kacheln.

## 0.9.41 – Eigene Trigger-Wörter, ein Ton je Rang und der Raidabend aus der Logdatei

- **der Knopf im Blizzard-Gildenfenster ist ersatzlos weg.** Er lag auf `HIGH`-Strata über allem, ließ sich nicht verschieben und verdeckte Inhalte. Es bleiben genug Aufrufwege: `/gcp`, das Minimap-Symbol und die Addon-Optionsseite. Eine Prüfung in `tests/validate.mjs` hält ihn draußen;
- **Trigger- und Ausschlusswörter fürs Postfach sind einstellbar.** Bisher war fest verdrahtet, wodurch jemand im Postfach landet. Öffentlicher Chat und Flüstern bleiben getrennt, weil die Fehlerkosten verschieden sind: Ein zu weiter Whisper-Trigger nervt nur einen selbst, ein zu weiter Chat-Trigger erzeugt Müll aus dem ganzen Realm. Ein **Ausschlusswort** verhindert den Eintrag auch dann, wenn ein Trigger passt – es holt aber niemanden aus dem Postfach, der schon drinsteht, sonst fehlte ausgerechnet die Nachricht, die zufällig ein Ausschlusswort enthält;
- ein **leeres Trigger-Feld bedeutet „Vorgabe"**, nicht „nichts" und erst recht nicht „alles". Wer die Erkennung abschalten will, nimmt die Schalter darüber. Dadurch ist die Vorgabe mit einem leeren Feld wiederherstellbar, ohne eine Kopie zu hinterlassen, die bei einer späteren Änderung der Vorgabe veraltet wäre. Ein Knopf trägt die Vorgabe zum Bearbeiten ein, damit man sie für ein zusätzliches Wort nicht abtippen muss. Die Listen sind persönlich, wie die beiden Schalter daneben;
- **der Bewerberton hängt am Gildenrang.** Wer nicht rekrutiert, will ihn nicht hören – weiß aber meist nicht, dass er ihn abschalten könnte. Deshalb entscheidet der Rang und nicht jeder für sich; die Freigabe wird gildenweit synchronisiert und hängt als Feld am Ende der Gildenprofil-Nutzlast, sodass ältere Clients die Nachricht weiter lesen. Erfasst wird weiter für alle, nur still: Wer später ins Postfach sieht, hat nichts verpasst. Ist der eigene Rang unbekannt, kommt der Ton – ein Ton zu viel ist verzeihlicher als der eine verpasste Bewerber;
- **Offline-Import aus `WoWCombatLog.txt`.** Ein Raidabend ist nicht mehr verloren, nur weil niemand „Sitzung starten" gedrückt hat. Der Installer liest die Datei streamend (46 MB in der Testinstallation), erkennt `ENCOUNTER_START`/`ENCOUNTER_END` samt übersetztem Bossnamen und zählt genau das, was die Livesitzung auch zählt. Kein Upload, keine Zugangsdaten; die Datei bleibt lokal. Sie wird als eigene Quelle **Combat Log** abgelegt und nie mit Live- oder Warcraft-Logs-Zahlen verrechnet;
- gegen die echte Datei gemessen und dabei dreimal korrigiert: **Wiederbelebungen** zählen nur über `SPELL_RESURRECT`, nicht zusätzlich über den gewirkten Zauber (sonst 47 statt 24 bei nur 39 Spielertoden); **Teilnehmer ohne Anwesenheit im Bosskampf** fallen heraus (elf Umstehende, die sich in Reichweite selbst gebufft hatten, standen neben 26 echten Teilnehmern); **`COMBATANT_INFO`** wird eigens behandelt, weil die Zeile kein Namensfeld hat – wer sie wie ein gewöhnliches Ereignis liest, bekommt einen Teilnehmer namens „0". Als Anwesenheitsbeleg ist sie dafür die beste Quelle, sie erscheint beim Pull für jedes Raidmitglied;
- fehlt einem Versuch die Schlusszeile, gilt er als Wipe. In der Testdatei stehen vier `ENCOUNTER_START`, aber nur drei `ENCOUNTER_END` – ohne diesen Abschluss hätte der Abend vier Versuche bei drei Ergebnissen;
- **die Zone kommt aus den Bossnamen.** Der Combat Log nennt keine, die Zuordnung Boss zu Instanz gibt es im Addon aber schon (`GC.RaidBosses`). So bleibt sie an einer Stelle gepflegt, statt im Installer ein zweites Mal;
- **ein Raidabend steht einmal in der Liste, nicht dreimal.** Derselbe Abend kann aus Livesitzung, Warcraft Logs und Logdatei kommen. Als Fingerabdruck taugt kein Hash aus den Teilnehmern – jede Quelle zieht die Liste anders und ein exakter Vergleich schlüge genau dann fehl, wenn er gebraucht wird. Entschieden wird über überschneidende Zeiträume **und** eine Teilnehmerdeckung von mindestens der Hälfte. Angezeigt wird die vollständigste Auswertung; die übrigen Quellen bleiben gespeichert und stehen als Knöpfe in der Kopfzeile der Teilnehmerkarte.

## 0.9.40 – „Twink“ statt „Alt“

*(Dieser Abschnitt fehlte und ist mit 0.9.45 aus dem Commit nachgetragen – deshalb ist er kürzer als seine Nachbarn.)*

- **im Profil und in der Gildenübersicht heißt es „Twink“**, nicht mehr „Alt“ – so nennt es die Gilde auch. Betroffen sind der Schalter neben „Main“ und die Statusspalte der Übersicht;
- **gespeichert und übertragen wird weiterhin `ALT`.** Die Beschriftung ist eine Anzeigefrage; wer den gespeicherten Wert mitumbenennt, sorgt dafür, dass alte und neue Clients sich beim Abgleich nicht mehr verstehen. Der Kommentar an der Stelle sagt genau das, damit es beim nächsten Umbenennen nicht doch passiert;
- `docs/TODO-naechste-sitzung.md` kam dazu und hält die offenen Punkte so fest, dass ein einzelner Prompt genügt: je Aufgabe die betroffenen Dateien, die Zeilennummern und die noch offenen Entscheidungen. Abgearbeitet wurden daraus der Knopf im Gildenfenster, die Trigger-Wörter und der Offline-Import (alle 0.9.41) sowie der Onboarding-Wizard (0.9.45).

## 0.9.39 – Postfach mit Uhrzeit, Realm und Haken statt Datum

- **die Empfangszeit steht jetzt am Eintrag.** Sie war längst gespeichert, aber nirgends zu sehen – dabei entscheidet sie mit, ob sich eine Antwort noch lohnt. Heutige Nachrichten zeigen nur die Uhrzeit, ältere Datum und Uhrzeit; das Jahr steht dabei nur im Weg;
- **kanonische Realm-Zuordnung.** Ein Name ohne Realm meint immer den eigenen – nur wusste das die Deduplizierung nicht. Sie verglich Kurznamen und legte deshalb „Doppel" und „Doppel-Fremdrealm" zusammen, also zwei verschiedene Spieler. Jetzt werden beide Namen erst auf dieselbe Schreibweise gebracht: „Doppel" und „Doppel-Aegwynn" sind auf Aegwynn derselbe, „Doppel" und „Doppel-Frostwolf" nicht. Ein Regressionstest bildet genau diesen Fall ab;
- die **Ignorierliste** war entgegen der bisherigen Notiz längst vollständig da – zeitlich begrenzt oder dauerhaft, einsehbar, mit „Wieder zulassen", und abgelaufene Einträge räumt sie selbst weg. Sie ist jetzt nur zusätzlich durch einen Test abgesichert;
- **die Profilbestätigung zeigt einen Haken statt eines Datums.** Der Zeitpunkt war neben dem Knopf ohnehin abgeschnitten („Bestätigt am 30.07.2026 um 0…"), und für „das hat geklappt" braucht es keine Worte. Ein Fehlschlag steht weiterhin im Klartext daneben – nur der muss erklären, was zu tun ist. Verwendet wird die WoW-eigene Hakentextur, kein Unicode-Zeichen: Die Spielschrift kennt es nicht und zeichnet leere Kästen.

## 0.9.38 – Essen, Bosse und ein Installer ohne Rückfragen

- **Essen zählt endlich mit.** Alle Sattgegessen-Buffs heißen im Spiel gleich, tragen aber je Gericht eine eigene Spell-ID – live erkennt das Addon sie am Auranamen, aus Warcraft Logs kommen nur IDs, und dort stand Essen deshalb dauerhaft auf null. Zehn Buffs sind jetzt einzeln nachgeschlagen und eingetragen. Bewusst draußen bleiben die reinen `Food`-Auren (33258, 33262, 33264, 33266 – nur Lebensregeneration während des Essens, kein Raidbuff) und das Tierfutter 33272, das ein Jägertier beglückt und keinen Teilnehmer. Beim Nachschlagen entpuppte sich außerdem 33270 als „Check Players" und 43765 als Kochrezept statt als Buff;
- **gepflegte Bossliste für alle neun TBC-Schlachtzüge.** Der Gewinn liegt beim **Wipe**: Dort stirbt der Boss gerade nicht, also hieß der Versuch bisher „Kampf" oder trug den Namen eines Adds – und Wipes sind das, was man hinterher ansieht. Erkannt wird über den **Eigennamen als Teilzeichenkette**: „Prinz Malchezaar" und „Prince Malchezaar" enthalten beide „Malchezaar". Damit trägt die Liste auf deutschen wie englischen Clients, ohne dass für jeden Boss eine belegte Übersetzung nötig wäre – die ließ sich nämlich nicht beschaffen, alle deutschen Bosslisten antworteten mit HTTP 403. Wo ein Boss keinen Eigennamen hat (Der Kurator, Maid der Tugend), stehen beide Sprachfassungen. Trifft nichts, bleibt es bei der bisherigen Heuristik;
- der Combat Log liefert im Raid tausende Ereignisse, deshalb prüft die Erkennung **nur, solange der Boss noch nicht feststeht**, und merkt sich abgewiesene Namen. Ist der Boss erkannt, kostet der Rest des Kampfes nichts mehr;
- **die Profilbestätigung bleibt sichtbar.** Erfolg und Fehler standen nur im Chat und waren nach ein paar Kampfmeldungen weggescrollt; wer nebenher etwas anderes tat, wusste hinterher nicht, ob sein Profil steht. Jetzt steht das Ergebnis samt Zeitpunkt am Profil. Dazu ein eigener Ton – der **Stufenaufstieg** (SoundKit 888) –, damit die Rückmeldung auf die eigene Eingabe nicht klingt wie die Meldung über einen fremden Interessenten.

### Installer 1.0.4

- **eigenes Dateisymbol** im Explorer, erzeugt aus dem Logo in sieben Größen von 16 bis 256 Pixeln. Eine einzelne Größe hätte Windows sichtbar hochskaliert;
- **„Nach Updates suchen" steht vorn und ist hervorgehoben**, „Neu installieren" tritt zurück: Der eine Knopf wird ständig gebraucht, der andere selten;
- **ein gefundenes Update wird sofort eingespielt** – ohne zweite Rückfrage, denn wer danach sucht, will es auch haben. Eine **Rückstufung** auf eine ältere Fassung im Repository bleibt ausdrücklich davon ausgenommen und weiter Handarbeit;
- **beim Öffnen wird immer aktualisiert.** Der Haken „Beim Öffnen automatisch aktualisieren" ist entfernt – er war nur eine Gelegenheit, veraltet zu bleiben. Beide Wege entscheiden jetzt über dieselbe Stelle, statt die Frage doppelt zu beantworten;
- die README erklärt jetzt, **warum Windows beim Herunterladen warnt** (die `.exe` ist nicht code-signiert, dazu Mark of the Web und SmartScreen), was ein Zertifikat kosten würde und warum ein selbst ausgestelltes nichts hilft. Dazu die SHA-256-Prüfsumme zum Vergleichen. Abschalten lässt sich die Warnung nicht – und SmartScreen auszuschalten wäre keine Lösung, sondern nur der Verzicht auf eine Prüfung, die auch anderswo nützt.

## 0.9.37 – Der Regelsatz ist nicht mehr leer

Seit 0.6 stand im Gear Audit dieselbe Lücke: Die Enchant-IDs müssten „aus einer belegbaren Quelle" kommen, und wowtbc.gg wie Wowhead antworteten auf Skriptabrufe mit HTTP 403. Beides gilt weiter – aber nicht für einen Abruf, der die Seite wie ein Leser holt.

- **49 Enchant-IDs, jede einzeln nachgeschlagen.** Genommen wird die Zahl aus der Wowhead-Zeile „Enchant Item: … (ID)": genau das, was auch im Item-Link steht. Geraten wurde nichts, und das war nötig – von den aus dem Gedächtnis angenommenen Spell-IDs waren mehrere falsch (27906 ist nicht Assault, sondern Major Defense; 33993 nicht Superior Agility, sondern Blasting; 27946 nicht Major Stamina, sondern Shield Block). Jede davon hätte still falsch bewertet;
- **welche Verzauberung für wen gut ist, stammt aus den BiS-Listen von wowtbc.gg** – abgefragt über neun Specs, nicht über eine. Das war der Unterschied: Erst der Schutz-Paladin zeigte, dass ein Tank auf **Zaubermacht** verzaubert, und erst der Jäger brachte den Distanz-Slot ins Spiel. Aus einer einzelnen Spec wäre ein Regelsatz entstanden, der die halbe Gilde falsch bewertet;
- **bewertet wird nach Archetyp, nicht nach Rolle.** Schattenpriester und Schurke sind beide `DAMAGER`; die Rolle taugt deshalb nicht als Maßstab. Unterschieden werden Zauber-Schaden, Heilung, physischer Schaden und Tank. Schutz-Paladine tragen beide Kennzeichen, Wildheits-Druiden ebenfalls;
- **eine Regel, die nicht passt, gilt nicht.** Anderer Slot, anderer Archetyp, spätere Phase: Dann wird die Verzauberung behandelt, als stünde sie nirgends – nie als schlecht. Vorher lieferte ein Slot-Fehltreffer ein hartes „Unbekannt", was auf der Ausrüstungsseite wie ein Fund aussah;
- **eine Enchant-ID hängt am Effekt, nicht am Ausrüstungsplatz:** `2649` ist „+12 Ausdauer" und sitzt sowohl auf Handgelenken als auch auf Stiefeln. Regeln führen deshalb alle Slots, auf denen ihr Effekt vorkommt;
- **Content-Phase je Gilde** (T4 bis T6.5, Vorgabe T5, `/gcp phase`): Jede Regel nennt die Phase, ab der es sie überhaupt gibt. Was noch nicht existiert, wird nicht eingefordert. Die Phase hängt additiv als Feld 25 am Gildenprofil; ein älterer Client ohne dieses Feld dreht sie nicht zurück;
- **Ausnahmen für Farmgear, Widerstandssets und Encounter-Sets** (Rechtsklick auf die eigene Slotzeile). Der Platz bleibt sichtbar und zählt nicht als Fund. Sie wandern mit dem Snapshot zu den anderen, aber nur als **freiwilliges sechstes Feld**: Der Empfang prüft die Feldzahl streng, deshalb bleibt ein Paket ohne Ausnahmen unverändert fünffeldrig und für ältere Clients lesbar. Ist das Feld da, muss es stimmen – ein unlesbarer Eintrag lässt das ganze Paket durchfallen, statt halb übernommen zu werden.

Bekannte Lücke: Die **Aldor**-Schulterinschriften (Vengeance, Faith, Discipline) ließen sich nicht belegen; nur die Scryer-Gegenstücke (Blade, Oracle, Orb) und die rangunabhängige Inschrift des Ritters stehen im Satz. Aldor-Inschriften werden deshalb nicht falsch bewertet, sondern gar nicht – sie gelten als unbewertet und damit als in Ordnung, und ein Klick stuft sie gildenweit ein.

## 0.9.36 – Spieler zählen statt Charaktere

Die Kachel **MIT ADDON** und die Kopfzeile zählten Charaktere: wer mit Main und zwei Twinks unterwegs war, erschien als drei Nutzer.

- WoW verrät Addons **grundsätzlich nicht**, welche Charaktere zu einem Account gehören – es gibt keine Account-ID in der API. Der Client kennt aber seinen eigenen Account, weil die SavedVariables dort liegen. Er würfelt deshalb beim ersten Start ein **anonymes Kennzeichen** (zehn Zufallszeichen, keine Account-Daten) und nennt es im Handshake mit; gleiche Kennzeichen sind derselbe Spieler;
- Kachel und Kopfzeile nennen jetzt die **Spielerzahl** als Hauptzahl und die Charakterzahl nur daneben, solange sie abweicht („4 Nutzer (5 Chars), alle synchron“); die Tooltips erklären beides;
- ein Charakter **ohne** gemeldetes Kennzeichen zählt weiter einzeln – lieber eine Zahl zu hoch als fremde Spieler fälschlich zusammenlegen. Ältere Clients senden das Feld nicht und werden dadurch nicht falsch dargestellt;
- das Feld hängt additiv am Ende des Handshakes, ältere Clients ignorieren es;
- **bewusst unverändert:** die Kachel **MITGLIEDER** zählt weiter Charaktere. Für Mitglieder ohne das Addon gibt es kein Account-Signal, das kein Addon erfinden kann; eine gruppierte Zahl dort wäre eine Schätzung, die wie eine Wahrheit aussieht. Auch die Gildenwerkstatt führt weiter einzelne Hersteller – dort ist die Zusammenfassung nicht hilfreich, weil es darauf ankommt, *welcher* Charakter etwas herstellen kann.

## 0.9.35 – Ein /reload kostet ein Paket statt achtzig

Jeder Login und jedes `/reload` loeste einen vollen Werkstattversand aus – rund 80 Pakete, obwohl sich nichts geaendert hatte. Die mit 0.9.31 eingefuehrte Manifest-Logik griff in der Praxis nie:

- ob der volle Bestand noetig ist, entschied eine **gildenweite Vermutung**: fehlte *irgendeinem* gespeicherten Addon-Nutzer die Faehigkeit `workshop4`, ging an alle der komplette Bestand. Gespeicherte Faehigkeiten sind aber bis zu 30 Tage alt – ein Mitglied, das zuletzt mit einer aelteren Fassung online war, liess damit **jeden** Abgleich zum Vollversand werden, dauerhaft;
- die Entscheidung faellt jetzt **am Fragenden**: wer Manifeste versteht, bekommt ein Manifest (ein Paket) und fordert daraus gezielt an, was ihm fehlt. Nur ein Client ohne Manifest-Verstaendnis erhaelt den vollen Bestand, und zwar wenn er selbst danach fragt;
- **Login und `/reload` senden ausschliesslich das Manifest.** Der volle Bestand ist dort nie noetig, weil jeder Client beim eigenen Start ohnehin nachfragt;
- der Vollversand verlangt jetzt ein ausdrueckliches Kennzeichen, statt aus einer Vermutung zu entstehen; Regressionstests belegen die Kosten beider Wege.

## 0.9.34 – Scrollstand bleibt stehen, Spalten mit Luft

- **Bugfix:** der Detailbereich sprang beim Lesen dauernd nach oben. Der Scrollstand wurde bei *jedem* Refresh zurückgesetzt, und während einer laufenden Synchronisierung löst jedes eingehende Paket einen Refresh aus. Zurückgesetzt wird er jetzt nur noch beim Wechsel auf ein anderes Rezept;
- die Zahlenspalten klebten am rechten Rand direkt an der Scrollleiste; sie haben jetzt Abstand, ebenso die Fließtexte darunter;
- die Spaltenüberschrift heißt wieder **GBank** statt „Bank“.

## 0.9.33 – Mehr Platz für die Rezeptdetails

- die Rezeptdetails sind **60 px breiter**, die Rezeptliste entsprechend schmaler: die Materialspalten und der Fehlt-Text hatten in der engen Spalte zu wenig Raum;
- damit die Rezeptnamen in der Liste dabei nicht verlieren, entfällt die **Berufsangabe je Zeile, solange nach einem Beruf gefiltert wird** – sie steht dann schon in der Kartenüberschrift und kostete nur Platz;
- **Bugfix:** ein langer „Dir fehlt“-Text wurde abgeschnitten („…Kristallphio..“). `GetStringHeight` liefert je nach Zeitpunkt nur die Höhe einer Zeile; die Zeilenzahl wird jetzt zusätzlich aus der Zeichenzahl abgeschätzt und das Größere genommen. Zu viel Platz ist harmlos, zu wenig schneidet Inhalt ab – das betrifft auch den Kopfbereich mit langen Herstellerlisten;
- Materialnamen dürfen 28 statt 20 Zeichen tragen, bevor sie gekürzt werden.

## 0.9.32 – Materialanzeige aufgeräumt

Die neue Materialanzeige war gedrängt und die Spalten ausgefranst. Ursache war ein Denkfehler: die Spalten wurden mit Leerzeichen in einem Textblock gesetzt – in der proportionalen Spielschrift kann das keine Spalte ergeben.

- die Materialien stehen jetzt in **echten Zeilen mit festen Spalten** (Name, „Du“, „Bank“) statt in einem formatierten Textblock; die Zahlen stehen damit sauber untereinander;
- **nur die Zahlen tragen Farbe**, nicht mehr die ganze Zeile. Fehlt alles, entstand vorher eine Wand aus Rot, in der nichts mehr heraussticht; jetzt bleibt der Name lesbar und die Farbe ist wieder ein Signal;
- Zusammenfassung („Dir fehlt …“) und Herkunftszeilen sind mit Abstand abgesetzt und wachsen mit ihrer tatsächlichen Texthöhe, statt an fester Höhe zu kleben;
- die Fußzeile mit Alter und Einleser der Bestände ist gedämpft: sie ist Beiwerk, keine Kernaussage;
- **Bugfix:** die Beschriftung „Gemerkt“ wurde im Favoritenknopf abgeschnitten („Gemer…“); der Knopf ist jetzt breit genug;
- ohne Suchumfang bleiben keine Materialzeilen eines vorher gewählten Rezepts stehen.

## 0.9.31 – Materialbestand, Gildenbank und ein schlankerer Login

Die Werkstatt beantwortete „wer kann das herstellen?“, aber nicht „habe ich die Materialien?“.

- **Eigene Bestände** werden gezählt: Taschen laufend, die eigene Bank bei jedem Öffnen des Bankfensters (anders ist sie technisch nicht lesbar) – und die Bestände der **eigenen Twinks** zählen mit, weil sie längst in derselben SavedVariables liegen. Diese Daten verlassen den Account nie; für sie existiert bewusst kein Sendeweg;
- **die Gildenbank** wird beim Besuch am Bankfach je Tab eingelesen und gildenweit geteilt. Bewusst **je Tab und nicht als Ganzes**: welche Tabs ein Mitglied sehen darf, hängt am Gildenrang – ein rangbeschränkter Snapshot darf den vollständigen eines Offiziers nicht überschreiben. Zeitstempel und Fingerabdruck gelten deshalb pro Tab, die aktuellsten Daten gewinnen rangunabhängig, und ein Manifest ohne einen Tab sagt nichts über diesen Tab aus – gelöscht wird nie;
- der Abgleich läuft **Manifest zuerst**: gesendet werden nur Tab, Zeitstempel und Fingerabdruck (ein Paket). Die eigentlichen Bestände gehen erst raus, wenn jemand nachweislich einen älteren Stand hat und danach fragt – gestreut, je Tab nur einmal, und eine fremde Anfrage unterdrückt die eigene;
- **in den Rezeptdetails** steht jetzt je Reagenz Bedarf, eigener Gesamtbestand und Gildenbankbestand mit Ampelfarbe: grün deckt der eigene Bestand, gelb erst zusammen mit der Gildenbank, rot fehlt auch dann. Darunter steht ausdrücklich, was fehlt und wie viel davon die Gildenbank hätte, dazu Alter und Einleser des Gildenbankstands;
- **Datenlast verschlankt, ohne Funktionsverlust:** Der Werkstatt-Login schickte bisher immer die vollen Schlüssellisten aller Account-Berufe (~14 Pakete), auch wenn sich nichts geändert hatte. Jetzt geht zuerst nur ein **Berufs-Manifest** raus (Hersteller, Zeitstempel, Anzahl, Fingerabdruck – in der Regel ein Paket); Schlüssellisten folgen ausschließlich für Berufe, die ein Mitglied nachweislich noch nicht hat. Wer alles kennt, verursacht keinen weiteren Verkehr. Clients ohne `workshop4` erhalten wie bisher den vollen Bestand.

## 0.9.30 – Rezeptkatalog statt hundert Vollkopien

Der Werkstattabgleich skalierte nicht: jeder Hersteller schickte und speicherte eine **vollständige eigene Kopie** aller seiner Rezepte, obwohl Rezeptdaten für alle identisch sind – der Schlüssel *ist* die Item- beziehungsweise Zauber-ID, und die Reagenzien hängen nicht am Spieler. Gemessen mit den echten Addon-Funktionen kostete ein Spieler mit drei vollen Berufen (294 + 405 + 250 Rezepte) **331 Pakete**; bei 100 Mitgliedern wären das **33.100 Pakete und rund 3,2 Stunden** Kanalzeit, dazu ein Vielfaches an SavedVariables für immer dieselben Daten.

- der gildenweite Bestand ist jetzt in zwei Teile getrennt: einen **Rezeptkatalog**, in dem jedes Rezept genau einmal steht, und einen **Herstellerindex**, der nur noch die Schlüssel dessen führt, was wer kann;
- der Regelfall auf dem Kanal ist deshalb die **Schlüsselliste**: nach Typ gruppierte, als Differenzen kodierte IDs. Derselbe Spieler kostet damit **14 statt 331 Pakete**; 100 Mitglieder brauchen **1.717 Pakete und knapp 10 Minuten** statt 3,2 Stunden;
- volle Rezeptdaten gehen nur noch raus, wenn sie wirklich fehlen: kennt ein Client ein gemeldetes Rezept nicht, fordert er **genau dieses** beim Hersteller nach. Die Anfrage läuft gestreut, wird pro Rezept nur einmal gestellt und entfällt, wenn ein anderer sie schon gestellt hat oder das Rezept zwischenzeitlich eintrifft;
- ein noch nicht nachgeliefertes Rezept verschwindet trotzdem nicht: Name und Beruf löst jeder Client aus der Item- beziehungsweise Zauber-ID selbst auf, allein die Reagenzien bleiben leer, bis die Nachlieferung da ist;
- **ausgetretene Mitglieder verschwinden mit ihren Rezepten.** Bisher wurden Hersteller erst nach 180 Tagen entfernt und die Gildenmitgliedschaft nie geprüft. Der Roster allein reicht als Maßstab aber nicht, weil Twinks nie im Gildenroster stehen und ihre Berufe seit 0.9.26 bewusst geteilt werden: ein Eintrag fällt deshalb nur, wenn weder der Hersteller selbst noch das Gildenmitglied, das ihn eingebracht hat, noch im Roster steht. Rezepte, die danach niemand mehr kann, verlassen auch den Katalog;
- Bestandsdaten werden beim ersten Laden automatisch in Katalog und Index überführt; Clients ohne diese Fassung melden sich im Handshake weiterhin ohne `workshop4` und erhalten solange die vollen Rezeptdaten, damit sie nichts verlieren.

## 0.9.29 – Armory-Pfad an die echte Seite angepasst

- der Armory-Link führt jetzt auf das tatsächliche Pfadschema von classic-armory.org, das die Spielfassung als eigenes Segment kennt: `…/character/eu/tbc-anniversary/<realm>/<name>`. Das Schema war bei der Umsetzung von 0.9.28 nicht maschinell prüfbar, weil die Seite automatisierte Abrufe mit HTTP 403 abweist; die Vorlage lag deshalb als Konstante bereit und musste nur an einer Stelle korrigiert werden. Der Warcraft-Logs-Link war bereits richtig.

## 0.9.28 – Interessenten auf einen Blick und geteilte Warcraft-Logs-Quelle

- Interessenten im **Postfach** erscheinen links und im Kopf der Unterhaltung in ihrer **Klassenfarbe**, im Kopf zusätzlich mit dem Klassennamen; die Klasse stammt aus der ohnehin erfassten GUID des Absenders, es braucht also keine neue Datenerhebung. Bereits gespeicherte Interessenten werden beim Öffnen des Postfachs nachträglich eingefärbt, sobald der Namens-Cache des Clients ihre GUID kennt; ohne auflösbare GUID bleibt der Name neutral statt falsch gefärbt;
- zwei **kopierbare Profil-Links** je Interessent (classic-armory.org und Warcraft Logs) stehen direkt in der Unterhaltung: hineinklicken markiert den ganzen Link, Strg+C kopiert ihn. Ein WoW-Addon darf weder einen Browser öffnen noch in die Zwischenablage schreiben, deshalb sind es bewusst Textfelder; Tippen stellt den vollständigen Link wieder her. Region und Realm kommen aus der gespeicherten Gildenquelle, ein Realm am Spielernamen hat Vorrang;
- die **Stufe** eines Interessenten bleibt bewusst ausgelassen: aus einer GUID liefert keine API ein Level, und der einzig saubere Weg (eine `/who`-Abfrage) ist serverseitig gedrosselt, funktioniert nur bei online befindlichen Spielern und würde mit manuellen `/who`-Abfragen des Nutzers kollidieren. Datenmodell und Anzeige sind vorbereitet, sodass eine Stufe erscheint, sobald sie verlässlich zu beschaffen ist;
- **Bugfix:** ein selbst eingetragener Warcraft-Logs-Host bleibt erhalten. Bisher wurde jede Eingabe auf `fresh.warcraftlogs.com` normalisiert, sodass eine gespeicherte Quelle wie `de.fresh.warcraftlogs.com` ihre Sprachvariante beim Speichern verlor;
- die **Warcraft-Logs-Gildenquelle wird gildenweit synchronisiert** (additives Feld im Gildenprofil-Paket, rangunabhängig, neueste Daten gewinnen): nur ein Mitglied muss sie pflegen, danach funktionieren die Profil-Links bei allen. Ein Paket ohne dieses Feld – etwa von einem älteren Client – löscht eine vorhandene Quelle nicht;
- die Karte **Gildenquelle** erklärt jetzt selbst, warum die URL dort steht, obwohl der Import von Hand kommt: ein WoW-Addon darf nichts aus dem Netz laden, der Windows-Helfer übernimmt den Abruf, und die gespeicherte Gilde erspart dort die Eingabe, liefert Region und Realm für die Profil-Links und gilt für die ganze Gilde;
- der **Status** der Warcraft-Logs-Seite nennt Stand und Herkunft des Datensatzes („zuletzt von …“), sodass ein von einem Gildenmitglied empfangener Stand nicht mehr wie ein eigener Import aussieht; ohne eigene Daten weist der Text darauf hin, dass ein Import eines anderen Mitglieds von selbst hier erscheint.

## 0.9.27 – Zwei stille Paketfresser beseitigt

- das Nutzlast-Budget jedes Werkstattpakets richtet sich jetzt nach dem echten 255-Byte-Chatlimit abzüglich der vollständigen Kopfzeile: bei langen Berufsnamen (z. B. „Ingenieurskunst“, „Juwelenschleifen“) und dem seit 0.9.26 angehängten Herstellernamen überschritten viele Pakete das Limit und wurden vor dem Senden kommentarlos verworfen – der Transfer blieb beim Empfänger für immer unvollständig („X Pakete konnten nicht gesendet werden“);
- der Anniversary-Client meldet Sendeergebnisse als Enum (0 = Erfolg, 3/8 = gedrosselt); bisher galt jede Enum-Antwort als Erfolg, wodurch vom Client gedrosselte Pakete lautlos verloren gingen, ohne dass eine Wiederholung anlief – jetzt zählt nur ein echter Erfolg als gesendet, alles andere wiederholt der Backoff;
- Regressionstests belegen, dass Pakete mit langen Berufs- und Herstellernamen das Chatlimit einhalten und vollständig ankommen und dass Drossel-Antworten des Clients als Fehlschlag behandelt werden.

## 0.9.26 – Gildenkanal als Standardweg und Twinks mitteilen

- der Werkstatt-Abgleich läuft jetzt grundsätzlich über den schnellen, zuverlässigen **Gildenkanal** statt über Flüsternachrichten; in Umgebungen, in denen Addon-Flüster den Empfänger nicht erreichen, kommt der Abgleich damit trotzdem zustande;
- ein eingeloggter Charakter teilt der Gilde jetzt **alle Berufe seines gesamten Accounts** – auch die seiner Twinks aus dem lokalen Cache –, ohne dass man auf dem jeweiligen Twink eingeloggt sein muss;
- jedes Rezeptpaket trägt den tatsächlichen **Herstellernamen**, sodass die Berufe der Twinks beim Empfänger dem richtigen Charakter zugeordnet werden statt dem gerade sendenden; ältere Clients ignorieren das Feld und ordnen wie bisher dem Absender zu;
- beim Login werden die eigenen Account-Berufe zusätzlich aktiv in die Gilde gegeben, damit andere sie erhalten, ohne selbst anzufragen; der Zeitstempel sorgt weiterhin dafür, dass neuere Daten alte ersetzen;
- Regressionstests decken die Zuordnung eines geteilten Twink-Berufs zum richtigen Charakter ab.

## 0.9.25 – Eigene Twinks im Katalog und geduldiger Gildenkanal

- die Gildenwerkstatt zeigt jetzt auch die Berufe der **anderen eigenen Charaktere desselben Accounts**: sie liegen längst lokal in der gemeinsamen SavedVariables, also erscheinen sie sofort im Katalog, ohne auf eine Netzwerksynchronisierung zu warten – die Verzauberkunst des Magier-Twinks ist damit auch auf dem Main sichtbar;
- der Gilden-Bulktransfer wiederholt abgelehnte Pakete jetzt mit echtem zeitlichem Abstand statt alle Versuche im selben Frame zu verbrennen; kurzzeitig greifende Client-Ratenlimits führen dadurch nicht mehr zu falsch als „verloren“ gemeldeten Paketen;
- ein Regressionstest belegt, dass ein Beruf eines eigenen Twinks im Katalog auftaucht.

## 0.9.24 – Werkstatt-Zustellung über den Gildenkanal absichern

- kommt der bestätigte Flüstertransfer eines Berufs nicht durch – in manchen Umgebungen erreichen Addon-Flüster den Empfänger nicht, während der Gildenkanal einwandfrei läuft –, wird der Beruf automatisch über den bewährten Gildenkanal nachgereicht, sodass der Anfragende die Rezepte trotzdem erhält;
- lässt sich der Flüstertransfer gar nicht erst starten oder das Flüster-Manifest nicht senden, greift sofort der Gilden-Bulktransfer;
- da die Zustellung so gesichert ist, bleibt bei einem gescheiterten Flüsterversuch kein Fehl-Banner mehr stehen; echte Verluste zählt weiterhin die Gilden-Warteschlange;
- ein Regressionstest belegt, dass ein vollständig gescheiterter Flüstertransfer den Beruf über den Gildenkanal nachreicht.

## 0.9.23 – Robuster Werkstatttransfer und rangunabhängiges Gildenprofil

- der bestätigte Werkstatttransfer gibt bei einem verlorenen ACK nur noch das betroffene Teilpaket auf, statt den ganzen Beruf abzubrechen; die übrigen Pakete werden weiter zugestellt und nur der tatsächliche Verlust gezählt;
- Teilpakete laufen mit wachsendem Abstand mehrfach erneut an, bevor sie als verloren gelten, sodass ein kurzzeitig überlasteter Addon-Kanal keinen Fehlschlag mehr vortäuscht;
- eine neue Datenanfrage setzt den Fehlschlagzähler zurück, damit „Übertragung unvollständig“ nicht dauerhaft stehen bleibt;
- das Gildenprofil wird rangunabhängig abgeglichen: die neuesten Daten gewinnen, und auch ein einfaches Mitglied darf seine zwischengespeicherte Kopie weitergeben, damit ein Offizier auf einem frischen Rechner nachgereicht bekommt, was gerade online ist; der Zeitstempel schützt weiter vor Überschreiben, nur Nicht-Gildenmitglieder bleiben gesperrt;
- Offiziere fragen beim Login zusätzlich aktiv den neuesten Gildenprofilstand an und warten kurz auf den Gildenroster, damit sie nicht fälschlich als einfaches Mitglied starten.

## 0.9.22 – Verlässlicher Gildenabgleich

- der direkte Rezeptburst aus 0.9.20 wurde durch eine gemeinsame, durchsatzorientierte Warteschlange ersetzt: Pakete werden weiterhin sofort eingereiht, der Addon-Kanal aber nicht mehr über seine sichere Burst-Kapazität hinaus geflutet;
- aktuelle Clients tauschen zuerst kleine Berufsmanifeste aus und übertragen nur fehlende oder geänderte Rezeptbestände direkt an den Anfragenden;
- große Direkttransfers verwenden ein gleitendes Paketfenster, Bestätigungen je Teilpaket und automatische Wiederholungen; ein lokal erfolgreicher `SendAddonMessage`-Aufruf gilt nicht länger fälschlich als Zustellnachweis;
- der Whisper-Router trennt Werkstatt-, Rekrutierungs-, Ausrüstungs- und Raidpakete nach Nachrichtentyp, statt alle Whisper pauschal an die Raidauswertung zu geben;
- die TBC-Clientbezeichnung **Alchimie** und die ältere Guild-Copilot-Schreibweise **Alchemie** werden auf denselben Beruf abgebildet, sodass vorhandene Rezepte beim Filtern nicht mehr verschwinden;
- Warcraft-Logs-Profile und der jeweils neueste Cache bekannter Addon-Profile bilden einen automatisch ermittelten Rekrutierungs-Datensatz; ein neuer Client wählt das vollständigste Angebot eines Online-Mitglieds und erhält dadurch dieselbe Grundlage für Copilot-Vorschläge;
- vollständige WCL-Kampfauswertungen werden dabei bewusst nicht über den Gildenkanal verteilt.

## 0.9.97 – Tragfähigkeit in großen Gilden

Anlass war eine vollständige Durchsicht vor der Veröffentlichung, verbunden mit einer Frage, die sich nicht aus dem Code beantworten lässt: Läuft das Addon in einer Gilde mit 500 Mitgliedern und 250 gleichzeitig Online noch? Dafür wurde ein Prüfstand gebaut, der das Addon außerhalb von WoW mit genau dieser Größe lädt und ausführt. Die Antwort war nein, und die Ursache war keine der Logik, sondern durchgängig die der Menge.

**Der Kern: Fan-out N**

Auf jede Anfrage im Gildenkanal antwortete bis 0.9.96 *jeder* Client einzeln. Bei fünfzehn Leuten fällt das nicht auf; bei 250 ist es das Ende des Kanals. Gemessen an einem einzigen fremden Login:

| Anfrage | vorher | nachher |
| --- | ---: | ---: |
| `GQ` Gildenprofil | 5.500 | 66 |
| `W\|Q` Werkstatt, moderner Fragender | 16.500 | 250 |
| `O\|Q` Auftragsabgleich | 45.000 | 240 |
| Login-Push der Aufträge | 30.000 | 150 |
| `RQ` Auswertung anfordern | 10.000 | 384 |
| `B\|BQ` Gildenbank | 250 | 3 |

Blizzards Addon-Kanal stellt größenordnungsmäßig zehn Pakete je Sekunde und Absender zu und verwirft den Rest lautlos. Es kam also nicht an, was gesendet wurde – und der Fortschrittsbalken meldete zu Recht dauerhaft „unvollständig".

Gelöst wird das mit zwei Verfahren, die beide schon je einmal im Addon standen und jetzt allen Anfragetypen offenstehen:

- **Wahl** (`GC.Sync:IsElectedResponder`): Nur eine Handvoll Clients antwortet. Wer dazugehört, rechnet jeder für sich aus – ohne eine einzige Zusatznachricht. Grundlage ist eine Streuzahl aus Anfragendem und Kandidat; sie ist auf jedem Client dieselbe, verteilt die Last aber bei jedem Anfragenden neu. Die erste Fassung tat das nicht: Über 200 Anfragen kamen nur neun verschiedene Clients zum Zug, einer davon 82-mal. Der Grund steckt in djb2 selbst – bei ähnlich langen Namen verschiebt der Anfragende alle Streuzahlen um denselben Faktor und ändert die Reihenfolge nicht. Mit zwei Runden sind es 235 verschiedene Clients.
- **Stille** (`NotePeerAnswer`/`PeerAnsweredSince`): Wer die Antwort eines anderen sieht, schweigt. Das greift nur bei Antworten über den Gildenkanal.

**Die Voraussetzung, an der die erste Fassung scheiterte**

Beide Verfahren ersetzen viele gleiche Antworten durch wenige. Sie setzen deshalb voraus, dass die Antwort bei jedem Antwortenden *dieselbe* ist. Für geteilte Gildendaten – Gildenprofil, Gildenbank, Aufträge – stimmt das. Für die Werkstatt nicht: Dort meldet jeder die Berufe seines eigenen Accounts. Die Wahl ließ von 250 Antworten drei übrig, und der Fragende erfuhr die Berufe von drei Spielern statt der ganzen Gilde; die Stille nahm ihm davon noch zwei. Wo jeder etwas Eigenes beiträgt, hilft nur Streuung in der Zeit: Alle antworten, verteilt über 30 Sekunden (Manifest) beziehungsweise 120 Sekunden (Vollversand an einen Altclient). Die Voraussetzung steht jetzt ausdrücklich im Kopf von `Sync.lua`.

Ein verwandter Fall sind die Raidauswertungen: Dort hängt die Antwort daran, ob dieser Client den Abend überhaupt gespeichert hat. Diese Prüfung gehört vor die Wahl – sonst verbraucht ein Client ohne Daten einen der wenigen Plätze und schweigt. Weil die Wahl zudem nur kennt, wer online ist, und nicht, wer Daten hält, bekommt sie hier eine großzügige Platzzahl: Mit drei Plätzen bekamen bei 16 % Halterquote 70 % der Anfragen nie eine Antwort, und weil die Streuzahl rein rechnerisch ist, immer dieselben Anfragenden.

**Der teure Pfad: `GC.DB:GetGuild`**

`MergeDefaults` fährt den kompletten Vorgabenbaum rekursiv ab. Beim ersten Mal ist das genau richtig, danach reine Arbeit ohne Ergebnis – aber der Aufruf steht in den heißesten Schleifen. Ein einziger Durchlauf von `ReapplyEnchantRules` rief ihn 17.168-mal auf: 307 ms, und `ReceiveGuildProfileChunk` stieß gleich drei Durchläufe an. Speicherte ein Offizier das Gildenprofil, stand das Spiel bei jedem Mitglied 932 ms still; ein einzelnes Rangkästchen genügte dafür. Mit gemerktem Ergebnis und einem statt drei Durchläufen sind es 61 ms.

**Wiedereintritt in die Sendewarteschlange**

ChatThrottleLib löst ihren Rückruf bei freiem Kanal synchron aus – noch innerhalb von `SendAddonMessage`, also bevor `PumpBulk` sein Paket aus der Warteschlange genommen hat. Führte dieser Rückruf zurück in `SendBulk` – und das tun der bestätigte Flüstertransfer und die Werkstatt –, lief `PumpBulk` ein zweites Mal an und griff auf dasselbe Paket zu. Nachgestellt: Das erste Paket ging zweimal raus, das im Rückruf eingereihte gar nicht, und `bulkOutstanding` blieb stehen und wurde nach zwei Minuten als Verlust verbucht. Das ist der Grund für „Abgleich unvollständig" ohne tatsächlichen Verlust. ChatThrottleLib ist über DBM, Details! und WeakAuras praktisch in jeder Raidgilde geladen; ohne sie tritt der Fall nicht auf, weshalb er im Test ohne Bibliothek unsichtbar blieb.

**Aufnahmegrenzen und Verdrängung**

Werkstatt und Ausrüstungsabgleich nahmen 20 beziehungsweise 40 Übertragungen gleichzeitig an. Von 60 gleichzeitigen Absendern wurden 20 angenommen und 40 stumm verworfen, ohne Wiederholung und ohne Meldung. Die Grenzen liegen jetzt bei 64 und 128, und beim Überlauf weicht die älteste angefangene Übertragung statt der neuen – ein frisches Paket ist immer wertvoller als eines, das seit Minuten nicht weitergekommen ist.

Bei den Raidauswertungen war die Grenze nicht zu eng, sondern falsch aufgeteilt: Seit jeder Teilnehmer seine Fassung als eigene Quelle abliefert, füllten 40 Antworten eines Abends alle 24 Plätze – sechs gespeicherte Raidabende waren danach gelöscht. Fremde Fassungen haben jetzt ein eigenes Kontingent und verdrängen keine eigene Auswertung mehr. Umgekehrt gilt aber auch: Ist die Ablage mit eigenen Quellen voll, darf die allgemeine Verdrängung nicht die eben eingefügte Fremdfassung greifen – sonst wird jede eintreffende Fassung eingefügt und im selben Durchlauf wieder entfernt, und die Reparatur lückenhafter Mitschnitte fällt dauerhaft und lautlos aus.

**Gespeicherte Daten**

Der Bestand lag bei 4,3 MB, davon 2,25 MB allein Ausrüstungsprüfungen – WoW liest die Datei bei jedem Login und schreibt sie bei jedem Ausloggen und `/reload`. Gespeichert werden jetzt nur noch die Messwerte; Beschriftung, Bewertung, Begründung und Verzauberungsname entstehen beim Lesen neu. Eine Ausnahme bleibt: Ein Verzauberungsname, der sich mangels Gegenstands- und Verzauberungs-ID nicht wiederherstellen lässt, wird behalten – sonst stünde er nach dem Speichern für immer nicht mehr da.

**Stille Ausfälle**

- Setzte ein anderes Addon `SetGuildRosterShowOffline(false)`, schrumpfte das Roster stumm auf die Online-Liste. Alles, was über `IsGuildMember` geht, war betroffen: Gildenprofil-Pakete der Offliner wurden verworfen, die Mitgliederpflege sah sie nicht mehr, und das Aufräumen der Werkstatt hielt sie für ausgetreten und löschte ihre Rezepte. Erkannt wird das jetzt an der Ausbeute; eine erkennbar gefilterte Liste ersetzt den vorherigen Stand nicht.
- Die WHISPER-Sperre deckte `RD` nicht ab – Raidauswertungen ließen sich von Gildenfremden einschleusen und verdrängten zusammen mit der Verdrängung oben die Abendhistorie.
- `GC.Perf:Measure` reichte die Rückgabe der gemessenen Funktion nur bei *ausgeschalteter* Messung durch. `/gcp debug` änderte damit das Programmverhalten, statt es zu beobachten.
- Fünf Merklisten wuchsen unbegrenzt, `Prune` lief nur beim Login, und `remoteProfiles` wie `addonUsers` führten jeden Spieler unter zwei Schlüsseln.

**Zusammengefuehrt mit den Wartezeiten**

Die Werkstatt-Wartezeiten aus derselben Fassung sind hier eingeflossen. Eine Stelle brauchte dabei eine Anpassung: Die Antwort auf eine Werkstatt-Anfrage schickt seither auch die laufenden Sperren mit, und zwar von jedem Client. Eine Sperre gehört wie ein Beruf dem eigenen Account – kein anderer kann sie melden –, also gilt für sie dieselbe Regel wie für das Manifest: Es antworten alle, aber zeitlich gestreut statt gleichzeitig.

**Was bewusst offen bleibt**

Der Vollversand an einen Client, der `workshop4` nicht meldet, bleibt bei 16.500 Paketen – jetzt über zwei Minuten verteilt statt auf einen Schlag. Ihn zu beschneiden hieße, genau diesem Client die halbe Gilde vorzuenthalten. Seit 0.9.96 meldet jeder Client `workshop4`; der Fall betrifft nur ältere Installationen.

Nachrichtenformate und Schemaversion 7 bleiben unverändert; ein 0.9.96-Client versteht jedes Paket weiterhin.

## Offene Punkte (Stand 0.9.45)

Der bisher ausgerollte Funktionsumfang der nummerierten Meilensteine ist umgesetzt. Offen bleiben Datenpflege, Erprobung im Spiel und diese klar getrennten nächsten Ausbaustufen:

- **Aldor-Schulterinschriften**: Die drei Aldor-Varianten fehlen im ausgelieferten Regelsatz, weil sich ihre Enchant-IDs nicht belegen ließen. Sie werden dadurch nicht falsch bewertet, sondern gar nicht.
- **Phasenauswahl nur über den Slash-Befehl**: `/gcp phase` stellt die Content-Phase um und synchronisiert sie gildenweit. Ein Auswahlfeld auf der Einstellungsseite fehlt noch.
- **Consumable-Spell-IDs**: Der Kernbestand wurde gegen einen echten SSC/TK-Report geprüft, ist damit aber nicht vollständig; Essen ist seit 0.9.38 abgedeckt. Unbekannte IDs werden nicht gezählt, es entstehen also keine falschen Zahlen.
- **Bosserkennung**: Seit 0.9.38 gibt es eine gepflegte Liste über den Eigennamen. Ob jeder deutsche Client-Name wirklich trifft, ist im Spiel noch nicht gegengeprüft – trifft einer nicht, greift die bisherige Heuristik.
- **Companion-Abfragen für die WCL-Nachanalyse**: seit 0.9.17 gegen echte Reports gelaufen und dabei viermal korrigiert; Einzelheiten oben unter „Nachanalyse aus Warcraft Logs". Erprobt ist bislang ein einzelner SSC/TK-Report – Karazhan, Gruul und Magtheridon sind noch nicht gegengeprüft.
- **Gear Audit**: Die eigenen Messdaten werden seit 0.9.19 automatisch in der Gilde verteilt; **Gruppe prüfen** bleibt als bewusster Inspect-Rückfall für Mitglieder ohne Addon oder ohne frischen Snapshot. Ausnahmen für Farmgear und Widerstandssets sind seit 0.9.37 umgesetzt.
- **Private WCL-Reports**: bewusst ausgeschlossen, dafür wäre eine OAuth-Benutzerfreigabe nötig.
- **Nicht verifizierbare API-Annahmen**: ob `GetProfessions` und `CombatLogGetCurrentEventInfo` in TBC Classic Anniversary genau so antworten, ließ sich von außen nicht belegen. Beide Aufrufe sind abgesichert und fallen still aus, statt Fehler zu werfen.
- **Code-Signing für den Installer**: Ohne Zertifikat warnen Browser, Windows und SmartScreen bei jedem Download auf einem fremden Rechner. Behebbar nur durch ein gekauftes Zertifikat; bis dahin steht die Prüfsumme in der README.
- **Encounter-Ereignisse im Combat Log**: Die Annahme „ohne Encounter-API in TBC" stimmt für die Logdatei nachweislich nicht – dort steht `ENCOUNTER_START,649,"Hochkönig Maulgar",4,25,565,5`, also ID und übersetzter Name. Ob das Addon dieselben Ereignisse auch live als Event empfängt, ist im Spiel noch nicht geprüft. Wenn ja, wäre das eine genauere Bosserkennung als die Namensliste aus 0.9.38.
- **`COMBATANT_INFO` als zweite Gear-Quelle**: Der Offline-Import aus 0.9.41 liest die Zeile bislang nur als Anwesenheitsbeleg. Darin steht aber die vollständige Ausrüstung jedes Raidmitglieds beim Pull, mit Verzauberungen und Sockeln – auch von Leuten ohne Addon. Genau die Lücke, für die es heute **Gruppe prüfen** als Inspect-Rückfall gibt.
- **Klasse im Offline-Import**: Der Combat Log nennt keine Klasse. Teilnehmerzeilen aus der Logdatei bleiben deshalb ohne Klassenfarbe. Über gewirkte Zauber wäre sie herleitbar, über `COMBATANT_INFO` sogar samt Spec.
- **Abende in zwei Instanzen**: Die Zone eines Offline-Imports wird aus den Bossnamen aufgelöst. Wer an einem Abend Gruul und das Auge macht, bekommt beide genannt („Gruuls Unterschlupf / Auge"); ob das in der schmalen Sitzungsliste noch lesbar ist, steht im Spiel noch nicht fest.

## Datenschutz und Fairness

- nur Daten erfassen, die WoW-API, Combat Log oder ausdrücklich konfigurierte externe Quellen liefern;
- Herkunft jeder Statistik anzeigen: **Live**, **Addon-Profil**, **Inspect** oder **Warcraft Logs**;
- keine heimliche Chat-, Tastatur-, Speicher- oder Prozesseingabe;
- Werbung nie ohne echte Eingabe und nie ohne ausdrücklich gesetzten Schalter: Auch die Automatik des Werbebalkens (0.9.101) postet nur im Kontext eines Tastendrucks und nur bei sichtbarem Balken; Einladung und Entfernung von Mitgliedern geschehen nie automatisch;
- zeitlich begrenzte Aufbewahrung und gezielte Löschfunktionen;
- keine Charakterbewertung ohne sichtbare Einzelkriterien;
- Officersichten und sensible Notizen nicht über ungeschützte Gildenkanäle synchronisieren.

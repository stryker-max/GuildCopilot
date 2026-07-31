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
- keine automatische Werbung, Einladung oder Entfernung von Mitgliedern;
- zeitlich begrenzte Aufbewahrung und gezielte Löschfunktionen;
- keine Charakterbewertung ohne sichtbare Einzelkriterien;
- Officersichten und sensible Notizen nicht über ungeschützte Gildenkanäle synchronisieren.

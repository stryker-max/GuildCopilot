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

Umgesetzt: Rezeptscan über das geöffnete TBC-Berufsfenster, gedrosselte Gildensynchronisierung, Suche nach Rezept/Beruf/Crafter, Herstellerliste und Reagenzienanzeige. Damit ist 0.4.0 abgeschlossen.

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
- Werkstattpakete deutlich gedrosselt, bei Sendefehlern wiederholt und nicht mehr still verworfen;
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

Umgesetzt: Der Companion liest je Report Kampfabschnitte, Teilnahme, Anwesenheitszeit, Tode, Interrupts, Dispels und Verbrauchsgegenstände und exportiert sie im Format `GCPWCL2`. Das Addon legt jede Nachanalyse als eigene Auswertung mit der Quelle **Warcraft Logs** ab. Live-, Sync- und Logs-Daten tragen unterschiedliche Kennungen und können sich gegenseitig nicht überschreiben – eine Auswertung anderer Quelle wird beim Speichern abgelehnt statt vermischt.

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

Offen und bewusst noch nicht umgesetzt:

- Der Name jeder vorhandenen Verzauberung wird inzwischen aus dem WoW-Tooltip gelesen: das Addon baut den Tooltip einmal mit und einmal mit auf 0 gesetzter Verzauberung auf und nimmt die Zeile, die nur in der ersten Fassung vorkommt. Das ist sprachunabhängig und braucht keine ID-Datenbank. Lässt sich die Vergleichsfassung nicht aufbauen, wird bewusst nichts gemeldet, damit nie der Gegenstandsname als Verzauberung erscheint.
- Der Regelsatz wird jetzt in der Gilde selbst gepflegt: Ein Klick auf eine Slotzeile stuft die erkannte Verzauberung ein, gespeichert wird die ID mit ihrer Stufe, geteilt wird sie gildenweit über das Gildenprofil. Damit sind Empfehlungen wie von wowtbc.gg als IDs und eigene Regeln versioniert statt als abgeschriebener Guide-Text – der externe Guide bleibt die menschliche Vorlage, die Daten entstehen im Client.
- Der mitgelieferte statische Regelsatz für **Optimal**, **Solide** und **Verbesserbar** ist weiterhin leer. Die Enchant-IDs müssen aus einer belegbaren Quelle übernommen werden; bis dahin werden vorhandene Verzauberungen als **Unbekannt** ausgewiesen und nie als schlecht gewertet. Fehlende Verzauberungen und leere Sockel erkennt der Audit auch ohne Regeln exakt.
- Ausnahmen für Farmgear, Widerstandssets und Encounter-Sets fehlen noch.
- Regeln nach Spec und Content-Phase sind vorbereitet (Rolle und Slot werden bereits ausgewertet), aber ohne Regeldaten noch nicht wirksam.
- Die Ergebnisse bleiben lokal bei dem, der geprüft hat. Ob sie zusätzlich wie die Raidauswertung über den Addon-Kanal an Offiziere verteilt werden sollen, ist weiterhin offen.

Ergänzt: Die Funde werden als lesbare Sätze mit Slotnamen aufbereitet statt als nackte Zahlen, eine Kopfzeile fasst alle geprüften Spieler zusammen, und jeder Spieler sieht seine eigene Prüfung unter **Profil → Deine Ausrüstung** und kann sie dort selbst auslösen.

Die Guides von [wowtbc.gg](https://wowtbc.gg/) führen spec-spezifische Consumables und Alternativen auf. Diese Trennung eignet sich als Grundlage für die Stufen **Optimal** und **Solide**, muss aber pro Phase und Spec gepflegt werden.

## 0.7 – Mitgliederpflege

Grundlage seit 0.4.4 umgesetzt: Abmeldungen, Inaktivitätsgrenze, Rangschutz und vorsichtige Prüfvorschläge. Für dieses Ausbaustadium verbleiben:

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
- **Gear Audit, Automatik**: Die eigene Ausrüstung prüft sich selbst, beim Login und nach dem Umziehen. Eine vorhandene, aber nirgends bewertete Verzauberung gilt wahlweise als in Ordnung, statt als „Unbekannt“ aufzufallen. Das behauptet keine Qualität, es unterscheidet nur verzaubert von nicht verzaubert. Beides ist abschaltbar und wirkt rein lokal.
- **Gear Audit, Statuszeile**: Sie zählte nur die mitgelieferte, absichtlich leere Regelliste. Gildeneigene Bewertungen wurden dadurch nie anerkannt, die Meldung blieb dauerhaft auf „Regelsatz ist noch leer“ stehen.
- **Aufklappmenüs**: Mehrere Seiten liegen in einem ScrollFrame, und ein ScrollFrame beschneidet alles, was über seinen Rand hinausragt. Als Kind der jeweiligen Karte wurde ein aufgeklapptes Menü oben abgeschnitten, unabhängig von seiner Höhe. Es hängt jetzt am Hauptfenster und wird nur noch am Knopf verankert; ab neun Einträgen scrollt es.
- **Kleinigkeiten**: Der Werbebalken kappte seinen Text bei 110 Bytes statt bei den 255, die in den Chat gehen. Die Hinweisspalte der Slot-Tabelle brach um und lief in die Nachbarzeilen. In `GetPlayerFullName` kürzte ein `and`-Ausdruck die Zuweisung auf einen Wert, der Realm kam dadurch nie an.

## Offene Punkte (Stand 0.9.17)

Alle nummerierten Meilensteine sind umgesetzt. Was bleibt, ist Datenpflege und Erprobung im Spiel:

- **Enchant-Regelsatz**: wird seit 0.8.1 in der Gilde selbst gepflegt; ausgeliefert wird eine leere Tabelle. wowtbc.gg und Wowhead lassen sich nicht automatisch auslesen (beide antworten mit HTTP 403), und die Guides nennen nur englische Namen, während der Item-Link eine Enchant-ID führt.
- **Regelsatz ohne Klassenbezug**: Eine gildeneigene Bewertung hängt allein an der Enchant-ID – ohne Slot, ohne Rolle, ohne Klasse. Wer eine Verzauberung als Optimal einstuft, tut das für jeden in der Gilde. In der Praxis fällt das selten auf, weil die meisten Verzauberungen ohnehin nur von einer Rolle getragen werden; bei generischen Verzauberungen, die mehrere Rollen unterschiedlich bewerten, trifft es aber zu. Das Format der mitgelieferten Regelliste kennt `slots` und `roles` bereits, der gildeneigene Weg nutzt sie noch nicht. Klassen kennt bisher keiner von beiden.
- **Consumable-Spell-IDs**: Ausgangsbestand aus dem Gedächtnis, nicht gegen echte Logs geprüft. Essen fehlt vollständig, weil die „Sattgegessen“-IDs je Gericht abweichen. Unbekannte IDs werden nicht gezählt, es entstehen also keine falschen Zahlen.
- **Bosserkennung**: heuristisch über Kampfabschnitte, keine gepflegte Bossliste je Instanz.
- **Companion-Abfragen für die WCL-Nachanalyse**: seit 0.9.17 gegen echte Reports gelaufen und dabei viermal korrigiert; Einzelheiten oben unter „Nachanalyse aus Warcraft Logs". Erprobt ist bislang ein einzelner SSC/TK-Report – Karazhan, Gruul und Magtheridon sind noch nicht gegengeprüft.
- **Gear Audit**: Ausnahmen für Farmgear und Widerstandssets fehlen; Ergebnisse bleiben lokal bei dem, der geprüft hat. Automatisch prüft sich seit 0.9.5 nur die eigene Ausrüstung – **Gruppe prüfen** bleibt ein Klick, weil ein selbsttätiger Raidscan für jeden Teilnehmer eine Inspect-Anfrage auslöst.
- **Private WCL-Reports**: bewusst ausgeschlossen, dafür wäre eine OAuth-Benutzerfreigabe nötig.
- **Nicht verifizierbare API-Annahmen**: ob `GetProfessions` und `CombatLogGetCurrentEventInfo` in TBC Classic Anniversary genau so antworten, ließ sich von außen nicht belegen. Beide Aufrufe sind abgesichert und fallen still aus, statt Fehler zu werfen.

## Datenschutz und Fairness

- nur Daten erfassen, die WoW-API, Combat Log oder ausdrücklich konfigurierte externe Quellen liefern;
- Herkunft jeder Statistik anzeigen: **Live**, **Addon-Profil**, **Inspect** oder **Warcraft Logs**;
- keine heimliche Chat-, Tastatur-, Speicher- oder Prozesseingabe;
- keine automatische Werbung, Einladung oder Entfernung von Mitgliedern;
- konfigurierbare Aufbewahrungszeit und Löschfunktion;
- keine Charakterbewertung ohne sichtbare Einzelkriterien;
- Officersichten und sensible Notizen nicht über ungeschützte Gildenkanäle synchronisieren.

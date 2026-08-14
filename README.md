# Guild Copilot 0.9.129

<p align="center">
  <img src="Brand/GuildCopilotLogo.png" width="240" alt="Guild Copilot Logo">
</p>

**Der deutschsprachige Gildenassistent für World of Warcraft: Burning Crusade Classic Anniversary.**

Guild Copilot nimmt einer Gildenleitung die Buchhaltung ab: Wer spielt was, wer fehlt im Raid, wer kann das Rezept, wem fehlt die Verzauberung, wer hat sich beworben. Die Daten sammelt es im Hintergrund aus dem Spiel und teilt sie über den unsichtbaren Addon-Kanal mit allen Gildenmitgliedern, die es ebenfalls installiert haben. Kein Webzugriff, keine Anmeldung, keine Kosten.

## Auf einen Blick

| Bereich | Wofür |
|---|---|
| **Rekrutierung** | Gildenprofil, Werbetext mit Kanalauswahl, Vorschläge, welche Specs fehlen |
| **Postfach** | Eingehende Bewerbungen sammeln, beantworten, einladen |
| **Gilde** | Roster mit Raidprofilen, Abmeldungen, Inaktivitätsvorschläge |
| **Werkstatt** | Wer kann welches Rezept, was kostet es an Material, wer hat es auf Lager |
| **Gildenaufträge** | Bestellungen an Handwerker mit Status, Übergabe und Kostenabrechnung |
| **Raidauswertung** | Anwesenheit, Versuche, Tode, Interrupts, Verbrauchsgegenstände je Abend |
| **Ausrüstung** | Fehlende Verzauberungen und leere Sockel der ganzen Gruppe |

Aufgerufen wird alles über `/gcp`, das Minimap-Symbol oder **Optionen → AddOns → Guild Copilot**.

---

## Rekrutierung

Der Ablauf geht von oben nach unten: Gildenprofil ausfüllen, Vorschläge ansehen, Werbetext bestätigen, posten.

**Gildenprofil.** Kurzbeschreibung, Raidzeiten, Progress, Lootsystem, Discord und Kontaktperson stehen einmal da und fließen automatisch in Werbe- und Antworttexte ein. Das Profil gilt gildenweit — ein Offizier pflegt es, alle haben es.

**Vorschläge.** Guild Copilot vergleicht die Raidprofile der aktiven Raider mit den Supportrollen, die ein TBC-Raid braucht, und nennt die Lücken. Gezählt werden dabei nur Spieler, die auch wirklich raiden können: Stufe 70, freigegebener Rang, nicht seit Monaten abgemeldet — ein Twink deckt keine Spec ab.

**Werbetext.** Editierbar, mit Raid-Symbolen und laufender 255-Byte-Kontrolle. Klassen und Specs wählst du über aufklappbare Klassenkarten; drei Specs einer Klasse werden zur Klasse verdichtet, ab sieben Klassen steht „alle Klassen“ da. Klassen lassen sich sortieren und als hohe Priorität markieren, die erscheinen dann zuerst und als „dringend“ im Text.

**Posten.** Ein Klick auf **Suche starten** bedient alle ausgewählten Kanäle auf einmal. Vorher muss der Text ausdrücklich bestätigt werden, und jeder Kanal hat 120 Sekunden lokalen Cooldown.

**Werbebalken.** Ein kleines, frei verschiebbares Fenster nur fürs Posten — bestätigter Text, Zahl der bereiten Kanäle, Cooldown als Countdown im Knopf. Damit muss für Werbung nicht das ganze Addonfenster offen bleiben. Ein- und ausblenden mit `/gcp recruite`.

**Automatisch wiederholen.** Auf Wunsch wiederholt der Werbebalken die Werbung von selbst: Läuft der Kanal-Cooldown ab, geht der bestätigte Text mit deinem nächsten Tastendruck raus — gleich welche Taste, auch beim Laufen. Den Umweg verlangt WoW: Kanalnachrichten aus Addons sind nur im Moment einer echten Eingabe erlaubt, ein Timer darf nie selbst posten. Die Automatik läuft nur, solange der Balken eingeblendet ist, die Statuszeile sagt jederzeit, was als Nächstes passiert, und Bestätigungspflicht wie Cooldowns gelten unverändert. Welche Taste du drückst, liest Guild Copilot nicht.

## Postfach

Eingehende Flüsternachrichten und erkannte „Suche Gilde“-Chatnachrichten landen automatisch als Interessent im Postfach — mit Klassenfarbe, Level und Empfangszeit.

- **Antworten** mit drei Knöpfen: Danke, Gildeninfos, Discord. Die Vorlagen dahinter pflegst du direkt im Postfach, sie gelten gildenweit und kennen Platzhalter wie `{name}`, `{raidzeiten}` oder `{discord}`.
- Jeder **Entwurf gehört zu seinem Interessenten** und bleibt beim Wechsel erhalten — auch wenn währenddessen eine neue Nachricht eintrifft und die Liste sich verschiebt.
- **Profil-Links** zu classic-armory.org und Warcraft Logs stehen kopierbar bereit; hineinklicken markiert den ganzen Link.
- **Ignorierliste** für Dauerschreiber, dauerhaft oder befristet, jederzeit widerrufbar.
- **Eigene Trigger- und Ausschlusswörter**, getrennt für öffentliche Nachrichten und Flüstern.
- Der **Bewerberton** hängt am Gildenrang: Wer nicht rekrutiert, hört ihn nicht, findet den Eintrag aber trotzdem.

## Gilde

**Roster.** Die zuletzt aktiven Level-70-Spieler mit Raidprofil, Main/Twink-Status, Berufen und letzter Onlinezeit. Welche Ränge als aktive Raider gelten, stellst du ein.

**Dein Profil.** Primär-Spec, optionaler Dual-Spec, Main oder Twink, „flexibel einsetzbar“ — der Talentbaum wird erkannt, bestätigen musst du selbst. Änderst du etwas, gilt es als unbestätigt, bis du erneut bestätigst; in der Gilde steht solange der letzte bestätigte Stand. Dazu die eigene **Abmeldung** von/bis mit optionalem Grund — das Datum wählst du über das Kalendersymbol im Feld, tippen geht weiterhin und nimmt auch `15.08.2026` an.

**Erste Schritte.** Beim ersten Login je Charakter öffnet sich ein Einrichtungsassistent: eine kurze Funktionstour entlang der Seitenleiste (was kann das Addon, und wo finde ich es), dann die drei Schritte — Raidprofil mit erkannter Spec per Klick bestätigen, Berufsfenster direkt aus dem Assistenten öffnen (die Rezepte liest Guild Copilot dabei selbst), die Ausrüstungsprüfung läuft ohnehin automatisch. Jederzeit abbrechbar über ×, Escape oder „Später“, jeder Schritt einzeln überspringbar. Wer den Assistenten zuklappt, verliert nichts: Dieselben Schritte stehen als Checkliste oben im Profil, die echte Aktion schiebt sie weiter, und ein Punkt am Minimap-Symbol erinnert an den Rest. Der Knopf **Einrichtung** im Fensterkopf und `/gcp welcome` holen den Assistenten jederzeit zurück.

**Mitgliederpflege** (ranggeschützt). Aktive Abmeldungen und nach Inaktivität sortierte Prüfvorschläge. Jeder Vorschlag lässt sich als **Ausnahme**, **zurückgestellt** oder **erledigt** ablegen — gildenweit synchronisiert, damit nicht zwei Offiziere denselben Fall bearbeiten. Unsichere Main/Twink-Fälle werden als „Prüfen“ gekennzeichnet, nicht als Entfernungsvorschlag.

> Ein Gildenausschluss ist immer eine Einzelentscheidung: zweite ausdrückliche Bestätigung, echte WoW-Berechtigung, nur gegen einen niedrigeren und ungeschützten Rang. Nichts davon läuft automatisch oder in Serie.

## Gildenwerkstatt

**Rezepte.** Öffnet ein Gildenmitglied sein Berufsfenster, liest Guild Copilot den gesamten bekannten Bestand ein — einschränkende Filter werden dafür kurz zurückgesetzt und Kategorien aufgeklappt. Danach findest du über die Suche jedes Rezept der Gilde samt Herstellern, Reagenzien und Berufssymbol. Auch die Berufe deiner eigenen Twinks sind dabei, ohne auf eine Synchronisierung zu warten.

**Materialbestand am Rezept.** Je Reagenz steht Bedarf, dein eigener Bestand (Taschen, Bank und Twinks) und der Gildenbankbestand mit Ampelfarbe: grün hast du selbst, gelb reicht erst mit der Gildenbank, rot fehlt auch dann. Darunter steht, was konkret fehlt.

**Wartezeiten.** Umwandlungen, Spezialtuche und Sphären lassen sich nicht beliebig oft herstellen. Wer ein Rezept kann, kann es deshalb noch lange nicht heute — und genau das steht jetzt am Hersteller: „frühestens 21:40“. Abgelesen wird die laufende Sperre beim Öffnen des Berufsfensters, also dort, wo der Client sie überhaupt nennt; sie wandert wie alles andere über den Addon-Kanal in die Gilde. Auch im Wunsch-Hersteller-Feld beim Auftragserstellen steht sie, damit die Bestellung nicht bei dem landet, der heute nicht mehr kann.

Die Angabe ist eine **Mindestangabe**, und das steht auch so da: Hat der Hersteller nach dem letzten Berufsfenster erneut hergestellt, ist er später frei — früher nie. Umgekehrt behauptet Guild Copilot nie, jemand sei frei: Das Spiel meldet für ein freies Rezept dasselbe wie für eines ganz ohne Wartezeit, und was sich nicht unterscheiden lässt, wird auch nicht behauptet.

Die **Gildenbank** wird beim Besuch am Bankfach je Tab eingelesen und gildenweit geteilt. Da die Sichtbarkeit eines Tabs am Rang hängt, gilt alles pro Tab — ein eingeschränkter Blick löscht nie fremde Tabs. Deine eigenen Taschen- und Bankbestände bleiben auf dem Account und werden nie gesendet.

Wer die Gilde verlässt, verschwindet mit seinen Rezepten. Twinks von Gildenmitgliedern bleiben erhalten, weil sie nie im Gildenroster stehen.

## Gildenaufträge

Der zweite Reiter der Werkstatt macht aus „kann das jemand craften?“ einen nachvollziehbaren Vorgang.

- **Auftrag erstellen** direkt an der Rezeptkarte: Menge, Materialmodell (du lieferst / Gildenbank / Beschaffung mit Kostenrahmen), Übergabe persönlich oder per Post, Trinkgeld und Notiz. Die Annahme ist die Zustimmung zu genau diesen Bedingungen.
- **Status mit Verlauf:** offen → angenommen → in Arbeit → gefertigt → versandt → erhalten → abgeschlossen. An jedem Auftrag steht, wer als Nächstes dran ist; jeder Schritt steht mit Zeit und Charakter im Verlauf.
- **Angenommen wird vom Account, nicht vom Charakter:** Dein Twink darf annehmen, gefertigt wird mit dem Charakter, der das Rezept kann. Nimmt jemand gleichzeitig an, gewinnt der frühere Zeitstempel und der andere bekommt eine klare Meldung.
- **Wunsch-Hersteller:** 24 Stunden lang darf nur er annehmen, danach ist der Auftrag offen für alle.
- **Kostenerstattung** mit Teilzahlungen und offenem Rest, zweiseitig abgeschlossen.
- **Vorlagen** je Rezept — der Wochenauftrag „15 Sphären“ ist ein Klick.
- **Kompakt-Tracker:** ein kleines Fenster, das nur erscheint, wenn du an der Reihe bist.

## Raidauswertung

**Sitzung starten** vor dem Raid, **Sitzung beenden** danach — dazwischen laufen Anwesenheitszeit, Versuche, Siege, Wipes, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände je Teilnehmer mit. Bosskämpfe erkennt das Addon über die Encounter-Ereignisse des Clients; Trashkämpfe zählen nicht als Versuch. Starten und beenden dürfen die für die Mitgliederpflege freigegebenen Ränge — in den Einstellungen wählbar, Vorgabe sind Gildenmeister und Offiziere.

**Ein Verbindungsabbruch kostet den Abend nicht.** Die laufende Sitzung wird lokal gesichert und beim nächsten Login mit denselben Zahlen fortgesetzt; war die Unterbrechung länger als acht Stunden, wird sie mit ihrem letzten Stand ausgewertet statt verworfen. Unabhängig davon schreiben alle Addon-Nutzer im Raid denselben Abend parallel mit — auch wer erst später dazustößt.

Ein Klick auf einen Teilnehmer öffnet sein **Verbrauchsprotokoll**: was wann eingeworfen wurde.

Denselben Abend gibt es aus bis zu drei Quellen — **Live**, **Warcraft Logs** und **Combat Log**. In der Liste steht er trotzdem nur einmal: angezeigt wird die vollständigste Auswertung, die übrigen sind daneben abrufbar und lassen sich gegenüberstellen. Zahlen verschiedener Quellen werden nie miteinander verrechnet.

Gespeichert werden ausschließlich Zusammenfassungen, keine Combat-Log-Rohdaten.

## Ausrüstungsprüfung

Fehlende Verzauberungen und leere Sockel — je Slot, für dich selbst auch ohne Gruppe.

Jeder Addon-Client stellt seine Ausrüstung als kompakten Rohdaten-Snapshot bereit: Slot, Gegenstands-ID, Verzauberungs-ID, Zahl leerer Sockel. Mehr nicht — keine Bewertungen, keine Tooltiptexte, keine Inventarinhalte. Für Teilnehmer ohne Addon gibt es **Gruppe prüfen** als Inspect-Rückfall; wer nicht in Reichweite ist, wird ausdrücklich als übersprungen ausgewiesen.

**Bewertet wird nach Archetyp, nicht nach Rolle.** Schattenpriester und Schurke sind beide „Schaden“, brauchen aber völlig verschiedene Verzauberungen. Unterschieden werden Zauber-Schaden, Heilung, physischer Schaden und Tank. Mitgeliefert wird ein Regelsatz aus belegten TBC-Enchant-IDs; die **Content-Phase** der Gilde (T4 bis T6.5) entscheidet, was überhaupt schon gilt.

- **Eigener Regelsatz der Gilde:** Ein Klick auf eine Slotzeile stuft eine Verzauberung als Optimal, Solide oder Verbesserbar ein — wahlweise für eine konkrete Spec. Die Gildenregel sticht den mitgelieferten Satz.
- **Ausnahmen** für Farmgear und Widerstandssets: Rechtsklick nimmt einen Slot aus der Wertung, sichtbar und mit Grund.
- Eine Regel, die auf den Geprüften nicht passt, wird behandelt, als gäbe es sie nicht. Unbewertete Verzauberungen gelten nie als schlecht.
- Es gibt **bewusst keine Gesamtnote** je Spieler. Die Funde stehen als lesbare Sätze da: „2 fehlende Verzauberungen: Kopf, Schulter“.

## Wie die Daten in der Gilde ankommen

Guild Copilot funktioniert allein, wird aber deutlich nützlicher, je mehr Gildenmitglieder es haben.

- Übertragen wird über den **unsichtbaren Addon-Datenkanal**, nie über sichtbare Chatnachrichten, und ausschließlich innerhalb der eigenen Gilde.
- Gesendet wird bei Login, bei Änderungen und auf Anfrage — keine Dauerbroadcasts. Große Übertragungen pausieren im Kampf.
- Wer neu dazukommt, **fragt den Bestand ab** und bekommt die Profile der bereits Eingeloggten nachgereicht.
- In der Gildenübersicht steht, **wer das Addon nutzt** und wessen Datenversion abweicht. Gezählt werden Spieler, nicht Charaktere: Main und Twinks erscheinen als einer.
- Was gildenweit gilt — Gildenprofil, Antwortvorlagen, Pflegeentscheidungen, Verzauberungsregeln, Rangfreigaben — pflegt ein Berechtigter, und alle haben es.

Alle sollten dieselbe Version fahren. Sie steht im Fenstertitel, Abweichungen werden in der Gildenübersicht ausgewiesen; `/gcp ver` fragt gezielt nach.

---

## Installation

**Der einfachste Weg unter Windows:** [`GuildCopilot-Installer.exe`](Installer/dist) starten. Sie erkennt die vorhandenen Spielversionen selbst, lädt das Addon direkt aus diesem Repository, aktualisiert eine vorhandene Fassung und hält sich auch selbst aktuell.

**Ohne die .exe:** `Install.cmd` doppelt anklicken. Das Skript sucht die WoW-Installation und kopiert die neue Fassung über eine vorhandene, ohne den funktionierenden Ordner vorher zu löschen.

**Von Hand:** den Ordner `GuildCopilot` nach `World of Warcraft/_anniversary_/Interface/AddOns/` kopieren. Danach muss `GuildCopilot.toc` direkt in `AddOns/GuildCopilot/` liegen — ein doppelt verschachtelter Ordner ist der häufigste Installationsfehler.

Danach WoW neu starten, **Guild Copilot** aktivieren und `/gcp` eingeben. Der Einrichtungsassistent führt durch den Rest.

## Der Installer

`GuildCopilot-Installer.exe` liegt unter [Installer/dist](Installer/dist), der Quellcode daneben unter [Installer/](Installer). Sie gehört **nicht** ins Addon-Verzeichnis — installiert wird ausschließlich der Ordner `GuildCopilot`.

Neben Installieren, Aktualisieren und Entfernen erledigt sie zwei Dinge, die ein Ingame-Addon nicht darf:

**Warcraft-Logs-Import.** Client ID, Client Secret, ein Gilden- oder Reportlink, ein Klick — der Importcode landet in der Zwischenablage und wird im Addon eingefügt. Das Client Secret wird nur auf Wunsch gespeichert, dann über die Windows-eigene DPAPI verschlüsselt und an das Windows-Konto gebunden, nie im Klartext. Node.js wird nicht gebraucht.

**Raidabend aus dem Combat Log.** Der netzfreie Weg: Der Installer liest eine `WoWCombatLog.txt` aus `<Spielversion>\Logs\` und erzeugt denselben Importcode — ohne Upload, ohne Zugangsdaten, ohne Warcraft-Logs-Konto. Der Nutzen ist die Rückwirkung: Die Datei hat den ganzen Abend, auch wenn niemand „Sitzung starten“ gedrückt hat. Zwei Grenzen: Die Klasse steht im Combat Log nicht (Teilnehmer erscheinen ohne Klassenfarbe statt mit einer geratenen), und gezählt wird nur, wer in einem Bosskampf auftaucht.

Installer und Addon werden **getrennt gezählt**. Aktuell stehen der Installer bei 1.0.7 und das Addon bei 0.9.129.

### Warum Windows beim Herunterladen warnt

Die `.exe` ist **nicht code-signiert**, und Windows markiert zusätzlich alles, was aus dem Internet kommt. Bei SmartScreen führt der Weg über **Weitere Informationen → Trotzdem ausführen**. Abstellen ließe sich das nur mit einem Code-Signing-Zertifikat (200–600 €/Jahr, seit 2023 nur mit Hardware-Token); ein selbst ausgestelltes hilft ausdrücklich nicht.

Wer sichergehen will, vergleicht die Prüfsumme:

```powershell
Get-FileHash .\GuildCopilot-Installer.exe -Algorithm SHA256
```

SHA-256 der Fassung 1.0.7: `6C4DEC10699DDA9F4035E3F8704CBA7CF58839F060A3F43960C2C696C80F05E6`

Wem das zu umständlich ist, nimmt `Install.cmd` — dort wird nichts ausgeführt, was Windows nicht ohnehin kennt.

Zum Bauen wird das .NET SDK gebraucht:

```bash
dotnet publish Installer -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -o Installer/dist
```

## Was ein WoW-Addon nicht darf

Zwei Grenzen prägen das ganze Addon, und beide sind Absicht:

**Kein zeitgesteuertes Posten.** WoW erlaubt Addons nicht, Chatnachrichten ohne echten Tastendruck zu versenden. Darum ist **Suche starten** ein manueller Klick — dieser eine Klick bedient dann alle ausgewählten Kanäle. Der Werbebalken sendet ausschließlich per echtem Klick; sein Countdown schaltet den Knopf nur frei und löst nie selbst aus.

**Kein Webzugriff aus dem Spiel.** Deshalb speichert Guild Copilot den Warcraft-Logs-Link nur und nimmt Daten über einen kontrollierten Import entgegen. Den eigentlichen Abruf macht der Installer außerhalb von WoW über die offizielle API.

Dazu die Selbstbeschränkungen: standardmäßig ist ausschließlich `Gildenrekrutierung` gewählt, jedes Ziel hat mindestens 120 Sekunden Cooldown, der Text muss nach jeder Änderung erneut bestätigt werden, und es gibt keine Eingabesimulation, keine WoW-Speicherzugriffe, keine kostenpflichtigen Funktionen und keine Werbung für Waren oder Dienstleistungen.

Die Nutzung bleibt an die jeweiligen Realm-, Kanal- und Verhaltensregeln gebunden. Blizzard kann Addon-Funktionen jederzeit einschränken; für eine verbindliche Einzelfallentscheidung nennt Blizzard `WoWUI@blizzard.com`.

## Slash-Befehle

| Befehl | Wirkung |
|---|---|
| `/gcp` | öffnet und schließt Guild Copilot (`/guildcopilot` tut dasselbe) |
| `/gcp help` | zeigt alle Befehle im Chat |
| `/gcp welcome` | öffnet den Einrichtungsassistenten mit der Funktionstour |
| `/gcp recruite` | blendet den Werbebalken ein oder aus (`/gcp werbung` bleibt gültig) |
| `/gcp ver` | fragt die Addon-Versionen in Gilde oder Gruppe ab |
| `/gcp phase` | zeigt die Content-Phase der Gilde; `/gcp phase T5` stellt sie um |
| `/gcp debug` | schaltet die Laufzeitmessung ein; ein zweiter Aufruf zeigt die Ergebnisse |

Dieselbe Liste steht unter **Optionen → AddOns → Guild Copilot** und auf der Einstellungsseite. Alle drei stammen aus derselben Tabelle im Code und können nicht auseinanderlaufen.

## Gespeicherte Daten

Einstellungen und Gildendaten liegen in `GuildCopilotDB` (SavedVariables). Über Addon-Nachrichten werden kompakte Charakter-, Ausrüstungs- und Werkstattprofile, die für die Vorschläge benötigten Warcraft-Logs-Profile sowie das Gildenprofil mit Berechtigungen, Antwortvorlagen, Pflegeentscheidungen und Verzauberungsregeln ausschließlich innerhalb der eigenen Gilde synchronisiert. Fertige Raidauswertungen laufen nur über Raid-, Gruppen- oder gezielte Flüsternachrichten.

Nicht gesendet werden: deine Taschen- und Bankbestände, Combat-Log-Rohdaten, Tooltiptexte und fertige Bewertungen.

## Weiteres

Der Verlauf aller Versionen steht in [ROADMAP.md](ROADMAP.md), offene Punkte und bewusst nicht umgesetzte Befunde in [docs/TODO-naechste-sitzung.md](docs/TODO-naechste-sitzung.md).

Der ältere Weg für den Warcraft-Logs-Abruf über `GuildCopilot/Companion/Start-WCL-Import.cmd` funktioniert unverändert weiter und braucht Node.js; er bleibt als Rückfallebene erhalten. Einzelheiten in [Companion/README.md](GuildCopilot/Companion/README.md). Im ausgelieferten Addon-Paket ist der Companion nicht enthalten.

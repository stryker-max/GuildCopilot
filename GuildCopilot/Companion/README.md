# Warcraft-Logs-Companion

Ein WoW-Addon darf keine Webseiten oder Web-APIs aufrufen. Dieses kleine, offen einsehbare Hilfsprogramm liest ausschließlich öffentliche Warcraft-Logs-Daten über die offizielle GraphQL-API. Es steuert WoW nicht und simuliert keine Eingaben.

## Einmalig: API-Client anlegen

Unter [Warcraft Logs – API Clients](https://www.warcraftlogs.com/api/clients/):

- Name: `Guild Copilot – private guild roster and spec importer`
- Redirect URLs: `http://localhost/callback` (Pflichtfeld der WCL-Maske; wird vom Companion nicht verwendet)
- Public Client: nicht anhaken

Die Zugangsdaten werden nur für den laufenden Import abgefragt und nicht in einer Datei gespeichert.

## Erster Versuch: ein einzelner Report

Der schnellste Weg zu einem belegbaren Ergebnis führt über genau einen Report statt über die ganze Gilde. Auf der Warcraft-Logs-Seite den Report öffnen und die Adresse kopieren (`https://…/reports/aBcD1234efGH5678`).

1. `Start-WCL-Import.cmd` doppelt anklicken.
2. Client ID und Client Secret eingeben.
3. Als Link die Reportadresse einfügen, bei der Anzahl `1` wählen.
4. Nach erfolgreichem Abruf liegt der Importcode in der Zwischenablage.
5. In WoW **Guild Copilot → Warcraft Logs** öffnen, mit `Strg+V` einfügen und **Daten importieren** anklicken.

Klappt das, funktioniert derselbe Ablauf auch mit dem Gildenlink.

## Aufruf von Hand

Zugangsdaten für das aktuelle PowerShell-Fenster setzen:

```powershell
$env:WCL_CLIENT_ID = "deine-client-id"
$env:WCL_CLIENT_SECRET = "dein-client-secret"
```

Node.js 18 oder neuer wird benötigt; `Start-WCL-Import.cmd` prüft die Hauptversion vor dem Abruf:

```powershell
node .\WCL-Import.mjs "https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath"
```

| Option | Bedeutung |
| --- | --- |
| `--report <Code oder Link>` | genau ein Report statt der Gildenübersicht |
| `--reports <n>` | Anzahl der jüngsten Reports (Standard 3, Maximum 12) |
| `--profiles` | nur Spielerprofile, keine Raidauswertung |
| `--sessions` | nur Raidauswertung, keine Spielerprofile |
| `--debug` | schreibt jede Rohantwort nach `GuildCopilot-WCL-Debug.json` |
| `--out <Pfad>` | Zieldatei für den Importcode |

Danach liegt `GuildCopilot-WCL-Import.txt` im temporären Windows-Ordner. Beim Start über die `.cmd` kopiert das Startprogramm ihren Inhalt automatisch in die Zwischenablage.

## Wenn nichts ankommt

Der Companion protokolliert jeden Schritt einzeln – Anmeldung, Reportsuche, dann Report für Report. Die Zeile, nach der es aufhört, benennt die Ursache:

- **Anmeldung fehlgeschlagen (401)** – Client ID oder Secret stimmen nicht.
- **Keine öffentlichen Reports gefunden** – darunter steht, welche Warcraft-Logs-Seiten und welche Schreibweisen des Gildennamens versucht wurden. Warcraft Logs betreibt je Spielvariante eine eigene Seite; der Companion probiert `fresh`, `classic` und `www` durch. Steht überall `0 Reports`, sind die Reports privat oder unter einem anderen Gildennamen abgelegt. Dann hilft der Weg über einen einzelnen Report.
- **Report ohne Nachanalyse** – die Profile sind trotzdem in der Datei; die Meldung nennt den Grund für den fehlenden Teil.
- **Größe über 60000 Zeichen** – zu viel für ein Einfügen in WoW. Mit `--reports 1` erneut laufen lassen.

Mit `--debug` landen alle Rohantworten in `GuildCopilot-WCL-Debug.json` neben der Importdatei. Die Datei enthält keine Zugangsdaten und lässt sich gefahrlos weitergeben.

## Was abgefragt wird

Je Report: Kampfabschnitte (nur Encounter, kein Trash), Teilnahme, Anwesenheitszeit, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände. Ausgewertet wird über die Ereignisliste (`events`) und nicht über die aufbereiteten Tabellen: dort steht je Ereignis eine Akteurs-ID und eine Spell-ID, das ist unabhängig von der Tabellenform und damit stabil.

Interrupts, Dispels, Wiederbelebungen und Verbrauchsgegenstände werden über den ganzen Report gezählt, also auch zwischen Bosskämpfen und auf Trash. Als Teilnehmer erscheinen trotzdem ausschließlich Spieler, die in mindestens einem Encounter geführt wurden; Zuschauer oder reine Trash-Akteure erzeugen keine Zeile mit null Anwesenheit.

Zwei Fallstricke der API sind der Grund, warum ältere Fassungen des Companions nie durchliefen:

1. `playerDetails` und `table` brauchen ein echtes Zeitfenster. Sind `startTime` und `endTime` beide 0, antwortet die API mit einem Fehler statt mit leeren Daten.
2. Die JSON-Form der `table`-Antworten hängt am Datentyp; eine feste Erwartung an die Verschachtelung geht schief.

Verbrauchsgegenstände werden als reine `Spell-ID:Anzahl`-Paare übertragen. In welche Kategorie eine ID fällt, entscheidet allein `GC.Consumables` im Addon; unbekannte IDs werden dort ignoriert und erzeugen nie falsche Zahlen.

Der zuletzt beobachtete Spec wird Primär-Spec, ein weiterer beobachteter Spec wird Dual-Spec. Private Reports werden mit dem Client-Credentials-Verfahren bewusst nicht gelesen.

## Importformat

Die erzeugte Datei beginnt mit `GCPWCL3|<Anzahl Reports>`, danach folgen Profilzeilen `Name;Klasse;Primär-Spec;Dual-Spec` und je Report ein Block aus einer Sitzungszeile `S|…` und Teilnehmerzeilen `P|…`. Das Addon liest `GCPWCL1`, `GCPWCL2` und `GCPWCL3`; Zeilen werden feldweise zerlegt, damit ein Companion anderen Alters keinen Import verhindert.

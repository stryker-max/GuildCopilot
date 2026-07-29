# Plan 0.9.28 – Postfach-Aufwertung und Warcraft-Logs-Quelle

> **Status: umgesetzt in Addon-Version 0.9.28.** Dieses Dokument bleibt als
> Entwurfs- und Begründungsprotokoll erhalten; der ausgelieferte Stand steht im
> ROADMAP-Abschnitt „0.9.28“.
>
> Abweichungen von diesem Entwurf bei der Umsetzung:
> - **Klassenfarben** kommen aus `GC.Classes[classFile].color` statt aus
>   `RAID_CLASS_COLORS`. Die Tabelle enthält bereits exakt die Blizzard-Farben,
>   ist ohne WoW-Umgebung testbar und wird im übrigen UI schon verwendet.
> - **A2 (Stufe)** wurde bewusst nicht gebaut (Begründung im ROADMAP-Eintrag).
>   Datenmodell (`lead.level`) und Anzeige sind vorbereitet.
> - Die URL-Erzeugung für eine empfangene Gildenquelle liegt in
>   `GC.WarcraftLogs:ApplySource`, damit das Pfad-Encoding an einer Stelle bleibt
>   und `Sync.lua` keine URLs zusammenbaut.
> - Zusätzlich nötig: `WCL_UPDATED` frischt jetzt auch das Postfach auf, sonst
>   zeigen die Profil-Links bis zum Seitenwechsel den alten Realm.
>
> Alle Datei- und Zeilenangaben unten beziehen sich auf den Stand **vor** der
> Umsetzung (Addon **0.9.27**, Commit `ca0c569`).

## Auftrag des Repository-Owners (Zusammenfassung)

1. **Postfach, linke Liste:** Interessenten („Leads“) in der korrekten
   Klassenfarbe anzeigen, dazu die Stufe des Spielers, *falls technisch machbar*
   („wenn nicht – dann nicht“).
2. **Postfach, rechtes Unterhaltungsfenster:** Zwei automatisch generierte,
   kopierbare Links zum ausgewählten Interessenten:
   - Zeile 1: Charakterprofil auf `https://classic-armory.org/` (zum Inspizieren),
   - Zeile 2: Charakterprofil auf `https://de.fresh.warcraftlogs.com/`.
3. **Warcraft-Logs-Seite:** Den Zweck des Gildenquelle-Felds klären/schärfen
   (Frage des Owners: „Welchen Sinn hat es, die URL einzufügen, wenn ich die
   Daten eh manuell importieren muss?“) und sicherstellen, dass einmal
   importierte Daten gildenweit synchronisiert und account-weit gespeichert
   sind.

## Bestandsaufnahme (was heute schon existiert)

Diese Fakten wurden im Code verifiziert; die Umsetzung MUSS darauf aufbauen
statt Parallelstrukturen zu erfinden.

### Leads / Postfach

- Lead-Erfassung: `GC.Chat:CaptureLead(message, sender, guid, source)` in
  `GuildCopilot/Chat.lua` (~Zeile 341). Ein Lead-Datensatz enthält bereits:
  `name`, **`guid`**, `firstSeenAt`, `lastSeenAt`, `unread`, `source`,
  `messages[]` (max. 20). Gespeichert in `GC.DB:GetGuild().inbox`
  (SavedVariables `GuildCopilotDB` → account-weit, pro Gilde).
- **Die GUID des Absenders wird also schon heute erfasst** (aus
  `CHAT_MSG_WHISPER`/`CHAT_MSG_CHANNEL`-Args). Damit ist die Klasse ohne jede
  neue Datenerhebung ableitbar: `GetPlayerInfoByGUID(guid)` liefert
  `localizedClass, englishClass (classFile), localizedRace, englishRace, sex,
  name, realm`. **Sie liefert KEIN Level** – siehe Teil A2.
- Duplikat-Zusammenführung: `SameLead(...)` + `MergeDuplicateLeads()`
  (Chat.lua ~Zeile 180 ff.) – neue Lead-Felder müssen dort beim Mergen
  berücksichtigt werden (Feld vom Duplikat übernehmen, wenn eigenes leer).
- UI: `GC.UI:BuildInboxPage()` (`GuildCopilot/UI.lua` ~2722),
  `GC.UI:RefreshInbox()` (~2979). Linke Liste: `page.leadButtons`
  (Beschriftung ~2029–3033: `"•  " .. PlayerShortName(lead.name) .. "(n)"`).
  Rechts: `page.leadTitle` (Kopf, ~3063 ff.), `page.lastMessage`,
  Antwortvorschau `page.replyEdit`, Knöpfe Danke/Gildeninfos/Discord,
  Antworten/Einladen, 7-Tage/Ignorieren.
- Klassenfarben/-symbole: Das UI nutzt bereits `SetClassIcon(...)` und ein
  `THEME`; für Farbtext existieren im Projekt Hex-Inlinefarben
  (`|cff...|r`-Muster überall in UI.lua).

### Warcraft Logs

- Modul `GuildCopilot/WarcraftLogs.lua`. Quelle:
  `GC.WarcraftLogs:SaveSource(url)` (~125) → parst über `ParseGuildURL`
  (~80–112) und speichert **strukturiert**:
  `guildData.warcraftLogs.url/.region/.serverSlug/.guildSlug`.
- **Fund/Bug für diesen Plan relevant:** `ParseGuildURL` akzeptiert jeden
  `*.warcraftlogs.com`-Host, **verwirft ihn aber** und normalisiert die
  gespeicherte URL hart auf `https://fresh.warcraftlogs.com/...` (~Zeile 107).
  Gibt der Owner `https://de.fresh.warcraftlogs.com/...` ein, geht die
  Sprachvariante verloren.
- `REGION_SLUGS` + `GC.WarcraftLogs:GetSuggestedURL()` (~114) existieren
  (Region aus `GetCurrentRegion()`, Realm aus `GetNormalizedRealmName()`).
  `EncodePath`/`DecodePath` (URL-Encoding) existieren im selben Modul.
- **Der Profil-Sync existiert bereits** (seit 0.9.22, „recruitmentsync“):
  `BuildRecruitmentSyncRecords/-Messages` (~487/565),
  `RequestRecruitmentData` (~613), Empfang mit `importedAt`-Revision
  (~698–817): Der **neueste vollständige Datensatz eines Online-Mitglieds
  gewinnt** und wird in `guildData.warcraftLogs.members` übernommen –
  account-weit persistent. Kampf-/Sessiondaten werden bewusst NICHT
  synchronisiert (Designentscheidung 0.9.22, beibehalten).
- Addon-seitiger HTTP-Abruf ist **verboten und technisch unmöglich**:
  `tests/validate.mjs` schlägt bei `C_HTTP|socket.http|HttpRequest` fehl;
  WoW-Addons haben keine Netzwerk-API. Deshalb existiert der
  Companion/Installer-Weg (Zwischenablage → „Daten importieren“).

### Projektregeln (aus AGENTS.md + gelebter Praxis dieser Session)

- Fertige, verifizierte Release-Änderungen direkt auf `main` pushen.
- Versionsnummer bei JEDEM Release anheben – synchron in:
  `GuildCopilot/GuildCopilot.toc`, `GuildCopilot/Constants.lua`,
  `README.md` (Kopfzeile **und** Zeile „…das Addon bei X.Y.Z…“),
  `tests/validate.mjs` (requiredMetadata) und neuer Abschnitt in `ROADMAP.md`
  (+ „Offene Punkte (Stand X.Y.Z)“ anpassen). Installer (1.0.3) NICHT anfassen.
- Tests müssen grün sein: `lua5.1 tests/smoke.lua` und
  `node tests/validate.mjs`. smoke.lua: Lua-5.1-Limit von 200 lokalen
  Variablen im Hauptchunk beachten → neue Testvariablen **global** anlegen
  (bestehendes Muster am Dateiende).
- `SCHEMA_VERSION` bleibt 7; Erweiterungen nur **additiv** (neue Felder am
  Paketende, alte Clients ignorieren sie – bewährtes Muster, siehe
  Gildenprofil-Felder 21–23 und Werkstatt-Feld 12).
- Sync-Grundregel des Owners: **rangunabhängig, neueste Daten gewinnen**
  (Zeitstempelvergleich beim Empfänger), Transport über den **Gildenkanal**
  (Whisper ist in der Zielumgebung unzuverlässig).

---

## Teil A – Postfach

### A1: Klassenfarbe (und Klasse) am Interessenten — Kernstück, rein lokal

**Datenmodell.** Lead um zwei Felder erweitern (persistiert, additiv):

```lua
lead.classFile = "PALADIN" | ... | nil   -- englishClass aus GetPlayerInfoByGUID
lead.level     = 70 | nil                 -- siehe A2, bleibt meist nil
```

**Befüllung.**
1. In `CaptureLead` direkt nach dem Anlegen/Auffrischen: wenn `lead.guid`
   vorhanden und `lead.classFile` leer →
   `local _, classFile = GetPlayerInfoByGUID(lead.guid)`; nur übernehmen, wenn
   `GC.Classes[classFile]` existiert (Validierung wie überall im Projekt).
   `GetPlayerInfoByGUID` kann direkt nach Login `nil` liefern (Cache kalt) –
   deshalb zusätzlich:
2. **Lazy-Nachrüstung beim Rendern:** In `RefreshInbox` für sichtbare Leads
   ohne `classFile`, aber mit `guid`, denselben Aufruf erneut versuchen
   (idempotent, kostenlos). Damit werden auch **Bestandsleads** aus alten
   SavedVariables nachträglich eingefärbt.
3. In `MergeDuplicateLeads`: `lead.classFile = lead.classFile or duplicate.classFile`
   (und `level` analog).

**Darstellung.**
- Linke Liste (`RefreshInbox`, Lead-Button-Beschriftung): Namen in
  Klassenfarbe. Farbe: `RAID_CLASS_COLORS[classFile].colorStr`
  (Fallback-Kette: `CUSTOM_CLASS_COLORS` → `RAID_CLASS_COLORS` → THEME-Text).
  Beispiel-Beschriftung:
  `•  |cfff58cbaDotlordd|r  (3)` bzw. mit Stufe `•  |cfff58cbaDotlordd|r  70  (3)`
  – Stufe nur anhängen, wenn `lead.level` gesetzt ist (A2), sonst NICHTS
  („wenn nicht – dann nicht“).
- Rechter Kopf `page.leadTitle`: Name ebenfalls einfärben; optional die
  lokalisierte Klasse als Zusatz („Dotlordd – Paladin“), da
  `GetPlayerInfoByGUID` auch `localizedClass` liefert. Lokalisierte Klasse
  NICHT persistieren (Locale-abhängig) – bei Bedarf live aus der GUID oder aus
  `GC.Classes[classFile]`-Daten ableiten.

**Tests (smoke.lua).**
- Mock `GetPlayerInfoByGUID` global bereitstellen (liefert für eine Test-GUID
  `"Paladin", "PALADIN", ...`), `CaptureLead` mit GUID aufrufen →
  `inbox[1].classFile == "PALADIN"`.
- Lead ohne GUID → `classFile == nil`, kein Fehler.
- Button-Text enthält den Farbcode der Klasse (String-Find auf `colorStr`).

### A2: Stufe des Spielers — optional, Phase 2, ausdrücklich abschaltbar

Es gibt **keine** API, die aus einer GUID das Level liefert. Realistische
Wege, ehrlich bewertet:

| Weg | Bewertung |
|---|---|
| `C_FriendList.SendWho('n-"Name"')` + `WHO_LIST_UPDATE` | Einzig sauberer Weg. Aber: serverseitige Drossel (~1 Anfrage/10 s), Ergebnis nur wenn der Spieler **online** ist, und konkurriert mit manuellen `/who` des Nutzers. `C_FriendList.SetWhoToUi(true)` nutzen, Ergebnis aus `C_FriendList.GetNumWhoResults()/GetWhoInfo(i)` lesen, danach Zustand nicht kaputt lassen. |
| Level aus dem Nachrichtentext parsen | Unzuverlässig (Beispiel im Screenshot: „Spiele einen Pala und nen Warlock“ – zwei Chars, kein Level). NICHT umsetzen. |
| Inspect/UnitLevel | Nur bei sichtbaren Units in Reichweite. NICHT umsetzen. |

**Empfohlene Umsetzung (klein halten):**
- Nur **auf Klick** des Leads (Auswahl im Postfach), nie als Hintergrund-Scan
  über alle Leads.
- Drossel im Addon: höchstens 1 Who-Anfrage je 15 s UND je Lead höchstens
  1×/Sitzung (`lead.levelCheckedAt` als Session-Merker, nicht persistieren).
- Treffer → `lead.level` + Anzeige wie A1; kein Treffer (offline/gedrosselt) →
  stillschweigend nichts anzeigen.
- Wenn `C_FriendList` im Anniversary-Client fehlt oder sich die Drossel als
  störend erweist: Feature per Guard einfach nicht aktivieren –
  **A2 ist Abnahme-optional**, A1/A3 dürfen nicht daran hängen.

### A3: Kopierbare Profil-Links im Unterhaltungsfenster

**Platzierung.** In der `detailCard` („Unterhaltung“, `BuildInboxPage`
~2786 ff.) unterhalb von „Letzte Nachricht“/oberhalb der Antwortvorschau:
zwei einzeilige, schreibgeschützte EditBoxes mit Beschriftung
`Armory` und `Warcraft Logs`. Höhe je ~24 px, volle Kartenbreite; Karte ggf.
um ~60 px erhöhen (Layout-Konstanten in `BuildInboxPage` prüfen; die Seite
scrollt bereits).

**Copy-&-Paste-Muster (WoW kann keine Browser öffnen und nichts ins
Clipboard schreiben – der Nutzer markiert+kopiert selbst):**
```lua
edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
edit:SetScript("OnTextChanged", function(self, userInput)
    if userInput then self:SetText(self.linkValue or "") ; self:HighlightText() end
end)
edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
```
`edit.linkValue` bei jedem `RefreshInbox` für den ausgewählten Lead setzen.
Vorhandene `CreateEdit`-Fabrik in UI.lua wiederverwenden; kein neues
Widget-System bauen.

**Link-Erzeugung.** Neuer, kleiner Helfer im WCL-Modul (dort liegen
`EncodePath`, `REGION_SLUGS`, Quelle) – z. B.
`GC.WarcraftLogs:BuildCharacterLinks(leadName)` → `{ armory = "...", logs = "..." }`:

- **Namens-/Realm-Zerlegung:** `PlayerShortName(leadName)` = Charname;
  Realm-Anteil aus `leadName` hinter dem `-`, sonst eigener Realm.
- **Region:** `guildData.warcraftLogs.region` (aus gespeicherter Gildenquelle),
  Fallback `REGION_SLUGS[GetCurrentRegion()]`, Fallback `"eu"`.
- **Realm-Slug:** `guildData.warcraftLogs.serverSlug` (Leads flüstern in TBC
  vom selben Realm – die Gildenquelle ist die verlässlichste Slug-Quelle),
  Fallback: `GetNormalizedRealmName():lower()`.
- **Warcraft-Logs-Link:**
  `https://<host>/character/<region>/<serverSlug>/<EncodePath(charName)>`
  – `<host>` aus der gespeicherten Quelle (siehe B1!), Fallback
  `de.fresh.warcraftlogs.com` als Konstante (Owner-Wunsch: deutsche Variante).
- **Armory-Link:** URL-Template als Konstante in `Constants.lua`, Annahme:
  `https://classic-armory.org/character/<region>/<realmSlug>/<charName-lowercase>`.
  ⚠️ **Vor der Umsetzung einmal im Browser verifizieren** – die Seite blockt
  automatisierte Abrufe (HTTP 403), das exakte Pfadschema (inkl. ob
  Anniversary-Realms einen Präfix/Suffix im Realm-Slug tragen, z. B.
  `-anniversary`) konnte hier nicht maschinell geprüft werden. Template so
  bauen, dass NUR die Konstante angepasst werden muss.
- Kein gespeicherter Quell-Slug UND kein Realm ermittelbar → Boxen leeren und
  Hinweistext „Unter Warcraft Logs zuerst die Gildenquelle speichern.“ zeigen.

**Tests (smoke.lua).** `BuildCharacterLinks("Dotlordd")` mit gesetzter Quelle
(`region="eu", serverSlug="thunderstrike", host="de.fresh.warcraftlogs.com"`)
→ exakte URL-Strings prüfen; Sonderzeichen-Name (Umlaut) → `EncodePath`
greift; ohne Quelle → Fallback-Verhalten.

---

## Teil B – Warcraft-Logs-Quelle

### B0: Antwort auf die Sinnfrage (in UI-Text gießen)

Der Sinn des Feldes heute: Ein WoW-Addon darf/kann **kein HTTP** – der Abruf
läuft über den mitgelieferten Windows-Companion/Installer. Die im Addon
gespeicherte, strukturierte Quelle (`region/serverSlug/guildSlug`) wandert
über die SavedVariables zum Companion, sodass die Gilde dort nicht erneut
eingetippt werden muss („Die gespeicherte URL ist für den Companion
vorbereitet.“). Mit diesem Plan bekommt das Feld **zwei weitere Nutzen**:
Basis für die Charakter-Links (A3) und gildenweit geteilte Einstellung (B2).

**Maßnahme:** Statustext/Hilfetext der Karte „Gildenquelle“ entsprechend
erweitern (ein Satz, der die drei Zwecke nennt), damit die Frage sich im UI
selbst beantwortet.

### B1: Eingegebenen Host erhalten (Bugfix)

`ParseGuildURL` (~WarcraftLogs.lua:80–112): Host wird gegen
`*.warcraftlogs.com` validiert, aber die gespeicherte URL hart auf
`https://fresh.warcraftlogs.com/...` normalisiert.

**Änderung:**
- Validierten Host als `source.host` zurückgeben und in
  `guildData.warcraftLogs.host` persistieren (Fallback beim Lesen:
  `"fresh.warcraftlogs.com"` für Bestandsdaten).
- `data.url` aus `host` statt hart codiertem Präfix zusammensetzen.
- Ohne Schema eingegebene Kurzform (`eu/realm/gilde`, zweiter Match-Zweig)
  behält den Default-Host.
- `GetSuggestedURL()` optional auf `de.fresh.warcraftlogs.com` stellen –
  Owner ist deutschsprachig; Konstante, keine Logik.

### B2: Gildenquelle gildenweit synchronisieren

Damit nur EIN Mitglied die Quelle pflegen muss und Charakter-Links (A3) bei
allen funktionieren.

**Transport:** Bestehendes Gildenprofil-Paket (`GP`, `BuildGuildProfileMessages`
in `Sync.lua` ~618 ff.) um **ein** additives Feld am Ende erweitern
(Position 24): `host,region,serverSlug,guildSlug` **komma-getrennt in einem
Feld** (Kommas kommen in Slugs nicht vor; `EscapeField` schützt `|`).
Empfang in `ReceiveGuildProfileChunk`: Feld 24 vorhanden **und nicht leer** →
übernehmen; fehlt/leer → eigene Quelle **unangetastet lassen** (Muster der
Felder 21–23 exakt kopieren, Kommentar „Ältere Absender…“ inklusive).

**Konfliktregel:** Es gilt der bestehende `profile.updatedAt`-Vergleich des
GP-Pakets (rangunabhängig, neueste gewinnt) – KEIN eigener Zeitstempel nötig.
`SaveSource` muss dafür zusätzlich `guildData.profile.updatedAt = GC.Util.Now()`
setzen und `GC.Sync:QueueGuildProfile(true)` anstoßen (Muster:
`MemberCareSettingsChanged` in Roster.lua ~340).

**Wichtig:** Chunk-Größe des GP-Pakets beachten (`chunkSize = 175`,
`total ≤ 30` beim Empfänger, Sync.lua ~686/759): Das neue Feld verlängert die
Nutzlast um ≤ ~90 Bytes → 1 zusätzlicher Chunk, unkritisch. Test ergänzen:
GP-Roundtrip inkl. Quelle; Alt-Paket ohne Feld 24 löscht die Quelle nicht.

### B3: Import-Daten-Sync – Status quo dokumentieren + sichtbar machen

**Keine neue Sync-Maschinerie bauen.** Die Rekrutierungsprofile aus dem
WCL-Import werden bereits gildenweit geteilt (recruitmentsync, `L|`-Pakete,
`importedAt`-Revision, neuester Datensatz gewinnt) und account-weit
gespeichert (`guildData.warcraftLogs.members`). Zwei kleine Ergänzungen:

1. **Herkunft anzeigen:** Beim Übernehmen eines empfangenen Datensatzes
   (`ReceiveSync`, ~812 ff.) zusätzlich `data.lastSyncFrom = PlayerShortName(sender)`
   speichern. Die Status-Karte der WCL-Seite (UI) zeigt dann:
   „N Profile · Stand <Datum aus importedAt> · zuletzt von <Name>“ statt
   „Noch keine Log-Daten importiert.“, sobald Daten (egal ob importiert oder
   empfangen) vorhanden sind.
2. **Kampf-/Sessiondaten bleiben lokal** (bewusste 0.9.22-Entscheidung,
   Gildenkanal-Budget!) – im Hilfetext der Import-Karte einen Halbsatz
   ergänzen, damit die Erwartung stimmt: „Profile werden automatisch in der
   Gilde geteilt; vollständige Kampfauswertungen bleiben lokal.“

---

## Ausdrückliche Nicht-Ziele

- Kein HTTP/Netzwerkzugriff aus dem Addon (verboten, validate.mjs wacht darüber).
- Kein automatisches Öffnen von Browser-Links (WoW-API kann das nicht;
  Copy-&-Paste-EditBox ist der korrekte Weg).
- Keine Synchronisierung vollständiger WCL-Kampfdaten über den Gildenkanal.
- Kein neues Whisper-Protokoll – alles Neue läuft über bestehende
  Gildenkanal-Pfade.
- Keine Installer-Änderung (bleibt 1.0.3).

## Empfohlene Umsetzungsreihenfolge

| Schritt | Inhalt | Risiko |
|---|---|---|
| 1 | B1 Host erhalten (kleiner Bugfix + Tests) | gering |
| 2 | A1 Klassenfarbe + A3 Links (rein lokal, keine Protokolländerung) | gering |
| 3 | B0 + B3 (UI-Texte, `lastSyncFrom`) | gering |
| 4 | B2 Quelle ins GP-Paket (Protokoll additiv, Roundtrip-Tests) | mittel |
| 5 | A2 Stufe per Who (optional; bei Problemen ersatzlos weglassen) | mittel |

Schritte 1–4 als **ein** Release `0.9.28` (Checkliste unter „Projektregeln“
abarbeiten, ROADMAP-Abschnitt „0.9.28“ ergänzen); A2 nur aufnehmen, wenn es
im Anniversary-Client nachweislich sauber funktioniert – andernfalls im
ROADMAP-Eintrag als bewusst ausgelassen dokumentieren.

## Abnahmekriterien

1. Interessent mit bekannter GUID erscheint links UND im Unterhaltungskopf in
   seiner Klassenfarbe; Bestandsleads färben sich spätestens beim Öffnen des
   Postfachs nach. Leads ohne GUID bleiben neutral, ohne Fehler.
2. Für den ausgewählten Interessenten stehen zwei kopierbare Links bereit
   (Armory + Warcraft Logs), die Host, Region und Realm-Slug aus der
   gespeicherten Gildenquelle verwenden; Fokus in die Box markiert den
   gesamten Link; der Text ist nicht editierbar (Tippen stellt ihn wieder her).
3. `de.fresh.warcraftlogs.com` als Gildenquelle überlebt Speichern & Neuladen
   (Host wird nicht mehr auf `fresh.` normalisiert).
4. Speichert ein beliebiges Mitglied die Gildenquelle, erscheint sie nach dem
   GP-Abgleich bei allen 0.9.28-Clients; ältere Clients stören den Abgleich
   nicht und verlieren nichts.
5. Die WCL-Status-Karte zeigt Profilzahl, Stand und Absender des zuletzt
   übernommenen Datensatzes.
6. `lua5.1 tests/smoke.lua` und `node tests/validate.mjs` sind grün; alle
   neuen Pfade (A1-Erfassung, A3-Linkbau, B1-Host, B2-Roundtrip) sind durch
   Regressionstests abgedeckt.

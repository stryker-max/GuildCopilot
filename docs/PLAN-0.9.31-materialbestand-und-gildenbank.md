# Plan 0.9.31 – Materialbestand: eigene Taschen, Bank, Twinks und Gildenbank

> **Status: umgesetzt in Addon-Version 0.9.31.** Dieses Dokument bleibt als
> Entwurfs- und Begründungsprotokoll erhalten; der ausgelieferte Stand steht im
> ROADMAP-Abschnitt „0.9.31“.
>
> Abweichungen und Ergänzungen bei der Umsetzung:
> - Die Container-API wird **defensiv** angebunden: `C_Container` zuerst, die
>   klassischen Globalen als Rückfall, Item-IDs bevorzugt aus dem Item-Link
>   (der einzige Weg, der in allen Client-Fassungen gleich funktioniert). Die
>   Gildenbank-Signaturen konnten **nicht im Spiel verifiziert** werden; alle
>   Aufrufe laufen daher über einen `pcall`-Wrapper und Existenzprüfungen –
>   fehlt eine Funktion, bleibt die Anzeige leer statt zu brechen.
> - `GUILDBANKBAGSLOTS_CHANGED` nennt den betroffenen Tab nicht. Gelesen wird
>   deshalb der aktuell offene Tab (`GetCurrentGuildBankTab`) plus alle noch
>   ausstehenden; ein leeres Ergebnis überschreibt einen vorhandenen Stand
>   nicht, weil die Abfrage womöglich noch läuft.
> - Schritt 6 (Manifest-zuerst) wurde als eigener Nachrichtentyp `KM`/`KR`
>   umgesetzt statt das Whisper-`M`-Format zu heben – letzteres trägt keinen
>   Herstellernamen und hätte Twink-Berufe nicht abdecken können.
> - Schritt 7 (Punkt in der Rezeptliste, Favoriten-Einkaufsliste) ist weiterhin
>   offen und war ausdrücklich nicht Teil der Abnahme.
>
> Datei- und Zeilenangaben unten beziehen sich auf den Stand **vor** der
> Umsetzung (Addon **0.9.30**, Commit `a2aedc7`).

## Auftrag des Repository-Owners (Zusammenfassung)

Die Gildenwerkstatt beantwortet „wer kann das herstellen?“. Jetzt fehlt die
Materialseite:

1. **Habe ich die Reagenzien?** In Taschen, auf der eigenen Bank – und in
   welchen Mengen? Was fehlt mir konkret? (Bestände der eigenen Twinks zählen
   dazu, das Addon kennt sie aus der gemeinsamen SavedVariables.)
2. **Hat die Gildenbank die Reagenzien?** In welchen Mengen?
3. **Gildenbank-Synchronisation unter den Mitgliedern** – Konfliktregel wie
   immer: die aktuellsten Daten gewinnen.
4. **Anzeige in der Werkstatt:** je Reagenz sichtbar machen, was in eigener
   Bank/Inventar und was in der Gildenbank liegt – „überlege dir da eine
   schöne Lösung“.
5. **Datenlast im Blick behalten:** Das Addon synchronisiert inzwischen viel.
   Die Last soll verschlankt werden, wo es ohne Funktionsverlust geht –
   „Funktion muss immer erhalten bleiben“.

## Bestandsaufnahme (verifiziert am Code, Stand 0.9.30)

- **Es gibt noch keinerlei Taschen-, Bank- oder Gildenbank-Code** im Addon
  (grep über `GetContainerItem|C_Container|BANKFRAME|GUILDBANK|BAG_UPDATE`
  liefert nichts). Alles in diesem Plan ist Neubau auf grüner Wiese.
- **Freier Nachrichtentyp:** Auf dem Gildenkanal sind `P, V, W, L, G, E, GQ,
  RQ` belegt (Router in `Sync.lua`, `GC.Sync:OnMessage`, ~Zeile 1270 ff.).
  **`B|` ist frei** und wird für alles Gildenbank-bezogene verwendet.
- **Anzeigeort:** Die Reagenzienliste des ausgewählten Rezepts entsteht in
  `GC.UI:RefreshWorkshop` (`UI.lua` ~2328–2335, „Materialien“-Block, heute
  reine Textzeilen `"6× Name"`). Die Status-Fußzeile der Werkstatt liegt
  direkt darunter (~2348 ff.).
- **Namensauflösung:** `GET_ITEM_INFO_RECEIVED` ist bereits abonniert
  (`Workshop.lua` ~1785) und feuert `WORKSHOP_UPDATED` → die UI aktualisiert
  sich von selbst, wenn Itemnamen nachträglich eintreffen. Dasselbe Muster
  trägt die neuen Bestandszahlen mit.
- **Wiederverwendbare Muster aus 0.9.27–0.9.30** (alle in `Workshop.lua`):
  - Paket-Budget aus dem echten 255-Byte-Limit minus tatsächlicher Kopfzeile
    (`BuildKeyListMessages` als Vorlage für byteweise geteilte Nutzlasten);
  - Differenz-Kodierung sortierter IDs (`EncodeRecipeKeys`/`DecodeRecipeKeys`);
  - Nachforderung mit Streuung + Unterdrückung, damit nicht hundert Clients
    dasselbe anfragen (`ScheduleMissingRecipeRequest`);
  - Capability-Gate im Handshake (`workshop4`-Muster in `Constants.lua`);
  - „neueste gewinnen“ über Zeitstempelvergleich beim Empfänger;
  - `SafeAPICall`-Duo für moderne und klassische API-Varianten
    (`ScanModernProfession` vs. Classic-Pfade).
- **Aggregation über eigene Charaktere:** `GC.Workshop:GetAccountProfessions`
  und der Twink-Teil von `GetCatalog` zeigen das Muster, Account-Daten aus
  `GC.DB.data.characters` einzusammeln (`character.fullName` als Name).

## WoW-API-Fakten (TBC Anniversary, Interface 20506)

⚠️ Die genauen Signaturen im Anniversary-Client **vor der Umsetzung einmal
im Spiel verifizieren** (`/dump`), das Addon läuft nicht gegen eine
dokumentierte Sandbox. Erwartete Lage:

| Quelle | Lesbar wann? | APIs | Events |
|---|---|---|---|
| Taschen (Container 0–4) | jederzeit | `C_Container.GetContainerNumSlots/GetContainerItemInfo` mit Fallback `GetContainerNumSlots/GetContainerItemInfo`; ItemID robust aus `GetContainerItemLink` + vorhandenem `ItemIDFromLink` | `BAG_UPDATE` (feuert oft → drosseln) |
| Eigene Bank (Container −1, Banktaschen 5–11) | **nur bei geöffnetem Bankfenster** | dieselben Container-APIs | `BANKFRAME_OPENED`, `PLAYERBANKSLOTS_CHANGED`, `BANKFRAME_CLOSED` |
| Gildenbank (bis **6 Tabs à 98 Slots** in TBC) | **nur am Gildenbank-NPC** | `GetNumGuildBankTabs()`, `GetGuildBankTabInfo(tab)` → `name, icon, isViewable, canDeposit`, `QueryGuildBankTab(tab)` (asynchron!), `GetGuildBankItemLink(tab, slot)`, `GetGuildBankItemInfo(tab, slot)` → `texture, count, locked` | `GUILDBANKFRAME_OPENED`, `GUILDBANKBAGSLOTS_CHANGED`, `GUILDBANKFRAME_CLOSED` |

Zwei Eigenheiten mit Architekturfolgen:

1. **Gildenbank-Tabs kommen asynchron.** Nach `QueryGuildBankTab(tab)`
   liefert erst `GUILDBANKBAGSLOTS_CHANGED` die Slots. Ein Tab darf erst dann
   als „gelesen“ gelten. Beim Öffnen alle sichtbaren Tabs **gestaffelt**
   abfragen (~0,5 s Abstand), nicht in einer Schleife.
2. **`isViewable` hängt am Gildenrang.** Ein Mitglied sieht womöglich nicht
   alle Tabs. Daraus folgt zwingend: Snapshot, Zeitstempel und
   Synchronisation **je Tab**, nie „die ganze Bank“ – sonst überschreibt der
   rangbeschränkte Snapshot eines Mitglieds den vollständigen eines
   Offiziers. Unsichtbare Tabs werden weder gesendet noch lokal angetastet.

## Datenmodell

### Eigene Bestände – lokal, account-weit, NIE synchronisiert

Neues Modul `GuildCopilot/Inventory.lua` (in der TOC vor `Workshop.lua`
einreihen; `validate.mjs` verlangt `local _, GC = ...`).

```lua
-- GC.DB:GetCharacter().inventory
inventory = {
    bags = { counts = { [itemID] = anzahl }, updatedAt = 0 },
    bank = { counts = { [itemID] = anzahl }, updatedAt = 0 },
}
```

Bewusst die **komplette Zähltabelle**, nicht nur „relevante“ Reagenzien: ein
Charakter hat höchstens ~100 Taschen- und ~180 Bankplätze, die Tabelle bleibt
also klein, und es gibt keinen Pflegeaufwand, wenn neue Rezepte neue
Reagenzien einführen.

Aggregation (im Inventory-Modul):

```lua
GC.Inventory:GetOwnCounts(itemID)
-- -> { bags=n, bank=n, alts=n, total=n,
--      perCharacter = { {name, bags, bank, bankAt}, ... }, oldestBankAt }
```

`alts` läuft über `GC.DB.data.characters` nach dem Muster von
`GetAccountProfessions`. Privatbestände verlassen den Account nie – es gibt
schlicht keinen Sync-Pfad dafür.

### Gildenbank – gildenweit, je Tab

```lua
-- GC.DB:GetGuild().guildBank
guildBank = {
    tabs = {
        [tabIndex] = {
            name = "Mats",
            counts = { [itemID] = anzahl },
            updatedAt = 0,     -- Snapshot-Zeitpunkt (Konfliktregel)
            seenBy = "Synkos", -- wer den Snapshot eingelesen hat (Kurzname)
            fingerprint = "…", -- Hash über sortierte itemID:count-Paare
        },
    },
}
```

`GUILD_DEFAULTS` in `Database.lua` entsprechend ergänzen (`MergeDefaults`
versorgt Bestandsdaten automatisch). Der vorhandene `FingerprintHash` aus
`Workshop.lua` wird herausgezogen oder dupliziert (kleine Funktion).

## Erfassung

- **Taschen:** `BAG_UPDATE` gedrosselt (≥ 1 s Sammelfenster über
  `C_Timer.After`, Muster `ScheduleScan`), dann Container 0–4 zählen.
- **Eigene Bank:** Snapshot bei `BANKFRAME_OPENED` und je
  `PLAYERBANKSLOTS_CHANGED`; Container −1 plus 5–11. `updatedAt` setzen –
  die Anzeige darf „Bankstand vom …“ sagen, denn er veraltet, sobald der
  Spieler ohne Addon-Sicht Items bewegt (kann in TBC nur am Bankfenster
  passieren, ist also praktisch immer aktuell).
- **Gildenbank:** Bei `GUILDBANKFRAME_OPENED` sichtbare Tabs
  (`isViewable == true`) gestaffelt per `QueryGuildBankTab` anfordern. Ein
  Tab wird erst nach seinem `GUILDBANKBAGSLOTS_CHANGED` gezählt
  (`locked`-Slots zählen normal). Je gelesenem Tab: `counts`, `name`,
  `updatedAt = Now()`, `seenBy = eigener Kurzname`, `fingerprint` neu.
  Beim Schließen (`GUILDBANKFRAME_CLOSED`) den Sync anstoßen (unten).

## Synchronisation – nur die Gildenbank, und so sparsam wie möglich

Neuer Top-Level-Typ **`B|`** auf dem Gildenkanal, geroutet in
`GC.Sync:OnMessage` → `GC.Inventory:ReceiveSync(fields, sender)` (Weiche
neben `"W|"` einhängen; `NoteAddonUser`-Zeile um `"B"` ergänzen, damit auch
diese Pakete den Absender als Addon-Nutzer sichtbar machen).

Drei Operationen – **Manifest zuerst, Volldaten nur bei Abweichung** (die
Kernantwort auf die Datenlast-Sorge):

| Op | Nutzlast | Wann |
|---|---|---|
| `BM` (Manifest) | je sichtbarem Tab `index,updatedAt,fingerprint` – **ein Paket** | nach jedem Gildenbank-Besuch; als Antwort auf `BQ` (gedrosselt + zufällig gestreut, Muster `ReplyToGuildProfileRequest`) |
| `BQ` (Anfrage) | leer | beim Login (einmal, ~12 s versetzt zu den bestehenden Login-Sendungen) |
| `BT` (Tab-Daten) | ein Tab: `index`, `name`, `updatedAt`, `seenBy`, Paare `idDelta:count` (IDs sortiert, Differenz-kodiert wie `EncodeRecipeKeys`), byteweise gechunkt mit Kopfzeilen-Budget (Vorlage `BuildKeyListMessages`) | **nur auf `BR`-Anforderung** |
| `BR` (Tab-Anforderung) | Tab-Indizes | wenn ein empfangenes Manifest einen neueren `updatedAt` oder abweichenden Fingerprint zeigt als der eigene Stand – mit Streuung und Unterdrückung (Muster `ScheduleMissingRecipeRequest`): sieht ein Client die `BR` eines anderen, stellt er seine eigene zurück; der Halter des neuesten Standes antwortet mit `BT` |

Empfangsregeln:

- `BT` wird nur übernommen, wenn `updatedAt` **neuer** ist als der lokale
  Tab-Stand (rangunabhängig, „aktuellste Daten gewinnen, wie immer“).
- Ein Manifest **ohne** einen Tab sagt nichts über diesen Tab aus (Absender
  darf ihn ggf. nicht sehen) – niemals löschen, nur ersetzen.
- Größenwächter analog Werkstatt: Tab-Index 1–8, `#name ≤ 40`, Paare-Anzahl
  ≤ 98 zzgl. Toleranz, Teilezahl ≤ 30.

**Kostenrechnung** (Differenz-Kodierung, 98 Slots ≈ ≤ 98 verschiedene IDs →
~700 Bytes ≈ 5 Pakete je Tab): Ein Bankbesuch, der zwei Tabs verändert,
kostet gildenweit **1 Manifest-Paket + ~10 Tab-Pakete – einmal**, nicht je
Mitglied. Ein Login kostet **1 `BQ` + höchstens 1 `BM`**-Antwort, solange
sich nichts geändert hat: null Tab-Pakete. Das ist die mit Abstand
billigste Sync-Klasse im Addon.

Capability `inventory1` in `GC.Capabilities` eintragen (Erkennung, kein
Gate – alte Clients ignorieren `B|` ohnehin kommentarlos).

## Anzeige in der Werkstatt („schöne Lösung“)

Der „Materialien“-Block der Rezeptdetails (`RefreshWorkshop`) wird von
Textzeilen zu einer kompakten dreispaltigen Darstellung – weiterhin als
formatierte Textzeilen realisierbar (Monoausrichtung über feste Spalten ist
im bestehenden Label-Layout ausreichend; alternativ drei FontStrings je
Zeile, Entscheidung dem Umsetzer überlassen):

```
Materialien                          Du   GBank
 6× Urmacht                        2 ✗    4 ✓
10× Großer Prismasplitter         14 ✓   32 ✓
 8× Arkaner Staub                120 ✓    –
─────────────────────────────────────────────
Fehlt dir: 4× Urmacht  ·  4 davon in der Gildenbank
Gildenbank-Stand: heute 21:14 von Synkos
```

- **Ampellogik je Reagenz:** grün (`THEME.success`) = eigener Bestand deckt
  den Bedarf; gelb (`THEME.warning`) = erst eigener Bestand **plus**
  Gildenbank decken ihn; rot (`THEME.danger`) = fehlt auch zusammen.
  `–` = Gildenbank hat keinen Stand zu diesem Item (oder nie eingelesen).
- **„Du“** = Taschen + Bank + Twinks. Tooltip auf der Zeile (GameTooltip auf
  einem unsichtbaren Hover-Frame je Zeile, Phase 2 falls aufwendig):
  Aufschlüsselung `Taschen 2 · Bank 0 · Twink Zwergenschmied 0` samt
  Bankstand-Datum je Charakter.
- **Summenzeile** unter der Liste: was konkret fehlt und wie viel davon die
  Gildenbank hätte – das ist die eigentliche Antwort auf „was fehlt mir?“.
- **Herkunftszeile:** Gildenbank-Stand mit Datum und `seenBy`; wurde die
  Gildenbank noch nie eingelesen: `„Gildenbank unbekannt – einmal am
  Bankfach öffnen genügt.“`
- Kartenhöhe: der Detailbereich (`workshopDetailContent`) skaliert bereits
  mit `#lines`; die Spaltenzeilen laufen über dieselbe Mechanik.
- **Phase 2 (optional, nicht Abnahme):** kleiner Farbpunkt in der
  Rezeptliste links („alles vorhanden / mit GBank / fehlt“) und eine
  „Einkaufsliste“ über alle Favoriten.

## Datenlast-Budget (Antwort auf „eventuell verschlanken, Funktion erhalten“)

Inventur der Sync-Ströme nach diesem Plan, je Client und Login:

| Strom | heute | Kosten/Login |
|---|---|---|
| Profil `P` | Broadcast + Antwort auf `V`-Anfrage | 1–2 Pakete |
| Gildenprofil `G` | `GQ`-Antwort gedrosselt, ein Antworter | ~10–15 Chunks, nur wenn jemand fragt |
| Werkstatt `W` | Schlüssellisten aller Account-Berufe beim Login **immer** | ~14 Pakete |
| Ausrüstung `E` | Snapshot auf Handshake-Anfrage | wenige Pakete |
| Rekrutierung `L` | Manifest/Angebot, ein Anbieter | klein |
| **Gildenbank `B` (neu)** | Manifest-zuerst | **1–2 Pakete**, Tab-Daten nur bei echter Änderung |

Festgeschriebene Prinzipien für alles Künftige (und Nachrüstkandidaten):

1. **Manifest zuerst** – Volldaten nur bei nachgewiesener Abweichung
   (Fingerprint/Zeitstempel).
2. **Unverändert → gar nichts senden.**
3. **Ein Antworter statt aller** – Streuung + Unterdrückung bei jeder
   Anfrage, die mehrere beantworten könnten.
4. **Zielgröße:** Login-Gesamtlast eines Clients ≤ ~30 Pakete.

Konkrete Verschlankung **ohne Funktionsverlust** als Teil dieses Plans
(Schritt 6): Der Werkstatt-Login-Broadcast (heute immer ~14 Pakete, siehe
`QueueAllProfessions` im Login-Callback) sendet künftig zuerst nur ein
**Berufs-Manifest** (`professionKey,updatedAt,fingerprintHash` je
Account-Beruf, 1 Paket – das `M`-Format existiert bereits, wird nur von
Whisper auf den Gildenkanal gehoben und um den Crafternamen ergänzt);
Schlüssellisten gehen nur noch für Berufe raus, die mindestens ein
Mitglied per Anforderung als veraltet meldet (Streuung + Unterdrückung wie
gehabt). Funktion identisch – wer etwas Neues hat, verteilt es; wer nichts
Neues hat, kostet ab dann **1 Paket pro Login statt 14**.

## Nicht-Ziele

- Kein Bewegen, Einzahlen oder Abheben von Items (geschützte Aktionen).
- **Keine Synchronisation privater Bestände** (Taschen/Bank/Twinks bleiben
  auf dem Account; nur die ohnehin gemeinsame Gildenbank wird geteilt).
- Kein Gildenbank-Gold, keine Einzelslot-Positionen (nur Zählstände), keine
  Auktionshaus-/Preisdaten.
- Keine Tabs senden oder überschreiben, die der Absender nicht sehen darf.
- Kein neues Whisper-Protokoll – alles läuft über den Gildenkanal.

## Umsetzungsreihenfolge

| Schritt | Inhalt | Risiko |
|---|---|---|
| 1 | `Inventory.lua`: Taschen + eigene Bank zählen, Account-Aggregation, Tests mit Container-Mocks | gering |
| 2 | Rezeptdetails: Spalten „Du“, Ampel, Summenzeile (nur eigene Bestände) | gering |
| 3 | Gildenbank-Snapshot je Tab (asynchrone Query-Kette!) | mittel – API im Client verifizieren |
| 4 | `B|`-Sync: `BM/BQ/BR/BT`, Konfliktregel je Tab, Router + Tests (Roundtrip, „Manifest ohne Tab löscht nichts“, „älterer Stand verliert“) | mittel |
| 5 | GBank-Spalte, Herkunfts-/Fehlt-Zeilen in der UI | gering |
| 6 | Werkstatt-Login auf Manifest-zuerst umstellen (Datenlast-Kapitel) | mittel |
| 7 (optional) | Punkt in der Rezeptliste, Favoriten-Einkaufsliste | gering |

Schritte 1–6 als **ein** Release `0.9.31`. Projekt-Checkliste wie gehabt:
Version in TOC/Constants/README (×2)/`validate.mjs` anheben, ROADMAP-Abschnitt
`0.9.31` + „Offene Punkte“, `lua5.1 tests/smoke.lua` und
`node tests/validate.mjs` grün, Installer unangetastet (1.0.3), Push auf
`main`. smoke.lua: 200-Locals-Limit → neue Testvariablen global. Schema
bleibt 7 (nur neuer Nachrichtentyp + additive Speicherfelder).

## Abnahmekriterien

1. Nach einmaligem Öffnen von Bank bzw. Gildenbank zeigt jedes Rezept je
   Reagenz Bedarf, eigenen Gesamtbestand (Taschen + Bank + Twinks) und
   Gildenbankbestand mit Ampelfarbe; die Summenzeile nennt die Fehlmenge und
   was davon die Gildenbank deckt.
2. Öffnet Mitglied A die Gildenbank, sehen B und C die neuen Stände ohne
   eigenen Bankbesuch; ein älterer Snapshot überschreibt nie einen neueren;
   ein Mitglied mit eingeschränkter Tab-Sicht löscht keine fremden Tabs.
3. Ein Login ohne Änderungen erzeugt für Gildenbank **und** Werkstatt
   zusammen höchstens ~4 Pakete (BQ + BM + Berufs-Manifest); die bisherigen
   ~14 Werkstatt-Pakete entfallen im unveränderten Fall nachweislich
   (Testassertion auf `#sentAddon`).
4. Private Bestände tauchen in keinem gesendeten Paket auf (Testassertion
   über alle `sentAddon`-Einträge).
5. Alle neuen Pfade (Zählen, Aggregation, Kodierungs-Roundtrip, Manifest-
   Logik, Konfliktregeln, UI-Ampel) sind durch smoke-Tests abgedeckt; beide
   Testläufe grün.

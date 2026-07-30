# Offene Aufgaben für die nächste Sitzung

Stand: 30.07.2026, nach Release 0.9.39 / Installer 1.0.4.

Diese Liste ist so geschrieben, dass ein einzelner Prompt genügt:
**„Arbeite `docs/TODO-naechste-sitzung.md` ab."**

Vorher die Testbasis herstellen – beide Suiten müssen grün sein, bevor
irgendetwas geändert wird:

```bash
node tests/validate.mjs
```

`tests/smoke.lua` braucht einen Lua-Interpreter. Auf diesem Rechner ist keiner
installiert; er läuft über **fengari** als npm-Paket (`npm install fengari` im
Scratchpad, Runner schreiben, der `loadfile` mit Dateiinhalt versorgt und die
Datei als **Bytes** übergibt). Lua bricht bei mehr als 200 lokalen Variablen je
Funktion ab, und smoke.lua ist eine einzige – neue Testblöcke deshalb in
`do ... end` kapseln.

Nach jedem fertigen Punkt: Version in `GuildCopilot.toc`, `Constants.lua`,
`README.md` und `tests/validate.mjs` gleichziehen, ROADMAP nachführen, nach
`main` pushen und den Ordner `GuildCopilot/` in die WoW-Installation spiegeln
(siehe `AGENTS.md`).

---

## 1. Knopf im Blizzard-Gildenfenster entfernen

**Was:** Der blaue „Guild Copilot"-Knopf oben rechts im Gildenfenster verdeckt
Inhalte, lässt sich nicht verschieben und wird nicht gebraucht. Ersatzlos raus.

**Wo:** `GuildCopilot/UI.lua`, Funktion `GC.UI:AddGuildWindowButton()` (um Zeile
4626). Er hängt an `GuildFrame` mit `TOPRIGHT, -32, -30` und
`SetFrameStrata("HIGH")` – deshalb liegt er über allem.

**Mitzuziehen:**
- der Aufruf von `AddGuildWindowButton` (Event-Registrierung suchen)
- `README.md`: Die Aufrufwege nennen den Knopf ausdrücklich („Aufruf über
  `/gcp`, den Button im Blizzard-Gildenfenster, das verschiebbare
  Minimap-Symbol oder **Optionen → AddOns → Guild Copilot**")
- `tests/validate.mjs` prüfen, ob dort ein Muster darauf zeigt
- Es bleiben genug Aufrufwege: `/gcp`, Minimap-Symbol, Addon-Optionsseite

**Aufwand:** klein.

---

## 2. Trigger-Wörter fürs Postfach konfigurierbar machen

**Was:** Aktuell ist fest verdrahtet, wodurch jemand im Postfach landet. Das
soll in den Einstellungen pflegbar sein – **und zusätzlich Ausschlusswörter**,
die einen Eintrag ausdrücklich verhindern.

**Wo:** `GuildCopilot/Chat.lua`

- `RECRUITMENT_TRIGGERS` (ab Zeile 38) – greift bei **öffentlichen
  Chatnachrichten**: „suche eine gilde", „suche gilde", „gilde gesucht",
  „gildensuche", „lf guild", „looking for a guild", „looking for guild"
- `WHISPER_RECRUITMENT_TRIGGERS` (ab Zeile 48) – greift bei **Flüsternachrichten**:
  „interesse", „interessiert", „gilde", …
- Ausgewertet in `GC.Chat:IsRecruitmentSignal` (Zeile ~471) und in
  `CaptureWhisper` (Zeile ~456)

**Zu entscheiden / umzusetzen:**
- Beide Listen in die Datenbank verlagern, mit den bisherigen Werten als
  Vorgabe (`Database.lua` DEFAULTS). Die Vorgabe muss wiederherstellbar sein.
- **Ausschlussliste** ergänzen: Trifft ein Ausschlusswort, entsteht kein
  Eintrag – auch wenn ein Trigger passt. Ausschluss schlägt Trigger.
- Getrennt für öffentliche Nachrichten und Flüstern lassen, sie haben
  unterschiedliche Fehlerkosten: Ein zu weiter Whisper-Trigger nervt nur
  einen selbst, ein zu weiter Chat-Trigger erzeugt Müll aus dem ganzen Realm.
- **Gildenweit oder lokal?** Die Standardtexte im Postfach sind gildenweit
  synchronisiert, die Erkennungsschalter dagegen persönlich
  (`captureOnlyDuringSearch`, `watchRecruitmentTriggers`). Trigger-Wörter sind
  eher persönlich – kurz beim Nutzer rückfragen, bevor Sync-Aufwand entsteht.
- Oberfläche: Einstellungsseite, Karte „Benachrichtigungen & Zugriff" oder eine
  eigene Karte. Mehrzeiliges Eingabefeld, ein Wort je Zeile, ist am einfachsten
  zu pflegen. Groß-/Kleinschreibung ignorieren (der Vergleich läuft heute schon
  über `:lower()`), Einträge trimmen, leere Zeilen verwerfen.

**Testfälle:** Ein eigenes Trigger-Wort greift; ein Ausschlusswort verhindert
den Eintrag trotz passendem Trigger; leere Listen führen nicht dazu, dass
plötzlich alles oder nichts erfasst wird.

**Aufwand:** mittel.

---

## 3. Onboarding-Wizard – erst konzipieren, noch nicht bauen

**Ausdrücklich nur Konzept.** Der Nutzer will das Konzept sehen, bevor
irgendetwas umgesetzt wird.

**Idee:** Beim ersten Start nach dem Einloggen führt ein Assistent durch drei
Schritte:

1. **Raidprofil ausfüllen und bestätigen.** In diesen Schritt gehört alles, was
   `GC.Profile:Confirm(raidSpecKey, secondarySpecKey, mainStatus, flex)` ohnehin
   annimmt – also die vollständige Karte „Dein Raidprofil":
   - **Primär-Spec**
   - **Dual-Spec** (optional)
   - **Main oder Twink**
   - **Flexibel einsetzbar** (Schalter)

   Wichtig: Es gibt keinen eigenen „Weiter"-Knopf – **das Bestätigen des Profils
   ist der Übergang zu Schritt 2**. Die eigentliche Aktion treibt den Wizard
   voran, statt daneben zu stehen. Seit 0.9.39 erscheint beim Bestätigen ein
   Haken und der Stufenaufstiegssound; das ist zugleich die Rückmeldung für den
   Schritt. Schlägt die Bestätigung fehl (etwa unpassende Spec), bleibt der
   Wizard stehen und zeigt den Grund – weitergehen darf er dann nicht.
2. **Berufe auswählen** – das WoW-Berufsfenster öffnen lassen und
   **Rückmeldung geben, sobald Berufe erkannt wurden**. Guild Copilot liest
   den Bestand beim Öffnen des Berufsfensters ohnehin ein
   (`Workshop.lua`, `ScanOpenProfession`), der Wizard muss das nur sichtbar
   machen. Auch hier gilt: Die erkannte Erfassung ist die Rückmeldung und
   führt weiter.
3. **Ausrüstung prüfen** – die Selbstprüfung läuft seit 0.9.19 automatisch im
   Hintergrund; hier geht es darum, das Ergebnis einmal zu zeigen
   (`Profil → Deine Ausrüstung`).

**Feste Anforderungen des Nutzers:**
- **Jeder Schritt einzeln überspringbar**
- **Der ganze Wizard jederzeit abbrechbar**
- **Jederzeit erneut aufrufbar** – vorgeschlagen: Knopf **„Einrichtung starten"**
  oben rechts im Hauptfenster

**Beim Konzipieren zu klären:**
- Woran wird „erster Start" erkannt? Ein Flag in den SavedVariables. Es darf
  nicht bei jedem Twink neu auslösen, wenn das nicht gewollt ist –
  `GuildCopilotDB.settings` ist kontoweit, das Profil dagegen pro Charakter.
  Vermutlich richtig: **pro Charakter**, weil Spec und Berufe pro Charakter
  gelten. Beim Nutzer rückfragen.
- Eigenes Fenster oder eine Überlagerung im Hauptfenster? Das Hauptfenster hat
  bereits eine Seitenleiste ohne Bildlaufleiste – ein zusätzlicher
  Navigationspunkt würde unten herausragen (`tests/validate.mjs` prüft das
  ausdrücklich). Ein Knopf oben rechts umgeht das Problem.
- Ein abgebrochener Wizard darf nicht bei jedem Login erneut aufspringen.

**Ergebnis dieser Aufgabe:** ein Konzeptdokument unter `docs/`, kein Code.

---

## 4. Offline-Import aus `WoWCombatLog.txt`

Der größte verbliebene Punkt. Details stehen bereits in `ROADMAP.md` unter
„Offene Punkte".

**Ausgangslage (am 30.07.2026 auf diesem Rechner geprüft):** Unter
`_anniversary_/Logs/` liegt eine echte Protokolldatei von 46 MB. Darin stehen:

- `COMBATANT_INFO` – **die komplette Ausrüstung jedes Raidmitglieds beim Pull**,
  mit Verzauberungen und Sockeln, im Format
  `(ItemID, ItemLevel, (Enchant,0,0), (), (Gems…))`. Stichprobe: Die dort
  gefundenen Enchant-IDs `3003`, `2661`, `3012`, `2939`, `1593`, `2564` stehen
  alle im Regelsatz aus 0.9.37 – der ist damit gegen echte Spieldaten bestätigt.
- `ENCOUNTER_START,649,"Hochkönig Maulgar",4,25,565,5` – **Encounter-ID und
  übersetzter Bossname**. Die Roadmap-Annahme „ohne Encounter-API in TBC" gilt
  für die Logdatei nachweislich nicht.
- `UNIT_DIED`, `SPELL_CAST_SUCCESS`, `SPELL_AURA_APPLIED`, `SPELL_INTERRUPT`,
  `SPELL_DISPEL`, `SPELL_RESURRECT` – alles, was die Livesitzung auch zählt.
- Kopfzeile: `COMBAT_LOG_VERSION,9,ADVANCED_LOG_ENABLED,1,BUILD_VERSION,2.5.6`

**Warum das lohnt:**
- **Rückwirkend** – heute ist ein Raidabend verloren, wenn niemand „Sitzung
  starten" gedrückt hat. Die Datei hat trotzdem alles.
- **Ohne Warcraft Logs** – kein Upload, keine API-Zugangsdaten.
- **Ausrüstung auch von Leuten ohne Addon** – genau die Lücke, für die es heute
  „Gruppe prüfen" als Inspect-Rückfall gibt.

**Umsetzung:**
- Ein WoW-Addon darf keine Dateien lesen. Der **Installer** wertet aus und
  erzeugt einen Importcode, genau wie beim Warcraft-Logs-Import
  (`Installer/Wcl/WclImporter.cs` als Vorlage, `LogsPanel.cs` für die
  Oberfläche).
- Importformat analog `GCPWCL3`; das Addon zerlegt Zeilen feldweise
  (`SplitFields`), damit ein Companion anderen Alters keinen Import verhindert.
- **Sitzungsfingerabdruck** zur Quell-Deduplizierung: Derselbe Abend kann aus
  Live-Sitzung, Warcraft Logs und Offline-Import kommen. Heute werden Quellen
  getrennt gehalten und nie verrechnet (`stored.source ~= summary.source`), aber
  auch nicht als *derselbe Abend* erkannt – er stünde dreimal in der Liste. Ein
  Fingerabdruck aus Startzeit, Teilnehmern und Bossen würde sie zusammenführen.
- `COMBATANT_INFO` als **zweite Gear-Quelle** anbinden. Die Datei ist 46 MB –
  streamend lesen, nicht am Stück (`File.ReadLines`).
- Die Datei enthält Spielernamen und Ausrüstung der ganzen Gilde. Sie bleibt
  lokal; über den Gildenkanal geht wie bisher nur, was ohnehin geteilt wird.

**Aufwand:** groß. Vor dem Start Umfang mit dem Nutzer abstecken – ob zuerst nur
die Raidauswertung oder gleich `COMBATANT_INFO` mit dazu.

---

## Bleibt bewusst offen

- **Code-Signing des Installers.** Ohne gekauftes Zertifikat warnen Browser,
  Windows und SmartScreen bei jedem Download auf einem fremden Rechner. Nicht
  von hier aus lösbar; die SHA-256-Prüfsumme steht in der README.
- **Aldor-Schulterinschriften** im Verzauberungs-Regelsatz. Ihre Enchant-IDs
  ließen sich nicht belegen; sie gelten deshalb als unbewertet und damit als in
  Ordnung, statt falsch bewertet zu werden.
- **Private Warcraft-Logs-Reports** – bräuchten eine OAuth-Benutzerfreigabe und
  sind ausdrücklich ausgeschlossen.

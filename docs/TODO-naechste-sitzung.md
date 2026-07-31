# Offene Aufgaben für die nächste Sitzung

Stand: 31.07.2026, nach Release 0.9.49 / Installer 1.0.5.

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
(siehe `AGENTS.md`). Wird der Installer geändert, zusätzlich `<Version>` in
`Installer/GuildCopilot-Installer.csproj`, `Installer/dist/version.txt`, die
veröffentlichte EXE (`dotnet publish`, Befehl in `README.md`) und die SHA-256 in
der README.

---

## 1. Onboarding-Wizard – ERLEDIGT in 0.9.45

**Konzept:** `docs/KONZEPT-onboarding-erste-schritte.md`.
**Umgesetzt:** `GuildCopilot/Onboarding.lua` und die Karte „Erste Schritte"
oben auf der Profilseite; Einzelheiten im ROADMAP-Abschnitt „0.9.45".

Aus dem Wizard wurde bewusst **kein eigenes Fenster**, sondern eine
Checkliste auf der Seite, auf der alle drei Schritte ohnehin liegen. Die
offene Frage „kontoweit oder pro Charakter?" hat sich mit dem abgeleiteten
Zustand von selbst beantwortet: pro Charakter. Der Owner hat entschieden,
dass sich das Fenster beim ersten Login **je Charakter** einmal von selbst
öffnet.

Der ursprüngliche Auftrag, zur Nachvollziehbarkeit:

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
Beides liegt inzwischen vor – siehe oben.

---

## 2. `COMBATANT_INFO` als zweite Ausrüstungsquelle

Der Offline-Import aus 0.9.41 liest die Zeile bislang nur als
Anwesenheitsbeleg (`Installer/CombatLog/CombatLogImporter.cs`, Zweig
`subevent == "COMBATANT_INFO"`). Darin steht aber mehr:

```
COMBATANT_INFO,Player-6409-048F2D0C,0,122,591,672,…,(20,41,0),(),
[(30146,133,(3003,0,0),(),(32409,70,24061,70)),(29381,110,(),(),()),…]
```

Also je Slot `(ItemID, ItemLevel, (Enchant,0,0), (), (Gems…))` – **die
vollständige Ausrüstung jedes Raidmitglieds beim Pull, mit Verzauberungen und
Sockeln.** Genau die Lücke, für die es heute **Gruppe prüfen** als
Inspect-Rückfall gibt: Leute ohne Addon.

**Ausgangslage geprüft:** Die Enchant-IDs `3003`, `2661`, `3012`, `2939`,
`1593`, `2564` aus der Testdatei stehen alle im Regelsatz aus 0.9.37 – der ist
damit gegen echte Spieldaten bestätigt.

**Zu klären / umzusetzen:**
- Zerlegung der geklammerten Struktur. Der Feld-Splitter in
  `CombatLogImporter.SplitFields` achtet auf Anführungszeichen, **nicht** auf
  Klammern – für diese Zeile braucht es einen eigenen Leser.
- Ein neuer Blocktyp im Importcode (`GCPLOG1` erweitern oder Zeilen `G|…`
  anhängen). Die Addon-Seite zerlegt feldweise (`SplitFields` in
  `WarcraftLogs.lua`), zusätzliche Felder am Ende stören ältere Clients nicht.
- Anbindung an die Selbstprüfung: `GC.GearAudit` erwartet welches Format?
  Vorher prüfen, wie ein Inspect-Snapshot dort abgelegt wird.
- Die Datei enthält Spielernamen und Ausrüstung der ganzen Gilde. Sie bleibt
  lokal; über den Gildenkanal geht wie bisher nur, was ohnehin geteilt wird.

**Aufwand:** mittel bis groß. Vor dem Start Umfang abstecken.

---

## 3. Klasse für Teilnehmer aus dem Combat Log

Der Combat Log nennt keine Klasse, deshalb erscheinen Teilnehmer aus der
Logdatei ohne Klassenfarbe (`classFile` bleibt leer, bewusst statt geraten).
Zwei Wege:

- über **`COMBATANT_INFO`** – dort stehen die Talentpunkte, also Klasse *und*
  Spec. Erledigt sich mit Aufgabe 2 mit;
- über **gewirkte Zauber** – nur teilweise verlässlich und eine zweite
  Zuordnungstabelle. Nur falls Aufgabe 2 nicht kommt.

**Aufwand:** klein, wenn Aufgabe 2 zuerst kommt.

---

## 4. Performance-Meldungen aus der Gilde – Ursache noch offen

Gemeldet wurden Bildraten-Einbrüche bei mehreren Spielern sowie ein Fall, in
dem nach dem Aktivieren von Guild Copilot **alle anderen Addons deaktiviert**
waren. Mit 0.9.48 sind zwei Ereignisabos korrigiert, mit 0.9.49 kam die
systematische Durchsicht aller Ereignispfade (fünf Funde behoben, der größte:
Seitenneuaufbau pro nachgeladenem Item bei offenem Fenster – das erklärt
Einbrüche **bei offenem Fenster** plausibel). Ob damit auch die gemeldeten
Fälle erklärt sind, ist **offen**, bis ein Betroffener misst.

**Ausgeschlossen ist bereits:** Das Addon ruft nirgends `DisableAddOn`,
`EnableAddOn` oder `C_AddOns` auf, und es legt außer `SLASH_GUILDCOPILOT1/2`
keine globalen Variablen an – eine Kollision mit fremden Addons scheidet aus.
Die Interface-Version `20506` stimmt mit dem Anniversary-Client überein.

**Arbeitshypothese zum Deaktivierungsfall:** WoW schreibt die Liste der
aktivierten Addons beim Ausloggen nach `WTF\Account\…\AddOns.txt`. Stürzt der
Client ab, bleibt die Datei unvollständig und beim nächsten Login sieht alles
deaktiviert aus. Zu klären: Ist der Client des Betroffenen abgestürzt, und
liegen Einträge im `Errors`- bzw. `Crashes`-Verzeichnis?

**Vor weiteren Codeänderungen erst messen:**
- **`/gcp debug`** beim Betroffenen: eingebaute Messung, protokolliert die
  schlimmste Einzeldauer je Vorgang (Roster-Scan, Seitenaufbau). Erste Wahl,
  weil ohne Zusatzaddon;
- BugSack + BugGrabber bei den Betroffenen, um Lua-Fehler statt Vermutungen zu
  bekommen;
- AddonProfiler im Raid, um zu belegen, ob GCP überhaupt die CPU-Zeit zieht;
- die `GuildCopilot.lua` aus dem WTF-Ordner eines Betroffenen ansehen – die
  reale Datenmenge ist unbekannt.

**Danach zu bewerten, aber nicht vorher zu optimieren:**
- `GC.DB:Prune()` räumt rein zeitbasiert auf. `remoteProfiles` und
  `workshop.crafters` haben **keine Mengenobergrenze**; nur `inbox` (100) und
  `postHistory` (50) sind gedeckelt. In einer großen Gilde kann das wachsen;
- `GetGuild()` läuft pro Aufruf durch den Defaults-Baum (`MergeDefaults`).
  Nach den 0.9.49-Entprellungen liegt es auf keinem heißen Pfad mehr; Caching
  wäre ein Semantikrisiko (Tests tauschen die Datenbank aus, nil-gesetzte
  Zweige würden nicht mehr repariert) und braucht erst einen Messbeleg.

*(Die 0.9.48er-Punkte zu `ResolveConsumable` und `FindParticipant` sind mit
0.9.49 umgesetzt: Namensprüfung nur noch bei Aura-Ereignissen, Namens-Memo je
Sitzung.)*

---

## 5. Gildenaufträge in der Werkstatt – Konzept abgenommen, bereit zur Umsetzung

**Konzept:** `docs/KONZEPT-werkstatt-gildenauftraege.md` (Stand 31.07.2026,
inklusive der fünf Owner-Entscheidungen am Dokumentende – alle Fragen sind
geklärt, es gibt keinen offenen Vorbehalt mehr).
Kern: Aufträge auf Katalogrezepte, genau ein Auftragnehmer (Account, nicht
Charakter – Twink nimmt an, Main fertigt), Statusmodell mit Verlauf, drei
Materialmodelle (Auftraggeber liefert / Gildenbank / Beschaffung mit
Kostenrahmen und zweiseitigem Abschluss), Übergabe persönlich oder per Post,
Offiziers-Abbruchrecht über die Rangfreigabe, Unterreiter in der Werkstatt
statt Pop-out-Fenster, **Kompakt-Tracker bereits in Stufe 1**.

**Aufwand:** groß – neue Nachrichtenfamilie `O` mit Manifest-Abgleich,
Rechteprüfung über `accountTag`, neuer Unterreiter, Tracker. In Etappen
bauen (Reihenfolge laut Konzept „Stufe 1"), nicht in einer Sitzung. Sinnvoller
erster Schnitt: Datenmodell + Sync + Statusmodell mit Tests, dann UI.

---

## Bleibt bewusst offen

- **Aldor-Schulterinschriften** im Verzauberungs-Regelsatz. Ihre Enchant-IDs
  ließen sich nicht belegen; sie gelten deshalb als unbewertet und damit als in
  Ordnung, statt falsch bewertet zu werden.
- **Private Warcraft-Logs-Reports** – bräuchten eine OAuth-Benutzerfreigabe und
  sind ausdrücklich ausgeschlossen.
- **Abende in zwei Instanzen** bekommen beide Zonen genannt („Gruuls
  Unterschlupf / Auge"). Ob das in der schmalen Sitzungsliste lesbar bleibt,
  zeigt erst der Blick im Spiel.
- **Encounter-Ereignisse live**: In der Logdatei steht `ENCOUNTER_START` samt
  übersetztem Bossnamen. Ob das Addon dieselben Ereignisse auch live als Event
  empfängt, ist nicht geprüft. Wenn ja, wäre das eine genauere Bosserkennung
  als die Namensliste aus 0.9.38.

# Konzept: Onboarding „Erste Schritte"

> **Status: umgesetzt in Addon-Version 0.9.45.** Dieses Dokument bleibt als
> Entwurfs- und Begründungsprotokoll erhalten; der ausgelieferte Stand steht im
> ROADMAP-Abschnitt „0.9.45".
>
> Abweichungen und Ergänzungen bei der Umsetzung:
> - Die Logik liegt in einem eigenen Modul `GuildCopilot/Onboarding.lua`, die
>   Karte in `UI.lua` (`BuildOnboardingCard`/`RefreshOnboarding`). So ist der
>   abgeleitete Zustand ohne UI prüfbar.
> - **Die Zustandszeichen sind Texturen, keine Schriftzeichen.** Der Entwurf
>   zeigte ✓, ►, ○ und – als Mockup; die Spielschrift kennt sie nicht und
>   zeichnet leere Kästen (Lektion aus 0.9.39). Erledigt trägt die
>   WoW-Hakentextur, alles andere ein eingefärbtes Quadrat.
> - **„Einrichtung" fängt die Liste neu an**, statt sie nur wieder
>   einzublenden: Der Knopf räumt Übersprungenes und „Nicht mehr anzeigen"
>   weg. Eine Liste aus lauter übersprungenen Zeilen wäre sonst genau das,
>   was man beim ausdrücklichen Aufruf nicht sehen will. Was tatsächlich
>   erledigt ist, bleibt erledigt – das steht in den echten Daten.
> - Die Zeilen sind anklickbar und rollen zur zugehörigen Karte; die Position
>   kommt aus `ROSTER_CARDS`, damit keine zweite Kopie derselben Maße
>   entsteht.
> - Zusätzlich nötig: `WORKSHOP_UPDATED` und `PROFILE_CONFIRMATION_CHANGED`
>   merken jetzt auch die Profilseite als veraltet vor – sonst reagiert die
>   Checkliste erst beim nächsten Seitenwechsel.
> - Nicht Teil des Konzepts, beim Bauen derselben Karte gefunden und
>   mitgenommen: Eine geänderte Auswahl gilt jetzt als unbestätigt (siehe
>   ROADMAP „0.9.45").
>
> Datei- und Zeilenangaben beziehen sich auf Addon **0.9.44**
> (Commit `e83f3f8`), den Stand **vor** der Umsetzung.

## Auftrag des Repository-Owners (Zusammenfassung)

Ein Assistent führt neue Nutzer durch drei Schritte: Raidprofil bestätigen,
Berufe einlesen, Ausrüstungsprüfung ansehen. Feste Anforderungen:

- **jeder Schritt einzeln überspringbar**;
- **der ganze Wizard jederzeit abbrechbar**;
- **jederzeit erneut aufrufbar** (vorgeschlagen: Knopf oben rechts im
  Hauptfenster);
- **kein eigener „Weiter"-Knopf** – die echte Aktion treibt den Wizard voran;
- ein abgebrochener Wizard darf nicht bei jedem Login erneut aufspringen;
- so einfach und intuitiv wie möglich.

## Leitidee: Checkliste statt Wizard-Fenster

**Kein eigenes Fenster, kein Overlay, keine Schrittfolge mit Weiter-Knopf.**
Alle drei Schritte leben bereits auf der Profil-Seite (`ROSTER`, erster
Navigationspunkt und Standardseite beim Öffnen): die Raidprofil-Karte, die
Berufe und die Karte **Deine Ausrüstung** (`UI.lua` ~1716). Ein eigenes
Wizard-Fenster müsste diese Karten duplizieren oder darüber schweben – und
weil die echte Aktion der Übergang sein soll, müsste es die echten Karten
ohnehin beobachten. Dann kann es auch gleich dorthin führen.

Stattdessen: eine Karte **„Erste Schritte"** ganz oben auf der Profil-Seite,
drei Zeilen, eine je Schritt.

```
┌─ ERSTE SCHRITTE ────────────────────────────── [×] ─┐
│                                                     │
│  ✓  Raidprofil bestätigt                            │
│  ►  Berufe einlesen                  [Überspringen] │
│     Öffne einmal jedes deiner Berufsfenster –       │
│     Guild Copilot liest die Rezepte automatisch.    │
│  ○  Ausrüstung ansehen               [Überspringen] │
│                                                     │
│  Nicht mehr anzeigen                                │
└─────────────────────────────────────────────────────┘
```

Zeilenzustände: **✓** erledigt (grün) · **►** aktueller Schritt
(hervorgehoben, mit einem Satz Anleitung) · **○** offen · **–** übersprungen.
Der aktuelle Schritt ist immer der erste, der weder erledigt noch
übersprungen ist.

**Der Zustand wird aus den echten Daten abgeleitet, nicht aus Flags.** Die
Karte kann dadurch nie lügen und nie veralten: Ein „Erster Start"-Merker, der
behauptet, was noch zu tun sei, läuft der Wirklichkeit zwangsläufig
hinterher – etwa wenn das Profil längst auf einem anderen Weg bestätigt
wurde. Abgeleiteter Zustand macht auch das Twink-Verhalten von selbst
richtig: Ein Twink ohne bestätigtes Profil sieht die Karte, ein fertig
eingerichteter Charakter nicht. Die im TODO offene Frage „kontoweit oder pro
Charakter?" beantwortet sich damit ebenfalls: **pro Charakter**, weil Spec,
Berufe und Ausrüstung pro Charakter gelten – gespeichert werden aber nur die
drei kleinen Merker unten, alles andere wird live abgelesen.

## Die drei Schritte

| # | Schritt | Erledigt, wenn … | Vorhandener Hook |
|---|---|---|---|
| 1 | Raidprofil bestätigen | `GC.Profile` hat eine Bestätigung (`lastConfirmation`) | `PROFILE_CONFIRMATION_CHANGED` (`Profile.lua` ~236) |
| 2 | Berufe einlesen | mindestens ein Beruf **dieses Charakters** bekannt – aus dem Scan oder manuell gesetzt | `WORKSHOP_UPDATED` nach `ScanOpenProfession` (`Workshop.lua`) |
| 3 | Ausrüstung ansehen | ein Selbstprüfungs-Ergebnis liegt vor (läuft seit 0.9.19 automatisch) | `GEAR_AUDIT_UPDATED` (`GearAudit.lua`) |

**Schritt 1.** Die Zeile führt zur Raidprofil-Karte direkt darunter. Das
Bestätigen selbst ist der Übergang – Haken und Stufenaufstiegssound aus
0.9.39 sind bereits die Rückmeldung, die Checkliste flippt die Zeile auf ✓.
Schlägt `Confirm` fehl (etwa unpassende Spec), zeigt die Profilkarte den
Grund schon heute im Klartext; die Checkliste bleibt einfach auf ► stehen
und tut nichts Zusätzliches.

**Schritt 2.** Das Addon kann das Berufsfenster nicht selbst öffnen
(geschützte Aktion), deshalb führt der Anleitungssatz hin; die Erkennung ist
automatisch, weil `ScanOpenProfession` beim Öffnen ohnehin liest. Die
Rückmeldung nennt das Erkannte beim Namen („Schneiderei erkannt ✓"). Auch
eine manuelle Berufsauswahl im Profil erfüllt den Schritt – es zählt das
Ergebnis, nicht der Weg.

**Schritt 3.** Die Selbstprüfung läuft im Hintergrund; hier geht es nur
darum, das Ergebnis einmal zu zeigen. Die Zeile trägt die Zusammenfassung
selbst („2 fehlende Verzauberungen: Kopf, Schulter" bzw. „keine Funde"), ein
Klick springt zur Karte **Deine Ausrüstung**. Liegt noch kein Ergebnis vor,
steht dort „Prüfung läuft …" – sie erledigt sich von selbst.

## Überspringen, Abbrechen, Wiederaufrufen

- **Je Schritt:** „Überspringen" setzt einen per-Charakter-Merker, die Zeile
  wird **–**, der nächste offene Schritt wird ►. Passiert die echte Aktion
  später doch, überstimmt ✓ das Überspringen automatisch – übersprungen
  heißt „nicht drängeln", nicht „nicht wahrnehmen".
- **Ganz abbrechen:** Das **×** auf der Karte blendet sie für die laufende
  Sitzung aus. **„Nicht mehr anzeigen"** blendet sie dauerhaft aus (per
  Charakter). Beides zusammen erfüllt „jederzeit abbrechbar", ohne dass ein
  abgebrochener Wizard je wieder von selbst aufspringt.
- **Wiederaufrufen:** Knopf **„Einrichtung"** oben rechts im Header des
  Hauptfensters (zwischen Sync-Badge und Schließen-Knopf ist Platz; die
  Seitenleiste bleibt unangetastet – `tests/validate.mjs` wacht über deren
  Höhe). Er öffnet die Profil-Seite und zeigt die Karte wieder – auch nach
  „Nicht mehr anzeigen", auch wenn alles fertig ist: Dann steht alles auf ✓,
  was zugleich als Bestätigung taugt, dass nichts mehr offen ist.
- **Fertig** (alle drei Zeilen ✓ oder –): einmalige Erfolgszeile mit dem
  Stufenaufstiegssound, ab dem nächsten Öffnen ist die Karte weg.

## Erster Login (Entscheidung des Owners, 30.07.2026)

**Auto-Öffnen je Charakter:** Jeder Charakter ohne bestätigtes Raidprofil
bekommt beim ersten Login einmalig das geöffnete Hauptfenster auf der
Profil-Seite – auch Twinks, bewusst.

- Der Merker `autoOpenedAt` wird **beim tatsächlichen Öffnen** gesetzt, pro
  Charakter, und danach nie wieder ausgelöst – unabhängig davon, ob der
  Nutzer etwas erledigt, überspringt oder sofort schließt. Damit ist „springt
  nicht bei jedem Login erneut auf" strukturell garantiert.
- Geöffnet wird kurz verzögert nach `PLAYER_ENTERING_WORLD` (ein paar
  Sekunden, damit Login-Lastspitze und andere Addon-Fenster durch sind).
  Im Kampf unterbleibt es; der Merker bleibt dann ungesetzt und der nächste
  Login versucht es erneut.
- Ist das Profil bereits bestätigt (etwa weil der Charakter vor dieser
  Version eingerichtet wurde), unterbleibt das Auto-Öffnen ersatzlos –
  Bestandsnutzer werden nicht behelligt.
- Weitere automatische Erinnerungen (Chat-Hinweise bei späteren Logins) gibt
  es bewusst nicht: Die Karte sitzt auf der Standardseite und wird beim
  nächsten natürlichen `/gcp` gesehen.

## Gespeichert wird (pro Charakter, nie synchronisiert)

```lua
-- GC.DB:GetCharacter().onboarding
onboarding = {
    skipped       = { profile = true, professions = true, gear = true }, -- je nach Klick
    dismissedAt   = 0,   -- „Nicht mehr anzeigen"
    autoOpenedAt  = 0,   -- Auto-Öffnen beim ersten Login verbraucht
    doneShownAt   = 0,   -- Erfolgszeile + Sound einmal gezeigt
}
```

Alles andere wird live abgeleitet. **Kein neuer Nachrichtentyp, keine
Pakete, keine Capability** – Onboarding ist rein persönlich und erzeugt null
Kanallast.

## Nicht-Ziele

- Kein eigenes Wizard-Fenster, kein Overlay-/Spotlight-System.
- Kein neuer Punkt in der Seitenleiste.
- Keine Synchronisierung irgendeines Onboarding-Zustands.
- Kein automatisches Öffnen von Berufsfenstern oder Auslösen geschützter
  Aktionen.
- Keine wiederkehrenden Erinnerungen über das einmalige Auto-Öffnen hinaus.

## Leitplanken für die spätere Umsetzung

- Die Karten unter der Checkliste wandern mit, wenn sie erscheint oder
  verschwindet – die Lektion aus 0.9.44. Die Überlappungsprüfung aus
  `tests/validate.mjs` auf die Profil-Seite ausweiten.
- Regressionstests (in `do ... end` gekapselt, 200-Locals-Limit):
  Zustandsableitung je Schritt; Erledigt überstimmt Übersprungen; × öffnet
  in derselben Sitzung nicht erneut; Auto-Öffnen setzt den Merker genau
  einmal; bestätigtes Profil verhindert Auto-Öffnen.
- Die drei Hooks existieren bereits (`PROFILE_CONFIRMATION_CHANGED`,
  `WORKSHOP_UPDATED`, `GEAR_AUDIT_UPDATED`) – es braucht keine neuen Events,
  nur Callbacks darauf.

## Bewusst offen

- **Stufen-Untergrenze:** Auch ein Level-5-Bank-Twink bekommt das
  Auto-Öffnen einmal. Ob das stört oder gerade richtig ist (auch Twinks
  sollen Profil und Berufe pflegen), zeigt der Gebrauch; eine Untergrenze
  wäre ein Einzeiler in der Auto-Öffnen-Bedingung.
- **Wortlaut** der Anleitungssätze und der Erfolgszeile – am lebenden UI
  entscheiden.

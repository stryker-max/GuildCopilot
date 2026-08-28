# Konzept: Raidsuche (LFM) – Raids gezielt auffüllen

> **Status: vom Owner abgenommen; Stufe 1 umgesetzt in 0.9.139.** Ergebnis
> des Konzeptauftrags vom 28.08.2026; die offenen Fragen hat der Owner am
> selben Tag entschieden (siehe „Entscheidungen des Owners" am Ende – einzig
> die gildenweite Stufe 3 bleibt bewusst offen). Datei- und Zeilenangaben
> beziehen sich auf Addon **0.9.137** (Commit `e358ad7`); Einzelheiten der
> Umsetzung im ROADMAP-Abschnitt 0.9.139.
>
> Zwei kleine Abweichungen der Umsetzung, beide aus Owner-Antworten
> abgeleitet: Das Wiederholen hat **kein eigenes Minuten-Intervall** – es
> übernimmt exakt das Werbebalken-Modell („wie bei der Gildenwerbung"), den
> Takt geben die Kanal-Cooldowns vor. Und die Spec-Wünsche werden über ein
> An/Aus-Menü gepflegt statt über Stückzahl-Zeilen; die Stückzahl trägt das
> Datenmodell weiterhin.

## Auftrag des Repository-Owners (Zusammenfassung)

Ein eigenständiges Suchwerkzeug im Guild Copilot, mit dem sich ein Raid
**zusammenklicken** lässt: Was suche ich, für wann, mit welchen Lootregeln?
Feste Anforderungen:

- **Datum und Uhrzeit** auswählen;
- **Klassen und Specs** auswählen, die gesucht werden;
- **Lootregeln** wie `2SR > MS > OS` angeben – am besten mit Freitext, in dem
  sich Dinge wie „dies und das ist HR" eintippen lassen;
- möglichst **einfach und logisch** in den Guild Copilot integriert, als
  eigenständiges Suchwerkzeug.

## Die Namensfrage: nicht „LFR"

„LFR" ist bei WoW-Spielern fest besetzt: **Looking For Raid** ist Blizzards
automatischer Schlachtzugsbrowser aus Retail. Was dieses Werkzeug tut, heißt
in der Szene seit jeher **LFM** – *Looking For More*, einen bestehenden Raid
auffüllen. Der Reiter selbst sollte aber wie alle Navigationspunkte deutsch
beschriftet sein (Postfach, Mitgliederpflege, Gildenwerkstatt …).

**Empfehlung: „Raidsuche"** als Reiter- und Featurename, in der Sektion
**RAID** als erster Punkt – die Sektion deckt damit den ganzen Bogen ab:
Raidsuche (vorher) → Raidauswertung (nachher). Im generierten Chatspruch
steht wie üblich „LFM". Modul- und Dateiname englisch wie bei allen Modulen:
`GC.RaidSearch`, `RaidSearch.lua` (in der TOC zwischen `Chat.lua` und
`Onboarding.lua` – das Modul braucht Chat-Helfer, die UI lädt zuletzt).

Verworfene Alternativen: „LFM-Zentrale" (Denglisch neben deutschen
Nachbarn), „Spielersuche" (klingt nach Rekrutierung – die hat ihre eigene
Sektion), „Raidplaner" (verspricht einen Kalender, den Stufe 1 nicht ist).

## Leitidee: ein Suchzettel, der sich selbst aktuell hält

Der Raidleiter füllt einen **Suchzettel** aus (Instanz, Termin, Lootregeln,
Sollbesetzung). Daraus entsteht **automatisch der Chatspruch**, immer unter
255 Bytes. Wer auf den Spruch antwortet, landet im **Zulauf** – einer Liste
mit erkannter Klasse, Einladen-Knopf und Antwortvorlagen. Und weil das Addon
die Raidgruppe live sieht, zählt der Suchzettel selbst mit: Wer eingeladen
ist, verschwindet aus „noch gesucht", und der Spruch schreibt sich um.

Drei Grundsätze:

1. **Der Spruch ist eine Ableitung, kein zweites Formular.** Geändert wird
   am Suchzettel; der Text folgt. Von Hand nachschleifen bleibt möglich –
   gepostet wird nur bestätigter Text (bewährtes Muster
   `recruitment.confirmedText`, `Chat.lua:528`).
2. **Ehrliche Zahlen statt Raterei.** Klassen kennt das Addon sicher (aus
   der Raidgruppe und aus Whisper-GUIDs); Specs kennt es nur für
   Gildenmitglieder mit bestätigtem Raidprofil. Externe ohne zugeordnete
   Spec erscheinen als „ohne Spec-Zuordnung" – sie werden nicht in eine
   Rolle geraten.
3. **Jede Nachricht nach draußen ist ein Klick** (oder ein Tastendruck beim
   eingebauten Wiederholen). Kein Timer postet von allein, kein Fremder
   wird unaufgefordert angeschrieben.

## Der Ablauf eines Suchabends

```
 ┌─────────────┐  „Suche starten"  ┌─────────────┐   „Suche beenden"
 │  ENTWURF    │ ────────────────► │  SUCHT      │ ────────────────►  BEENDET
 │  Suchzettel │                   │  postet,    │    (voll oder
 │  ausfüllen  │ ◄──────────────── │  sammelt    │     abgebrochen)
 └─────────────┘   „pausieren"     │  Zulauf     │
                                   └─────────────┘
```

- Es gibt **genau einen Suchzettel** (Owner-Entscheidung: „nur ein Raid").
  „Neue Suche" leert ihn – bei laufender Suche erst nach Rückfrage. Wer
  mehrere Termine vorbereitet (Kara Dienstag, Gruul Freitag), speichert je
  eine **Vorlage** und wendet sie an, wenn sie dran ist. Das hält auch die
  Whisper-Weiche eindeutig: Jede Antwort gehört der einen laufenden Suche.
- Ein BEENDETER Zettel bleibt zum Nachschauen liegen, bis „Neue Suche" ihn
  ersetzt, längstens 7 Tage (`GC.DB:Prune()`-Muster, `Database.lua:402`).

## Wo das Werkzeug wohnt: die Platzfrage

Die Seitenleiste hat keine Bildlaufleiste und ist praktisch voll: 14 Reiter
in 5 Sektionen belegen 606 px von 630 px, ein weiterer Punkt kostet 34 px
(`NAV_TAB_SPACING`, `UI.lua:59`; Nachrechnung in `tests/validate.mjs:985`).
Vier Wege standen zur Wahl:

| Weg | Bewertung |
|---|---|
| **a) `NAV_TAB_SPACING` von 34 auf 32 senken** | **So entschieden** – mit dem Reiternamen „Raidsuche" hat der Owner den eigenen Navigationspunkt bestätigt. Schafft Platz für genau einen weiteren Reiter; 2 px weniger Abstand sind optisch verkraftbar. `validate.mjs` zieht nach. Ehrlicherweise: Das ist der **letzte** Slot – der nächste Navigationspunkt braucht einen Umbau (schmalere Sektionsköpfe oder höheres Fenster). |
| b) Unteransicht einer bestehenden Seite | Es gibt keine Seite, zu der die Raidsuche gehört. Unter „Werbung posten" (Rekrutierung) wäre sie begraben – Gildenwerbung und Raid-LFM sind verschiedene Tätigkeiten mit verschiedenen Zielgruppen. |
| c) Eigenes Fenster per Knopf | Sieben Präzedenzfälle existieren (`CreateAttendanceFrame` u. a.), aber der Auftrag lautet „in den GCP integriert". Ein Hauptwerkzeug hinter einem Knopf zu verstecken widerspricht dem. |
| d) Fenster höher | `WINDOW_HEIGHT` hängt an pixelgenau vermessenen Seiten (`UI.lua:1658`) – unverhältnismäßig. |

**Dazu ein Suchbalken** für den laufenden Betrieb, nach dem Muster des
Werbebalkens (`CreatePostBar`, `UI.lua:10891`) und des Auftrags-Trackers:
Während einer Suche will man spielen, nicht das Hauptfenster offen halten.
Der Balken ist frei verschiebbar, zeigt Füllstand und neue Antworten und
trägt den Posten-Knopf samt Countdown:

```
┌──────────────────────────────────────────────┐
│ Kara Do 19:30 · 8/10 · offen: 1 Heiler, 1 DD │
│ [Posten (0:47)]      2 neue Antworten        │
└──────────────────────────────────────────────┘
```

Klick auf den Balken öffnet die Raidsuche-Seite. Der Owner hat entschieden
wie seinerzeit beim Auftrags-Tracker: **Suchbalken in Stufe 1**, wie beim
Werbebalken samt sichtbarem Cooldown-Countdown am Posten-Knopf.

## Oberfläche

Layout nach Hauskonvention (`CreatePageTitle` oben, zwei Karten, Maße wie
Postfach 224+528 bzw. Roster 486+270; endgültige Pixel bei der Umsetzung):

```
┌─ RAIDSUCHE ────────────────────────────────────────────────────────────┐
│ Raidsuche                                     [Vorlagen] [Neue Suche]  │
│ Raid zusammenstellen, Suche posten, Zulauf verwalten                   │
│                                                                        │
│ ┌─ SUCHZETTEL ───────────────────┐ ┌─ BESETZUNG 8/10 ────────────────┐ │
│ │ Instanz    [Karazhan        ▼] │ │ Tanks   [–] 2 [+]  dabei 2   ✓  │ │
│ │ Größe      [–] 10 [+]          │ │ Heiler  [–] 3 [+]  dabei 2  −1  │ │
│ │ Termin     [Do 04.09.] [19:30] │ │ DD      [–] 5 [+]  dabei 3  −2  │ │
│ │ Lootregel  [2SR > MS > OS   ▼] │ │ Wünsche: 1× Schattenpriester,   │ │
│ │            [2SR > MS > OS____] │ │ 1× Vergelter     [Specs wählen] │ │
│ │ Hard Res.  [Urne des Nachtb._] │ │ 1 dabei ohne Spec-Zuordnung     │ │
│ │ SR-Link    [softres.it/r/abc_] │ ├─ ZULAUF (3) ────────────────────┤ │
│ │ Notiz      [Voice Pflicht____] │ │ ● Palanor · Paladin 70 ·   NEU  │ │
│ ├─ SPRUCH (176/255 Bytes) ───────┤ │   „heiler da? kann holy"        │ │
│ │ LFM Karazhan Do 19:30 – 2SR >  │ │   [Einladen] [Antworten] [×]    │ │
│ │ MS > OS, HR: Urne – noch 1     │ │ ● Zaubro · Magier 70 ·   DABEI  │ │
│ │ Heiler, 2 DD – SR:             │ │ ○ Gronn · Krieger 68 · ABGESAGT │ │
│ │ softres.it/r/abc – /w me       │ │                                 │ │
│ │ [Text bestätigen]              │ │                                 │ │
│ │ Kanäle: [✓]LFG [✓]Handel       │ │                                 │ │
│ │ [ ]Allg. [✓]Gilde [✓]World     │ │                                 │ │
│ │ [Suche starten] Wdh. [5 Min ▼] │ │                                 │ │
│ └────────────────────────────────┘ └─────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

Alle Bausteine existieren als Fabrik: Dropdown mit Scrollen
(`CreateChoiceDropdown`, `UI.lua:1159`), Datumswahl als Kalenderblatt
(`OpenDatePicker`, `UI.lua:1092`), Stepper (`UI.lua:772`), Editfelder,
Karten, klassengefärbte Namen (`ClassColoredName`, `UI.lua:197`). Die
Zulauf-Zeilen folgen dem Slot-Muster der Auftragszeilen (`BuildOrderRow`,
`UI.lua:6276`): feste Zeilenzahl vorab bauen, beim Refresh nur befüllen.
Im Spiel-UI keine Unicode-Symbole – die Marken werden gezeichnet
(`SetButtonMark`, `UI.lua:591`); ▼/✓/× oben stehen stellvertretend dafür.

### Der Suchzettel im Einzelnen

- **Instanz:** Dropdown mit den TBC-Schlachtzügen (Karazhan, Gruuls
  Unterschlupf, Magtheridons Kammer, Höhle des Schlangenschreins, Festung
  der Stürme, Hyjalgipfel, Schwarzer Tempel, Zul'Aman, Sonnenbrunnenplateau)
  plus **„Frei"** mit Textfeld für Weltbosse und Sonderfälle. Je Instanz
  sind Größe und ein **Kurzname** hinterlegt („Kara", „SSC", „TK" – für die
  knappen Spruchstufen). Die Zonennamen gleicht die Umsetzung mit
  `GC.RaidBosses` (`Constants.lua:636`) ab, damit Raidsuche und
  Raidauswertung dieselben Namen sprechen.
- **Größe:** aus der Instanz vorbelegt (10/25), per Stepper überschreibbar –
  damit sind auch 5er-Gruppen möglich, ohne dass Stufe 1 sie eigens
  behandelt.
- **Termin:** Datum über das vorhandene Kalenderblatt, Uhrzeit als Textfeld
  mit Normalisierung („1930" → „19:30"; Muster `NormalizeDateInput`,
  `Core.lua:395`). Der Wochentag wird automatisch angezeigt und im Spruch
  verwendet (`WeekdayOfISO`, `Core.lua:340`); „heute"/„morgen" erkennt der
  Spruchbaukasten selbst. **Bonus, den nur der GCP hat:** Liegen für den
  Termin Abmeldungen vor (`GC.Roster:GetGuildAbsences`, `Roster.lua:724`),
  zeigt der Suchzettel eine Zeile „Am Termin abgemeldet: 2 (Namen im
  Tooltip)" – man sieht beim Planen, was intern fehlt.
- **Lootregel:** genau wie gewünscht **Freitext**, der wörtlich in den
  Spruch übernommen wird. Das Dropdown davor ist nur eine Schreibhilfe: Es
  füllt das Feld mit `2SR > MS > OS`, `1SR > MS > OS`, `MS > OS`, `GDKP`
  oder dem gildenweiten Lootsystem aus dem Gildenprofil
  (`guildData.profile.lootSystem`, `Database.lua:142`) – danach darf der
  Text beliebig angepasst werden.
- **Hard Reserve:** eigenes Freitextfeld („Urne des Nachtbanns, Wolfsherz"),
  erscheint im Spruch als „HR: …". Getrennt von der Lootregel, weil es die
  Angabe ist, die sich je Abend ändert, während die Regel gleich bleibt.
- **SR-Link:** Freitextfeld für den softres.it-Link (o. ä.). Steht im
  Spruch hinten; die Antwortvorlagen können ihn als Platzhalter nutzen.
- **Notiz:** freier Zusatz („Voice Pflicht", „Kara-ID beachten"), fliegt
  bei Platznot als Erstes aus dem Spruch.

### Besetzung: Soll und Ist in zwei Ebenen

**Ebene 1 – Rollen (immer):** drei Stepper für Tanks/Heiler/DD. Für die
meisten Suchen reicht das, und es macht die Kurzform des Spruchs möglich
(„noch 1 Tank, 2 Heiler").

**Ebene 2 – Spec-Wünsche (optional):** „Specs wählen" öffnet die
aufklappbare Klassen-und-Spec-Auswahl, die es als Bedienmuster bereits gibt
(Klassenzeilen der Rekrutierungsseite, `UI.lua:7884`; Spec-Katalog aus
`Constants.lua`, derselbe, den das Raidprofil nutzt) – nur dass hier je
Spec eine **Stückzahl** statt einer Priorität steht: „1× Schattenpriester,
1× Vergelter". Spec-Wünsche sind eine Verfeinerung innerhalb der
Rollensumme, keine zweite Rechnung.

**Ist-Stand:** Bei jedem `GROUP_ROSTER_UPDATE` (Events wie im RaidMonitor,
`RaidMonitor.lua:2795`) zählt das Modul die aktuelle Gruppe:

- **Klasse** ist immer sicher (Rosterdaten).
- **Rolle/Spec**: Für Gildenmitglieder mit bestätigtem Raidprofil liefert
  sie das geteilte Profil (`GC.Roster:GetSummary`, `Roster.lua:889`). Für
  Externe gilt die Spec, die im Zulauf zugeordnet wurde (erkannt oder von
  Hand, s. u.). Wer übrig bleibt, steht als „n dabei ohne Spec-Zuordnung"
  da und wird **keiner** Rolle zugeschlagen – lieber eine ehrliche
  Restzeile als ein falsch beruhigter Zähler.

„Noch gesucht" = Soll minus sicher Zugeordnete; daraus speist sich der
Spruch. Ist alles gedeckt, bietet die Seite „Suche beenden" an.

### Der Spruchbaukasten

Vorbild und Werkzeug ist der Werbetext-Generator
(`GenerateAdvertisement`, `Recruitment.lua:326`): mehrere
Ausführlichkeitsstufen erzeugen, die erste nehmen, die in
`GC.Constants.MAX_CHAT_BYTES = 255` passt (`Constants.lua:29`; Bytes, nicht
Zeichen – Umlaute zählen doppelt, `SafeChatText` kürzt UTF-8-sicher,
`Core.lua:220`). Bausteine in fester Reihenfolge:

```
LFM <Instanz> <Termin> [<Raidsymbol>] – <Lootregel>[, HR: <…>]
– noch <Bedarf> [– SR: <Link>] [– <Notiz>] – /w me
```

Kürzungsstufen, von ausführlich nach knapp:

1. Instanz ausgeschrieben, Bedarf mit Spec-Wünschen („noch 1 Heiler
   (Schattenpriester bevorzugt), 2 DD"), Notiz dabei;
2. Notiz raus, Bedarf nur Rollen;
3. HR-Liste wird zu „HR laut SR-Link" (wenn ein SR-Link da ist);
4. Instanz-Kurzname („Kara" statt „Karazhan").

Beispiel (Stufe 2, 129 Bytes):

```
LFM Karazhan Do 19:30 – 2SR > MS > OS, HR: Urne – noch 1 Heiler, 2 DD – SR: softres.it/r/abc – /w me
```

Die Vorschau ist eine Editbox: Handarbeit erlaubt, gepostet wird nur
**bestätigter** Text – ändert sich der Suchzettel danach, erlischt die
Bestätigung und der Knopf verlangt einen neuen Blick (exakt das
`confirmedText`-Muster aus `StartSearch`, `Chat.lua:528`). Ein Byte-Zähler
steht daneben; das Raidsymbol kommt vom vorhandenen Wähler
(`CreateRaidMarkerButton`, `UI.lua:1145`).

### Posten: Kanäle, Cooldowns, Wiederholen

- **Kanäle:** je Suche frei wählbar, in welche Kanäle gepostet wird
  (Owner-Anforderung). Zur Wahl stehen die vier vorhandenen Kanalarten mit
  deutscher und englischer Auflösung (`GC.ChannelKinds`,
  `Constants.lua:1230` – Gildenrekrutierung, SucheNachGruppe, Handel,
  Allgemein), **neu „Gilde"** (`chatType = "GUILD"`, über den bestehenden
  Wrapper `GC.Chat:SendChat`, `Chat.lua:517`) – **und die selbst
  beigetretenen Kanäle** wie ein „World"-Kanal: Die Liste liest sie aus
  `GetChannelList()` (`FindChannel`-Muster, `Chat.lua:483`) und merkt sich
  die Wahl unter dem Kanal**namen**, nicht der Nummer – die kann sich je
  Login ändern. Gilde zuerst posten ist guter Stil: erst die eigenen
  Leute fragen, dann die Welt.
- **Cooldowns:** je Kanalart wie bei der Werbung
  (`GetRemainingCooldown`, `Chat.lua:507`; Server-Drosselung wird aus
  `CHAT_MSG_CHANNEL_NOTICE`/`THROTTLED` gelesen, `Chat.lua:1381`). Der
  Posten-Knopf zeigt den Countdown.
- **Wiederholen:** übernimmt die vorhandene, dokumentierte Lösung des
  Hardware-Event-Problems (`Chat.lua:581-651`): WoW erlaubt
  Kanalnachrichten aus Addons nur im Kontext einer echten Eingabe, deshalb
  postet die Wiederholung **beim nächsten Tastendruck** nach Ablauf des
  Intervalls – exakt wie der Werbebalken (`SetAutoRepeat`,
  `UI.lua:10986`). Das ist keine Einschränkung, die das Konzept erfindet,
  sondern eine, die das Addon längst sauber gelöst hat. Sie wird in der
  Oberfläche ehrlich beschriftet („postet beim nächsten Tastendruck").

### Der Zulauf: Antworten sammeln, einladen, absagen

**Erfassung:** Läuft eine Suche (Zustand SUCHT), werden eingehende Whisper
der Suche zugeordnet. Die Weiche sitzt in `CaptureWhisper` (`Chat.lua:839`)
und bleibt einfach:

1. `!rezept` gewinnt wie bisher (Werkstattbefehl);
2. **Gildenmitglieder** → Zulauf (das Rekrutierungs-Postfach schließt sie
   ohnehin aus, `Chat.lua:736` – für die Raidsuche sind sie dagegen die
   liebsten Antworten);
3. Externe, deren Nachricht ein **Postfach-Triggerwort** enthält („Gilde",
   „Bewerbung" …) → Postfach wie bisher – wer Anschluss sucht, ist
   Bewerber, nicht Raid-Auffüller;
4. alle übrigen Whisper Externer → Zulauf. LFM-Antworten sind formlos
   („kann mein mage mit?"), ein Triggerzwang würde sie verlieren. Falsche
   Treffer fliegen per ×; der Löschmerker (Tombstone-Muster,
   `Chat.lua:337`) hält sie für den Rest der Suche draußen.

Ohne laufende Suche ändert sich am heutigen Verhalten **nichts**.

**Je Antwort** entsteht ein Eintrag nach dem Vorbild des Lead-Datensatzes
(`Chat.lua:780`): Name, Klasse **sicher aus der Whisper-GUID**
(`ResolveLeadClass` existiert), Stufe aus dem Text, die letzten Nachrichten
(gedeckelt). Die Spec wird, wo der Text sie verrät („kann holy"), als
Vorschlag gesetzt und sonst per Dropdown an der Zeile zugeordnet – erst
dann zählt die Person auf den Rollen-Soll.

**Aktionen je Zeile:**

- **Einladen** → Gruppen-/Raideinladung (neu; siehe Prüfpunkte). Tritt die
  Person bei, springt ihr Zustand automatisch auf DABEI
  (`GROUP_ROSTER_UPDATE`-Abgleich über den Namen) und die Besetzung zählt
  hoch.
- **Antworten** → Antwortentwurf in der Editbox, gesendet per Knopf über
  `GC.Chat:SendReply` (`Chat.lua:1022`) – dasselbe Entwurf-statt-Automatik-
  Prinzip wie im Postfach. Die Vorlagen dazu **baut man sich selbst**
  (Owner-Entscheidung): eine persönliche Liste eigener Antwortvorlagen
  (anlegen, umbenennen, löschen; Deckel 8), jede mit den Platzhaltern
  `{name}`, `{instanz}`, `{termin}`, `{loot}`, `{srlink}`. Zwei Beispiele
  sind ab Werk da und ebenso veränderbar: **„Invite kommt"** und **„Leider
  voll"**. Die Liste liegt **lokal** in den Einstellungen, nicht
  gildenweit – Raid-Antworten sind der Ton des Raidleiters, anders als die
  gildenweiten Standardantworten des Postfachs (`replyTemplates`,
  `Database.lua:150`), die unangetastet bleiben.
- **Als Gildenbewerber übernehmen** → ruft `CaptureLead` und legt die
  Person ins Rekrutierungs-Postfach – der Weg vom guten Random zum
  Rekruten, ohne Abtippen (Stufe 2).
- **×** → raus, mit Löschmerker.

Zustände je Antwort: NEU → ANGESCHRIEBEN → EINGELADEN → DABEI bzw.
ABGESAGT. Neue Antworten melden sich dezent wie Bewerber: Zähler am
Reiter, Punkt am Minimap-Symbol, optionaler Ton über die bestehende
Soundeinstellung (Vorgabe: aus).

## Gilde zuerst (Stufe 2)

Was kein LFM-Spam-Addon kann, der GCP aber schon weiß: **wer intern passen
würde.** Ein Abschnitt „Aus der Gilde passend" listet Mitglieder, deren
bestätigte Raid-Spec (`GC.Roster:GetActiveRaiders`, `Roster.lua:222` +
Profildaten) auf den offenen Bedarf passt, mit Online-Status und ohne die
am Termin Abgemeldeten (`GetGuildAbsences`). Je Zeile: Anflüstern
(vorbelegtes Chatfenster, Muster der Gildenaufträge) und Einladen. Kein
Massen-Anschreiben-Knopf – jede Nachricht bleibt ein Klick pro Person.

## Vorlagen

„Als Vorlage speichern" legt den Suchzettel ohne Zulauf ab – **mit
Wochentag statt Datum** („Kara · dienstags · 19:30 · 2SR > MS > OS · HR:
Urne · Sollbesetzung"). „Anwenden" erzeugt einen neuen Entwurf mit dem
nächsten passenden Datum (`AddDaysISO`/`WeekdayOfISO`, `Core.lua:300-429`).
Der wiederkehrende Dienstags-Kara ist damit zwei Klicks: Vorlage anwenden,
Suche starten. Gedeckelt auf 12 Vorlagen.

## Was das Werkzeug bewusst nicht tut

- **Kein Auto-Spam.** Kein Timer postet ohne Eingabe; das
  Hardware-Event-Prinzip (`Chat.lua:581`) wird wiederverwendet, nicht
  umgangen. Kanal-Cooldowns und Server-Drosselung werden angezeigt statt
  ausgereizt.
- **Keine unaufgeforderten Whisper.** Angeschrieben wird nur, wer
  geantwortet hat oder in der Gilde ist – und immer per Klick, mit
  sichtbarem Entwurf.
- **Kein Matchmaking-Versprechen.** Das Werkzeug verwaltet ehrlich, was
  reinkommt; es „findet" niemanden von selbst und bewertet keine Spieler.
- **Keine Kalenderpflicht.** Stufe 1 ist das persönliche Werkzeug des
  Raidleiters; gildenweite Termine mit Zusagen sind Stufe 3 und ändern
  daran nichts rückwirkend.

## Datenmodell (SavedVariables-Skizze)

Gildenbezogen abgelegt (`guilds[key]`, `Database.lua:135`), in Stufe 1
**nicht synchronisiert** – es wird schlicht keine Sync-Nachrichtenart
registriert. Liegt es von Anfang an dort, braucht Stufe 3 keinen
Datenumzug. Lokale Anzeigezustände liegen wie üblich in `settings`.

```lua
guildData.raidSearch = {
    plan = {                         -- genau EIN Suchzettel (Owner: „nur ein Raid")
        createdBy, createdAt,
        status = "ENTWURF",          -- ENTWURF | SUCHT | BEENDET
        zone = "Karazhan", zoneShort = "Kara", size = 10,
        dateISO = "2026-09-04", timeText = "19:30",
        loot = { rule = "2SR > MS > OS", hr = "Urne", srLink = "…" },
        note = "…",                  -- ≤ 120 Bytes, SanitizedText
        need = {
            roles = { TANK = 2, HEALER = 3, DPS = 5 },
            specs = { ["PRIEST:SHADOW"] = 1 },   -- optionale Feinwünsche
        },
        confirmedText = "…",         -- bestätigter Spruch
        lastPosts = {},              -- je Kanal, wie settings-Pendant
        responses = {                -- Deckel 40, Nachrichten je Antwort ≤ 10
            { name, classFile, level, specKey,
              state = "NEU",         -- NEU|ANGESCHRIEBEN|EINGELADEN|DABEI|ABGESAGT
              firstSeenAt, lastSeenAt, messages = { … } },
        },
        tombstones = {},             -- ×-gelöschte Namen, für die Dauer der Suche
        startedSearchAt, endedAt,
    },
    templates = {},                  -- Deckel 12: Suchzettel mit Wochentag statt Datum
}

settings.raidSearch = {              -- kontoweit, lokal
    bar = { hidden = false, x, y },  -- Suchbalken, Muster settings.postBar
    channels = { LFG = true, TRADE = true, GENERAL = false, GUILD = true,
                 custom = { "World" } },   -- beigetretene Kanäle, je Name
    replyTemplates = {               -- Deckel 8, frei bearbeitbar; 2 ab Werk
        { label = "Invite kommt", text = "…" },
        { label = "Leider voll",  text = "…" },
    },
    repeatMinutes = 5,
    sound = false,
}
```

`GC.DB:Prune()` räumt einen BEENDETEN Zettel nach 7 Tagen ab und hält die
Deckel (Zulauf 40, Nachrichten 10, Suchzettel-Vorlagen 12, Antwortvorlagen
8) – neue Listen ohne Obergrenze gibt es im Projekt bewusst nicht
(`docs/TODO-naechste-sitzung.md:195-201`).

## Was schon dasteht und wiederverwendet wird

| Baustein | Ort | Rolle im Konzept |
|---|---|---|
| Chatspruch mit Längenstufen gegen 255 Bytes | `Recruitment.lua:326` | Vorbild des Spruchbaukastens |
| Kanalversand + Kanalauflösung + Cooldowns | `Chat.lua:483-579`, `Constants.lua:1230` | Posten |
| Hardware-Event-Lösung fürs Wiederholen | `Chat.lua:581-651`, `UI.lua:10986` | Wiederholen-Funktion |
| Byte-sicheres Kürzen | `Core.lua:220` | Spruch |
| Whisper-Erfassung, Klasse aus GUID, Löschmerker | `Chat.lua:337-931` | Zulauf |
| Antwortvorlagen mit Platzhaltern | `Recruitment.lua:397`, `Database.lua:150` | „Invite kommt" / „Leider voll" |
| Klassen/Spec-Auswahl-UI + Spec-Katalog | `UI.lua:7884`, `Constants.lua` | Spec-Wünsche |
| Datumswähler + ISO-Werkzeuge | `UI.lua:945`, `Core.lua:300-429` | Termin, Vorlagen |
| Abmeldungen je Zeitraum | `Roster.lua:724` | „Am Termin abgemeldet: n" |
| Roster/Profile (Spec der Mitglieder) | `Roster.lua:222/889` | Ist-Zählung, „Gilde zuerst" |
| Zeilen-Slot-Muster + Auftragszeilen-Fabrik | `UI.lua:6276-6420` | Zulauf-Liste |
| Verschiebbarer Kompaktrahmen | `UI.lua:10891` | Suchbalken |
| Raidgruppen-Events | `RaidMonitor.lua:2795` | Ist-Zählung, DABEI-Erkennung |

Neu zu bauen sind im Kern: der Plan-Datentyp mit Zustandsmodell, die
Bedarfsrechnung Soll/Ist, die Whisper-Weiche, die Gruppeneinladung und die
Seite selbst.

## Umsetzungs-Prüfpunkte (WoW-API zuerst nachschlagen)

Lehre aus `GuildUninvite` (`#protected`, stilles Nichtstun –
`docs/TODO-naechste-sitzung.md:304`): Vor der Umsetzung gegen die
2.5.6-API-Dokumentation prüfen, nicht aus dem Gedächtnis bauen:

1. **Gruppeneinladung aus dem Addon:** `C_PartyInfo.InviteUnit` bzw.
   `InviteUnit` – vorhanden und nicht `#protected`? (Der Einladen-Knopf
   ist ein Klick, ein Hardware-Event liegt also vor.)
2. **Umwandlung zu Schlachtzug** ab dem 6. Mitglied:
   `C_PartyInfo.ConvertToRaid` – aufrufbar, oder braucht es den Hinweis
   „bitte von Hand umwandeln"?
3. **`GC.Onboarding.TOUR`**: Sektion RAID ist abgedeckt; ob je Reiter ein
   Eintrag nötig ist, sagt `tests/validate.mjs:1006`.
4. Kanalnachrichten sind belegt gelöst (der Werbebalken postet heute schon
   in LFG/Handel) – hier ist nichts zu prüfen, nur wiederzuverwenden.

## Ausbaustufen

**Stufe 1 (der eigentliche Vorschlag):** Navigationspunkt „Raidsuche" in
der RAID-Sektion (`NAV_TAB_SPACING` 34 → 32), der eine Suchzettel mit
Instanz, Termin, Lootregel-Freitext, HR, SR-Link, Notiz; Besetzung in zwei
Ebenen mit Live-Ist-Zählung; Spruchbaukasten mit Bestätigung, Kanalwahl
(inkl. Gilde und eigener Kanäle), Cooldowns und Tastendruck-Wiederholen;
Zulauf mit Klassenerkennung, Einladen, selbstgebauten Antwortvorlagen,
×-Merker; Suchzettel-Vorlagen mit Wochentag; Suchbalken mit
Cooldown-Anzeige.

**Stufe 2:** „Aus der Gilde passend" (Roster + Profile + Abmeldungen),
„Als Gildenbewerber übernehmen" ins Postfach, Brücke zur Raidauswertung
(nach dem Abend: welche Externen aus dem Zulauf waren dabei – ein Klick
zum Vormerken).

**Stufe 3 – gildenweite Raidplanung:** Pläne über eine neue
Sync-Nachrichtenart (Muster gildenweites Postfach, `Chat.lua:1148`,
Registrierung `Sync.lua:2662`) teilen; Mitglieder sehen kommende Raids und
sagen im Addon zu oder ab. Das wäre der Kalender-Ersatz, den der
2.5.6-Client nicht mitbringt – aber erst, wenn Stufe 1 sich im Alltag
bewährt hat.

**Ausdrücklich offen gelassen:** ein LFG-Kanal-Radar (eingehende
„LFG"-Rufe passend zum Bedarf einsammeln – die Kanal-Erfassung existiert,
aber der Nutzen muss den Datenmüll rechtfertigen); GDKP-Sonderfunktionen;
Anwesenheits-Statistik über Externe.

## Entscheidungen des Owners (28.08.2026)

Fünf der sechs beim Entwurf offenen Fragen sind entschieden (die
Platzfrage über den Reiternamen gleich mit); der Text oben ist
entsprechend nachgezogen:

1. **Name: „Raidsuche"** als Reiter- und Featurename. Damit ist auch der
   Platzweg bestätigt: eigener Navigationspunkt in der RAID-Sektion,
   `NAV_TAB_SPACING` 34 → 32.
2. **Nur ein Raid:** genau ein Suchzettel statt einer Planliste. Mehrere
   Termine werden über Suchzettel-Vorlagen vorbereitet.
3. **Kanalwahl ausdrücklich bekräftigt:** je Suche frei wählbar, in welche
   Kanäle gepostet wird – zusätzlich zu den vier Kanalarten und „Gilde"
   stehen die selbst beigetretenen Kanäle (z. B. „World") zur Wahl.
4. **Suchbalken in Stufe 1**, wie der Werbebalken der Gildenwerbung samt
   Cooldown-Countdown am Posten-Knopf.
5. **Antwortvorlagen zum Selbstbasteln:** eine frei bearbeitbare
   persönliche Vorlagenliste (lokal, Deckel 8) statt fest verdrahteter
   Texte; zwei editierbare Beispiele ab Werk.

**Bleibt offen:** Stufe 3 (gildenweit geteilte Termine mit Zu-/Absagen).
Die Datenablage im `guilds[key]`-Zweig hält den Weg frei; entschieden wird
mit Erfahrungswerten aus Stufe 1.

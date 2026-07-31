# Konzept: Gildenaufträge in der Gildenwerkstatt

> **Status: Entwurf, nicht umgesetzt.** Dieses Dokument ist das Ergebnis des
> Konzeptauftrags vom 31.07.2026. Datei- und Zeilenangaben beziehen sich auf
> Addon **0.9.49** (Commit `9dde916`).

## Auftrag des Repository-Owners (Zusammenfassung)

Gildenmitglieder sollen **Gildenaufträge** für Rezepte erstellen können, die in
der Gildenwerkstatt vorhanden sind. Feste Anforderungen:

- Rezeptübersicht aufklappbar und suchbar je Beruf; daraus wird das Rezept
  gewählt, das in Auftrag geht;
- alle Gildenmitglieder, die das Rezept beherrschen, können annehmen –
  **aber nur einer gleichzeitig**;
- Status- bzw. Logfunktion als Rückmeldung für den Auftraggeber
  (angenommen → in Bearbeitung → versandt/übergabebereit → …);
- der Auftraggeber legt fest, ob **persönliche Übergabe oder Post** gewünscht
  ist;
- die **Materialfrage** braucht ein durchdachtes Modell (Gildenbank,
  Auftragnehmer kauft ein und bekommt es erstattet, Auftraggeber liefert
  vorab);
- **Twink-Regel** (Nachtrag): Wer auf einem Twink eingeloggt ist, darf
  annehmen, wenn **ein Charakter seines Accounts** – etwa der Main – Beruf
  und Rezept hat; gefertigt wird dann mit diesem Charakter. Wer Beruf und
  Rezept nirgends hat, darf nicht annehmen;
- eventuell die Werkstatt als eigenes Fenster „auspoppen";
- intuitiv, logisch für alle Beteiligten, klare Übersicht für beide Seiten.

## Leitidee: Koordinationsschicht, kein Treuhänder

Das Addon kann keine Gegenstände bewegen, kein Gold verschieben und keine
Post automatisch verschicken. Jeder Gildenauftrag ist deshalb eine
**dokumentierte Absprache**: Das Addon hält fest, was vereinbart wurde, zeigt
beiden Seiten jederzeit, **wer als Nächstes dran ist**, und protokolliert
jeden Schritt in einem Verlauf. Vertrauen bleibt Sache der Gilde – das Addon
macht es sichtbar statt es zu ersetzen.

Daraus folgen drei Grundsätze, die sich durch das ganze Konzept ziehen:

1. **„Wer ist dran?" steht an jedem Auftrag.** Jeder Status hat genau einen
   nächsten Handelnden. Die eigene Liste sortiert „du bist dran" nach oben.
2. **Jede Statusänderung ist eine Selbstauskunft mit Absender und Zeit.**
   Das Addon prüft, wer sie melden darf, aber nicht, ob sie stimmt – dafür
   gibt es den Verlauf, den beide Seiten sehen.
3. **Absprachen werden vor der Annahme festgezurrt.** Die Annahme ist die
   Zustimmung zu den ausgeschriebenen Bedingungen. Wer andere Bedingungen
   will, flüstert vorher; der Auftraggeber passt den offenen Auftrag an.
   Nach der Annahme sind die Bedingungen eingefroren.

## Rollen und Begriffe

| Begriff | Bedeutung |
|---|---|
| **Auftraggeber** | Charakter, der den Auftrag erstellt. Nur er kann ihn ändern (solange offen), abbrechen und abschließen. |
| **Auftragnehmer** | Der **Account**, der angenommen hat – nicht der einzelne Charakter. Grundlage ist der `accountTag`, den der Handshake bereits gildenweit teilt (`Sync.lua` ~1216). |
| **Ausführender Charakter** | Der Charakter des Auftragnehmer-Accounts, der das Rezept laut geteiltem Katalog beherrscht und fertigt. Wird bei der Annahme festgelegt. |
| **Katalog** | Die bestehende geteilte Rezeptliste der Werkstatt (`workshop.catalog` mit Herstellerliste je Rezept, `Workshop.lua` ~1750). Sie ist die Wahrheit dafür, wer was kann. |

## Der Lebenslauf eines Gildenauftrags

```
                    ┌──────────────────────────────┐
                    │ ERSTELLT (= OFFEN)           │◄──────────┐
                    │ dran: jeder passende Account │           │
                    └──────────────┬───────────────┘           │
                                   │ annehmen                  │ zurücklegen /
                                   ▼                           │ Rückfall
                    ┌──────────────────────────────┐           │
                    │ ANGENOMMEN                   │───────────┘
                    │ dran: je nach Materialmodell │
                    └──────────────┬───────────────┘
                                   │ „Materialien vollständig"
                                   ▼
                    ┌──────────────────────────────┐
                    │ IN ARBEIT                    │
                    │ dran: Auftragnehmer          │
                    └──────────────┬───────────────┘
                                   │ „gefertigt"
                                   ▼
                    ┌──────────────────────────────┐
                    │ FERTIG                       │
                    │ dran: je nach Übergabeart    │
                    └──────┬───────────────┬───────┘
                     Post: │ „versandt"    │ persönlich:
                           ▼               │ Übergabe im Spiel
                    ┌────────────┐         │
                    │ VERSANDT   │         │
                    └──────┬─────┘         │
                           └───────┬───────┘
                                   │ Auftraggeber: „erhalten"
                                   ▼
                    ┌──────────────────────────────┐
                    │ ABGESCHLOSSEN                │
                    └──────────────────────────────┘

  Jederzeit durch den Auftraggeber: ABGEBROCHEN (mit Pflicht-Hinweis im
  Verlauf, wenn bereits angenommen). OFFENE Aufträge verfallen nach TTL.
```

Warum **IN ARBEIT** ein eigener Schritt ist: Zwischen Annahme und Fertigung
liegt bei zwei der drei Materialmodelle echte Wartezeit (Material unterwegs,
Einkauf läuft). „Materialien vollständig" ist der natürliche Übergang – ein
Klick des Auftragnehmers, der dem Auftraggeber sagt: *ab jetzt hängt es nur
noch am Fertigen.* Beim Modell „Auftragnehmer hat alles selbst" springt die
Annahme direkt auf IN ARBEIT, der Zwischenschritt entfällt automatisch.

**Der Verlauf** ist die geforderte Logfunktion: je Auftrag eine kompakte
Liste `Zeit – Charakter – Ereignis – optionale Notiz`, gedeckelt auf die
letzten 12 Einträge (Platzdisziplin wie überall in den SavedVariables).
Jede Statusänderung erzeugt genau einen Eintrag; zusätzlich gibt es einen
freien „Notiz an die Gegenseite"-Eintrag (z. B. „bin bis Sonntag im Urlaub").

**Zweiseitiger Abschluss nur beim Geldmodell:** Meldet der Auftragnehmer beim
Beschaffungsmodell offene Kosten an, wird aus „erhalten" erst dann
ABGESCHLOSSEN, wenn auch er „Erstattung erhalten" bestätigt hat. In allen
anderen Fällen schließt der Auftraggeber allein ab – er ist derjenige, dem
geliefert wird.

## Annehmen und die Twink-Regel

**Wer darf annehmen?** Der Annehmen-Knopf erscheint nur, wenn im geteilten
Katalog **ein Charakter des eigenen Accounts** als Hersteller des Rezepts
steht. Das deckt die Twink-Regel vollständig ab, denn die Werkstatt teilt
Twink-Berufe seit 0.9.26 unter ihren echten Charakternamen
(`GetAccountProfessions`, `Workshop.lua` ~1019):

- Eingeloggt auf dem Twink, Rezept ist auf dem Main → annehmbar. Als
  ausführender Charakter wird der Main eingetragen; können mehrere eigene
  Charaktere das Rezept, fragt ein kleiner Dialog, wer fertigt.
- Rezept auf keinem eigenen Charakter → kein Annehmen-Knopf, stattdessen
  ausgegraut mit Begründung („Kein Charakter deines Accounts beherrscht
  dieses Rezept").

**Was prüfen die anderen Clients?** Zwei Dinge, beide gegen geteilte Daten:

1. Der im Auftrag genannte **ausführende Charakter steht im Katalog** als
   Hersteller des Rezepts.
2. Spätere Auftragnehmer-Aktionen (Material vollständig, gefertigt, versandt,
   zurücklegen) kommen von einem Charakter, dessen `accountTag` zum
   Auftragnehmer-Account passt. Der Absendername einer Addon-Nachricht kommt
   vom Server und ist nicht fälschbar; die Zuordnung Charakter → accountTag
   liefert der bestehende Handshake. Ist der Tag eines Absenders (noch)
   unbekannt, gelten ersatzweise die beiden im Auftrag genannten Charaktere.

**Nur einer gleichzeitig – die Doppelannahme.** Zwei Spieler können in
derselben Sekunde annehmen, bevor die Nachricht des jeweils anderen ankommt.
Das löst keine Sperre, sondern eine **deterministische Regel**, wie überall
im Addon („die aktuellsten Daten gewinnen", `Inventory.lua` ~655 – hier
umgekehrt: der **früheste** Zeitstempel gewinnt, bei Gleichstand die
alphabetisch kleinere Account-Kennung). Beide Clients kommen ohne Rückfrage
zum selben Ergebnis. Der Unterlegene sieht: *„Muradin war schneller – der
Auftrag ist wieder bei ihm."* Das Fenster ist wenige Sekunden groß und die
Auflösung harmlos, weil zwischen Annahme und erster echter Handlung
praktisch immer Zeit liegt.

## Die Materialfrage: drei klare Modelle

Der Auftraggeber wählt das Modell **beim Erstellen** – es ist Teil der
ausgeschriebenen Bedingungen, die mit der Annahme akzeptiert sind. Damit die
Wahl leichtfällt, rechnet der Erstellen-Dialog mit der vorhandenen
Bedarfslogik (`GetReagentStatus`, `Inventory.lua` ~680) vor, was der eigene
Bestand und die bekannte Gildenbank bereits abdecken, und schlägt das
passende Modell vor.

### Modell A – „Ich liefere die Materialien" (Vorgabe)

| Schritt | Wer | Was |
|---|---|---|
| Nach Annahme | Auftraggeber | übergibt Materialien persönlich oder per Post an den ausführenden Charakter (Name steht am Auftrag) |
| Danach | Auftragnehmer | klickt „Materialien vollständig" → IN ARBEIT |

Klarster Fall, kein Geld im Spiel. Der Auftrag zeigt dem Auftraggeber bis
dahin als Nächstes-dran-Hinweis: *„Materialien an &lt;Charakter&gt; liefern."*

### Modell B – „Materialien aus der Gildenbank"

| Schritt | Wer | Was |
|---|---|---|
| Nach Annahme | Auftragnehmer (oder wer Bankzugriff hat) | entnimmt die Materialien; der Auftrag listet sie mit Stückzahl |
| Danach | Auftragnehmer | „Materialien vollständig" → IN ARBEIT |

Das Addon zeigt beim Erstellen, welche Positionen die bekannte Gildenbank
laut geteiltem Bestand abdeckt – **als Auskunft, nicht als Reservierung**.
Ob die Entnahme erlaubt ist, regeln Bankrechte und Gildenregeln, nicht das
Addon; der Verlauf dokumentiert nur, dass dieses Modell vereinbart war.
Deckt die Bank nur einen Teil, gilt für den Rest automatisch Modell A – der
Auftrag listet beide Anteile getrennt.

### Modell C – „Auftragnehmer besorgt, Auftraggeber erstattet"

| Schritt | Wer | Was |
|---|---|---|
| Beim Erstellen | Auftraggeber | setzt optional einen **Kostenrahmen** („bis 50 g") – Teil der Bedingungen |
| Nach Annahme | Auftragnehmer | kauft ein (AH, Händler, Farmen); „Materialien vollständig" → IN ARBEIT |
| Bei „gefertigt" | Auftragnehmer | trägt die **tatsächlichen Kosten** ein → am Auftrag erscheint „Erstattung offen: 43 g 20 s" |
| Nach Erhalt | Auftraggeber | erstattet per Handel oder Post und markiert „erstattet" |
| Abschluss | Auftragnehmer | bestätigt „Erstattung erhalten" → erst dann ABGESCHLOSSEN |

Der Kostenrahmen ist die Absicherung gegen das „schwammige" Gefühl: Beide
wissen vor der Annahme, was maximal fällig wird. Liegt der echte Betrag
darüber, kann der Auftragnehmer ihn zwar eintragen, der Auftrag markiert die
Überschreitung aber sichtbar – klären müssen es die beiden, das Addon zeigt
es nur ehrlich an.

**Bewusst kein viertes Modell „Mischformen frei verhandeln":** Jede weitere
Variante macht die Statusanzeige mehrdeutig. Wer etwas Exotisches vereinbaren
will, nutzt Modell A plus Notizfeld – der Verlauf hält es fest.

### Trinkgeld

Eigenes optionales Feld beim Erstellen („Trinkgeld: 5 g"), getrennt von der
Materialfrage. Es ändert keinen Status, steht aber gut sichtbar an der
Ausschreibung – erfahrungsgemäß der beste Beschleuniger für offene Aufträge.

## Übergabe: persönlich oder per Post

Der Auftraggeber wählt beim Erstellen die gewünschte Übergabeart; sie steht
als Bedingung an der Ausschreibung.

- **Persönlich:** Nach FERTIG zeigt der Auftrag beiden ein „Übergabe
  vereinbaren" mit Flüster-Knopf (öffnet das Chatfenster mit dem richtigen
  Empfänger vorbelegt – der jeweils zuletzt online gesehene Charakter des
  anderen Accounts aus dem Roster). Nach der Übergabe klickt der
  Auftraggeber „erhalten".
- **Post:** Nach FERTIG klickt der Auftragnehmer beim Abschicken „versandt";
  der Auftraggeber bestätigt „erhalten", sobald die Post da ist. Die
  Empfängerangabe steht am Auftrag (der Auftraggeber-Charakter); das Addon
  verschickt nichts selbst, es erinnert nur an den richtigen Namen.

Die Namensfrage bei Accounts mit mehreren Charakteren löst der Auftrag
explizit: Geliefert wird immer an den **Auftraggeber-Charakter**, gefertigt
und versandt vom **ausführenden Charakter** – beide Namen stehen von Anfang
bis Ende sichtbar am Auftrag, niemand muss raten.

## Oberfläche

### Ort: ein Unterbereich der Werkstattseite – kein eigenes Hauptfenster

Empfehlung gegen das komplette „Auspoppen" der Werkstatt, aus denselben
Gründen, aus denen das Onboarding eine Karte statt eines Wizards wurde
(`KONZEPT-onboarding-erste-schritte.md`): Ein zweites großes Fenster
dupliziert Katalog, Suche und Bestandslogik oder muss sie fernsteuern. Die
Seitenleiste des Hauptfensters ist außerdem exakt bemessen
(`tests/validate.mjs` prüft die Maße) – ein weiterer Navigationspunkt passt,
ein zweites Fensterlayout ist ein eigenes Projekt.

Stattdessen bekommt die Werkstattseite **zwei Unterreiter**:

```
┌─ GILDENWERKSTATT ───────────────────────────────────────────┐
│  [ Katalog ]  [ Gildenaufträge (3) ]                        │
│  ─────────────────────────────────────────────────────────  │
│  … bestehende Rezeptsuche mit Berufsfilter …                │
│  ┌─ Rezept: Mongoose ───────────────────────────────┐       │
│  │ Hersteller: Falco, Muradin                       │       │
│  │ Reagenzien: …                    [In Auftrag geben]      │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

- **„In Auftrag geben"** sitzt direkt an der Rezeptkarte im Katalog – die
  gewünschte „aufklappbare, suchbare Rezeptübersicht je Beruf" **ist** die
  bestehende Katalogsuche; es gibt keinen zweiten Auswahlweg. Der Knopf ist
  nur aktiv, wenn das Rezept mindestens einen Hersteller hat.
- Der Reiter **Gildenaufträge** zeigt drei Abschnitte untereinander, jeder
  einklappbar:

```
┌─ GILDENAUFTRÄGE ────────────────────────────────────────────┐
│ ▼ DU BIST DRAN (2)                                          │
│  ● Mongoose ×1 · für Brooklee · IN ARBEIT                   │
│    „gefertigt" melden                        [Gefertigt]    │
│  ● Erdstärke ×2 · von Falco · ANGENOMMEN                    │
│    Materialien an Muradin liefern       [Verlauf] [Notiz]   │
│ ▼ OFFENE AUFTRÄGE DER GILDE (4)          [nur machbare ☑]   │
│  ○ Sonnenfeuer ×1 · von Ysel · Modell C, bis 60 g · Post    │
│    Dein Main Falco kann das Rezept           [Annehmen]     │
│  ○ Manaöl ×5 · von Tars · Modell A · persönlich   (grau)    │
│    Kein Charakter deines Accounts kann dieses Rezept        │
│ ▶ MEINE ABGESCHLOSSENEN (7)                                 │
└─────────────────────────────────────────────────────────────┘
```

- **„Du bist dran"** fasst beide Rollen zusammen – erteilte und angenommene
  Aufträge, bei denen die nächste Handlung beim eigenen Account liegt. Das
  ist die geforderte klare Übersicht für beide Seiten in einer Liste, ohne
  dass jemand zwischen „meine erteilten" und „meine angenommenen" hin- und
  herdenken muss; die Rolle steht als „für &lt;Name&gt;" / „von &lt;Name&gt;"
  in der Zeile.
- Der Filter **„nur machbare"** blendet offene Aufträge aus, die kein
  eigener Charakter fertigen kann (Vorgabe: an).
- **Verlauf** öffnet die Logliste des Auftrags als kleines Overlay.

### Kompakt-Tracker statt Werkstatt-Pop-out

Für den Wunsch, Aufträge im Blick zu behalten, ohne das Hauptfenster offen zu
halten, gibt es einen **abkoppelbaren Mini-Rahmen** nach dem bewährten
Muster des Werbebalkens (`UI.lua` ~5175: frei verschiebbar, Position in den
Einstellungen, eigenständige Auffrischung): drei Zeilen „Du bist dran",
Klick öffnet die Werkstattseite am richtigen Auftrag. Das erfüllt den Kern
des Pop-out-Wunsches mit einem Bruchteil des Aufwands. Sollte sich später
herausstellen, dass die ganze Werkstatt als Fenster gebraucht wird, ist der
Unterreiter-Schnitt dafür die richtige Vorarbeit (die Auftragsliste ist dann
ein fertiger, unabhängiger Baustein).

### Benachrichtigungen

Dezent und über die bestehenden Kanäle, keine Popups:

- Chat-Hinweis (eine Zeile) bei: neuer machbarer Auftrag, Annahme des
  eigenen Auftrags, Statuswechsel eines eigenen Auftrags, Rückfall.
- Zähler am Reiter („Gildenaufträge (3)" = „du bist dran"-Anzahl) und
  derselbe Punkt am Minimap-Symbol, der schon fürs Onboarding existiert
  (`RefreshMinimapMarker`).
- Ton nur optional und über die bestehende Soundeinstellung, aus denselben
  Gründen wie beim Bewerberton (wer ihn nicht braucht, soll ihn nicht
  abschalten müssen – Vorgabe: aus).

## Synchronisation und Konflikte

Neue Nachrichtenfamilie **`O`** über die vorhandene Infrastruktur:

- **Transport:** Statuswechsel sind Einzeiler über den Gildenkanal (weit
  unter 255 Bytes). Vollstände (Antwort auf Anfrage) laufen über die
  Bulk-Warteschlange, wie Werkstattkataloge heute.
- **Anti-Entropie wie beim Werkstatt-Manifest:** Beim Login sendet der
  Client ein kompaktes Auftrags-Manifest (`ID + Revision` je Auftrag);
  wer Neueres kennt, antwortet gezielt. Ein Login ohne Änderungen kostet ein
  Paket – dasselbe Prinzip, das die Werkstatt seit dem Manifest fährt.
- **Revision je Auftrag:** Jede legitime Änderung erhöht `rev`. Höhere
  Revision gewinnt; gleiche Revision mit widersprüchlichem Inhalt löst die
  deterministische Regel (frühester Zeitstempel, dann Account-Kennung) –
  relevant praktisch nur für die Doppelannahme.
- **Berechtigungsprüfung beim Empfang:** Auftraggeber-Aktionen nur vom
  Auftraggeber-Charakter; Auftragnehmer-Aktionen von jedem Charakter mit
  passendem `accountTag` (Rückfall: die beiden benannten Charaktere);
  Annahme nur, wenn der ausführende Charakter laut Katalog das Rezept kann.
  Absendernamen liefert der Server, sie sind nicht fälschbar.
- **Alte Clients:** Der `O`-Typ fällt bei ihnen durch die bestehende
  Weiche in `Sync.lua` (~1408) in keinen Zweig und wird ignoriert. Kein
  Schema-Bruch; Nutzer alter Versionen sehen schlicht keine Aufträge.

## Datenmodell (SavedVariables-Skizze)

```lua
guildData.workshop.orders = {
    [orderID] = {                     -- "Falco-1785…-4711", Muster wie Session-IDs
        rev = 7,
        recipeKey = "ENCHANTING:2673",
        quantity = 1,
        createdBy = "Brooklee",       -- Auftraggeber-Charakter (Lieferziel)
        createdByTag = "a1b2c3d4e5",
        createdAt = 1785512345,
        materialModel = "C",          -- A | B | C
        delivery = "MAIL",            -- TRADE | MAIL
        costLimit = 600000,           -- Kupfer; nur Modell C, optional
        tip = 50000,                  -- optional
        note = "…",                   -- ≤ 120 Bytes, SanitizedText
        status = "IN_ARBEIT",
        acceptedByTag = "f6g7h8…",
        acceptedAt = 1785512999,
        crafter = "Falco",            -- ausführender Charakter
        acceptedVia = "Falcotwink",   -- wer den Knopf drückte (fürs Log)
        actualCost = 432000,          -- Modell C, vom Auftragnehmer
        reimbursed = false,           -- Modell C, zweiseitiger Abschluss
        log = { { at=…, by="…", event="ACCEPTED", note="…" }, … },  -- ≤ 12
    },
}
```

**Platz- und Fairnessgrenzen** (Prune-Philosophie wie `Database.lua` ~250):

- höchstens **5 offene** Aufträge je Account (Spam-Schutz);
- OFFENE Aufträge verfallen nach **14 Tagen** (Verlauf vermerkt es);
- ABGESCHLOSSENE/ABGEBROCHENE wandern in eine Historie, gedeckelt auf die
  **letzten 20** je Gilde, Rest wird weggeräumt;
- Gesamtdeckel **60 Aufträge** je Gilde – die ältesten erledigten zuerst.

**Rückfall bei Inaktivität:** Bewegt sich ein ANGENOMMENER Auftrag **3 Tage**
nicht, bekommt der Auftraggeber einen „Zurücklegen"-Knopf (kein Automatismus –
vielleicht ist der Auftragnehmer nur im Urlaub, und genau dafür gibt es die
Notiz). Verlässt der Auftragnehmer-Account die Gilde (kein Charakter mehr im
Roster), fällt der Auftrag automatisch auf OFFEN zurück, mit Logeintrag.

## Was das Addon bewusst nicht tut

- **Keine Reservierung in der Gildenbank** – es zeigt nur, was der geteilte
  Bestand hergibt. Rechte und Regeln bleiben bei der Gilde.
- **Kein Gold- oder Gegenstandstransfer, keine automatische Post.** Alles,
  was Werte bewegt, passiert im Spiel von Hand; das Addon dokumentiert.
- **Keine Bewertung, keine Durchsetzung.** Ob ein Kostenrahmen fair war,
  entscheidet keine Logik. Der Verlauf macht Absprachen nachlesbar – das ist
  die ganze Autorität, die ein Addon haben sollte.
- **Keine auftragsbezogene Chat-Automatik** außer dem vorbelegten
  Flüster-Fenster.

## Ausbaustufen

**Stufe 1 (der eigentliche Vorschlag):** Unterreiter mit den drei
Abschnitten, Erstellen-Dialog am Katalogrezept (Menge, Modell A/B/C,
Übergabeart, Kostenrahmen, Trinkgeld, Notiz), Statusmodell mit Verlauf,
Twink-Regel, Doppelannahme-Auflösung, Manifest-Abgleich, Grenzen und
Rückfall. Ohne Kompakt-Tracker.

**Stufe 2:** Kompakt-Tracker; „Erstattung erhalten"-Feinschliff mit
Restbetragsanzeige; Flüster-Vorbelegung mit Online-Erkennung des richtigen
Charakters; optional ein gerichteter Auftrag („Wunsch-Hersteller", der 24 h
Vorrang hat, danach offen für alle").

**Ausdrücklich offen gelassen** (erst mit Erfahrungswerten entscheiden):
Teillieferungen bei Stückzahlen > 1, Auftragsvorlagen, Statistiken („wer hat
wie viele Aufträge erfüllt") – Letzteres kann sozialen Druck erzeugen, den
eine Gilde vielleicht gar nicht will.

## Offene Fragen an den Owner

1. **Name im UI:** „Gildenaufträge" als Reiter- und Featurename – oder
   lieber Einzahl „Gildenauftrag" als Aktionsbegriff („Gildenauftrag
   erstellen") und „Aufträge" als Reiter?
2. Dürfen **Offiziere** fremde Aufträge abbrechen (Aufräumrecht wie bei der
   Mitgliederpflege, über die bestehende Rangfreigabe), oder bleibt das
   allein beim Auftraggeber?
3. Soll Modell B (Gildenbank) eine **Rangbedingung** sichtbar machen („nur
   wählbar, wenn dein Rang die Bank nutzen darf")? Das Addon kennt die
   Bankrechte nicht zuverlässig – es wäre eine Angabe der Gilde in den
   Einstellungen, keine echte Prüfung.
4. Reichen **5 offene Aufträge je Account und 14 Tage TTL**, oder andere
   Werte?
5. Stufe 1 ohne Kompakt-Tracker in Ordnung, oder gehört er von Anfang an
   dazu?

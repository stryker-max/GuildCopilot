# Änderungen

Kurzfassung je Version – was sich für Nutzer ändert, in einer Handvoll Zeilen.
Die ausführliche Begründung samt Hintergrund steht weiterhin in
[ROADMAP.md](ROADMAP.md); diese Liste beginnt mit 0.9.83, ältere Versionen sind
dort nachzulesen.

Installer und Addon werden getrennt gezählt.

## 0.9.86 – Addon

**Neu**

- **Ladebalken statt Paketzahl.** Unten in der Gildenwerkstatt stand bisher
  „110 Berufspakete empfangen". Die Zahl beantwortete die Frage nicht, die man
  dort stellt. Jetzt steht dort ein Balken mit Prozentwert: Er zählt, was noch
  offen ist — ausgehende Pakete, angefangene Übertragungen und Berufe, die
  jemand angekündigt und noch nicht geliefert hat. **100 % gibt es nur, wenn
  davon nichts übrig ist.** Darunter in einem Satz, woran es hängt, und wann
  zuletzt alles vollständig war. Im Fensterkopf steht derselbe Stand.
- **Gildenübersicht mit Puffer: 35 statt 25 Plätze.** 25 war exakt die Größe
  eines Schlachtzugs — Ersatzleute und gerade offline gegangene Stammspieler
  fielen hinten heraus.

**Behoben**

- **Zwei Offiziere gleichzeitig auf „Sitzung starten": der Abend wurde zweimal
  mitgeschrieben.** Es entstanden zwei Sitzungen mit zwei Kennungen, jeder
  behielt seine eigene, und die Teilnehmer verteilten sich auf beide — je
  nachdem, wessen Startruf zuerst ankam. „Sitzung beenden" schloss immer nur
  eine davon; die andere lief weiter. Jetzt entscheidet eine Regel, die auf
  jedem Rechner dasselbe Ergebnis liefert: **die früher gestartete Sitzung
  gewinnt**, bei gleicher Sekunde die kleinere Kennung. Wer verliert, bekommt
  „Die Raidsitzung wurde bereits von *Name* gestartet – deine wurde damit
  zusammengeführt." Ein bereits laufender Abend wird dabei nie verworfen: Nach
  zwei Minuten bleibt die eigene Sitzung stehen, und es gibt stattdessen eine
  Warnung.
- **„Es läuft bereits eine Sitzung"** sagt jetzt auch, **wer** sie gestartet
  hat — und das Fenster „Raidinstanz betreten" verschwindet nicht mehr wortlos,
  wenn jemand schneller war.
- **Das Kalendersymbol der Abmeldung ließ sich kaum anklicken.** In der Mitte
  passierte nichts, nur ganz am Rand — praktisch nur in der unteren rechten
  Ecke. Knopf und Eingabefeld lagen auf derselben Ebene, und das Eingabefeld
  fing den Klick ab; anklickbar blieb genau der schmale Rand, den es nicht
  bedeckt. Der Knopf sitzt jetzt sichtbar **über** dem Feld und ist auf ganzer
  Fläche anklickbar. Das `×` der Rezeptsuche hatte denselben Fehler.
- **Bildraten-Einbrüche durch eine Endlosschleife bei der Berufserfassung.**
  Um eingeklappte Kategorien im Fähigkeitenfenster lesen zu können, klappt das
  Addon sie kurz auf und wieder zu. Genau das löst aber `SKILL_LINES_CHANGED`
  aus — also dasselbe Ereignis, das die Erfassung anstößt. Das Addon trieb sich
  damit endlos selbst an, bei jedem, der mindestens eine Kategorie zugeklappt
  hatte. Jetzt wird zuerst nachgesehen, ohne etwas anzufassen; nur wenn das
  nichts findet, wird auf- und zugeklappt, und das dabei entstehende Ereignis
  wird erkannt und übergangen. Zusätzlich ist die Erfassung entprellt —
  `SKILL_LINES_CHANGED` feuert in TBC auch für jeden Waffenfertigkeitspunkt,
  also mitten im Kampf im Sekundentakt.
- **Ruckler beim Ein- und Ausloggen vieler Gildenmitglieder.** Jedes
  eingehende Profil zeichnete die offene Seite sofort und vollständig neu. Der
  Sammel-Timer aus 0.9.49 war dafür gebaut, dieser eine Pfad lief an ihm vorbei.
- **Ein älteres Profil konnte ein neueres überschreiben.** Pakete desselben
  Absenders können sich überholen; bisher gewann schlicht das zuletzt
  eingetroffene. Jetzt gewinnt der neuere Zeitstempel.
- **„Zuletzt geändert" stimmte nicht.** Der Zeitstempel des eigenen Profils
  sprang bei jedem Spielereignis nach vorn, auch wenn sich nichts geändert
  hatte.

**Geändert**

- **Seitenleiste geordnet.** „Warcraft Logs" steht jetzt im Abschnitt **Raid**,
  vor der Raidauswertung, die es beliefert — statt unter „Roster". Der
  Abschnitt „Roster" heißt jetzt **Gilde** und führt Mitgliederpflege und
  Gildenwerkstatt.
- **„Alle synchron" im Fensterkopf** meinte bisher „alle haben dieselbe
  Addon-Version", nicht „die Daten sind vollständig". Das ist jetzt
  auseinandergehalten.

## 0.9.85 – Addon

**Behoben**

- **Leere Kästchen statt Symbolen.** In den Abmeldefeldern Von und Bis stand
  seit 0.9.84 ein leerer Kasten, wo das Kalendersymbol hingehört: Die
  Spielschrift kennt kein Emoji und zeichnet dafür ein Ersatzzeichen. Dasselbe
  galt für die Blätterpfeile im Postfach. Beide Symbole werden jetzt gezeichnet
  statt geschrieben und können deshalb nicht mehr fehlen.
- **Ankreuzkästchen ohne Haken.** Ob ein Kästchen angekreuzt war, verriet nur
  die Füllfarbe — der Haken lag hinter dem Kästchen und war in der ganzen
  Oberfläche unsichtbar. Er steht jetzt sichtbar darin.
- **Das goldene Häkchen neben „Bestätigen"** stammte aus Blizzards
  Benutzeroberfläche und passte weder farblich noch stilistisch. Es ist jetzt
  ein schlichter grüner Haken — dieselbe Farbe, in der das Addon überall
  „erledigt" meldet. Ebenso in der Checkliste „Erste Schritte".

## 0.9.84 – Addon

**Behoben**

- **Abmeldung: angefangene Eingaben verschwanden.** Wer das Von-Datum eintrug
  und dann ins Bis-Feld klickte, fand das erste Feld kurz darauf leer vor. Die
  Felder wurden im Hintergrund mit dem gespeicherten — also noch leeren —
  Stand überschrieben. Wie oft das passierte, hing daran, wie viel gerade an
  Gildendaten hereinkam; deshalb trat es nicht bei jedem auf. Ein angefangenes
  Formular bleibt jetzt stehen, bis es gespeichert oder gelöscht wird.

**Neu**

- **Datum per Kalender wählen.** Das Kalendersymbol in den Feldern Von und Bis
  öffnet ein Monatsblatt mit deutschen Monatsnamen, Mo–So, Monatswechsel und
  einem Knopf für heute. Der heutige Tag ist umrandet, der gewählte gefüllt.
- Getippt wird auch **`15.08.2026`** angenommen und umgerechnet — die
  Schreibweise `JJJJ-MM-TT` muss niemand mehr treffen.

## 0.9.83 – Addon

**Neu**

- Eine laufende Raidsitzung überlebt Verbindungsabbruch, Absturz und `/reload`:
  Sie wird lokal gesichert und beim nächsten Login mit denselben Zahlen
  fortgesetzt.
- Eine länger als acht Stunden unterbrochene Sitzung wird nicht fortgesetzt,
  aber auch nicht verworfen – sie wird mit ihrem letzten Stand ausgewertet und
  abgelegt.
- Wer erst später zum Raid stößt oder nach einem Abbruch zurückkommt, schreibt
  denselben Abend ab sofort mit. Dafür sorgt ein Herzschlag, der höchstens
  einmal pro Minute und immer nur von einem Client gesendet wird.

**Geändert**

- Eine Sitzung starten und beenden dürfen nur noch die Gildenränge, die auch
  die Mitgliederpflege öffnen (Vorgabe: Rang 0 und 1, in den Einstellungen
  änderbar). Der Raidrang allein genügt nicht mehr – bisher konnte jeder
  Assistent eine Sitzung beenden.

**Technisch**

- Der Herzschlag läuft über einen Rahmen, der nur während einer Sitzung
  sichtbar ist. Außerhalb einer Sitzung kostet er keinen Handleraufruf pro
  Bild; das Sichern der Sitzung kostet während des Raids nichts, weil die
  Tabelle gehalten und nicht kopiert wird.

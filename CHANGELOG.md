# Änderungen

Kurzfassung je Version – was sich für Nutzer ändert, in einer Handvoll Zeilen.
Die ausführliche Begründung samt Hintergrund steht weiterhin in
[ROADMAP.md](ROADMAP.md); diese Liste beginnt mit 0.9.83, ältere Versionen sind
dort nachzulesen.

Installer und Addon werden getrennt gezählt.

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

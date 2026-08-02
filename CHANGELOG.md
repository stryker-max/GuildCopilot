# Änderungen

Kurzfassung je Version – was sich für Nutzer ändert, in einer Handvoll Zeilen.
Die ausführliche Begründung samt Hintergrund steht weiterhin in
[ROADMAP.md](ROADMAP.md); diese Liste beginnt mit 0.9.83, ältere Versionen sind
dort nachzulesen.

Installer und Addon werden getrennt gezählt.

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

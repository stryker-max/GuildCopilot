# Änderungen

Kurzfassung je Version – was sich für Nutzer ändert, in einer Handvoll Zeilen.
Die ausführliche Begründung samt Hintergrund steht weiterhin in
[ROADMAP.md](ROADMAP.md); diese Liste beginnt mit 0.9.83, ältere Versionen sind
dort nachzulesen.

Installer und Addon werden getrennt gezählt.

## 1.0.7 – Installer

**Behoben**

- **Der Offline-Import zählte Verbrauchsgegenstände doppelt.** Live war das in
  0.9.87 abgestellt, der Importer aus der `WoWCombatLog.txt` hat es weiter
  gemacht: Er zählte Wirkereignis *und* Aura aus einer einzigen Liste.
  Trommeln wurden dadurch jedem gutgeschrieben, der den Buff bekam, Tränke mit
  Buff zählten doppelt, Fläschchen und Elixiere mehrfach über
  Aura-Auffrischungen. Gezählt wird jetzt je Gruppe genau eine Quelle: bei
  Essen der Buff, sonst der Zauber – dieselbe Regel wie in der Livesitzung.
- **Ein zu großer Import kam in WoW nur halb an.** Das Importfeld im Addon
  nimmt 60.000 Zeichen; alles darüber schneidet WoW beim Einfügen
  stillschweigend ab, und das Addon nimmt den Rest als gültigen Teilimport an.
  Der Warcraft-Logs-Bereich prüfte das längst, der Offline-Import nicht. Jetzt
  passt sich der Importcode an: Enthält die Datei mehr Raidabende, als
  hineinpassen, gehen die ältesten – geschnitten wird nur an der Abendgrenze,
  nie mitten in einem Abend. Wie viele weggelassen wurden, steht in der
  Statuszeile statt nur im Protokoll.
- **Ein Raidabend über Silvester bekam das falsche Jahr.** Alte
  Spielfassungen schreiben kein Jahr in den Zeitstempel; bis 1.0.6 galt für
  jede Zeile das Jahr der Datei, der Dezemberteil sprang damit ein Jahr nach
  vorn. Der Jahreswechsel wird jetzt am Monatsrücksprung erkannt.
- **Eine abgebrochene Installation konnte zwei Versionen vermischen.** Bisher
  wurde direkt über die laufende Installation kopiert; brach das mittendrin ab,
  blieb eine Mischung liegen. Jede Datei geht jetzt in einem Schritt an ihren
  Platz, und scheitert etwas, wird der vorherige Stand wiederhergestellt. Am
  bewussten Verzicht auf Löschen und Umbenennen ändert sich nichts – ein
  offenes Explorer-Fenster darf die Installation weiterhin nicht aufhalten.
- **Ein schneller Doppelklick auf „Nach Updates suchen" startete zwei
  Durchläufe.** Der erste Schritt wartet auf das Netz, und in dieser Zeit blieb
  der Knopf bedienbar. Im schlechtesten Fall installierten zwei Abläufe
  gleichzeitig in denselben Ordner.

## 0.9.88 – Addon

**Behoben**

- **Die Ausrüstungsprüfung konnte Ausrüstung dem falschen Spieler
  zuschreiben.** „raid7" ist kein Spieler, sondern ein Platz in der
  Aufstellung. Zwischen Einsammeln und Prüfen liegen 1,5 Sekunden je Spieler –
  bei 24 Leuten eine gute halbe Minute, in der jemand die Gruppe wechseln oder
  den Raid verlassen kann. Dann wurde die Ausrüstung des neuen „raid7" unter
  dem Namen des früheren gespeichert. Jetzt wird beim Einsammeln die
  Spieler-ID festgehalten und vor jedem Zugriff geprüft, ob der Platz noch
  denselben Spieler meint.
- **„Bulk-Sync im Kampf pausieren" wirkte bei den meisten gar nicht.** Wer eine
  globale ChatThrottleLib geladen hatte – bei Raidern die Regel –, übergab die
  Daten dort, bevor die Kampfprüfung überhaupt zur Sprache kam. Ohne die
  Bibliothek pausierte der Versand zwar, der Antrieb lief aber den ganzen Kampf
  über bei jedem Einzelbild weiter. Beides ist behoben; nach dem Kampf läuft
  die Warteschlange von selbst wieder an.
- **Die Gildenbank fand bei gleichem Zeitstempel nie zusammen.** Zeitstempel
  kennen nur ganze Sekunden. Standen zwei Stände in derselben Sekunde, forderte
  der eine Client die Daten an – und verwarf sie beim Empfang, weil sie „nicht
  neuer" waren. Das lief endlos im Kreis. Jetzt entscheidet bei Gleichstand der
  Fingerabdruck, auf beiden Seiten nach derselben Regel. Zusätzlich wird der
  Fingerabdruck nach dem Empfang selbst nachgerechnet statt dem Absender
  geglaubt.
- **Ein Bankbesuch las die Fächer immer wieder neu.** Erledigte Fächer wurden
  nicht aus der Warteliste genommen; jede Änderung las danach das offene Fach
  doppelt und alle vorher besuchten gleich mit – bei acht Fächern bis zu 882
  Abfragen pro Ereignis.
- **Der Werkstatt-Abgleich konnte neuere Rezepte zurückdrehen.** Ein
  verspätetes Paket oder ein Zweitclient mit altem Stand überschrieb die
  Rezeptliste ungeprüft, bei einer vollen Liste samt der Rezepte, die seitdem
  dazugelernt wurden. Ein älterer Stand gewinnt jetzt nicht mehr.
- **Ein verlernter Beruf blieb für immer stehen.** Eine leere Berufsliste wurde
  nur vermerkt, nie übernommen – der alte Beruf stand weiter im Profil und
  wurde weiter an die Gilde gemeldet. Jetzt wird geräumt, sobald derselbe
  Spielstart die Berufe vorher schon einmal gelesen hat. Die Vorsicht direkt
  nach dem Login bleibt: Dort ist die Liste oft nur noch nicht geladen.
- **Ohne Boss-Ende galt jeder tote Gegner als Sieg.** Meldet der Client das
  Kampfende nicht, entscheidet die Heuristik – und die machte aus dem ersten
  gestorbenen Add einen „Kill". Gewertet wird jetzt nur der Tod des Bosses.
- **Nach unlesbarer eigener Ausrüstung lief die Prüfung endlos weiter.** War
  die Ausrüstung nach allen Versuchen noch nicht lesbar, blieb das Abo auf
  nachgeladene Gegenstandsdaten bestehen. Danach löste jedes geladene Item –
  auch aus Bank, Auktionshaus oder einem Chatlink – eine neue Vollprüfung aus.
- **Derselbe Spieler stand in der Werkstatt doppelt.** Nur dort enthielt der
  Schlüssel den Realmanteil, während Raidauswertung und Ausrüstungsprüfung
  längst den Kurznamen benutzen. Der eigene Charakter erschien deshalb einmal
  als „alex" und einmal als „alex-realm". Bestehende Einträge werden beim
  nächsten Start einmalig zusammengeführt.

**Geändert**

- **Anwesenheit zählt nur noch mit Verbindung.** Wer die Verbindung verliert,
  bleibt Teilnehmer des Abends, seine Anwesenheitsuhr steht aber. Vorher zählte
  die bloße Raidmitgliedschaft: Wer nach zwanzig Minuten rausflog und nicht
  wiederkam, stand am Ende mit der vollen Abenddauer da, solange ihn niemand
  aus dem Raid nahm.

## 0.9.87 – Addon

**Behoben**

- **Verbrauchsgegenstände wurden falsch gezählt – live wie beim Import.** Der
  Vergleich mit dem Warcraft-Logs-Bericht vom 02.08. hat vier Ursachen gezeigt,
  die sich gegenseitig überlagert haben:
  - **Trommeln zählten bei allen, die den Buff bekamen.** Eine Trommel bufft
    die ganze Gruppe; gutgeschrieben wurde sie jedem Mitglied. Im Log haben
    fünf Spieler Trommeln geworfen, angezeigt wurden sie bei acht – darunter
    zwei, die den ganzen Abend keine einzige geworfen haben, und einer mit 68
    statt 28. Gezählt wird jetzt nur noch, wer sie tatsächlich wirft.
  - **Tränke mit Buff zählten doppelt.** Hast-, Zerstörungs- und Heldentrank
    erzeugen einen Zauber *und* eine eigene Aura; beide wurden gezählt. Vier
    Hasttränke standen deshalb als acht da.
  - **Die geläufigsten Manatränke fehlten in der Liste.** Die Salben und
    Flaschen aus Zangarmarschen und Netherstrum waren unbekannt – allein auf
    sie kamen im Vergleichslog 146 Anwendungen. Wer 24 Manatränke benutzt hat,
    stand mit **1** da, wer 23 benutzt hat, mit **0**. Ebenfalls nachgetragen:
    Heldentrank, Großes Arkanelixier, Elixier des Ansturms und Elixier des
    Adepten. Zwei Tränke trugen falsche Namen und heißen jetzt richtig Feuer-
    und Frostschutztrank.
  - **Essen, Fläschchen und Elixiere zählten je Abend nur einmal.** Wer nach
    drei Wipes dreimal gegessen hat, stand mit einem Essen da. Gezählt wird
    jetzt der Verbrauch, nicht der Zustand – auch beim Import aus Warcraft
    Logs, der die richtigen Zahlen bereits geliefert hat und hier wieder
    eingeebnet bekam.
- **Fläschchen und Elixiere von vor dem Pull tauchen auf.** Wer sich vor dem
  Raid bufft, erzeugt kein Kampfereignis – ein vollständig gebuffter Raid stand
  deshalb mit lauter Nullen da (23 von 25 Teilnehmern ohne Fläschchen). Beim
  Sitzungsstart und bei jedem, der später dazustößt, wird jetzt einmal
  abgelesen, was er schon trägt.
- **Sitzungsliste: Einträge lagen übereinander.** „02.08. 19:37 Höhle des
  Schlangenschreins +Logs" passte nicht in eine Zeile, brach um und überlagerte
  den nächsten Eintrag. Beschriftungen in Knöpfen brechen jetzt grundsätzlich
  nicht mehr um, lange Instanznamen stehen in ihrer geläufigen Kurzform, und
  dieselbe Quelle wird nur einmal genannt (statt „+Sync+Logs+Sync").

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

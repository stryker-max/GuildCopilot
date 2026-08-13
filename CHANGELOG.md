# Änderungen

Kurzfassung je Version – was sich für Nutzer ändert, in einer Handvoll Zeilen.
Die ausführliche Begründung samt Hintergrund steht weiterhin in
[ROADMAP.md](ROADMAP.md); diese Liste beginnt mit 0.9.83, ältere Versionen sind
dort nachzulesen.

Installer und Addon werden getrennt gezählt.

## 0.9.122 – Addon

**Behoben**

- **Rechte kommen jetzt bestätigt an – oder du erfährst, dass sie es nicht
  taten.** Das Gildenprofil war der einzige Transfer im Addon **ohne
  Empfangsbestätigung**: fünf Pakete in den Gildenkanal, und niemand erfuhr je,
  ob sie ankamen. Fällt eines aus – der eingebaute Ratenbegrenzer des Clients
  verwirft im Anmeldegetümmel regelmäßig welche –, verwirft der Empfänger den
  **ganzen** Transfer, weil er ihn nicht zusammensetzen kann. Nach außen sah das
  aus wie „die Rechte kommen einfach nicht an", ohne jeden Hinweis worauf.
  Werkstatt und Warcraft Logs haben für genau dieses Problem längst den
  bestätigten Weg; das Gildenprofil hat ihn jetzt auch.

**Geändert**

- **„Rechte erneut senden" sagt, was passiert ist.** Der Knopf schickt den Stand
  weiterhin an die ganze Gilde und zusätzlich gezielt und quittiert an jeden, von
  dem dein Client weiß, dass er gerade online ist. Danach steht dort „Rechte
  bestätigt angekommen bei 2 von 2" – oder eben, bei wie vielen nicht. Ist
  niemand mit dem Addon online, sagt er auch das, statt Erfolg zu behaupten.

## 0.9.121 – Addon

**Neu**

- **„Rechte erneut senden".** Eine Rangfreigabe geht in dem Moment raus, in dem
  du sie setzt – über den Gildenkanal, und der erreicht nur, wer gerade online
  ist. Wer den Moment verpasst, holt sich den Stand beim nächsten Anmelden zwar
  selbst ab, aber nur, wenn dann jemand mit dem neueren Stand online ist. In
  einer frischen Gilde mit zwei Leuten ist genau das der Regelfall. Der Knopf
  steht in den Einstellungen unter „Gildenweite Einstellungen bearbeiten" und
  schickt den vollständigen Stand noch einmal an alle. Ein versehentlicher Druck
  kann nichts kaputt machen: Beim Empfänger entscheidet wie immer der
  Zeitstempel, ein älterer Stand wird verworfen.

## 0.9.120 – Addon

**Behoben**

- **Wer einer Gilde beitritt, während er eingeloggt ist, gleicht jetzt auch ab.**
  Der gesamte Handschlag – Versionsansage, Gildenprofil, Werkstattmanifest,
  Gildenaufträge – lief bisher genau einmal, in den ersten zwanzig Sekunden nach
  dem Anmelden. Ein Beitritt danach kam zu spät: Roster und Fenster stellten
  sich sofort um, gesendet und angefordert wurde in der neuen Gilde aber nichts,
  bis zum nächsten `/reload`. Das Addon sah lebendig aus und war stumm. Jetzt
  läuft dieselbe Anlaufsequenz beim Gildenwechsel noch einmal.
- **Zwei Gilden mit einem Account bleiben getrennt.** Die Werkstatt meldete die
  Berufe *aller* Charaktere des Accounts in die Gilde, in der man gerade
  eingeloggt war – wer mit einem Account in zwei Gilden spielt, trug damit Namen
  und Rezepte seines Twinks aus Gilde A nach Gilde B und umgekehrt. Die Daten
  der Gilden selbst waren nie vermischt, die des eigenen Accounts schon. Jeder
  Charakter hinterlässt jetzt beim Einloggen, in welcher Gilde er steht;
  veröffentlicht wird nur, was zur aktuellen Gilde gehört. Dasselbe gilt für die
  Twink-Regel beim Annehmen von Gildenaufträgen.

**Hinweis**

- Ein Twink erscheint im Gildenkatalog erst wieder, wenn er **einmal eingeloggt**
  war – vorher weiß das Addon nicht, in welcher Gilde er steht, und hält ihn
  bewusst zurück. Alte Einträge fremder Twinks räumt das Addon beim nächsten
  Aufräumen von selbst weg.

## 0.9.119 – Addon

**Geändert**

- **Das Mini-Fenster bleibt stehen.** Bisher zeigte es sich nur, wenn du selbst
  am Zug warst, und verschwand sonst von allein – aus dem Spiel gemeldet: „Jetzt
  wird mir der Tracker gar nicht mehr angezeigt", obwohl ein Auftrag lief. Er
  wartete nur gerade auf den Auftraggeber. Jetzt steht das Fenster, bis du es
  über das × schließt.
- **Es zeigt jetzt alles Laufende, an dem du beteiligt bist.** Deine eigenen
  Aufgaben stehen oben wie bisher; darunter gedämpft die Aufträge, bei denen ein
  anderer am Zug ist, mit dem Namen dessen, auf den gewartet wird („Wartet auf
  Buffdæddy."). Läuft gerade nichts, steht das auch da – statt eines leeren
  Bildschirms. Der Titel nennt die Zahl deiner eigenen Aufgaben, und was nicht
  mehr in die drei Zeilen passt, steht als „… und 2 weitere." darunter.

## 0.9.118 – Addon

**Behoben**

- **Im Auftrags-Tracker lagen zwei Zeilen übereinander.** Rezeptname und
  Aufgabe („Materialien beschaffen und vollständig melden") standen
  ineinandergeschoben und waren beide kaum zu lesen. Jede Zeile hat jetzt ihren
  eigenen Platz.

**Neu**

- **Hinweis auf eine neuere Version.** Ist eine neuere Fassung von Guild
  Copilot draußen, steht das jetzt einmal je Sitzung im Chat – mit der Zahl,
  die es zu holen gibt, und woher: CurseForge-App oder Installer. Danach steht
  die Zahl weiter oben in der Kopfzeile des Fensters und im Versionsprüfer,
  falls die Chatzeile durchgerutscht ist. Erfahren tut das Addon es von der
  eigenen Gilde – ein WoW-Addon darf selbst nicht ins Netz.
- **Der Versionsprüfer unterscheidet „älter" von „neuer".** Wer eine neuere
  Fassung fährt als man selbst, stand bisher rot unter „veraltet". Diese
  Zeilen sind jetzt gelb und zählen eigens.

## 0.9.117 – Addon

**Geändert**

- **Das Verbrauchsprotokoll bleibt vollständig.** Bisher hob die abgelegte
  Auswertung je Teilnehmer nur die letzten 40 Einträge auf, obwohl der Abend
  100 gesammelt hatte – bei Vielverbrauchern fiel damit ein Teil des Abends
  weg. Beide Grenzen liegen jetzt bei 200 und stehen als eine einzige Zahl im
  Code, sodass sie nicht wieder auseinanderlaufen können. Die Zähler waren
  davon nie betroffen; lückenlos nachprüfbar ist jetzt auch das Protokoll.

## 0.9.116 – Addon

**Behoben**

- **Doppelt gezählte Mahlzeiten und Buffs.** Beim Zonenwechsel mitten im Raid
  las Guild Copilot die getragenen Buffs des ganzen Raids erneut ein und
  schrieb sie noch einmal gut – am 09.08. traf das 23 von 25 Teilnehmern in
  zwei Minuten. Was einmal gezählt ist, zählt jetzt nie wieder.
- **Nachträglich aufgetragene Buffs fehlten.** Umgekehrt las das Addon die
  getragenen Buffs bisher nur ein einziges Mal je Teilnehmer: Wer sein
  Fläschchen erst nach dem ersten Sichtkontakt aufmachte, stand den ganzen
  Abend ohne da. Beides ist dieselbe Änderung – gemerkt wird jetzt der
  einzelne Buff statt „schon geschaut".
- **Zwei weitere Verbrauchsgegenstände.** Elixier des Mungos und
  Eisenschildtrank wurden nicht gezählt. Im Log des 09.08. betraf das sieben
  Elixiere bei einem Spieler und vier Tränke bei zwei weiteren.

## 0.9.115 – Addon

**Behoben**

- **Ein Fläschchen wurde nicht gezählt.** Wer das Classic-Fläschchen der
  destillierten Weisheit trinkt – in TBC weiterhin üblich –, stand in der
  Raidauswertung ohne Fläschchen da, obwohl er eins hatte. Die Kennung
  fehlte schlicht in der Tabelle; sie ist jetzt eingetragen, auch für den
  Warcraft-Logs-Import.

## 0.9.114 – Addon

**Neu**

- **Minimieren.** Neben dem Schließen-× sitzt ein zweiter Knopf: Er klappt
  alles unter der Kopfzeile weg, sodass nur noch der Balken mit Titel,
  Abgleichstand und Knöpfen stehen bleibt – der Bildschirm ist frei, das
  Fenster aber nicht geschlossen. Der Balken lässt sich weiter verschieben,
  ein zweiter Klick holt alles zurück, und wer zugeklappt ausloggt, findet
  ihn beim nächsten Mal wieder so vor. Wird eine Seite von außen
  aufgeschlagen (etwa über den Auftrags-Tracker), klappt das Fenster von
  selbst auf.

## 0.9.113 – Addon

**Behoben**

- **Im freien Auftrag ließ sich kein Beruf wählen.** Das Aufklappmenü öffnete
  sich hinter dem Dialog – unsichtbar und nicht anklickbar.
- **„Tracker einble…"** – der Knopf war zu schmal für seine eigene
  Beschriftung.

**Neu**

- **Gildenaufträge stehen jetzt in der Seitenleiste.** Die beiden Umschalter
  oben rechts waren zu versteckt: Man musste erst wissen, dass es sie gibt.
  Beide Ansichten der Werkstatt haben deshalb einen eigenen
  Navigationspunkt; der aktive leuchtet wie gewohnt.
- **Fenstergröße an der Ecke ziehen.** Unten rechts sitzt ein Griff: Ziehen
  macht das Fenster kleiner oder größer, die Ecke folgt dem Mauszeiger. Es
  ist derselbe Wert wie der Regler in den Einstellungen.

## 0.9.112 – Addon

**Neu**

- **Freie Aufträge für Rezepte, die der Katalog nicht kennt.** Der Knopf
  „Freier Auftrag" unten am Auftragsboard fragt nach Beruf und Wunsch in
  Worten – für alles, was noch niemand eingelesen hat oder was der Hersteller
  erst lernen muss. Annehmen darf, wer den Beruf hat; ansonsten läuft der
  Auftrag durch dieselben Schritte wie jeder andere.
- **Herstellen aus dem Cockpit.** Beherrscht der gerade gespielte Charakter
  ein Rezept, steht an der Rezeptkarte ein Knopf: erster Klick öffnet das
  Berufsfenster, zweiter fertigt. Im Dialog „Gefertigt melden" fertigt er
  gleich die noch offene Menge des Auftrags.
- **Der Zähler zählt selbst.** Was du herstellst, zählt Guild Copilot mit –
  egal ob über den neuen Knopf oder von Hand im Berufsfenster. Der Stand
  steht in der Auftragszeile und füllt die Meldung vor. Er bleibt bis zum
  Klick auf „Melden" bei dir; von allein geht nichts in die Gilde.

## 0.9.111 – Addon

**Neu**

- **Fenstergröße und Deckkraft einstellbar.** Neue Karte „Fenster" am Ende
  der Einstellungsseite: Größe von 70 bis 130 Prozent, Deckkraft von 40 bis
  100 Prozent, beides wirkt sofort und lässt sich mit einem Knopf
  zurücksetzen. Damit passt Guild Copilot auch auf kleinere Auflösungen und
  verdeckt weniger vom Spiel.

## 0.9.110 – Addon

**Neu**

- **Das Auftragsboard scrollt.** Jeder Abschnitt zeigt so viele Aufträge, wie
  es gibt, statt drei – der vierte Auftrag war bisher zwar gespeichert, aber
  mit keinem Handgriff erreichbar. Dazu ein eigener Abschnitt „Läuft in der
  Gilde": Fremde laufende Aufträge standen bis jetzt unter „Meine Aufträge"
  und verdrängten dort die eigenen.
- **Aufträge ablehnen.** Der kleine „–"-Knopf blendet einen offenen Auftrag
  aus, der nichts für einen ist. Das bleibt rein lokal: Für die Gilde ist er
  weiter offen, niemand erfährt davon, und der Knopf „n abgelehnt" holt alles
  jederzeit zurück.
- **Stückzahlen werden gezählt.** Die Auftragsstatistik zeigt jetzt Stück
  statt nur Aufträge (40 Urnen und ein Ring waren vorher beide „1 erledigt"),
  mit Gesamtzeile über allen Herstellern.

**Verbessert**

- **Teilfertigung steht in der Zeile.** Ein Auftrag über zehn Stück zeigt
  „×10 3 fertig", solange er läuft; bisher stand der Zwischenstand nur im
  Verlaufsdialog.
- Leere Abschnitte sagen, dass sie leer sind, statt als nackte Überschrift
  dazustehen.

## 0.9.109 – Addon

**Verbessert**

- **Englisch, Nachzügler-Runde.** Der Praxistest des Owners (Sprachwahl auf
  English) zeigte die Reste: Texte, die erst beim Aktualisieren gesetzt
  werden (162 Stellen laufen jetzt durch die Sprachschicht), Klassen, Specs
  und Berufe (offizielle englische Begriffe: Retribution, Enhancement,
  Tailoring …), Rekrutierungs-Labels und -Begründungen, Kennzahlen-Karten,
  Spaltenköpfe sowie die zusammengesetzten Anzeigen (Kopfzeilen-Status,
  Werkstatt-Abgleichzeile, Ausrüstungs-Status, Funde, Bewertungsgründe,
  Zeitangaben „vor 3 Std."). Was der Spielclient selbst benennt (gescannte
  Rezeptnamen, Verzauberungszeilen), bleibt in der Clientsprache – das gibt
  die WoW-API nicht anders her.

## 0.9.108 – Addon

**Neu**

- **Sprachwahl in den Einstellungen.** Neue Karte „Sprache / Language" am
  Ende der Einstellungsseite: Automatisch (folgt dem WoW-Client), Deutsch
  oder English – mit Knopf zum sofortigen Neuladen, denn vollständig wirkt
  die Umstellung erst nach /reload.
- **Englisch, Teilschritt 4.** Alle restlichen statischen Oberflächentexte
  (Hilfetexte, Leerzustände, Eingabe-Beschriftungen – auch die langen,
  zusammengesetzten) sind übersetzt, dazu die meistgesehenen Chatmeldungen
  über Platzhalter (Login-Zeile, Sitzungsstart und -ende, Rezept-Scan,
  Wartezeit-Erinnerung). Seltene Fehler- und Randmeldungen im Chat bleiben
  deutsch und fallen sauber zurück.

## 0.9.107 – Addon

**Neu**

- **Englische Oberfläche (Teilschritte 1–3).** Auf nicht-deutschen Clients
  zeigen Seitenleiste, Seitentitel, Karten, Knöpfe, Schalter, Spaltenköpfe
  und die gängigen Statusmeldungen jetzt Englisch. Deutsch bleibt die
  Quellsprache – was (noch) nicht übersetzt ist, fällt sichtbar auf Deutsch
  zurück, statt zu brechen; längere Hilfetexte und Chat-Ausgaben bleiben
  vorerst deutsch.
- **Spielbegriffe einzeln belegt, nie frei übersetzt.** Alle ~50 Namen der
  Verbrauchsliste (Tränke, Fläschchen, Elixiere, Trommeln, Öle, Essen)
  tragen jetzt ihr englisches Gegenstück – jeder Name am 08.08.2026 über
  seine Item-ID gegen Wowheads TBC-Datenbank verifiziert, die Belege stehen
  als Kommentar im Code. Slots heißen wie auf Wowhead (Head, Main Hand,
  Trinket …). Das Verbrauchsprotokoll und die Warcraft-Logs-Details zeigen
  die Namen in der Clientsprache.

## 0.9.106 – Addon

**Behoben**

- **Essen zählt wieder ehrlich.** Wer sitzen bleibt und weiterisst, dessen
  Sattgegessen-Aura meldet sich alle zehn Sekunden erneut – jede Meldung
  zählte als neue Mahlzeit (11 statt real 4 an einem Vergleichsabend). Ein
  und dieselbe Aura zählt jetzt höchstens einmal pro Minute; ein echtes
  Nachessen später zählt weiterhin.
- **Waffenöle werden endlich gesehen.** Öle und Wetzsteine sitzen auf der
  Waffe, nicht als Buff auf dem Spieler – vor dem Sitzungsstart aufgetragen
  waren sie unsichtbar und die Spalte „Öle/Steine" blieb bei null. Die eigene
  Waffe wird jetzt beim Sitzungseintritt mitgelesen; gezählt wird nur ein
  Treffer bekannter Öl/Stein-Namen (Windzorn und Gifte zählen nie). Die
  „Superior"-Öle heißen jetzt wie im deutschen Client „Hervorragendes …".

**Neu**

- **Wartezeit-Erinnerung.** Abgelaufene Berufs-Wartezeiten (Umwandlung,
  Spezialtuch, Sphäre) melden sich im Chat – beim Login gesammelt, während
  des Spielens zum Ablaufzeitpunkt, auch für die eigenen Twinks. Eine Zeile
  je Sperre, nie doppelt; abschaltbar in den Einstellungen (Werkstatt).
- **Rezept-Lücken der Gilde.** Der Knopf auf der Ausrüstungsseite zeigt, was
  der Regelsatz empfiehlt, aber niemand in der Gilde herstellen kann – eine
  fertige Farm- und Einkaufsliste, OPTIMAL zuerst, nur Regeln der laufenden
  Content-Phase.
- **Anwesenheit über Abende hinweg.** Der Knopf „Anwesenheit" auf der
  Raidauswertungsseite zeigt je Spieler die besuchten Bossabende und den
  mittleren Anwesenheitsanteil – aus einem eigenen, dauerhaften Speicher
  (bis 60 Abende), der das Löschen alter Auswertungen übersteht.
  Probesitzungen ohne Bosskampf zählen nicht, ein verpasster Abend zählt
  mit 0 %.

**Außerdem behoben (Ausrüstungsseite)**

- **„Verzauberung 3010" heilt jetzt zum echten Namen.** Ein bei kaltem
  Item-Cache fehlgeschlagener Namens-Abgleich wurde für die ganze Sitzung
  als „kein Name" gemerkt und nie erneut versucht – die Slots-Tabelle nannte
  dauerhaft IDs. Fehlende Namen werden jetzt bei jedem Lesen nachgetragen,
  samt neuer Bewertung und Begründung.
- **Lesbarkeit:** Die Statuszeile bricht nicht mehr in eine abgeschnittene
  vierte Zeile um, das Prüfalter steht als Minuten/Stunden/Tage statt
  „vor 8157 Min.", und die HINWEIS-Spalte ist breiter (Slot und Sockel gaben
  Reserve ab). Was dennoch nicht passt, steht vollständig im Zeilentooltip.

## 0.9.105 – Addon

**Behoben**

- **Rezeptdetails zeigen Namen statt „Item #25708".** Empfangene Rezepte
  nennen Reagenzien nur per ID; kannte der Client den Gegenstand beim Empfang
  noch nicht, blieb der Platzhalter für immer stehen. Aufgelöst wird jetzt bei
  jedem Katalogaufbau erneut: Sobald der Client den Gegenstand nachgeladen
  hat, steht der echte Name da – auch bei Beständen, die den Platzhalter aus
  früheren Versionen bereits gespeichert haben. Gespeichert wird der
  Platzhalter gar nicht mehr.

**Neu**

- **Die laufende Raidsitzung steht sofort in der Sitzungsliste.** Ab dem
  Start – auch bei allen, die über Startruf oder Herzschlag mitschreiben –
  führt sie die Liste grün als „läuft" an und lässt sich wie jede Auswertung
  öffnen: Teilnehmer, Anwesenheit, Verbrauch und Bosszahlen als
  Zwischenstand, ohne auf das Sitzungsende zu warten. Beim Beenden geht die
  Auswahl nahtlos auf die abgelegte Auswertung über. Löschen lässt sich der
  Zwischenstand nicht – er liegt nirgends gespeichert.

**Stabilität**

- **Letzte ungedeckelte Empfangstabelle geschlossen.** Die eingehenden
  Rekrutierungs-Übertragungen (Warcraft-Logs-Abgleich) begrenzen jetzt wie
  Werkstatt, Ausrüstung und Raidauswertung die Zahl gleichzeitig offener
  Teiltransfers; beim Überlauf weicht die älteste unfertige Übertragung.

## 0.9.104 – Addon

**Neu**

- **Fehlende Verzauberung direkt bestellen.** Auf der Ausrüstungsseite steht
  am eigenen Charakter ein Bestellknopf, sobald ein verbesserbarer Slot eine
  Empfehlung hat, die die Gilde herstellen kann: Der Regelsatz sagt, WAS
  optimal wäre, die Werkstatt weiß, WER es kann – der Klick öffnet den
  Auftragsdialog mit dem richtigen Rezept. Die Zuordnung Verzauberung → Rezept
  ist für 27 Regelsatz-Verzauberungen einzeln per Wowhead belegt; was sich
  nicht belegen ließ, macht schlicht keinen Vorschlag.
- **Helfer neben dem Handelsfenster.** Beginnt ein Handel mit jemandem, mit
  dem Gildenaufträge offen sind, zeigt ein kleines Fenster daneben, worum es
  geht – samt demselben Aktionsknopf wie auf dem Auftragsboard („Gefertigt“,
  „Erhalten“ …). Nichts wechselt den Status von selbst, und im Kampf bleibt
  der Helfer weg.
- **Flüsterbefehl „!rezept“.** Wer ihn in den Einstellungen einschaltet
  (Vorgabe: aus – das Addon flüstert nie ungefragt), beantwortet
  Gildenmitgliedern „!rezept mungo“ automatisch mit Materialliste und
  Herstellern aus dem Katalog. Nur für Gildenmitglieder, gedrosselt je
  Absender. Auch „!recipe“ und „!enchant“ funktionieren.
- **Die Suche findet beide Sprachen.** Der Katalog-Suchtext trägt neben dem
  übersetzten Namen jetzt auch die Schreibweise des Scanners: „boars speed“
  und „Ebergeschwindigkeit“ treffen denselben Eintrag.

Die Ideen zu Handelsfenster und Flüsterbefehl stammen aus dem Addon
Pro Enchanters (GPLv3) – übernommen ist wie beim Werbebalken das Prinzip,
nicht der Code.

## 0.9.103 – Addon

**Neu**

- **Rezeptdaten von Offline-Spielern kommen jetzt über Boten.** Meldet ein
  Bestandsmanifest einen Hersteller, dessen Besitzer offline ist, fragt der
  Client die Schlüsselliste direkt beim Melder an – und Rezeptdetails liefert
  ein Gewählter aus seinem Katalog. Die Lieferung trägt immer den Stand und
  die Zeitstempel des Besitzers; ein Bote kann einen neueren Stand nie
  zurückdrehen. Wer selten mit anderen gleichzeitig online ist, bekommt den
  vollen Katalog damit von jedem, der ihn hat.
- **Gebaut für volle Gilden:** Auf eine Frage antwortet genau der eine
  Adressierte oder höchstens zwei Gewählte – nie alle. Wer sieht, dass ein
  anderer schon liefert, schweigt; wer die gleiche Lücke hat, erbt die
  Antwort aus dem Gildenkanal, statt selbst zu fragen. Auch bei 250 Spielern
  online bleibt der Kanal ruhig.
- **„Daten anfragen“ quittiert sichtbar.** Der Balken zeigt sofort „Anfrage
  gesendet – die Antworten treffen gestreut ein“, der Knopf zählt herunter
  und sperrt sich solange. Vorher passierte bis zur ersten Antwort eine
  halbe Minute lang sichtbar nichts, und der Klick wirkte wirkungslos.
  Doppelklicks lösen keine zweite gildenweite Antwortwelle mehr aus.

## 0.9.102 – Addon

**Neu**

- **Die Werkstatt weiß jetzt, was ihr fehlt.** Auf „Daten anfragen“ melden
  einige Antwortende zusätzlich, welche Hersteller es in der Gilde überhaupt
  gibt – als reines Inhaltsverzeichnis, die Rezeptdaten selbst kommen weiter
  nur vom Besitzer. Wer selten mit anderen gleichzeitig online ist, sieht
  damit erstmals: „Rezepte von 18 Herstellern fehlen noch – sie kommen, sobald
  deren Besitzer online sind“, statt eines grünen Balkens über einem Drittel
  des Katalogs.
- **„Vollständig synchronisiert“ steht nur noch da, wenn es belegt ist.**
  Die Zeile nennt jetzt ihre Reichweite („abgeglichen mit 24 weiteren
  Nutzern“). Ist eine Bestandslücke bekannt, sagt Balken wie Kopfzeile
  „Bestand lückenhaft“ – nichts offen und vollständig sind zwei verschiedene
  Aussagen.
- **Englische Clients werden voll unterstützt.** Berufe werden unabhängig von
  der Spielsprache verschlüsselt: „Enchanting“ und „Verzauberkunst“ sind
  derselbe Beruf, angezeigt wird der deutsche Name. Vorhandene Bestände
  wandern beim ersten Laden automatisch zusammen.

**Behoben**

- **Ein angekündigter Beruf, dessen Daten ausblieben, verschwand lautlos.**
  Loggte der Hersteller aus, bevor seine Rezepte ankamen, sprang der Balken
  nach zwei Minuten auf „Vollständig synchronisiert • Stand: gerade eben“.
  Jetzt endet der Zyklus als „Abgleich unvollständig“ mit Begründung
  („Hersteller offline?“), und die Lücke bleibt sichtbar, bis die Daten
  wirklich da sind.
- **Der Katalog zählte Berufe englischer Clients doppelt** – 16 „Berufe“, wo
  TBC höchstens 12 kennt – und der Berufsfilter fand deren Rezepte nicht.
- **Mit englischem Client blieb „Deine Berufe fehlen noch“ für immer stehen**,
  obwohl das Berufsfenster längst geöffnet war: Das Profil sprach deutsch, der
  Scan legte englisch ab. Auch die automatische Berufserkennung aus den
  Fähigkeitszeilen erkannte englische Namen nicht, und der Knopf des
  Einrichtungsassistenten konnte das Fenster nicht öffnen (der deutsche
  Zaubername sagt einem englischen Client nichts).
- **Bergbau galt trotz geöffnetem Schmelzen-Fenster als „nicht eingelesen“** –
  der Fenstername zählt jetzt als der Beruf, zu dem er gehört.

## 0.9.101 – Addon

**Neu**

- **Der Werbebalken kann die Werbung automatisch wiederholen.** Ein Schalter
  im Balken und auf der Seite „Werbung posten“: Läuft der Kanal-Cooldown ab,
  geht der bestätigte Text mit dem nächsten Tastendruck raus — gleich welche
  Taste, auch beim Laufen. Den Umweg verlangt WoW: Kanalnachrichten aus
  Addons sind nur im Moment einer echten Eingabe erlaubt, ein Timer darf nie
  selbst posten. Die Automatik läuft nur, solange der Balken eingeblendet
  ist, und seine Statuszeile sagt jederzeit, was als Nächstes passiert.
  Bestätigungspflicht und Cooldowns gelten unverändert; welche Taste gedrückt
  wird, liest Guild Copilot nicht.

## 0.9.100 – Addon

**Neu**

- **Ein Einrichtungsassistent ersetzt das alte Willkommensfenster.** Beim
  ersten Login je Charakter öffnet sich ein mehrseitiges Fenster: das Logo,
  eine kurze Funktionstour entlang der Seitenleiste — was kann Guild Copilot,
  und wo finde ich es —, dann die drei Einrichtungsschritte als je eigene
  Seite, zum Schluss die Fundorte für später (Minimap-Symbol, `/gcp`, der
  Knopf „Einrichtung“ im Fensterkopf).
- **Der Assistent nimmt die Schritte ab, soweit WoW das erlaubt.** Die aus den
  Talenten erkannte Spec ist vorgewählt, ein Klick bestätigt sie. Die
  Berufsfenster öffnet ein Knopf direkt aus dem Assistenten — die Rezepte
  liest Guild Copilot dabei von selbst, und die Zeile springt auf Grün,
  während das Fenster noch offen ist. Die Ausrüstungsprüfung stößt der
  Assistent selbst an und zeigt ihr Ergebnis.
- **Jederzeit abbrechbar, nichts geht verloren.** ×, Escape und „Später“
  schließen folgenlos, jeder Schritt hat sein „Überspringen“. Die Checkliste
  oben im Profil zeigt denselben Stand weiter — beide fragen dieselben Daten
  und können sich nicht widersprechen. Der Knopf „Einrichtung“ und
  `/gcp welcome` öffnen den Assistenten jederzeit erneut.
- **Nach dem ersten Blick im Spiel nachgeschärft.** Die Funktionstour ist auf
  die Seitenhöhe verteilt und jede Zeile trägt das Symbol ihrer Seite. Die
  Gildenwerkstatt hat eine eigene Zeile statt sich eine mit der
  Mitgliederpflege zu teilen, und Warcraft Logs steht nicht mehr in der Tour —
  wer frisch installiert, hat nur das Addon. „Fertig“ klingt nach
  Stufenaufstieg, und das erste „Später“ zeigt einmalig ein kleines
  Hinweisfenster mit dem Weg zurück (`/gcp welcome` oder der Knopf
  „Einrichtung“). Der Abschnittsname steht an jeder Tourzeile, und keine
  Zeile wird mehr abgeschnitten — die REKRUTIERUNG-Zeile war zu lang und
  endete im Spiel als „Postfa…“; ein Test misst jetzt alle Tourzeilen nach.
  Auch das × zeigt beim ersten vorzeitigen Schließen den „Bis später!“-Hinweis
  — derselbe einmalige Merker wie bei „Später“. Unten rechts steht in kleiner
  Schrift der Autor: Nexarius - Thunderstrike.
- **Dual-Spec und „flexibel einsetzbar“ direkt im Assistenten.** Die
  Profilseite des Assistenten bietet jetzt auch die Dual-Spec-Wahl (samt
  „Keiner“) und den Flex-Haken an — beides gehört zum Raidprofil, und der
  Platz war da. Main/Twink und die Abmeldung bleiben bewusst der Profilseite
  vorbehalten.
- **Der grüne Haken ist nicht mehr verpixelt.** Schräge Striche der selbst
  gezeichneten Symbole waren eine Reihe überlappender Quadrate — ab etwa
  20 px Kantenlänge sichtbar getreppt, am deutlichsten am Haken neben
  „Bestätigen“. Sie werden jetzt als eine glatt gedrehte Fläche gezeichnet
  (`SetVertexOffset`); die Quadratreihe bleibt als Rückfall.
- **Der Klick auf den Beruf öffnet jetzt wirklich das Berufsfenster.** Zwei
  Ursachen: Der sichere Knopf war nur auf das Loslassen der Maustaste
  registriert, die moderne Engine feuert geschützte Aktionen aber je nach
  Client-Einstellung beim Drücken — jetzt sind beide Flanken registriert.
  Und die ganze Berufszeile (Symbol + Name) ist der Knopf, nicht nur
  „Fenster öffnen“ — sie bleibt auch nach dem Einlesen klickbar.
- **Der Abschluss meldet sich wie ein neuer Gildenauftrag.** Wer „Fertig“
  drückt, hört den Stufenaufstieg und sieht den Banner „Guild Copilot is
  ready for takeoff“.
- **Die Berufsspalte der Gildenübersicht nennt nur noch Namen.** Die
  Fertigkeitspunkte standen nur an automatisch erfassten Berufen — von Hand
  eingetragene haben keine —, und eine Spalte mit mal Zahl, mal keiner sah
  nach einem Fehler aus.
- Die Autorenzeile hat Abstand zum „Weiter“-Knopf bekommen; die
  Navigationsleiste sitzt dafür ein Stück höher.

**Behoben**

- **Reine Sammler hingen für immer im Rezeptschritt.** Kräuterkunde und
  Kürschnerei haben kein Rezeptfenster; der Schritt „Rezepte einlesen“ war für
  Charaktere mit zwei Sammelberufen unerfüllbar und stand auf ewig offen. Er
  gilt dort jetzt als erledigt („Keine Berufe mit Rezepten“).
- **Bergbau heißt am Fenster „Schmelzen“.** Der Assistent ordnet den Scan des
  Schmelzen-Fensters dem Beruf zu und beschriftet den Öffnen-Knopf
  entsprechend.

## 0.9.99 – Addon

**Behoben**

- **Beim Einloggen lief die Klangfolge der letzten Tage erneut ab.** Jeder
  Login und jedes `/reload` spielte Töne und Chatmeldungen für Aufträge, die
  längst erledigt waren. Der Grund: Ein Auftrag erreicht dich nicht dann, wenn
  er sich ändert, sondern dann, wenn du davon erfährst — beim Login schickt dir
  jeder Gildenclient alles, was er kennt, und für dein Addon sah jeder dieser
  Stände aus wie eine Änderung von jetzt.
- **Gemeldet wird jetzt nur, was frisch ist.** Klang und Chatzeile laufen nur
  noch für Änderungen der letzten zwei Minuten — also für das, was wirklich
  gerade passiert: Auftrag rein, Fortschritt, Abschluss. Ein Nachholstand
  bleibt still, egal auf welchem Weg er ankommt.
- **Verbucht wird trotzdem alles.** Die Auftragsstatistik zählt den stummen
  Nachholstand weiter mit; sonst hinge es am Zufall, ob man online war, als ein
  Auftrag fertig wurde.

## 0.9.98 – Addon

**Behoben**

- **Verzauberkunst meldete nie eine Wartezeit.** In TBC hängt der Beruf an einer
  eigenen Oberfläche — dort steht „Verzaubern", wo sonst „Herstellen" steht —,
  und Guild Copilot hat dafür einen eigenen Scanzweig. Die Wartezeiten aus
  0.9.97 wurden in die beiden anderen Zweige eingebaut und in diesen nicht.
  Ausgerechnet Sphäre der Leere und Prismasphäre, die bekanntesten Sperren des
  Spiels, blieben damit unsichtbar: Das Berufsfenster zeigte „Verbleibende
  Abklingzeit: 21 Std. 20 Min.", die Rezeptkarte daneben am selben Hersteller
  nichts.
- Auffallen konnte das nicht von selbst. Es gab keinen Fehler und keine leere
  Stelle — ein nicht gebauter Zweig sieht genauso aus wie ein Beruf ohne
  laufende Sperre, und beides zeigt das Addon bewusst gleich an.

Der Regressionstest aus 0.9.97 prüfte den Weg bis in die Rezeptkarte, aber an
Schneiderei — also im Zweig, der bereits funktionierte. Der neue läuft über die
Craft-API und schlägt gegen 0.9.97 fehl.

## 0.9.97 – Addon

Zwei Dinge in einer Fassung: Die Werkstatt beantwortet endlich die Frage nach
dem *Wann*, und das Addon hält einer großen Gilde stand. Bei 500 Mitgliedern
und 250 gleichzeitig online lief 0.9.96 nachweislich nicht mehr stabil — an
dem, was es kann, ändert dieser zweite Teil nichts.

**Neu**

- **Die Werkstatt kennt Wartezeiten.** Umwandlungen, Spezialtuche und Sphären
  haben eine Sperre, und wer ein Rezept kann, kann es deshalb noch lange nicht
  heute. In den Rezeptdetails steht sie jetzt am Hersteller („frühestens
  21:40“), ebenso in der Wunsch-Hersteller-Liste beim Auftragserstellen.
  Abgelesen wird beim Öffnen des Berufsfensters — dort, wo der Client sie
  überhaupt nennt —, geteilt wird sie über den Addon-Kanal.
- **Gesagt wird nur, was sich belegen lässt.** Die Angabe ist ausdrücklich eine
  Mindestangabe: Wer seitdem erneut hergestellt hat, ist später frei, nie
  früher. Dass jemand frei *ist*, behauptet Guild Copilot dagegen nie — das
  Spiel meldet für ein freies Rezept dasselbe wie für eines ohne jede
  Wartezeit.

**Behoben – Wartezeiten**

- **Ein erneuter Berufsscan verlor gemerkte Wartezeiten.** Der Scan baut den
  Berufsdatensatz vollständig neu auf; Angaben, die nicht aus den Rezepten
  stammen, fielen dabei heraus. Aufgefallen ist es nur, weil eine
  Spielfassung ohne Cooldown-Abfrage nichts hat, was sie ersetzt.

**Behoben – der Kanal**

- **Auf jede gildenweite Anfrage antwortete jeder Client einzeln.** Ein
  einziger Login löste dadurch gemessene 107.250 Pakete in der Gilde aus, für
  Inhalte, die bei allen dieselben sind. Blizzards Addon-Kanal stellt davon
  einen Bruchteil zu und verwirft den Rest lautlos – deshalb blieben
  Werkstattdaten unvollständig, fehlten Aufträge, und der Fortschrittsbalken
  meldete zu Recht dauerhaft „unvollständig". Jetzt beantwortet eine kleine,
  bei jedem Fragenden andere Auswahl die Anfrage: 777 Pakete statt 107.250.
- **Werkstatt und Gildenbank antworten weiterhin vollzählig**, nur zeitlich
  verteilt. Dort trägt jeder die Berufe seines eigenen Accounts bei, und die
  kann kein anderer für ihn melden.
- **Ein Paket ging doppelt raus, ein anderes gar nicht.** Bei geladener
  ChatThrottleLib – über DBM, Details! oder WeakAuras praktisch überall –
  konnte die Sendewarteschlange sich selbst überholen. Der Fortschrittszähler
  blieb danach stehen und buchte nach zwei Minuten einen Verlust, den es nie
  gegeben hatte.
- **Nach einem Warcraft-Logs-Import forderten alle gleichzeitig an.** Der
  Importeur bekam 250 vollständige Datensatz-Abrufe auf einmal. Jetzt fragt
  eine Handvoll; der Rest bekommt den Stand über den nächsten Abgleich.

**Behoben – die Bildrate**

- **Speicherte ein Offizier das Gildenprofil, stand das Spiel bei allen fast
  eine Sekunde still** (gemessen 932 ms bei 500 Mitgliedern). Ein einzelnes
  Rangkästchen genügte dafür. Jetzt sind es 61 ms.
- **Bei offener Werkstatt brach die Bildrate während eines Abgleichs ein.**
  Der Rezeptkatalog wurde je eintreffendem Rezept neu aufgebaut.
- **Die Mitgliederpflege und die Ausrüstungsseite** brauchen ein Vielfaches
  weniger Rechenzeit; die Spielerliste der Ausrüstungsprüfung legt nicht mehr
  einen Rahmen je geprüftem Spieler an.

**Behoben – verlorene Daten**

- **Bei vielen gleichzeitigen Absendern wurde der Großteil stumm verworfen.**
  Werkstatt und Ausrüstungsabgleich nahmen 20 bzw. 40 Übertragungen
  gleichzeitig an, bei 250 Online kamen deutlich mehr. Jetzt 64 bzw. 128, und
  beim Überlauf weicht die älteste angefangene statt der neuen.
- **Ein Raidabend löschte die Abendhistorie.** Weil jeder Teilnehmer seine
  Fassung als eigene Quelle ablegt, füllten 40 Antworten eines Abends alle 24
  Plätze – sechs gespeicherte Raidabende waren danach weg. Fremde Fassungen
  haben jetzt ein eigenes Kontingent.
- **Die Ausrüstungsprüfungen sind der größte Posten der gespeicherten Daten.**
  Sie speichern nur noch Messwerte; Beschriftung und Bewertung entstehen beim
  Anzeigen neu.

**Behoben – stille Ausfälle**

- **Setzte ein anderes Addon die Gildenliste auf „nur Online",** schrumpfte das
  Roster stumm mit. Offline-Mitglieder galten dann als ausgetreten: Ihre
  Profilpakete wurden verworfen, die Mitgliederpflege sah sie nicht mehr, und
  ihre Rezepte wurden gelöscht.
- **„Auswertung anfordern" blieb für manche dauerhaft ohne Antwort** – und zwar
  immer für dieselben.
- **Raidauswertungen ließen sich von außerhalb der Gilde einschleusen.**
- Der Gildenbank-Abgleich brachte den Client zum Schweigen, der den *neueren*
  Stand hielt.
- `/gcp debug` veränderte das Verhalten, statt es nur zu messen.

## 0.9.96 – Addon

**Behoben**

- **Die gemeldete Zahl verlorener Pakete konnte ins Unendliche wachsen.** Die
  Stillstandssperre schrieb den gesamten offenen Sendezähler als Verlust ab,
  räumte aber nur einen Teil davon ab — die bestätigten Flüsterteile blieben
  stehen. Damit sank der Gesamtwert nicht, der Zeitstempel rückte nicht weiter,
  und dieselbe Abschreibung lief beim nächsten Statusabruf erneut: zweimal je
  Sekunde. Abgeschrieben wird jetzt nur, was auch wirklich abgeräumt wird; die
  Flüsterteile geben ohnehin selbst auf.
- **Ein langer Kampf machte aus pausierten Paketen Verluste.** Dauert ein Kampf
  länger als zwei Minuten, liegen die Pakete weiterhin vollständig in der
  eigenen Warteschlange — die Sperre hat sie trotzdem als verloren gebucht,
  obwohl sie nach dem Kampf ordnungsgemäß hinausgingen. Was nachweislich noch
  bei uns liegt, gilt nicht mehr als verloren.
- **Die Anzeige nennt die Kampfpause beim Namen.** Statt „noch 12 Pakete" steht
  während des Kampfes „Im Kampf pausiert; es geht nach dem Kampf weiter."

Alle drei stammen aus dieser Reihe und waren nie veröffentlicht.

## 0.9.95 – Addon

**Behoben**

- **Ein langsamer Chatkanal machte aus einem gelungenen Abgleich einen
  „unvollständigen".** Kam der Sendezähler zwei Minuten nicht voran, buchte die
  Anzeige alles Ausstehende als verloren — auch die Pakete, die zu dem
  Zeitpunkt völlig regulär beim Chatkanal warteten. Trafen deren Rückmeldungen
  danach ein, war der Fehlerzähler längst hochgesetzt, und der Abgleich blieb
  bis zum Ausloggen „unvollständig", obwohl jedes einzelne Paket angekommen
  war. Solange nachweislich noch etwas unterwegs ist, wird jetzt nichts als
  verloren gebucht.
- **Stattdessen sagt die Anzeige, was los ist.** Wartet dasselbe Paket länger
  als zwei Minuten auf den Kanal, steht dort „Der Chatkanal ist gerade
  ausgelastet; es geht weiter, sobald er frei wird." Vorher stand bei einem
  verstopften Kanal beliebig lange „läuft", ohne dass sich etwas rührte.
- **Die letzte Ausnahme beim Warten ist entfallen.** 0.9.94 gab den Platz noch
  frei, wenn die ChatThrottleLib nicht mehr geladen schien. Auch das war eine
  unbelegte Annahme: Die Bibliothek hält ihre eigene Referenz und einen
  laufenden Zeitgeber, ein eingereihtes Paket geht weiter hinaus und meldet
  zurück. Es gibt keinen Zustand, aus dem sich „kommt nie an" ableiten ließe —
  also wird ohne Ausnahme gewartet.

Alle drei stammen aus 0.9.92 bis 0.9.94 und waren nie veröffentlicht.

## 0.9.94 – Addon

**Behoben**

- **Die Sicherung aus 0.9.92 konnte selbst mehrere Pakete gleichzeitig
  losschicken.** Sie erklärte ein Paket nach 15 Sekunden für verloren und gab
  das nächste frei. Die ChatThrottleLib kennt für eingereihte Nachrichten aber
  weder eine Ablaufzeit noch einen Abbruch — das vermeintlich verlorene Paket
  lag weiter in ihrer Warteschlange und ging später hinaus. Unter Last sammelte
  sich so eines nach dem anderen an, und die Zusage „im Kampf geht höchstens
  eines raus" fiel damit wieder. Eine lange Wartezeit heißt nicht, dass etwas
  verloren ist; zurückziehen lässt sich nichts, also wird gewartet. Dass der
  Abgleich hängt, meldet weiterhin die Fortschrittsanzeige.

  Der Platz wird nur noch in einem Fall ohne Rückmeldung frei: wenn die
  ChatThrottleLib gar nicht mehr geladen ist und deshalb nichts mehr zustellen
  kann. Das hängt an einer Tatsache statt an einer Uhr und kann keine Pakete
  anhäufen.

Der Fehler stammt aus 0.9.92 und war nie in einer veröffentlichten Fassung.

## 0.9.93 – Addon

**Behoben**

- **Der Gildenabgleich wäre mit 0.9.92 fast zum Stillstand gekommen.** Die
  ChatThrottleLib meldet bei freiem Kanal sofort zurück – noch während der
  Übergabe. Der Vermerk „ein Paket ist unterwegs" wurde aber erst *danach*
  gesetzt: Die Rückmeldung räumte damit ein Feld auf, das es noch gar nicht
  gab, und anschließend trug sich das längst gesendete Paket als unterwegs ein.
  Weiter ging es erst nach der 15-Sekunden-Sicherung – und das je Paket. Ein
  Abgleich mit dreißig Paketen hätte über sieben Minuten gebraucht statt
  weniger Sekunden. Der Vermerk steht jetzt vor der Übergabe.
- **Eine verspätete Rückmeldung konnte ein fremdes Paket freigeben.** Sie
  räumte den Vermerk auf, ohne zu prüfen, ob er noch zu ihr gehört. Wurde ein
  Paket nach der Sicherung aufgegeben und lief längst das nächste, gab die
  verspätete Meldung des alten das übernächste frei – und dann lagen wieder
  zwei gleichzeitig draußen, womit die Kampfpause ihre Zusage verlor. Jede
  Übergabe trägt jetzt eine laufende Nummer; aufgeräumt wird nur, was noch
  zusammengehört.

Beide Fehler stammen aus 0.9.92 und waren nie in einer veröffentlichten
Fassung.

## 0.9.92 – Addon

**Behoben**

- **„Bulk-Sync im Kampf pausieren" hält jetzt wirklich alles an.** Die Korrektur
  aus 0.9.91 war noch unvollständig: Die Warteschlange gab so viele Pakete an
  ChatThrottleLib ab, wie das Sendebudget hergab — bei 30 Paketen gingen 18
  sofort raus und nur 12 blieben anhaltbar. Übergeben wird jetzt genau **ein**
  Paket; erst dessen Rückmeldung gibt das nächste frei, und der Weg dorthin
  führt wieder durch die Kampfprüfung. Beginnt der Kampf, ist damit höchstens
  noch ein einzelnes Paket unterwegs.

  Auf die Dauer des Abgleichs wirkt sich das nicht aus: Getaktet wird ohnehin
  auf 800 Byte je Sekunde, und daran ändert die Reihenfolge nichts.

  Bleibt eine Rückmeldung ganz aus, gilt das Paket nach 15 Sekunden als
  verloren und die Warteschlange läuft weiter — sonst hielte ein einziger
  ausbleibender Rückruf ab jetzt den gesamten Abgleich an.

## 0.9.91 – Addon

**Behoben**

- **Die Raid-Reparatur konnte verschiedene Abende vermischen.** Sie prüfte
  überlappende Zeit und halbe Teilnehmerdeckung statt der Sitzungskennung —
  zwei Gruppen derselben Gilde, die gleichzeitig unterwegs sind und sich ein
  paar Leute teilen, erfüllen das. Dieselbe Prüfung war zugleich zu eng: Wer
  den halben Abend weg war, kennt zu wenige Teilnehmer für die Hälfte und bekam
  ausgerechnet dann keine Reparatur, wofür sie gedacht ist. Jetzt entscheidet
  die Kennung des Abends, auf die sich alle Mitschreiber ohnehin einigen.
- **Bei mehreren gleichzeitigen Reparaturen bekam nur der Erste seine Daten.**
  Die Antwortdrossel galt global statt je Anfragendem — fliegen nach einem
  Serverruckler drei Leute gleichzeitig raus, ging der zweite und dritte leer
  aus. Außerdem fragte eine Reparatur pauschal nach allem, und jeder antwortete
  mit bis zu fünf vollständigen Auswertungen. Gefragt wird jetzt nach genau dem
  einen Abend, und gedrosselt wird je Anfragendem.
- **Der Werkstatt-Abgleich fand bei gleichem Zeitstempel nicht zusammen.**
  Dieselbe Sache, die für die Gildenbank schon behoben war: Das Manifest
  forderte bei jeder Abweichung an — auch bei nachweislich älteren Ständen —,
  während die Übernahme nur strikt ältere verwarf. Zwei verschiedene
  Rezeptstände derselben Sekunde überschrieben einander, und wer zuletzt
  eintraf, gewann. Beide Seiten benutzen jetzt dieselbe Regel: der neuere
  gewinnt, bei gleicher Sekunde der mit dem größeren Fingerabdruck.
- **Die Kampfpause griff nicht für schon übergebene Pakete.** Wer eine globale
  ChatThrottleLib geladen hat, bekam sein Paket bisher sofort übergeben,
  solange kein Kampf lief. Die Werkstatt reicht ihre gesamte Warteschlange in
  einem Durchlauf weiter — ein vollständiger Rezeptkatalog war damit außer
  Reichweite, sobald danach der Kampf begann. Die eigene Warteschlange bleibt
  jetzt maßgeblich; an ChatThrottleLib geht immer nur das nächste Paket.
- **Gildenbank: Der übertragene Fingerabdruck wird gegengeprüft.** Er entschied
  den Konflikt, gespeichert wurde danach der selbst nachgerechnete — ohne
  Vergleich. Passt er nicht zu den angekommenen Beständen, wird der Stand jetzt
  verworfen, statt unter einer Angabe zu gewinnen, die die Daten nicht tragen.

## 0.9.90 – Addon

**Behoben**

- **Der Fortschrittsbalken des Abgleichs sprang hin und her.** Gemeldet für den
  Berufsabgleich: „80 % → 40 % → 90 % → 10 %, und das sehr schnell, so dass man
  nie weiß, wie weit der Fortschritt eigentlich ist." Der Anteil lief gegen den
  *Umfang*, und der wächst, sobald neue Arbeit auftaucht – beim Berufsabgleich
  ständig, weil jedes eintreffende Manifest eines Gildenmitglieds weitere
  fehlende Rezepte meldet. Acht erledigte von zehn Paketen sind 80 %; kommen
  zehn Pakete dazu, sind dieselben acht nur noch 8 von 20 und damit 40 % –
  obwohl nichts verloren ging. Bei einem Takt von einer halben Sekunde wirkte
  das wie Zufall.

  Erledigtes bleibt jetzt erledigt: Der Balken steigt innerhalb eines
  Durchlaufs nur noch. Dass der Umfang gewachsen ist, steht weiterhin daneben –
  in der echten Zahl der offenen Pakete, wo ein Sprung nach oben eine Auskunft
  ist statt einer Irritation.

## 0.9.89 – Addon

**Behoben**

- **Eine von jemand anderem gestartete Raidsitzung fehlte in den eigenen
  Einträgen.** Der Empfänger verwarf jede Sitzungsnachricht, deren *Absender*
  in seiner eigenen Sicht kein Steuerungsrecht hatte – geprüft am Gildenrang im
  lokalen Rosterabbild. Wen die zugehörige Einstellung noch nicht erreicht
  hatte oder wessen Roster den Absender nicht kannte, der bekam weder den
  Startruf noch einen der 60-Sekunden-Herzschläge mit, und zwar dauerhaft und
  ohne jede Meldung. Der Starter sah eine normal laufende Sitzung, beim anderen
  kam der Abend nie an. Startruf und Herzschlag sind Mitteilungen und brauchen
  jetzt keine Berechtigung mehr.

**Geändert**

- **Jeder schreibt seinen eigenen Raidabend mit.** Bisher gehörte eine Sitzung
  dem ganzen Raid: Startete jemand anderes früher, wurde der eigene Mitschnitt
  verworfen und durch seinen ersetzt. Jetzt bleibt dein Mitschnitt immer deiner.
  Übernommen wird nur noch das gemeinsame Etikett des Abends, damit alle
  denselben Abend unter derselben Kennung ablegen – deine Teilnehmer, Versuche
  und Zähler bleiben dabei unangetastet.
- **Starten und Beenden darf jeder für sich.** Beides schreibt nur in den
  eigenen Mitschnitt. Rangbeschränkt bleibt, was auf andere wirkt: der Ruf, der
  die Sitzung bei allen beendet, und das Löschen einer Auswertung.
- **Fremde Auswertungen tragen den Namen ihres Aufzeichners.** Vorher hießen
  alle schlicht „Sync" und überschrieben sich gegenseitig – von zwei
  Gildenmitgliedern, die denselben Abend mitgeschrieben hatten, blieb nur eins
  übrig.

**Neu**

- **Lückenhafte Mitschnitte reparieren sich aus den Mitschnitten der anderen.**
  Wer mitten im Abend neu lädt, rausfliegt oder später einsteigt, hat ein Loch
  in seinen Zahlen. Das wird jetzt vermerkt, und beim Sitzungsende fordert der
  Client genau dann die Auswertungen der anderen an. Ergänzt wird je Teilnehmer
  und Zähler mit dem **höheren** Wert – nie mit der Summe, sonst zählte doppelt,
  was beide gesehen haben. Das Ergebnis steht als eigene, benannte Fassung
  neben deinem unveränderten Rohmitschnitt.
- **Schutz gegen Zahlen aus alten Addon-Fassungen.** Jede Auswertung trägt
  jetzt, nach welchen Zählregeln sie entstanden ist. Verrechnet werden nur
  Fassungen derselben Regelversion, und nur solche, die sich selbst als
  lückenlos melden. Ohne diese Schranke hätte ein Client vor 0.9.87 seine
  überhöhten Trommelzahlen in fremde Auswertungen getragen – im Vergleichslog
  waren das 68 statt 28. Ältere Auswertungen bleiben sichtbar nebeneinander
  stehen, statt eingerechnet zu werden.
- **Ein lückenhafter Abend sagt es.** In der Kopfzeile der Auswertung steht,
  wenn dein Mitschnitt Lücken hat.

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

# Guild Copilot 0.9.52

<p align="center">
  <img src="Brand/GuildCopilotLogo.png" width="240" alt="Guild Copilot Logo">
</p>

Guild Copilot ist ein deutschsprachiger Rekrutierungshelfer für **World of Warcraft: Burning Crusade Classic Anniversary**.

## Funktionen

- automatische Erkennung des eigenen Talentbaums;
- frei bestätigbares Raidprofil mit Primär-Spec, optionalem Dual-Spec, Main/Twink und Flexibilität;
- unsichtbare Profilsynchronisierung zwischen Gildenmitgliedern mit installiertem Addon; wer neu dazukommt, fragt den Bestand ab und bekommt die Profile der bereits Eingeloggten nachgereicht, statt nur die Änderungen ab dem eigenen Login zu sehen;
- Addon-Erkennung in der Gildenübersicht: sichtbar, wer Guild Copilot nutzt und wessen Datenversion abweicht, ohne Dauerbroadcasts;
- gezählt werden dabei **Spieler, nicht Charaktere**: jeder Client meldet im Handshake ein anonymes Account-Kennzeichen, sodass Main und Twinks eines Spielers als einer erscheinen (die Charakterzahl steht daneben). Wer das Feld nicht sendet, zählt einzeln – lieber eine Zahl zu hoch als fremde Spieler fälschlich zusammengelegt;
- Gildenroster-Auswertung und TBC-orientierte Supportrollen-Vorschläge; importierte Warcraft-Logs-Profile und bereits bekannte Addon-Profile bilden automatisch einen gemeinsamen Gildendatensatz, damit alle Clients dieselben Lücken sehen;
- moderne, kompakte Oberfläche mit Seitenleiste und sauber begrenzten Scroll-Textfeldern;
- Aufklappmenüs mit vielen Einträgen scrollen und öffnen sich in die Richtung, in der Platz ist, statt am Rand des Scrollbereichs abgeschnitten zu werden;
- aufklappbare Klassenkarten zur Auswahl ganzer Klassen oder beliebig vieler Specs, ohne Pflichtangabe einer Anzahl;
- editierbare Werbetexte mit Raid-Symbolen und 255-Byte-Kontrolle;
- frei wählbares Raid-Symbol direkt über eine Symbolleiste im Werbeeditor;
- Abschluss-Symbol bleibt auch bei der automatischen 255-Byte-Kürzung erhalten;
- aktive Chatkanäle werden mit einem deutlichen Häkchen markiert;
- drei gewählte Specs werden zur Klasse verdichtet, alle vollständig gewählten Klassen zu „alle Klassen“;
- Klassen lassen sich dauerhaft hoch-/runtersortieren und als hohe Priorität kennzeichnen;
- hohe Prioritäten erscheinen zuerst und als „dringend“ im Werbetext;
- die rechte Auswahlleiste sortiert Klassen per Pfeil und markiert hohe Prioritäten; jede Änderung erzeugt beim nächsten Öffnen sicher einen neuen Text;
- ab sieben ausgewählten Klassen wird die lange Aufzählung als „alle Klassen“ verdichtet;
- ausdrückliche Prüfung über **Text bestätigen**, bevor ein Posting möglich ist;
- ein Klick auf **Suche starten** postet einmalig in alle ausgewählten und verfügbaren Kanäle;
- 120-Sekunden-Sicherheits-Cooldown pro Kanal und zusätzliche Server-Throttle-Erkennung;
- **Werbebalken**: ein kleines, verschiebbares Fenster nur fürs Posten – bestätigter Text, Zahl der bereiten Kanäle und der laufende Cooldown als Countdown direkt im Knopf. Damit muss für Werbung nicht das ganze Addonfenster offen bleiben;
- der Werbebalken sendet ausschließlich per echtem Klick; der Countdown schaltet den Knopf nur frei und löst nie selbst aus. Ein- und ausblenden über den Knopf auf **Werbung posten** oder `/gcp werbung`;
- Bewerber-Postfach mit Rekrutierungsfilter für eingehende Whispers und erkannte „Suche Gilde“-Chatnachrichten, auswählbarem Erfolgssound, editierbarer Antwortvorschau, optionalen Raid-Symbolen und Gildeneinladung;
- die Standardtexte für **Danke**, **Gildeninfos** und **Discord** werden direkt im **Postfach** unter den zugehörigen Knöpfen gepflegt – dort, wo sie benutzt werden – und gelten gildenweit;
- Interessenten lassen sich über ein **×** direkt neben ihrem Eintrag entfernen oder nach einem Bestätigungsklick vollständig aus dem Postfach löschen;
- Interessenten erscheinen in ihrer **Klassenfarbe** samt Klassennamen; die Klasse stammt aus der GUID der eingegangenen Nachricht, ist die Klasse unbekannt, bleibt der Name neutral;
- zu jeder Unterhaltung steht die **Empfangszeit** der letzten Nachricht – heute nur die Uhrzeit, älteres mit Datum;
- ein Name **ohne Realm** meint den eigenen: Erst dadurch werden derselbe Spieler mit und ohne Realmangabe zusammengeführt, zwei gleichnamige Spieler verschiedener Realms aber auseinandergehalten;
- eine **Ignorierliste** blendet Dauerschreiber aus – dauerhaft oder bis zu einem Datum, einsehbar und jederzeit über **Wieder zulassen** widerrufbar; abgelaufene Einträge räumt sie selbst weg;
- zu jedem Interessenten stehen zwei **kopierbare Profil-Links** bereit (classic-armory.org und Warcraft Logs): hineinklicken markiert den ganzen Link, Strg+C kopiert ihn. Region und Realm stammen aus der gespeicherten Warcraft-Logs-Gildenquelle, die dafür gildenweit synchronisiert wird;
- Gildenübersicht mit bis zu 25 zuletzt aktiven Level-70-Spielern, frei wählbaren Raider-Rängen, Raidprofil, Main/Twink-Status und Berufen;
- persönliches **Profil** als erster Menüpunkt mit Raidprofil, Dual-Spec, Berufen und eigener Abmeldung von/bis samt optionalem Grund;
- **Willkommensfenster beim ersten Login je Charakter**: Schriftlogo und ein einziger Knopf – **Einrichtung starten** – der auf die Profilseite führt. Es erscheint genau einmal und nie bei Charakteren mit längst bestätigtem Profil;
- **Einrichtung als Checkliste statt als Wizard-Fenster**: „Erste Schritte“ steht oben im Profil und zeigt, was noch offen ist – Raidprofil bestätigen, Rezepte einlesen, Ausrüstung ansehen. Einen „Weiter“-Knopf gibt es nicht, die echte Aktion schiebt die Liste weiter; jeder Schritt ist einzeln überspringbar und die ganze Karte jederzeit abbrechbar. Übersprungen wird von der echten Aktion überstimmt, und **Einrichtung** oben rechts holt die Liste jederzeit zurück;
- solange etwas offen ist, sitzt ein **Punkt am Minimap-Symbol**; sein Tooltip nennt den nächsten Schritt. Er verschwindet von selbst und wiederholt sich nie im Chat;
- **eine geänderte Auswahl gilt als unbestätigt**: Wer Spec, Dual-Spec, Main/Twink oder „flexibel“ umstellt, sieht statt des Bestätigungshakens den Hinweis, dass in der Gilde weiter der zuletzt bestätigte Stand steht;
- ranggeschützte Mitgliederpflege mit aktiven Gildenabmeldungen und nach Inaktivität sortierten Prüfvorschlägen;
- Vorschläge lassen sich als dauerhafte **Ausnahme**, **zurückgestellt** (30 Tage) oder **erledigt** ablegen; alle Einträge werden gildenweit synchronisiert, damit nicht zwei Offiziere denselben Fall bearbeiten;
- einzelner Gildenausschluss nur nach einer zweiten, ausdrücklichen Bestätigung, nur mit echter WoW-Berechtigung, nur gegen einen niedrigeren und ungeschützten Rang und niemals automatisch oder in Serie;
- frei wählbare Inaktivitätsgrenze und geschützte Gildenränge; Twinks und aktiv Abgemeldete werden aus den Vorschlägen ausgeschlossen;
- unsichere Main/Twink-Fälle werden ausdrücklich als **Prüfen** statt als Entfernungsvorschlag gekennzeichnet; es gibt keine automatischen Gildenausschlüsse;
- die beiden **Hauptberufe liest das Addon aus deinen Fähigkeiten**, ohne dass du etwas öffnen musst – eine zugeklappte Kategorie wird dafür kurz auf- und wieder zugeklappt. Gibt der Client keine Auskunft, sagt die Statuszeile das und du wählst von Hand, statt eine erfolgreiche Übernahme vorgespielt zu bekommen. Die **Rezepte** darin sind etwas anderes: Die gibt WoW nur bei geöffnetem Berufsfenster heraus;
- Gildenwerkstatt mit sofortigem, vollständigem Rezeptscan beim Öffnen des Berufsfensters: aktive Filter werden zurückgesetzt, eingeklappte Kategorien automatisch geöffnet und die separate TBC-Verzauberkunst-Schnittstelle unterstützt;
- kompakte Werkstatt-Synchronisierung zwischen Online-Gildenmitgliedern: große Datenmengen werden sofort eingereiht und mit dem maximal sicheren Addon-Kanal-Durchsatz gesendet; aktuelle Clients bestätigen jedes direkte Teilpaket, verlorene Pakete werden automatisch wiederholt und ältere Guild-Copilot-Versionen erhalten weiterhin das bisherige Datenformat;
- der gildenweite Bestand besteht aus einem **Rezeptkatalog**, in dem jedes Rezept genau einmal steht, und einem **Herstellerindex**, der nur die Schlüssel dessen führt, was wer kann. Über den Kanal geht deshalb im Regelfall nur eine kurze Schlüsselliste – ein Spieler mit drei vollen Berufen kostet 14 statt 331 Pakete. Fehlt einem Client ein gemeldetes Rezept, fordert er genau dieses gestreut und nur einmal nach;
- wer die Gilde verlässt, verschwindet mit seinen Rezepten aus der Werkstatt; Twinks von Gildenmitgliedern bleiben erhalten, weil sie nie im Gildenroster stehen;
- **Materialbestand am Rezept**: je Reagenz Bedarf, eigener Bestand (Taschen, Bank und eigene Twinks) und Gildenbankbestand mit Ampelfarbe – grün hast du selbst, gelb reicht erst mit der Gildenbank, rot fehlt auch dann. Darunter steht, was konkret fehlt und wie viel davon in der Gildenbank liegt;
- die **Gildenbank** wird beim Besuch am Bankfach je Tab eingelesen und gildenweit geteilt (Manifest zuerst, Bestände nur auf Anforderung, neueste Daten gewinnen); da die Sichtbarkeit eines Tabs am Gildenrang hängt, gilt alles pro Tab und ein eingeschränkter Blick löscht nie fremde Tabs. Eigene Taschen- und Bankbestände bleiben dagegen auf dem Account und werden nie gesendet;
- suchbasierte Gildenwerkstatt: Statt hunderte Rezepte ungefiltert zu laden, werden Ergebnisse erst nach Suchbegriff, Berufsauswahl oder über gespeicherte Favoriten angezeigt;
- bebilderter Berufsfilter, Berufssymbole in der Rezeptliste und lokale Rezeptfavoriten;
- Einstellungsseite für aktive Raider-Ränge, berechtigte Einstellungs-Editoren, Mitgliederpflege-Zugriff, Postfach-Erkennung, TBC-kompatible Erfolgssounds und das Minimap-Symbol;
- **eigene Trigger- und Ausschlusswörter** für das Postfach, getrennt für öffentliche Nachrichten und Flüstern; ein Ausschlusswort verhindert den Eintrag auch dann, wenn ein Trigger passt. Die Listen gelten nur für dich; ein leeres Trigger-Feld nutzt die mitgelieferte Vorgabe, statt die Erkennung stillschweigend abzuschalten;
- der **Bewerberton hängt am Gildenrang**: Wer nicht rekrutiert, hört ihn nicht, findet den Eintrag aber trotzdem im Postfach. Die Freigabe wird gildenweit synchronisiert;
- in der **Mitgliederpflege** stehen Prüfregeln, Pflegevorschläge und Entscheidungen als zusammenhängender Ablauf untereinander; die Abmeldungen als eigenes Thema darunter;
- Lockout-Schutz für gildenweite Einstellungen: eigener Rang nicht abwählbar, Entzug nur durch höhere Ränge und einmalige Offiziers-Wiederherstellung je Gilde für alte Sperren;
- Gildenprofil, Editor-Ränge, Mitgliederpflege-Zugriff, Raider-Ränge, Bewerberton-Ränge und Postfach-Standardtexte werden zwischen Addon-Nutzern synchronisiert;
- Aufruf über `/gcp`, das Minimap-Symbol oder **Optionen → AddOns → Guild Copilot**; das Blizzard-Gildenfenster bleibt unangetastet;
- das **Minimap-Symbol ist frei platzierbar**: In der Nähe der Minimap fährt es am Ring entlang, weit genug weggezogen löst es sich und steht überall auf dem Bildschirm. **Symbol zurück an die Minimap** in den Einstellungen holt es zurück, falls es unerreichbar liegt;
- **sparsam beim Ein- und Ausloggen anderer**: Rosterereignisse werden gesammelt statt einzeln verarbeitet, gezeichnet wird nur die aufgeschlagene Seite, und bei geschlossenem Fenster gar nichts. Große Übertragungen (Werkstatt, Gildenbank) pausieren im Kampf und laufen danach weiter;
- eigene statische Addon-Optionsseite mit Schriftlogo, Slash-Befehl und ausdrücklichem Öffnen-Button; sie öffnet kein zweites Fenster mehr automatisch und blockiert dadurch nicht die Escape-Taste;
- zusätzliche direkte Escape-Behandlung für Hauptfenster und Textfelder;
- eigenes Guild-Copilot-Logo im Fenstertitel und in den Addon-Metadaten;
- **Raidauswertung** mit ausdrücklich gestarteter Sitzung: Anwesenheitszeit, Versuche, Siege, Wipes, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände;
- **nachträgliche Raidauswertung aus `WoWCombatLog.txt`**: Der Installer wertet die Protokolldatei aus und erzeugt einen Importcode – auch für einen Abend, an dem niemand „Sitzung starten" gedrückt hat. Ohne Upload und ohne Zugangsdaten; die Datei bleibt lokal;
- derselbe Abend aus Livesitzung, Warcraft Logs und Logdatei steht **einmal in der Liste**: angezeigt wird die vollständigste Auswertung, die übrigen Quellen sind daneben abrufbar. Zahlen verschiedener Quellen werden nie miteinander verrechnet;
- Sitzungen dürfen Raidleiter, Assistenten und die für die Mitgliederpflege freigegebenen Gildenränge starten und beenden;
- die fertige Auswertung wird über den Raidkanal an alle berechtigten Teilnehmer verteilt; Offiziere außerhalb des Raids fragen sie an und erhalten sie per Flüsterkanal;
- gespeichert werden ausschließlich Zusammenfassungen, keine Combat-Log-Rohdaten;
- die Auswertung steht vollständig im Addonfenster: Sitzungsliste und Teilnehmertabelle. Kurze Rückmeldungen wie Start, Ende und abgelehnte Aktionen erscheinen zusätzlich im Chat, damit sie auch bei geschlossenem Fenster ankommen;
- die Übertragung zwischen den Addon-Nutzern läuft über den unsichtbaren Addon-Datenkanal, nicht über sichtbare Chatnachrichten;
- **Ausrüstungsprüfung** über automatische Eigendaten und die Inspect-API als Rückfall: fehlende Verzauberungen und leere Sockel je Slot, für die eigene Ausrüstung auch ohne Gruppe;
- geprüft wird nur, wer in Reichweite und erreichbar ist; nicht erreichbare Spieler werden ausdrücklich als übersprungen ausgewiesen;
- Bewertungen stammen aus einem versionierten Regelsatz und zeigen Regel, Quelle und Alter der Daten; unbewertete Verzauberungen werden nie als schlecht gewertet;
- **ohne hinterlegte Bewertung** gilt eine vorhandene Verzauberung standardmäßig als in Ordnung, damit als Fund übrig bleibt, was objektiv aus dem Item-Link hervorgeht: fehlende Verzauberungen und leere Sockel. Das behauptet keine Qualität, es unterscheidet nur verzaubert von nicht verzaubert. Wer stattdessen **Unbekannt** sehen will, schaltet es in den Einstellungen ab;
- die eigene Ausrüstung prüft sich beim Login sowie nach Ausrüstungs- und Inventaränderungen automatisch, entprellt, damit ein kompletter Wechsel nur eine Prüfung auslöst;
- noch nicht geladene Item-Links werden anhand der angelegten Gegenstands-ID erkannt, erneut gelesen und niemals als vollständiger Gildensnapshot verteilt;
- jeder Addon-Client stellt diesen kompakten Rohdaten-Snapshot ohne Schalter im Hintergrund der Gilde bereit. Andere Clients bewerten ihn mit dem aktuellen Regelsatz und müssen diesen Spieler nicht zusätzlich inspecten;
- synchronisiert werden ausschließlich Slot, Gegenstands-ID, Verzauberungs-ID und Zahl leerer Sockel. Fertige Bewertungen, Tooltiptexte und Inventarinhalte werden nicht übertragen;
- **mitgelieferter Verzauberungs-Regelsatz** mit 49 belegten TBC-Enchant-IDs über alle Ausrüstungsplätze: jede ID stammt aus der Wowhead-Zeile „Enchant Item: … (ID)" und ist damit genau die Zahl, die auch im Item-Link steht; welche Verzauberung für wen die beste ist, kommt aus den BiS-Listen von wowtbc.gg;
- bewertet wird nach **Archetyp statt nach Rolle**: Schattenpriester und Schurke sind beide „Schaden", brauchen aber völlig verschiedene Verzauberungen. Unterschieden werden Zauber-Schaden, Heilung, physischer Schaden und Tank; Schutz-Paladine zählen zusätzlich als Zauberer, weil ihre Bedrohung an Zaubermacht hängt;
- eine Regel, die auf den Geprüften nicht passt – anderer Slot, anderer Archetyp, spätere Phase –, wird behandelt, als gäbe es sie nicht. Eine Verzauberung wird nie deshalb schlecht bewertet, weil eine fremde Regel nicht auf sie zutrifft;
- **Content-Phase** je Gilde (T4 bis T6.5, Vorgabe T5): Was es im Spiel noch gar nicht gibt, wird nicht eingefordert. Umstellen mit `/gcp phase T5`, die Einstellung gilt gildenweit;
- **Ausnahmen für Farmgear, Widerstandssets und Encounter-Sets**: Rechtsklick auf eine Slotzeile nimmt den eigenen Ausrüstungsplatz aus der Wertung. Er bleibt sichtbar, zählt aber nicht als Fund, und der Grund steht dabei. Ausnahmen wandern mit dem Ausrüstungs-Snapshot zu den anderen Clients;
- **eigener Regelsatz der Gilde**: ein Klick auf eine Slotzeile stuft die erkannte Verzauberung als Optimal, Solide oder Verbesserbar ein; ein weiterer Klick nimmt die Bewertung zurück; die Gildenregel sticht dabei immer den mitgelieferten Satz;
- gespeichert und geteilt wird nur die Verzauberungs-ID mit ihrer Stufe – den Namen löst jeder Client selbst in seiner Sprache auf;
- den Regelsatz dürfen nur Ränge mit Einstellungsrecht ändern, er gilt gildenweit und wirkt sofort auf alle gespeicherten Prüfungen;
- gildeneigene Bewertungen gelten wahlweise für eine konkrete Spec; fehlt dort eine Regel, greift die allgemeine Bewertung derselben Enchant-ID für alle Specs;
- der Name der Verzauberung kommt aus dem WoW-Tooltip selbst und steht dadurch ohne gepflegte Datenbank im Klartext da („Verzaubert: Außergewöhnliche Gesundheit“), in der Sprache des Clients;
- es gibt bewusst keine Gesamtnote je Spieler;
- die Funde stehen als lesbare Sätze da statt als nackte Zahlen: „2 fehlende Verzauberungen: Kopf, Schulter“, „3 leere Sockel: Brust, Hände“; leere Pflichtslots zählen ebenfalls als Fund;
- die Liste geprüfter Spieler ist vollständig scrollbar; ein per Addon-Daten geprüftes aktuelles Gruppenmitglied wird automatisch ausgewählt und bleibt auch bei mehr als zwölf gespeicherten Prüfungen erreichbar;
- eine Kopfzeile fasst alle geprüften Spieler zusammen, etwa „8 geprüft, davon 5 ohne Funde • 6 fehlende Verzauberungen • 4 leere Sockel“;
- jeder Spieler sieht seine eigene Prüfung unter **Profil → Deine Ausrüstung** und kann sie dort jederzeit selbst auslösen;
- Warcraft-Logs-Gildenlink aus Region, Realm und Gildenname automatisch vorbereiten oder direkt einfügen;
- Warcraft-Logs-Import, dessen Specs die Roster- und Copilot-Auswertung ergänzen; die importierten Profile und der neueste bekannte Addon-Profilcache werden automatisch innerhalb der Gilde abgeglichen, vollständige Kampfprotokolle bleiben getrennt;
- **Nachanalyse aus Warcraft Logs**: öffentliche Reports liefern Teilnahme, Anwesenheitszeit, Versuche, Siege, Wipes, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände;
- der Abruf steckt im **Installer** – ein Fenster für Zugangsdaten, Link und Anzahl der Reports; der fertige Importcode landet in der Zwischenablage. Node.js wird dafür nicht gebraucht;
- der Import lässt sich zuerst mit einem einzelnen Report ausprobieren und protokolliert jeden Schritt einzeln;
- **beim Einfügen verlorene Zeilenumbrüche werden repariert**: WoW lässt gelegentlich einen Umbruch fallen, zwei Zeilen verschmelzen und beide Datensätze gehen verloren. Das Addon setzt den Umbruch selbst, wo mitten in einer Zeile ein neuer Datensatz beginnt;
- der Import ersetzt die gespeicherten Profile erst nach einer zweiten, ausdrücklichen Bestätigung; jede Rückmeldung trägt die Uhrzeit, und eine fehlende Kopf- oder Sitzungszeile wird benannt statt still verworfen;
- Logs-Auswertungen erscheinen als eigene Einträge mit der Quelle **Warcraft Logs** neben den Livesitzungen; beide werden getrennt gehalten und niemals miteinander verrechnet;
- welche Spell-ID welcher Verbrauchskategorie entspricht, entscheidet allein das Addon – unbekannte IDs aus dem Companion werden ignoriert statt falsch einsortiert.
- manueller Profilimport ohne API im lesbaren Format `Name;Klasse;Primär-Spec;Dual-Spec`.

## Installation

0. Der einfachste Weg unter Windows: **`GuildCopilot-Installer.exe`** starten – zu finden unter [Installer/dist](Installer/dist). Sie erkennt die vorhandenen Spielversionen selbst, lädt das Addon direkt aus diesem Repository, aktualisiert eine vorhandene Fassung und hält sich auch selbst aktuell. Der Warcraft-Logs-Import steckt gleich mit drin.
1. Ohne die .exe: `Install.cmd` doppelt anklicken. Das Skript sucht die WoW-Installation und kopiert die neue Fassung über eine eventuell vorhandene, ohne den funktionierenden Ordner vorher zu löschen. Wird die Installation nicht gefunden, fragt es nach dem Pfad zum Ordner `_anniversary_`.
2. Von Hand: den Ordner `GuildCopilot` in den Addon-Ordner der TBC-Anniversary-Installation kopieren:
   `World of Warcraft/_anniversary_/Interface/AddOns/`
   Danach muss `GuildCopilot.toc` direkt in `AddOns/GuildCopilot/` liegen – ein doppelt verschachtelter Ordner ist der häufigste Installationsfehler.
3. WoW neu starten oder am Charakterbildschirm **AddOns** öffnen.
4. **Guild Copilot** aktivieren und im Spiel `/gcp` eingeben.
5. Im Rekrutierungs-Workflow zuerst das **Gildenprofil** ausfüllen und danach die **Copilot-Vorschläge** prüfen.
6. Unter **Profil** das eigene Raidprofil mit **Bestätigen** speichern, Berufe übernehmen und bei Bedarf eine Abmeldung eintragen.
7. Unter **Einstellungen** festlegen, welche Gildenränge als aktive Raider erscheinen, die Mitgliederpflege öffnen und gildenweite Einstellungen bearbeiten dürfen.
8. Optional unter **Warcraft Logs** die Gildenseite speichern und einen Import aus dem Installer einfügen.
9. Unter **Gildenwerkstatt** einen Beruf auswählen, einen Rezept-/Spielernamen suchen oder Favoriten öffnen. Jeder Nutzer öffnet seine Berufsfenster mindestens einmal; Guild Copilot entfernt dabei einschränkende Rezeptfilter, klappt Kategorien auf und liest den gesamten bekannten Bestand automatisch ein.
10. Unter **Mitgliederpflege** – mit freigegebenem Gildenrang – Abmeldungen und Inaktivitätsvorschläge prüfen sowie Inaktivitätsgrenze und geschützte Ränge festlegen.
11. Unter **Raidauswertung** vor dem Raid **Sitzung starten** und danach **Sitzung beenden**. Offiziere außerhalb des Raids holen sich die Auswertung über **Auswertung anfordern**.
12. Unter **Ausrüstung** stehen Daten von Addon-Nutzern automatisch bereit. **Gruppe prüfen** ist nur noch der manuelle Rückfall für Teilnehmer ohne frischen Addon-Snapshot; bereits synchronisierte Spieler werden dabei nicht erneut inspectet.

Alle Mitglieder sollten dieselbe Version fahren. Die Versionsnummer steht im Fenstertitel, und abweichende Datenversionen werden in der Gildenübersicht ausgewiesen.

## Installer

`GuildCopilot-Installer.exe` liegt unter [Installer/dist](Installer/dist), der Quellcode daneben unter [Installer/](Installer). Sie gehört **nicht** ins Addon-Verzeichnis – installiert wird ausschließlich der Ordner `GuildCopilot`.

- erkennt vorhandene WoW-Installationen selbst und merkt sich die gewählte;
- lädt das Addon direkt aus diesem Repository, aktualisiert und entfernt es;
- vergleicht Versionen stellenweise, nicht auf ungleich: eine ältere Fassung im Repository wird ausdrücklich als Rückstufung ausgewiesen und nie als Aktualisierung angeboten;
- überschreibt beim Aktualisieren, statt vorher zu löschen. Ein geöffnetes Explorer-Fenster hat sonst gereicht, um die Installation abzubrechen;
- hält sich selbst aktuell; **Nach Updates suchen** prüft Addon und Installer und **spielt ein gefundenes Addon-Update sofort ein** – ohne zweite Rückfrage, weil wer danach sucht es auch haben will. Eine Rückstufung auf eine ältere Fassung im Repository bleibt eine bewusste Entscheidung von Hand;
- **Nach Updates suchen** steht vorn und ist hervorgehoben, **Neu installieren** tritt zurück: der eine Knopf wird ständig gebraucht, der andere selten;
- hat ein eigenes Dateisymbol im Explorer (mehrere Größen von 16 bis 256 Pixeln);
- enthält den Warcraft-Logs-Import.

Installer und Addon werden **getrennt gezählt**. Aktuell stehen der Installer bei 1.0.5 und das Addon bei 0.9.52; beide Nummern stehen im Verlauf.

### Warum Windows beim Herunterladen warnt

Auf einem fremden Rechner meldet sich erst der Browser, dann Windows, dann SmartScreen („Der Computer wurde durch Windows geschützt"). Das ist kein Fehler und liegt nicht an der Datei: Die `.exe` ist **nicht code-signiert**, und Windows markiert zusätzlich alles, was aus dem Internet kommt.

Abstellen lässt sich das nicht von hier aus – dafür bräuchte es ein **Code-Signing-Zertifikat** (OV etwa 200–400 €/Jahr und erst nach aufgebauter Reputation wirksam, EV etwa 400–600 €/Jahr und sofort; beide seit 2023 nur noch mit Hardware-Token). Ein selbst ausgestelltes Zertifikat hilft ausdrücklich **nicht**, SmartScreen ignoriert es. SmartScreen abzuschalten ist keine Lösung, sondern nur der Verzicht auf eine Prüfung, die auch bei anderen Dateien nützlich ist.

Bei SmartScreen führt der Weg über **Weitere Informationen → Trotzdem ausführen**. Wer sichergehen will, vergleicht vorher die Prüfsumme:

```powershell
Get-FileHash .\GuildCopilot-Installer.exe -Algorithm SHA256
```

SHA-256 der Fassung 1.0.5: `30A4DD7FD03A5C50E1E9DC424588468D19B978E318AEE74003F4A321A0666DC8`

Wem das zu umständlich ist, nimmt `Install.cmd` aus dem Repository – dort wird nichts ausgeführt, was Windows nicht ohnehin kennt.

Zum Bauen wird das .NET SDK gebraucht:

```bash
dotnet publish Installer -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -o Installer/dist
```

`Installer/dist/version.txt` muss dabei auf die neue Installer-Version gesetzt werden – daraus liest die laufende Fassung, ob es etwas Neueres gibt.

## Wichtige WoW-Grenzen

WoW erlaubt Addons nicht, Chatwerbung zeitgesteuert oder ohne echten Tastendruck zu versenden. Darum ist **Suche starten** bewusst ein manueller Klick; dieser eine Klick bedient alle ausgewählten Kanäle. Ein Ingame-Addon besitzt außerdem keinen Webzugriff. Deshalb speichert Guild Copilot den Warcraft-Logs-Link und nimmt Daten über einen kontrollierten Import entgegen. Ein echter Abruf muss außerhalb von WoW über die offizielle Warcraft-Logs-API und OAuth erfolgen.

Den Abruf übernimmt der **Installer** im Bereich **Warcraft Logs**: Client ID, Client Secret, ein Gilden- oder Reportlink, ein Klick – der Importcode landet in der Zwischenablage und wird im Addon eingefügt. Für den WCL-Client wird `http://localhost/callback` als technisch verlangte Redirect-URL eingetragen; verwendet wird sie nicht. Das Client Secret wird nur auf Wunsch gespeichert, dann über die Windows-eigene DPAPI verschlüsselt und an das Windows-Konto gebunden – nie im Klartext.

Beim Gildenlink werden die jüngsten Reports genommen, sortiert nach Endzeit; bei „Reports: 1" also der letzte Raid. Ein Reportlink holt gezielt genau diesen einen.

### Raidabend aus dem Combat Log

Für die Raidauswertung gibt es einen zweiten, netzfreien Weg: den Bereich **Raidabend aus dem Combat Log** im Installer. Er liest eine `WoWCombatLog.txt` aus `<Spielversion>\Logs\` und erzeugt denselben Importcode – ohne Upload, ohne Zugangsdaten, ohne Warcraft-Logs-Konto. Die Datei bleibt auf dem Rechner; über den Gildenkanal geht wie bisher nur, was ohnehin geteilt wird.

Der Nutzen ist die Rückwirkung: Aufgezeichnet wird im Spiel mit `/combatlog`, und die Datei hat den ganzen Abend – auch wenn niemand **Sitzung starten** gedrückt hat. Ein Raidabend ist dabei ein Block aus Bosskämpfen; längere Pausen trennen zwei Abende, eine Logdatei läuft über mehrere Abende weiter.

Grenzen, damit die Zahlen richtig gelesen werden:

- die **Klasse** steht im Combat Log nicht. Teilnehmer aus der Logdatei erscheinen ohne Klassenfarbe, statt mit einer geratenen Klasse;
- gezählt wird nur, wer in einem Bosskampf auftaucht. Wer daneben stand und sich selbst gebufft hat, kommt nicht in die Liste;
- die **Zone** wird aus den Bossnamen aufgelöst, weil die Datei keine nennt;
- die Auswertung ist eine eigene Quelle (**Combat Log**) und wird nie mit Live- oder Warcraft-Logs-Zahlen verrechnet. Liegt derselbe Abend mehrfach vor, steht er einmal in der Liste – angezeigt wird die vollständigste Auswertung, die übrigen Quellen sind über die Knöpfe in der Teilnehmerkarte erreichbar.

Der ältere Weg über `GuildCopilot/Companion/Start-WCL-Import.cmd` funktioniert unverändert weiter und braucht Node.js. Er bleibt vorerst als Rückfallebene erhalten; Einzelheiten und Fehlersuche stehen in [Companion/README.md](GuildCopilot/Companion/README.md).

## Blizzard-Compliance

- keine Timer, Schleifen oder Hintergrundfunktionen zum Senden von Chatwerbung;
- jedes Posting erfordert einen echten Klick des Spielers;
- standardmäßig ist ausschließlich `Gildenrekrutierung` gewählt;
- SucheNachGruppe, Handel und Allgemein müssen bewusst zugeschaltet werden;
- jedes einzelne Ziel hat mindestens 120 Sekunden lokalen Cooldown;
- der Text muss nach jeder Änderung erneut bestätigt werden;
- Gildenprofile werden nur bei Login, Änderung oder ausdrücklicher Abfrage kompakt synchronisiert;
- keine Eingabesimulation, WoW-Speicherzugriffe oder Webzugriffe aus WoW;
- keine kostenpflichtigen Funktionen, Spendenaufrufe oder Werbung für Waren und Dienstleistungen.

Die Nutzung bleibt außerdem an die jeweiligen Realm-, Kanal- und Verhaltensregeln gebunden. Blizzard kann Addon-Funktionen jederzeit einschränken. Für eine verbindliche Einzelfallentscheidung nennt Blizzard `WoWUI@blizzard.com`.

## Slash-Befehle

- `/gcp` – öffnet und schließt Guild Copilot; `/guildcopilot` tut überall dasselbe
- `/gcp help` – zeigt alle Befehle im Chat
- `/gcp welcome` – zeigt das Willkommensfenster mit der Einrichtung
- `/gcp recruite` – blendet den Werbebalken ein oder aus (`/gcp werbung` bleibt gültig)
- `/gcp phase` – zeigt die Content-Phase der Gilde; `/gcp phase T5` stellt sie um
- `/gcp debug` – schaltet die Laufzeitmessung ein; ein zweiter Aufruf zeigt die schlimmsten Einzelmessungen und beendet sie

Dieselbe Liste steht unter **Optionen → AddOns → Guild Copilot** – dort sucht man sie, wenn einem der Chatbefehl gerade nicht einfällt. Beide Aufzählungen stammen aus derselben Tabelle im Code und können nicht auseinanderlaufen.

## Gespeicherte Daten

Einstellungen und Gildendaten liegen in `GuildCopilotDB` (SavedVariables). Über Addon-Nachrichten werden kompakte Charakter-, Ausrüstungs- und Werkstattprofile, die für Copilot benötigten Warcraft-Logs-Profile sowie das Gildenprofil mit Berechtigungen, Antwortvorlagen, Pflegeentscheidungen und Verzauberungsregeln ausschließlich innerhalb der eigenen Gilde synchronisiert. Fertige Raidauswertungen laufen nur über Raid-, Gruppen- oder gezielte Flüsternachrichten. Vollständige Warcraft-Logs-Auswertungen bleiben von diesem Rekrutierungsabgleich getrennt.

Raidstatistik, Consumable-Auswertung, Gear-Audit und Mitgliederpflege sind umgesetzt. Verbleibende Datenpflege, bekannte Grenzen und spätere Ausbaustufen stehen in [ROADMAP.md](ROADMAP.md).

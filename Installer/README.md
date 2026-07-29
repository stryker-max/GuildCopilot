# Guild-Copilot-Installer

Ein Windows-Fenster für zwei Aufgaben: das Addon installieren und aktuell halten, und den Warcraft-Logs-Import erzeugen.

Die fertige Anwendung liegt unter [dist/GuildCopilot-Installer.exe](dist/GuildCopilot-Installer.exe). Sie gehört **nicht** in den AddOns-Ordner – installiert wird ausschließlich der Ordner `GuildCopilot` aus diesem Repository.

## Bereich „Addon"

- erkennt die vorhandenen WoW-Installationen selbst und merkt sich die gewählte in `%AppData%\GuildCopilotInstaller\settings.ini`;
- lädt das Addon direkt aus `stryker-max/GuildCopilot`, aktualisiert und entfernt es;
- vergleicht Versionen stellenweise, nicht auf ungleich: eine ältere Fassung im Repository gilt ausdrücklich als Rückstufung und wird nie als Aktualisierung angeboten;
- überschreibt beim Aktualisieren, statt vorher zu löschen. Ein geöffnetes Explorer-Fenster hat sonst gereicht, um die Installation abzubrechen; anschließend werden nur noch die Dateien entfernt, die es in der neuen Fassung nicht mehr gibt;
- optional automatische Aktualisierung beim Öffnen und Autostart mit Windows;
- hält sich selbst aktuell – **Nach Updates suchen** prüft Addon und Installer.

## Bereich „Warcraft Logs"

Ein WoW-Addon darf nicht ins Netz. Dieser Bereich liest öffentliche Reports über die offizielle GraphQL-API v2 und legt den Importcode in die Zwischenablage.

Einmalig braucht es einen API-Client unter [Warcraft Logs – API Clients](https://www.warcraftlogs.com/api/clients/):

- Name: `Guild Copilot – private guild roster and spec importer`
- Redirect URLs: `http://localhost/callback` (Pflichtfeld der WCL-Maske; wird nicht verwendet)
- Public Client: nicht anhaken

Danach im Installer Client ID und Secret eintragen, einen Gilden- oder Reportlink angeben und **Import erzeugen** klicken. In WoW `/reload`, dann **Guild Copilot → Warcraft Logs**, Feld leeren, `Strg+V`, **Daten importieren**.

Beim **Gildenlink** werden die jüngsten Reports genommen, sortiert nach Endzeit – bei „Reports: 1" also der letzte Raid. Ein **Reportlink** (`https://…/reports/…`) holt gezielt genau diesen einen; das ist auch der beste erste Versuch.

Das Client Secret wird nur auf Wunsch gespeichert. Dann verschlüsselt es Windows über die DPAPI an das angemeldete Konto gebunden – eine kopierte `settings.ini` ist auf einem anderen Rechner wertlos. Im Klartext liegt es nie auf der Platte.

## Was abgefragt wird

Je Report: Kampfabschnitte (nur Encounter, kein Trash), Teilnahme, Anwesenheitszeit, Tode, Wiederbelebungen, Interrupts, Dispels und Verbrauchsgegenstände. Ausgewertet wird über die Ereignisliste (`events`) und nicht über die aufbereiteten Tabellen: dort steht je Ereignis eine Akteurs-ID und eine Spell-ID, das ist unabhängig von der Tabellenform.

Die Ereignisse werden über den ganzen Report gelesen, nicht nur über die Bosskämpfe – wiederbelebt wird zwischen den Pulls, dispelt und unterbrochen auch auf Trash, getrunken vor dem Pull. Nur die Anwesenheitszeit bleibt kampfbasiert, sie misst genau das.

Verbrauchsgegenstände werden als reine `Spell-ID:Anzahl`-Paare übertragen. In welche Kategorie eine ID fällt, entscheidet allein `GC.Consumables` im Addon; unbekannte IDs werden dort ignoriert und erzeugen nie falsche Zahlen.

## Selbsttest ohne Zugangsdaten

```bash
GuildCopilot-Installer.exe --selftest-core
GuildCopilot-Installer.exe --selftest GuildCopilot-WCL-Debug.json
```

Der Kernselbsttest prüft Linkvalidierung und Encounter-Teilnehmerauswahl vollständig offline. Der dateibasierte Selbsttest spielt zusätzlich eine mit `--debug` aufgezeichnete API-Antwort durch die Auswertung und gibt die Importzeilen aus. Damit lässt sich belegen, dass Änderungen an der Auswertung dieselben Zeilen erzeugen wie zuvor – ohne Netz und ohne API-Client.

## Bauen

Gebraucht wird das .NET SDK.

```bash
dotnet publish Installer -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -o Installer/dist
```

Danach `Installer/dist/version.txt` auf die neue Installer-Version setzen – daraus liest die laufende Fassung, ob es etwas Neueres gibt. **Installer und Addon werden getrennt gezählt**; die Installer-Version steht in `GuildCopilot-Installer.csproj`.

Eine laufende `.exe` kann sich nicht selbst überschreiben. Beim Selbstupdate wird die neue Fassung daneben abgelegt und die alte umbenannt. Die neue Instanz wartet unsichtbar, bis die alte vollständig beendet ist; dadurch sind nie zwei Installer-Fenster gleichzeitig offen. Beim nächsten Start verschwindet die umbenannte Datei.

Aktueller Stand: Installer 1.0.3, Addon 0.9.19.

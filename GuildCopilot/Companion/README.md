# Warcraft-Logs-Companion

Ein WoW-Addon darf keine Webseiten oder Web-APIs aufrufen. Dieses kleine, offen einsehbare Hilfsprogramm liest ausschließlich öffentliche Warcraft-Logs-Daten über die offizielle GraphQL-API. Es steuert WoW nicht und simuliert keine Eingaben.

## Einfacher Start

1. Unter [Warcraft Logs – API Clients](https://www.warcraftlogs.com/api/clients/) einmalig einen API-Client anlegen:
   - Name: `Guild Copilot – private guild roster and spec importer`
   - Redirect URLs: `http://localhost/callback` (Pflichtfeld der WCL-Maske; wird vom Companion nicht verwendet)
   - Public Client: nicht anhaken
2. `Start-WCL-Import.cmd` doppelt anklicken.
3. Client ID, Client Secret und den Warcraft-Logs-Gildenlink eingeben.
4. Nach erfolgreichem Abruf liegt der Importcode automatisch in der Zwischenablage.
5. In WoW **Guild Copilot → Warcraft Logs** öffnen, den Code mit `Strg+V` einfügen und **Daten importieren** anklicken.

Die Zugangsdaten werden nicht in einer Datei gespeichert.

## Alternativ über PowerShell

Die Zugangsdaten für das aktuelle Fenster setzen:

   ```powershell
   $env:WCL_CLIENT_ID = "deine-client-id"
   $env:WCL_CLIENT_SECRET = "dein-client-secret"
   ```

Node.js 18 oder neuer wird benötigt:

```powershell
node .\WCL-Import.mjs "https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath"
```

Danach liegt die Datei `GuildCopilot-WCL-Import.txt` im temporären Windows-Ordner. Beim einfachen Start kopiert das Startprogramm ihren Inhalt automatisch in die Zwischenablage. Im Addon unter **Warcraft Logs → Companion-Import** einfügen und **Daten importieren** klicken.

Das Script betrachtet die zwölf jüngsten öffentlichen Reports und exportiert neben den Spielerprofilen auch je Report eine Raidauswertung (Teilnahme, Anwesenheitszeit, Versuche, Siege, Wipes, Tode, Interrupts, Dispels, Verbrauchsgegenstände). Der zuletzt beobachtete Spec wird Primär-Spec, ein weiterer beobachteter Spec wird Dual-Spec. Private Reports werden mit dem Client-Credentials-Verfahren bewusst nicht gelesen.

local _, GC = ...

-- === Sprache ================================================================
--
-- Deutsch ist die Quellsprache des Addons: Jeder Text im Code steht deutsch,
-- und GC.L(text) gibt ihn auf deutschen Clients unveraendert zurueck. Auf
-- allen anderen Clients schlaegt GC.L in der englischen Tabelle nach; was
-- dort (noch) fehlt, bleibt deutsch, statt zu brechen - die Uebersetzung
-- kann damit in Teilschritten wachsen, ohne je einen halben Zustand zu
-- zeigen.
--
-- Der Fahrplan (Owner-Vorgabe vom 08.08.2026):
--
--   Teilschritt 1 (dieser Stand): Navigation, Seitentitel und Untertitel -
--   ausschliesslich eigene Addon-Texte.
--
--   Teilschritt 2: Spielbegriffe (Verbrauchsgegenstaende, Slots, Instanzen).
--   Fuer sie gilt eine harte Regel: NIE frei uebersetzen. Jeder Name eines
--   Gegenstands, Zaubers oder einer Verzauberung wird einzeln aus einer
--   offiziellen Quelle uebernommen (Wowhead ueber die Spell-/Item-ID, oder
--   der Spielclient selbst) und traegt seinen Beleg als Kommentar - dasselbe
--   Verfahren wie bei GC.EnchantRecipeKeys.
--
--   Teilschritt 3: Seiteninhalte, Status- und Chatmeldungen.
--
-- Warum Deutsch als Schluessel: Das Addon ist deutschsprachig gewachsen,
-- jede Zeile Code traegt ihren Text schon. Ein Schluesselsystem ("PAGE_
-- TITLE_GEAR") haette tausende Stellen angefasst, bevor die erste
-- Uebersetzung sichtbar wird; so genuegt eine Tabellenzeile je Text, und
-- nicht Uebersetztes faellt sichtbar und harmlos auf Deutsch zurueck.

local english = {
    -- === Teilschritt 1: Navigation =========================================
    -- Abschnitte der Seitenleiste. COPILOT, RAID und SYSTEM sind in beiden
    -- Sprachen dieselben Woerter und brauchen keinen Eintrag.
    ["REKRUTIERUNG"] = "RECRUITMENT",
    ["GILDE"] = "GUILD",

    -- Reiter der Seitenleiste.
    ["Profil"] = "Profile",
    ["Übersicht"] = "Overview",
    ["Gildenprofil"] = "Guild Profile",
    ["Vorschläge"] = "Suggestions",
    ["Klassen & Specs"] = "Classes & Specs",
    ["Werbung posten"] = "Post Ad",
    ["Postfach"] = "Inbox",
    ["Mitgliederpflege"] = "Member Care",
    ["Gildenwerkstatt"] = "Guild Workshop",
    ["Raidauswertung"] = "Raid Review",
    ["Ausrüstung"] = "Gear",
    ["Einstellungen"] = "Settings",

    -- === Teilschritt 1: Seitentitel ========================================
    ["Dein Profil"] = "Your Profile",
    ["Gildenübersicht"] = "Guild Overview",
    ["Copilot-Vorschläge"] = "Copilot Suggestions",

    -- === Teilschritt 1: Untertitel der Seiten ==============================
    ["Raidprofil, Berufe und Abmeldung an einem Ort – diese Angaben werden mit Guild-Copilot-Nutzern in deiner Gilde synchronisiert."]
        = "Raid profile, professions and absences in one place – these details are synchronized with Guild Copilot users in your guild.",
    ["Bis zu {n} zuletzt aktive Level-70-Spieler – nach gewählten Raider-Rängen, mit Raidprofil und Berufen."]
        = "Up to {n} recently active level 70 players – filtered by the selected raider ranks, with raid profile and professions.",
    ["Diese Angaben werden gildenweit synchronisiert und fließen in Werbe- und Antworttexte ein."]
        = "These details are synchronized guild-wide and feed the ad and reply templates.",
    ["Gildenroster, bestätigte Profile und importierte Logs ergeben einen Vorschlag für die Rekrutierung."]
        = "Guild roster, confirmed profiles and imported logs combine into a recruiting suggestion.",
    ["Klassen öffnen, Bedarf auswählen und die Reihenfolge rechts nach Priorität sortieren."]
        = "Open a class, pick what you need and order the list on the right by priority.",
    ["Text prüfen, bestätigen und mit einem echten Klick in die ausgewählten Kanäle senden — oder die Automatik postet mit dem nächsten Tastendruck, sobald ein Kanal bereit ist."]
        = "Review the text, confirm and send it to the selected channels with a real click — or let auto-repeat post on your next keypress once a channel is ready.",
    ["Whispers und erkannte „Suche Gilde“-Nachrichten werden hier gesammelt."]
        = "Whispers and detected \"looking for guild\" messages are collected here.",
    ["Abmeldungen berücksichtigen und lange Inaktivität nachvollziehbar prüfen – niemals automatisch entfernen."]
        = "Respect absences and review long inactivity transparently – never remove anyone automatically.",
    ["Rezepte werden automatisch erfasst, sobald ein Spieler sein WoW-Berufsfenster öffnet."]
        = "Recipes are recorded automatically whenever a player opens their WoW profession window.",
    ["Profile manuell eingeben oder öffentliche Reports mit dem mitgelieferten Windows-Helfer auslesen."]
        = "Enter profiles by hand or read public reports with the bundled Windows companion.",
    ["Sitzungen starten nur berechtigte Ränge; gespeichert werden Zusammenfassungen, keine Rohdaten. Spaltenkopf: Klick sortiert, Ziehen ordnet um. Maus über einer Zeile zeigt alles im Detail."]
        = "Only authorized ranks start sessions; summaries are stored, never raw data. Column headers: click sorts, drag reorders. Hover over a row for full details.",
    ["Fehlende Verzauberungen, leere Pflichtslots und Sockel je Slot. Addon-Nutzer liefern aktuelle Eigendaten; Inspect bleibt der Rückfall für erreichbare Gruppenmitglieder. Es gibt bewusst keine Gesamtnote."]
        = "Missing enchants, empty mandatory slots and sockets per slot. Addon users provide fresh self-reports; inspect remains the fallback for group members in range. There is deliberately no overall score.",
    ["Lokale Komfortoptionen und gildenweite Berechtigungen für Guild Copilot."]
        = "Local convenience options and guild-wide permissions for Guild Copilot.",
}

-- Entschieden wird einmal beim Laden: Die Clientsprache aendert sich nie
-- innerhalb einer Sitzung. Alles, was nicht Deutsch ist, bekommt Englisch -
-- eine franzoesische Uebersetzung gibt es nicht, und Englisch versteht dort
-- jeder eher als Deutsch. Das Feld bleibt zur Laufzeit umschaltbar, damit
-- die Tests beide Wege pruefen koennen.
local locale = type(GetLocale) == "function" and tostring(GetLocale() or "") or "deDE"
GC.LocaleEnglish = locale:find("^de") == nil

function GC.L(text)
    if not GC.LocaleEnglish or type(text) ~= "string" then
        return text
    end
    return english[text] or text
end

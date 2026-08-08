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

    -- === Teilschritt 2: Spielbegriffe ======================================
    -- Ausruestungsslots. Die englischen Begriffe sind die offiziellen
    -- Slot-Bezeichnungen, wie sie Wowheads Itemseiten fuehren (Head,
    -- Shoulder, Finger, Trinket, Main Hand, Off Hand, Ranged, ...) -
    -- abgeglichen am 08.08.2026, nichts frei uebersetzt.
    ["Kopf"] = "Head",
    ["Hals"] = "Neck",
    ["Schulter"] = "Shoulder",
    ["Brust"] = "Chest",
    ["Gürtel"] = "Waist",
    ["Beine"] = "Legs",
    ["Füße"] = "Feet",
    ["Handgelenke"] = "Wrist",
    ["Hände"] = "Hands",
    ["Ring 1"] = "Finger 1",
    ["Ring 2"] = "Finger 2",
    ["Schmuck 1"] = "Trinket 1",
    ["Schmuck 2"] = "Trinket 2",
    ["Rücken"] = "Back",
    ["Waffenhand"] = "Main Hand",
    ["Schildhand"] = "Off Hand",
    ["Distanz"] = "Ranged",
    ["alle Slots"] = "all slots",

    -- Bewertungsstufen und Verbrauchskategorien: eigenes Addon-Vokabular,
    -- keine Spielnamen ("Optimal" ist in beiden Sprachen dasselbe Wort).
    ["Solide"] = "Solid",
    ["Verbesserbar"] = "Improvable",
    ["Fehlt"] = "Missing",
    ["Unbekannt"] = "Unknown",
    ["Ausnahme"] = "Exempt",
    ["Tränke"] = "Potions",
    ["Runen"] = "Runes",
    ["Trommeln"] = "Drums",
    ["Fläschchen"] = "Flasks",
    ["Elixiere"] = "Elixirs",
    ["Essen"] = "Food",
    ["Öle/Steine"] = "Oils/Stones",

    -- === Teilschritt 3: Karten =============================================
    ["Aktive Raider  •  Level 70"] = "Active Raiders  •  Level 70",
    ["Aktuelle Abmeldungen"] = "Current Absences",
    ["Allgemein"] = "General",
    ["Ausgeblendete Spieler"] = "Hidden Players",
    ["Ausnahmen und Entscheidungen"] = "Exceptions and Decisions",
    ["Ausrüstung – Hintergrundabgleich"] = "Gear – Background Sync",
    ["Bewerberton hören"] = "Applicant Sound",
    ["Chat-Befehle"] = "Chat Commands",
    ["Dein Raidprofil"] = "Your Raid Profile",
    ["Deine Abmeldung"] = "Your Absence",
    ["Deine Ausrüstung"] = "Your Gear",
    ["Deine Berufe"] = "Your Professions",
    ["Deine Suche"] = "Your Search",
    ["Empfohlener Rekrutierungsbedarf"] = "Recommended Recruiting Needs",
    ["Erste Schritte"] = "Getting Started",
    ["Gefundene Rezepte"] = "Recipes Found",
    ["Geprüfte Spieler"] = "Audited Players",
    ["Gildenaufträge"] = "Guild Orders",
    ["Gildenquelle"] = "Guild Source",
    ["Import – manuell oder Installer"] = "Import – manual or installer",
    ["Interessenten"] = "Applicants",
    ["Kanäle"] = "Channels",
    ["Mitgliederpflege öffnen"] = "Open Member Care",
    ["Pflegevorschläge"] = "Care Suggestions",
    ["Postfach-Erkennung: eigene Wörter"] = "Inbox Detection: Custom Words",
    ["Prüfregeln"] = "Audit Rules",
    ["Rekrutierung: Meldungen & Töne"] = "Recruitment: Alerts & Sounds",
    ["Rezeptdetails"] = "Recipe Details",
    ["Sitzungen"] = "Sessions",
    ["Teilnehmer"] = "Participants",
    ["Texte & Eckdaten"] = "Texts & Key Facts",
    ["Unterhaltung"] = "Conversation",
    ["Vorlagen für Danke, Gildeninfos und Discord"] = "Templates for Thanks, Guild Info and Discord",
    ["Werbetext"] = "Ad Text",
    ["Werkstatt"] = "Workshop",

    -- === Teilschritt 3: Knöpfe =============================================
    ["(keiner)"] = "(none)",
    ["7 Tage ausblenden"] = "Hide for 7 days",
    ["Abbrechen"] = "Cancel",
    ["Abmelden"] = "Set absence",
    ["Abmeldung löschen"] = "Delete absence",
    ["Alle Prüfungen"] = "All audits",
    ["Alle anzeigen"] = "Show all",
    ["Alle löschen"] = "Delete all",
    ["Alles klar"] = "Got it",
    ["Als Vorlage merken"] = "Save as template",
    ["Anflüstern"] = "Whisper",
    ["Annehmen"] = "Accept",
    ["Antworten"] = "Reply",
    ["Anwesenheit"] = "Attendance",
    ["Aus"] = "Off",
    ["Aus Gilde erkennen"] = "Detect from guild",
    ["Ausrüstung prüfen"] = "Audit gear",
    ["Auswahl leeren"] = "Clear selection",
    ["Auswertung anfordern"] = "Request reviews",
    ["Bestätigen"] = "Confirm",
    ["Danke"] = "Thanks",
    ["Daten anfragen"] = "Request data",
    ["Daten importieren"] = "Import data",
    ["Dauerhaft ignorieren"] = "Ignore permanently",
    ["Detailfenster"] = "Detail window",
    ["Eigene Ausrüstung"] = "My gear",
    ["Einrichtung"] = "Setup",
    ["Entfernen"] = "Remove",
    ["Erledigt"] = "Done",
    ["Erneut prüfen"] = "Re-check",
    ["Erstellen"] = "Create",
    ["Favoriten"] = "Favorites",
    ["Ganze Klasse"] = "Whole class",
    ["Gezahlt melden"] = "Mark paid",
    ["Gilde"] = "Guild",
    ["Gildeninfos"] = "Guild info",
    ["Gildenprofil prüfen"] = "Review guild profile",
    ["Gruppe"] = "Group",
    ["Gruppe prüfen"] = "Check group",
    ["Guild Copilot öffnen"] = "Open Guild Copilot",
    ["Heute"] = "Today",
    ["In Auftrag geben"] = "Place order",
    ["In Gilde einladen"] = "Invite to guild",
    ["Katalog"] = "Catalog",
    ["Keiner"] = "None",
    ["Leeren"] = "Clear",
    ["Los geht's"] = "Let's go",
    ["Manuell auswählen"] = "Pick manually",
    ["Melden"] = "Report",
    ["Meldung testen"] = "Test alert",
    ["Merken"] = "Favorite",
    ["Gemerkt"] = "Favorited",
    ["Neu generieren"] = "Regenerate",
    ["Nicht gesetzt"] = "Not set",
    ["Nicht jetzt"] = "Not now",
    ["Nicht mehr anzeigen"] = "Don't show again",
    ["Notiz senden"] = "Send note",
    ["Position zurücksetzen"] = "Reset position",
    ["Profil bestätigen"] = "Confirm profile",
    ["Quelle speichern"] = "Save source",
    ["Rezept-Lücken der Gilde"] = "Guild recipe gaps",
    ["Roster aktualisieren"] = "Refresh roster",
    ["Ränge: alle"] = "Ranks: all",
    ["Schließen"] = "Close",
    ["Sitzung löschen"] = "Delete session",
    ["Sitzung starten"] = "Start session",
    ["Sitzung beenden"] = "End session",
    ["Sound testen"] = "Test sound",
    ["Speichern & weiter"] = "Save & continue",
    ["Später"] = "Later",
    ["Statistik"] = "Statistics",
    ["Suche starten"] = "Start search",
    ["Symbol zurück an die Minimap"] = "Icon back to the minimap",
    ["Text bestätigen"] = "Confirm text",
    ["Vergleich"] = "Compare",
    ["Verlauf"] = "History",
    ["Verzauberung bestellen"] = "Order enchant",
    ["Vorgabe eintragen"] = "Insert default",
    ["Vorgabe wiederherstellen"] = "Restore default",
    ["Vorlagen speichern"] = "Save templates",
    ["Vorschläge übernehmen"] = "Apply suggestions",
    ["Weiter"] = "Continue",
    ["Werbebalken"] = "Ad bar",
    ["Werbetext erstellen  >"] = "Create ad text  >",
    ["Wieder zulassen"] = "Allow again",
    ["Wirklich löschen?"] = "Really delete?",
    ["Wörter speichern"] = "Save words",
    ["Zur Gildenwerkstatt"] = "To the guild workshop",
    ["Zur Gruppe"] = "To the group",
    ["Zurück"] = "Back",
    ["Zurückholen"] = "Bring back",
    ["nur machbare"] = "only craftable",
    ["Überspringen"] = "Skip",

    -- === Teilschritt 3: Schalter ===========================================
    ["Automatisch wiederholen"] = "Auto-repeat",
    ["Erfolgssound aktiv"] = "Success sound on",
    ["Flexibel einsetzbar"] = "Flexible",
    ["Twink"] = "Alt",
    ["Minimap-Symbol anzeigen"] = "Show minimap icon",
    ["Vorhandene Verzauberung gilt als in Ordnung"] = "Existing enchant counts as fine",
    ["Whispers nur während einer Suche prüfen"] = "Check whispers only during a search",
    ["Öffentliche „Suche Gilde“-Nachrichten erkennen"] = "Detect public \"looking for guild\" messages",
    ["Abgelaufene Berufs-Wartezeiten im Chat melden"] = "Announce expired profession cooldowns in chat",
    ["Bildschirmmeldung bei neuen machbaren Aufträgen"] = "On-screen alert for new craftable orders",
    ["Flüsterbefehl beantworten: „!rezept <Suche>“"] = "Answer whisper command: \"!rezept <search>\"",

    -- === Teilschritt 3: Spaltenköpfe und Kurztexte =========================
    ["ZEIT"] = "TIME",
    ["WAS"] = "WHAT",
    ["ART"] = "TYPE",
    ["EMPFEHLUNG"] = "RECOMMENDATION",
    ["STUFE"] = "GRADE",
    ["ABENDE"] = "NIGHTS",
    ["ANTEIL"] = "SHARE",
    ["ZULETZT"] = "LAST",
    ["HINWEIS"] = "NOTE",
    ["SOCKEL"] = "SOCKETS",
    ["BEWERTUNG"] = "RATING",
    ["BEFUND"] = "FINDINGS",
    ["STAND"] = "AS OF",
    ["RANG"] = "RANK",
    ["ABGESCHLOSSEN"] = "COMPLETED",
    ["DU BIST DRAN"] = "YOUR TURN",
    ["VERZAUBERUNG & SOCKEL"] = "ENCHANT & SOCKETS",

    -- === Teilschritt 3: statische Meldungen und Zustände ===================
    ["Abgleich mit der Gilde"] = "Guild sync",
    ["Abmeldung abgelaufen – neu eintragen oder löschen."] = "Absence expired – re-enter or delete it.",
    ["Abmeldung gelöscht und mit der Gilde synchronisiert."] = "Absence deleted and synchronized with the guild.",
    ["Alle vier Listen stehen wieder auf der Vorgabe."] = "All four lists are back to the default.",
    ["Aus Warcraft Logs: exakte Gegenstände mit Anzahl - Uhrzeiten kennt der Export nicht."] = "From Warcraft Logs: exact items with counts - the export knows no timestamps.",
    ["Auswertung angefragt - warte auf Antworten …"] = "Reviews requested - waiting for answers …",
    ["Automatik aus: Gepostet wird nur noch per Klick."] = "Auto-repeat off: posting only by click now.",
    ["Automatik wartet auf einen bestätigten Text."] = "Auto-repeat is waiting for a confirmed text.",
    ["Automatik: kein ausgewählter Kanal beigetreten."] = "Auto-repeat: no selected channel joined.",
    ["Bitte Interessent und Antwort auswählen."] = "Please select an applicant and a reply.",
    ["Dein Gildenrang darf das Gildenprofil nicht bearbeiten."] = "Your guild rank may not edit the guild profile.",
    ["Dein Gildenrang darf den Rangschutz nicht ändern."] = "Your guild rank may not change rank protection.",
    ["Dein Gildenrang darf die Prüfregeln nicht ändern."] = "Your guild rank may not change the audit rules.",
    ["Dein Gildenrang darf die gildenweiten Vorlagen nicht bearbeiten."] = "Your guild rank may not edit the guild-wide templates.",
    ["Dein Gildenrang darf diese Berechtigung nicht ändern."] = "Your guild rank may not change this permission.",
    ["Dein Rang darf dieses gildenweite Profil bearbeiten."] = "Your rank may edit this guild-wide profile.",
    ["Dein eigener Rang wurde einmalig wieder freigeschaltet."] = "Your own rank has been unlocked once.",
    ["Den eigenen Rang kannst du nicht abwählen."] = "You cannot deselect your own rank.",
    ["Die Vorlagen sind für deinen Rang schreibgeschützt."] = "The templates are read-only for your rank.",
    ["Diese Quelle liefert nur Kategoriezähler ohne Einzelheiten."] = "This source provides only category counters without details.",
    ["Diesen Rang darf nur ein höherer Gildenrang abwählen."] = "Only a higher guild rank may deselect this rank.",
    ["Dieser Charakter ist eingerichtet."] = "This character is set up.",
    ["Ein Klick genügt – ändern kannst du alles jederzeit."] = "One click is enough – you can change everything later.",
    ["Ein leerer Werbetext kann nicht bestätigt werden."] = "An empty ad text cannot be confirmed.",
    ["Empfehlung des Regelsatzes"] = "Rule set recommendation",
    ["Erneut bestätigen"] = "Confirm again",
    ["Es gelten durchgehend deine eigenen Listen."] = "Your own lists apply throughout.",
    ["Favorisierte Rezepte"] = "Favorite recipes",
    ["Fertig – dieser Charakter ist eingerichtet."] = "Done – this character is set up.",
    ["Für Links zuerst unter Warcraft Logs die Gildenquelle speichern."] = "For links, save the guild source under Warcraft Logs first.",
    ["Für deinen Gildenrang gesperrt"] = "Locked for your guild rank",
    ["Für diese Sitzung wurden keine Teilnehmer erfasst."] = "No participants were recorded for this session.",
    ["Für diesen Teilnehmer wurde kein Verbrauch erfasst."] = "No consumables were recorded for this participant.",
    ["Geprüft wird von allein weiter – bei jedem Login und nach jedem Ausrüstungswechsel."] = "Auditing continues on its own – at every login and after every gear change.",
    ["Gespeichert und zur Gildensynchronisierung vorgemerkt."] = "Saved and queued for guild synchronization.",
    ["Gespeichert. Leere Trigger-Felder nutzen wieder die Vorgabe."] = "Saved. Empty trigger fields use the default again.",
    ["Gezielte Rezeptsuche"] = "Targeted recipe search",
    ["Gildenaufträge – du bist dran"] = "Guild orders – your turn",
    ["Gildenweite Änderungen sind für deinen Rang freigegeben."] = "Guild-wide changes are enabled for your rank.",
    ["Guild Copilot in der Gilde"] = "Guild Copilot in the guild",
    ["Kein Interessent ausgewählt."] = "No applicant selected.",
    ["Keine Abmeldung eingetragen."] = "No absence entered.",
    ["Keine Auswertung vorhanden. Auf der Seite Raidauswertung einen Abend wählen."] = "No review available. Pick a night on the Raid Review page.",
    ["Keine Favoriten gefunden"] = "No favorites found",
    ["Keine Mitglieder erfüllen die aktuellen Prüfregeln."] = "No members match the current audit rules.",
    ["Keine Reagenzien erfasst."] = "No reagents recorded.",
    ["Keine Talente erkannt – wähle deine Spec von Hand."] = "No talents detected – pick your spec by hand.",
    ["Keine Treffer"] = "No matches",
    ["Keine aktiven oder geplanten Abmeldungen bekannt."] = "No active or upcoming absences known.",
    ["Link aus Region, Realm und Gildenname vorbereitet."] = "Link prepared from region, realm and guild name.",
    ["Live mitgeschrieben: jeder gezählte Einwurf mit Uhrzeit."] = "Recorded live: every counted use with its time.",
    ["Löschen bestätigen"] = "Confirm delete",
    ["Mindestens ein Rang muss Zugriff auf die Mitgliederpflege behalten."] = "At least one rank must keep access to member care.",
    ["Mindestens ein berechtigter Rang muss erhalten bleiben."] = "At least one authorized rank must remain.",
    ["Nachgesehen: Dieser Charakter hat keinen Hauptberuf erlernt."] = "Checked: this character has not learned a primary profession.",
    ["Nicht installiert"] = "Not installed",
    ["Niemand ausgeblendet."] = "Nobody hidden.",
    ["Noch keine Interessenten"] = "No applicants yet",
    ["Noch nicht abgefragt"] = "Not queried yet",
    ["Noch nicht bestätigt."] = "Not confirmed yet.",
    ["Noch nicht eingelesen"] = "Not read yet",
    ["Nur Vorschläge – keine automatische Entfernung."] = "Suggestions only – no automatic removal.",
    ["Nur freigegebene Gildenränge dürfen den Bewerberton umstellen."] = "Only enabled guild ranks may change the applicant sound.",
    ["Nur in Einstellungen freigegebene Gildenränge dürfen Änderungen speichern."] = "Only guild ranks enabled in the settings may save changes.",
    ["Offene Schritte warten in der Checkliste oben auf der Profilseite – ganz ohne Eile."] = "Open steps wait in the checklist at the top of the profile page – no rush.",
    ["Postfach vollständig geleert."] = "Inbox completely cleared.",
    ["Prüfe den Suchbegriff oder frage aktuelle Gildendaten an."] = "Check the search term or request fresh guild data.",
    ["Prüfregeln sind für deinen Rang schreibgeschützt."] = "Audit rules are read-only for your rank.",
    ["Raid-Symbol geändert. Bitte den Text erneut bestätigen."] = "Raid marker changed. Please confirm the text again.",
    ["Regeln werden gildenweit synchronisiert."] = "Rules are synchronized guild-wide.",
    ["Rezepte eingelesen – ein Klick öffnet das Fenster erneut"] = "Recipes read – one click opens the window again",
    ["Roster aktuell"] = "Roster up to date",
    ["Roster wird neu abgefragt …"] = "Refreshing roster …",
    ["Sammelberuf ohne Rezepte – nichts einzulesen"] = "Gathering profession without recipes – nothing to read",
    ["Sicher?"] = "Sure?",
    ["Stand des Gildenabgleichs"] = "Guild sync status",
    ["Starte eine Suche. Eingehende Flüsternachrichten erscheinen automatisch hier."] = "Start a search. Incoming whispers appear here automatically.",
    ["Suchergebnisse"] = "Search results",
    ["Vorgabe eingetragen – jetzt bearbeiten und speichern."] = "Default inserted – now edit and save.",
    ["Vorlagen gespeichert und für die Gilde synchronisiert."] = "Templates saved and synchronized for the guild.",
    ["Warte auf Antwort …"] = "Waiting for a reply …",
    ["Werbetext bestätigt und bereit."] = "Ad text confirmed and ready.",
    ["Wirklich ersetzen"] = "Really replace",
    ["Wonach suchst du?"] = "What are you looking for?",
    ["Wähle links eine Sitzung aus."] = "Pick a session on the left.",
    ["dauerhaft ignoriert"] = "permanently ignored",
    ["ganze Klasse"] = "whole class",
    ["|cff59e695Alle Materialien vorhanden.|r"] = "|cff59e695All materials available.|r",
    ["|cff59e695Keine automatische Lücke erkannt.|r Du kannst trotzdem Klassen und Specs manuell wählen."] = "|cff59e695No automatic gap detected.|r You can still pick classes and specs manually.",
    ["|cff59e695Workflow bereit:|r Vorschläge übernehmen, Auswahl prüfen und anschließend den Werbetext bestätigen."] = "|cff59e695Workflow ready:|r apply the suggestions, check the selection, then confirm the ad text.",
    ["|cff8b98a5• kein anderer Nutzer erkannt|r"] = "|cff8b98a5• no other user detected|r",
    ["|cff91a3b8Die Prüfung läuft gerade im Hintergrund – das Ergebnis erscheint hier.|r"] = "|cff91a3b8The audit is running in the background – results appear here.|r",
    ["|cffff6266• Abgleich unvollständig|r"] = "|cffff6266• sync incomplete|r",
    ["|cffffb840Kein bestätigter Text. Unter „Werbung posten“ bestätigen.|r"] = "|cffffb840No confirmed text. Confirm it under Post Ad.|r",
    ["|cffffb84dDatenlage noch dünn:|r Mehr Mitglieder sollten ihr Profil bestätigen oder Logs importiert werden."] = "|cffffb84dData still thin:|r more members should confirm their profile, or import logs.",
    ["„Zur Gruppe“ führt zurück zur Übersicht."] = "\"To the group\" leads back to the overview.",
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

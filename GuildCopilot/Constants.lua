local _, GC = ...

GC.Constants = {
    ADDON_NAME = "Guild Copilot",
    VERSION = "0.9.95",
    SCHEMA_VERSION = 7,
    -- Wie eine Zahl der Raidauswertung ZU LESEN ist. Nicht zu verwechseln mit
    -- SCHEMA_VERSION: Die beschreibt das Nachrichtenformat, also ob zwei
    -- Clients einander verstehen. Diese hier beschreibt, ob zwei Zahlen
    -- dasselbe bedeuten - und nur dann duerfen sie miteinander verrechnet
    -- werden.
    --
    -- Sie steigt bei jeder Aenderung an der Bedeutung, auch wenn das Format
    -- gleich bleibt:
    --   1  bis 0.9.86 - Trommeln wurden jedem Beschenkten gutgeschrieben,
    --      Traenke mit Buff zaehlten doppelt, Dauerbuffs je Abend nur einmal.
    --   2  ab 0.9.89 - Zaehlung je Kategorie ueber genau eine Quelle (0.9.87)
    --      und Anwesenheit ohne Offlinezeit (0.9.88).
    --
    -- Wozu: Ein Mitschnitt aus einer anderen Regelversion darf beim Reparieren
    -- einer eigenen Luecke NICHT eingerechnet werden. Der Hoechstwert wuerde
    -- sonst genau die kaputten Zaehler eines alten Clients uebernehmen - im
    -- Vergleichslog vom 02.08.2026 waren das 68 Trommeln statt 28. Solche
    -- Auswertungen bleiben sichtbar nebeneinander stehen, statt verrechnet zu
    -- werden.
    RAID_RULES_VERSION = 2,
    INTERFACE_VERSION = 20506,
    COMM_PREFIX = "GuildCopilot",
    MAX_CHAT_BYTES = 255,
    -- Das Gildenprofil wandert zerlegt durch den Gildenkanal. Sender und
    -- Empfaenger MUESSEN dieselbe Obergrenze kennen: Bisher schnitt der Sender
    -- unbegrenzt viele Bloecke, waehrend der Empfaenger jede Uebertragung mit
    -- mehr als 30 Bloecken verwarf. Alles ueber 5250 Bytes verschwand damit
    -- ohne eine einzige Meldung - und allein die Spec-Verzauberungsregeln
    -- duerfen schon rund 4300 Bytes gross werden.
    GUILD_PROFILE_CHUNK_BYTES = 175,
    GUILD_PROFILE_MAX_CHUNKS = 150,
    -- Warcraft-Logs-Host, wenn die gespeicherte Gildenquelle keinen eigenen
    -- nennt. Die deutsche Variante ist Vorgabe, weil das Addon deutschsprachig
    -- ist; ein selbst eingetragener Host bleibt immer erhalten.
    WCL_DEFAULT_HOST = "de.fresh.warcraftlogs.com",
    -- Profil-Links zum Nachschlagen eines Interessenten. Beide Vorlagen
    -- verstehen die Platzhalter <host>, <region>, <realm> und <name>. Wer eine
    -- andere Seite bevorzugt oder ein Pfadschema sich aendert, tauscht nur
    -- diese Zeichenketten.
    -- Classic Armory fuehrt die Spielfassung als eigenes Pfadsegment; dieses
    -- Addon ist ausschliesslich fuer TBC Anniversary gedacht.
    ARMORY_CHARACTER_URL = "https://classic-armory.org/character/<region>/tbc-anniversary/<realm>/<name>",
    WCL_CHARACTER_URL = "https://<host>/character/<region>/<realm>/<name>",
    -- Wie viele aktive Raider die Gildenuebersicht fuehrt. 25 war exakt die
    -- Groesse eines Schlachtzugs und damit zu knapp: Ersatzleute, Twinks und
    -- gerade offline gegangene Stammspieler fielen hinten heraus, und die Liste
    -- sah kleiner aus als die Gilde ist. 35 laesst zehn Plaetze Puffer.
    ACTIVE_RAIDER_LIMIT = 35,
    ADDON_USER_TTL = 30 * 24 * 60 * 60,
    DEFAULT_POST_COOLDOWN = 120,
    DEFAULT_LFG_COOLDOWN = 120,
}

-- Fähigkeiten, die dieser Client im Handshake meldet. Neue Module tragen sich
-- hier ein, damit spätere Versionen erkennen können, was das Gegenüber kann,
-- ohne die Schemaversion anheben zu müssen.
GC.Capabilities = {
    "profile",
    "guildprofile",
    "workshop",
    "workshop2",
    "workshop3",
    -- workshop4: getrennter Rezeptkatalog und Herstellerindex. Wer das meldet,
    -- versteht Schluessellisten und braucht keine Vollkopie aller Rezepte.
    "workshop4",
    "recruitmentsync",
    "membercare",
    "raidmonitor",
    "gearaudit",
    "gearsync",
    "wclimport",
    -- inventory1: Materialbestand und Gildenbank-Abgleich ueber "B|".
    "inventory1",
    -- gearexempt1: versteht ausgenommene Ausruestungsplaetze im Snapshot.
    "gearexempt1",
}

GC.ProfessionOptions = {
    "",
    "Alchimie",
    "Bergbau",
    "Ingenieurskunst",
    "Juwelenschleifen",
    "Kräuterkunde",
    "Kürschnerei",
    "Lederverarbeitung",
    "Schmiedekunst",
    "Schneiderei",
    "Verzauberkunst",
}

GC.ProfessionIcons = {
    [""] = "Interface\\Icons\\INV_Misc_Book_09",
    ["Alchimie"] = "Interface\\Icons\\Trade_Alchemy",
    ["Alchemie"] = "Interface\\Icons\\Trade_Alchemy",
    ["Bergbau"] = "Interface\\Icons\\Trade_Mining",
    ["Ingenieurskunst"] = "Interface\\Icons\\Trade_Engineering",
    ["Juwelenschleifen"] = "Interface\\Icons\\INV_Misc_Gem_01",
    ["Kräuterkunde"] = "Interface\\Icons\\Spell_Nature_NatureTouchGrow",
    ["Kürschnerei"] = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
    ["Lederverarbeitung"] = "Interface\\Icons\\Trade_LeatherWorking",
    ["Schmiedekunst"] = "Interface\\Icons\\Trade_BlackSmithing",
    ["Schneiderei"] = "Interface\\Icons\\Trade_Tailoring",
    ["Verzauberkunst"] = "Interface\\Icons\\Trade_Engraving",
    ["Kochkunst"] = "Interface\\Icons\\INV_Misc_Food_15",
    ["Erste Hilfe"] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
}

GC.SuccessSoundOptions = {
    { key = "READY_CHECK", name = "Bereitschaftscheck", soundID = 8960 },
    { key = "GROUP_FINDER", name = "Gruppensuche", soundID = 3081 },
    { key = "RAID_WARNING", name = "Raidwarnung", soundID = 8959 },
    { key = "IG_QUEST_LIST_COMPLETE", name = "Quest abgeschlossen", soundID = 619 },
    -- Der kurze Quest-Annahme-Klang; fehlt der Schluessel im SOUNDKIT der
    -- Spielfassung, greift die nackte Zahl.
    { key = "IG_QUEST_ACTIVATE", name = "Quest angenommen", soundID = 618 },
    { key = "MAP_PING", name = "Karten-Ping", soundID = 3175 },
    -- SoundKit 888 heisst in Classic "LEVELUP". Der Schluessel steht wie bei
    -- den anderen Eintraegen zuerst; fehlt er im SOUNDKIT der Spielfassung,
    -- greift die nackte Zahl.
    { key = "LEVEL_UP", name = "Stufenaufstieg", soundID = 888 },
}

-- Vorgabe fuer die eigene Profilbestaetigung. Bewusst ein anderer Ton als der
-- Bewerberklang: Der eine meldet einen fremden Interessenten, der andere
-- bestaetigt die eigene Eingabe.
GC.DefaultProfileSoundKey = "LEVEL_UP"

-- Woran ein Bewerber erkannt wird. Beide Listen sind Vorgaben und in den
-- Einstellungen ueberschreibbar; sie stehen hier, damit ein geleertes
-- Eingabefeld wieder auf diesen Stand zurueckfaellt.
--
-- Oeffentliche Chatnachrichten und Fluesternachrichten bleiben absichtlich
-- getrennt: Ein zu weiter Whisper-Trigger nervt nur einen selbst, ein zu
-- weiter Chat-Trigger erzeugt Muell aus dem ganzen Realm. Deshalb ist die
-- oeffentliche Liste eng und aus ganzen Wendungen gebaut, die Whisper-Liste
-- darf einzelne Woerter enthalten.
GC.DefaultChatTriggers = {
    "suche eine gilde",
    "suche gilde",
    "gilde gesucht",
    "gildensuche",
    "lf guild",
    "looking for a guild",
    "looking for guild",
}

GC.DefaultWhisperTriggers = {
    "interesse",
    "interessiert",
    "gilde",
    "guild",
    "bewerb",
    "rekrut",
    "raidplatz",
    "raid platz",
    "mehr info",
    "mehr infos",
    "discord",
    "sucht ihr",
    "mitmachen",
    "anschließen",
    "anschliessen",
}

-- Ausschlusswoerter haben bewusst keine Vorgabe: Was Muell ist, weiss nur der
-- eigene Realm. Eine mitgelieferte Liste wuerde Eintraege verhindern, die
-- jemand anders ausdruecklich haben will.
GC.MaxRecruitmentFilterWords = 40

-- Verbrauchsgegenstände werden nach Spell-ID gezählt. Gezählt wird der
-- VERBRAUCH, nicht der Besitz: Wer dreimal Buffood isst, steht mit drei
-- Essen da, wer zwei Fläschchen leert, mit zwei.
--
-- "track" entscheidet, welches Kampfereignis zählt - und daran hing der
-- größte Teil der falschen Zahlen:
--
--   CAST  Der Gegenstand wird benutzt und erzeugt ein Wirkereignis beim
--         Benutzer. Nur das zählt, der daraus entstehende Buff wird
--         ignoriert. Sonst bekäme jedes Gruppenmitglied eine Trommel
--         gutgeschrieben, die der Trommler geworfen hat, und ein Hasttrank
--         zählte doppelt (einmal als Zauber, einmal als eigene Aura).
--   AURA  Der Gegenstand erzeugt gar kein Wirkereignis, nur eine Aura beim
--         Beschenkten. Das trifft auf "Sattgegessen" zu: Gegessen wird,
--         der Buff erscheint Sekunden später, einen Zauber gibt es nie.
--
-- "scan" markiert die dauerhaften Buffs, die zu Sitzungsbeginn - und wenn
-- jemand später dazustößt - einmal von den Anwesenden abgelesen werden.
-- Fläschchen, Elixiere und Essen kommen vor dem Raid auf den Charakter, oft
-- lange vor dem ersten Pull. Ohne diese Momentaufnahme steht dort dauerhaft
-- eine Null, obwohl der Raid vollständig gebufft antritt.
GC.ConsumableCategories = {
    { key = "POTION", label = "Tränke", track = "CAST" },
    { key = "RUNE", label = "Runen", track = "CAST" },
    { key = "DRUM", label = "Trommeln", track = "CAST" },
    { key = "FLASK", label = "Fläschchen", track = "CAST", scan = true },
    { key = "ELIXIR", label = "Elixiere", track = "CAST", scan = true },
    { key = "FOOD", label = "Essen", track = "AURA", scan = true },
    { key = "OIL", label = "Öle/Steine", track = "CAST" },
}

GC.ConsumableCategoryByKey = {}
for index, category in ipairs(GC.ConsumableCategories) do
    category.index = index
    GC.ConsumableCategoryByKey[category.key] = category
end

-- Ausgangsbestand gebräuchlicher TBC-Verbrauchsgegenstände. Die Liste ist
-- bewusst erweiterbar gehalten: unbekannte Spell-IDs werden schlicht nicht
-- gezählt, es entstehen also keine falschen Zahlen, sondern nur unvollständige.
-- Vor dem Scharfschalten gegen echte Logs abgleichen.
GC.Consumables = {
    -- Namen wie im deutschen Client (Owner-Korrektur): "Super" heißt dort
    -- "Erstklassig", die Major-Elixiere heißen "übermächtig".
    [28495] = { category = "POTION", name = "Erstklassiger Heiltrank" },
    [28499] = { category = "POTION", name = "Erstklassiger Manatrank" },
    [28507] = { category = "POTION", name = "Hasttrank" },
    [28508] = { category = "POTION", name = "Zerstörungstrank" },
    [28494] = { category = "POTION", name = "Trank der irren Stärke" },
    [28506] = { category = "POTION", name = "Heldentrank" },
    -- 28511 und 28512 trugen bis 0.9.86 die Namen "Heldentrank" und
    -- "Eisenschildtrank". Beide waren falsch: es sind die Schutztränke, und
    -- der echte Heldentrank (28506) fehlte deshalb ganz.
    [28511] = { category = "POTION", name = "Großer Feuerschutztrank" },
    [28512] = { category = "POTION", name = "Großer Frostschutztrank" },
    [38908] = { category = "POTION", name = "Teufelsmanatrank" },
    -- Die Salben und Flaschen aus Zangarmarschen und Netherstrum. Sie sind in
    -- TBC der meistbenutzte Manatrank überhaupt und fehlten bis 0.9.86
    -- komplett - im Vergleichslog vom 02.08.2026 kamen allein auf sie 146
    -- Anwendungen, während die Spalte "Tränke" bei den Betroffenen auf null
    -- stand.
    [41617] = { category = "POTION", name = "Manatrank (Cenarische Salbe)" },
    [41618] = { category = "POTION", name = "Manatrank (Nethergonenergie)" },
    [41619] = { category = "POTION", name = "Heiltrank (Cenarische Salbe)" },
    [41620] = { category = "POTION", name = "Heiltrank (Nethergondampf)" },
    [16666] = { category = "RUNE", name = "Dämonische Rune" },
    [27869] = { category = "RUNE", name = "Dunkle Rune" },
    [35476] = { category = "DRUM", name = "Trommeln der Schlacht" },
    [35475] = { category = "DRUM", name = "Trommeln des Krieges" },
    [35478] = { category = "DRUM", name = "Trommeln der Wiederherstellung" },
    [35477] = { category = "DRUM", name = "Trommeln der Schnelligkeit" },
    [35474] = { category = "DRUM", name = "Trommeln der Panik" },
    [28518] = { category = "FLASK", name = "Fläschchen der Festigung" },
    [28519] = { category = "FLASK", name = "Fläschchen der mächtigen Wiederherstellung" },
    [28520] = { category = "FLASK", name = "Fläschchen des unerbittlichen Angriffs" },
    [28521] = { category = "FLASK", name = "Fläschchen des blendenden Lichts" },
    [28540] = { category = "FLASK", name = "Fläschchen des reinen Todes" },
    [28490] = { category = "ELIXIR", name = "Elixier der übermächtigen Stärke" },
    [28497] = { category = "ELIXIR", name = "Elixier der übermächtigen Beweglichkeit" },
    [28491] = { category = "ELIXIR", name = "Elixier der Heilkraft" },
    [28493] = { category = "ELIXIR", name = "Elixier der übermächtigen Frostmacht" },
    [28501] = { category = "ELIXIR", name = "Elixier der übermächtigen Feuermacht" },
    [28502] = { category = "ELIXIR", name = "Elixier der übermächtigen Verteidigung" },
    [28503] = { category = "ELIXIR", name = "Elixier der übermächtigen Schattenmacht" },
    [28509] = { category = "ELIXIR", name = "Elixier des übermächtigen Magierbluts" },
    [39625] = { category = "ELIXIR", name = "Elixier der übermächtigen Seelenstärke" },
    [39627] = { category = "ELIXIR", name = "Elixier der draenischen Weisheit" },
    -- Aus dem Vergleichslog vom 02.08.2026 nachgetragen: drei gebräuchliche
    -- Elixiere, die die Liste nicht kannte.
    [17539] = { category = "ELIXIR", name = "Großes Arkanelixier" },
    [33720] = { category = "ELIXIR", name = "Elixier des Ansturms" },
    [33721] = { category = "ELIXIR", name = "Elixier des Adepten" },
    [28017] = { category = "OIL", name = "Überragendes Zauberöl" },
    [28019] = { category = "OIL", name = "Überragendes Manaöl" },

    -- === Essen ==============================================================
    --
    -- Alle Sattgegessen-Buffs heissen im Spiel gleich, tragen aber je Gericht
    -- eine eigene Spell-ID. Live erkennt das Addon sie deshalb zusaetzlich am
    -- Auranamen ("Sattgegessen"/"Well Fed"); aus Warcraft Logs kommen nur IDs,
    -- und ohne diese Liste blieb Essen dort dauerhaft bei null.
    --
    -- Aufgenommen sind nur Buffs, die wirklich Werte geben. Bewusst draussen:
    -- die "Food"-Auren (blosse Lebensregeneration waehrend des Essens, z. B.
    -- 33258, 33262, 33264, 33266), die reine Regenerationsvariante 33269 und
    -- das Tierfutter 33272 (+10 Zufriedenheit) - letzteres beglueckt das
    -- Jaegertier, nicht den Raidteilnehmer.
    [33254] = { category = "FOOD", name = "Sattgegessen (+20 Ausdauer)" },
    [33256] = { category = "FOOD", name = "Sattgegessen (+20 Stärke)" },
    [33257] = { category = "FOOD", name = "Sattgegessen (+30 Ausdauer)" },
    [33259] = { category = "FOOD", name = "Sattgegessen (+40 Angriffskraft)" },
    [33261] = { category = "FOOD", name = "Sattgegessen (+20 Beweglichkeit)" },
    [33263] = { category = "FOOD", name = "Sattgegessen (+23 Zaubermacht)" },
    [33265] = { category = "FOOD", name = "Sattgegessen (+20 Ausdauer, +8 Mana/5s)" },
    [33268] = { category = "FOOD", name = "Sattgegessen (+44 Heilung)" },
    [43764] = { category = "FOOD", name = "Sattgegessen (+20 Trefferwertung)" },
    [45245] = { category = "FOOD", name = "Sattgegessen (+20 Ausdauer, +20 Willenskraft)" },
}

-- Bosse der TBC-Schlachtzuege.
--
-- Wozu: Ohne Encounter-API benennt der Raidmonitor einen Kampfabschnitt nach
-- dem zuletzt gestorbenen Gegner. Bei einem Wipe stirbt der Boss aber gerade
-- nicht - der Versuch hiess dann "Kampf" oder trug den Namen eines Adds.
-- Genau die Wipes sind aber das, was man hinterher ansehen will.
--
-- Erkannt wird ueber den **Eigennamen**, nicht ueber den vollen Titel: "Prinz
-- Malchezaar" und "Prince Malchezaar" enthalten beide "Malchezaar". Damit
-- funktioniert die Liste auf einem deutschen wie auf einem englischen Client,
-- ohne dass fuer jeden Boss eine belegte Uebersetzung noetig waere - die liess
-- sich naemlich nicht zuverlaessig beschaffen.
--
-- Wo ein Boss keinen Eigennamen hat (Der Kurator, Maid der Tugend), stehen
-- beide Sprachfassungen. Trifft nichts davon, bleibt es bei der bisherigen
-- Heuristik: Es geht nichts verloren, es wird nur nichts gewonnen.
GC.RaidBosses = {
    { instance = "Karazhan", names = { "Attumen", "Midnight" } },
    { instance = "Karazhan", names = { "Moroes" } },
    { instance = "Karazhan", names = { "Maid der Tugend", "Maiden of Virtue" } },
    { instance = "Karazhan", names = { "Dorothee", "Tito", "Roar", "Strohmann", "Strawman",
        "Tinhead", "Blechkopf", "Kruschik", "Der Große, Böse Wolf", "The Big Bad Wolf",
        "Romulo", "Julianne" } },
    { instance = "Karazhan", names = { "Der Kurator", "The Curator" } },
    { instance = "Karazhan", names = { "Terestian" } },
    { instance = "Karazhan", names = { "Aran" } },
    { instance = "Karazhan", names = { "Netherspite" } },
    { instance = "Karazhan", names = { "Malchezaar" } },
    { instance = "Karazhan", names = { "Nachtbann", "Nightbane" } },

    { instance = "Gruuls Unterschlupf", names = { "Maulgar" } },
    { instance = "Gruuls Unterschlupf", names = { "Gruul" } },

    { instance = "Magtheridons Kammer", names = { "Magtheridon" } },

    { instance = "Serpentinhöhle", names = { "Hydross" } },
    { instance = "Serpentinhöhle", names = { "Lurker", "Lauerer" } },
    { instance = "Serpentinhöhle", names = { "Leotheras" } },
    { instance = "Serpentinhöhle", names = { "Karathress" } },
    { instance = "Serpentinhöhle", names = { "Morogrim" } },
    { instance = "Serpentinhöhle", names = { "Vashj" } },

    { instance = "Auge", names = { "Al'ar" } },
    { instance = "Auge", names = { "Solarian" } },
    { instance = "Auge", names = { "Void Reaver", "Leerenschinder" } },
    { instance = "Auge", names = { "Kael'thas" } },

    { instance = "Zul'Aman", names = { "Nalorakk" } },
    { instance = "Zul'Aman", names = { "Akil'zon" } },
    { instance = "Zul'Aman", names = { "Jan'alai" } },
    { instance = "Zul'Aman", names = { "Halazzi" } },
    { instance = "Zul'Aman", names = { "Malacrass" } },
    { instance = "Zul'Aman", names = { "Zul'jin" } },

    { instance = "Hyjal", names = { "Winterchill" } },
    { instance = "Hyjal", names = { "Anetheron" } },
    { instance = "Hyjal", names = { "Kaz'rogal" } },
    { instance = "Hyjal", names = { "Azgalor" } },
    { instance = "Hyjal", names = { "Archimonde" } },

    { instance = "Schwarzer Tempel", names = { "Naj'entus" } },
    { instance = "Schwarzer Tempel", names = { "Supremus" } },
    { instance = "Schwarzer Tempel", names = { "Akama" } },
    { instance = "Schwarzer Tempel", names = { "Teron" } },
    { instance = "Schwarzer Tempel", names = { "Gurtogg" } },
    { instance = "Schwarzer Tempel", names = { "Reliquiar der Seelen", "Reliquary of Souls" } },
    { instance = "Schwarzer Tempel", names = { "Shahraz" } },
    { instance = "Schwarzer Tempel", names = { "Illidari", "Veras", "Zerevor", "Malande", "Gathios" } },
    { instance = "Schwarzer Tempel", names = { "Illidan" } },

    { instance = "Sonnenbrunnen", names = { "Kalecgos", "Sathrovarr" } },
    { instance = "Sonnenbrunnen", names = { "Sacrolash", "Alythess" } },
    { instance = "Sonnenbrunnen", names = { "Felmyst" } },
    { instance = "Sonnenbrunnen", names = { "Muru", "Entropius" } },
    { instance = "Sonnenbrunnen", names = { "Kil'jaeden" } },
}

-- Ausrüstungsslots für den Gear Audit. "enchantRequired" markiert nur Slots,
-- die in TBC jede Raidklasse verzaubern kann. Ringe (nur Verzauberer),
-- Schildhand (nur Schilde) und Distanz (nur Schusswaffen) sind bewusst nicht
-- eingefordert, damit keine falschen Fehlmeldungen entstehen.
GC.GearSlots = {
    { id = 1, key = "HEAD", label = "Kopf", enchantRequired = true },
    { id = 2, key = "NECK", label = "Hals" },
    { id = 3, key = "SHOULDER", label = "Schulter", enchantRequired = true },
    { id = 5, key = "CHEST", label = "Brust", enchantRequired = true },
    { id = 6, key = "WAIST", label = "Gürtel" },
    { id = 7, key = "LEGS", label = "Beine", enchantRequired = true },
    { id = 8, key = "FEET", label = "Füße", enchantRequired = true },
    { id = 9, key = "WRIST", label = "Handgelenke", enchantRequired = true },
    { id = 10, key = "HANDS", label = "Hände", enchantRequired = true },
    { id = 11, key = "FINGER1", label = "Ring 1" },
    { id = 12, key = "FINGER2", label = "Ring 2" },
    { id = 13, key = "TRINKET1", label = "Schmuck 1" },
    { id = 14, key = "TRINKET2", label = "Schmuck 2" },
    { id = 15, key = "BACK", label = "Rücken", enchantRequired = true },
    { id = 16, key = "MAINHAND", label = "Waffenhand", enchantRequired = true },
    { id = 17, key = "OFFHAND", label = "Schildhand" },
    { id = 18, key = "RANGED", label = "Distanz" },
}

GC.GearVerdicts = {
    OPTIMAL = { key = "OPTIMAL", label = "Optimal", order = 1 },
    SOLID = { key = "SOLID", label = "Solide", order = 2 },
    IMPROVABLE = { key = "IMPROVABLE", label = "Verbesserbar", order = 3 },
    MISSING = { key = "MISSING", label = "Fehlt", order = 4 },
    UNKNOWN = { key = "UNKNOWN", label = "Unbekannt", order = 5 },
    -- Ausdrueckliche Ausnahme: Farmgear, Widerstandsset oder ein besonderes
    -- Encounter-Set. Der Slot wird weiter angezeigt, zaehlt aber nicht als Fund.
    EXEMPT = { key = "EXEMPT", label = "Ausnahme", order = 6 },
}

-- Gruende, aus denen ein Slot von der Pruefung ausgenommen wird. Sie stehen
-- als Text im Tooltip, damit eine Ausnahme nachvollziehbar bleibt und nicht
-- wie ein stiller Trick wirkt.
GC.GearExemptionReasons = {
    { key = "FARM", label = "Farmgear", help = "Ausrüstung außerhalb des Raids." },
    { key = "RESIST", label = "Widerstandsset", help = "Widerstandsteil für einen bestimmten Kampf." },
    { key = "ENCOUNTER", label = "Encounter-Set", help = "Sonderausrüstung für einen Bosskampf." },
}

GC.GearExemptionReasonByKey = {}
for _, reason in ipairs(GC.GearExemptionReasons) do
    GC.GearExemptionReasonByKey[reason.key] = reason
end

-- Spielarchetypen für die Bewertung von Verzauberungen.
--
-- Die Rolle (TANK/HEALER/DAMAGER) ist dafür zu grob: Ein Schattenpriester und
-- ein Schurke sind beide DAMAGER, brauchen aber völlig andere Verzauberungen.
-- Der Archetyp trennt genau dort, wo sich die Empfehlungen unterscheiden.
--
-- Jäger stehen bewusst bei den physischen Damage-Dealern: Sie verzaubern ihre
-- Rüstung mit denselben Beweglichkeits- und Angriffskraftwerten wie Schurken.
GC.EnchantArchetypes = {
    CASTER_DPS = { key = "CASTER_DPS", label = "Zauber-Schaden" },
    HEALER = { key = "HEALER", label = "Heilung" },
    PHYSICAL_DPS = { key = "PHYSICAL_DPS", label = "Physischer Schaden" },
    TANK = { key = "TANK", label = "Tank" },
}

-- Welche Archetypen zu einer Spec gehören. Wildheit steht in beiden Listen,
-- weil derselbe Druide als Katze und als Bär spielt - eine Verzauberung, die
-- für einen von beiden taugt, ist für ihn deshalb nie "falsch".
GC.SpecArchetypes = {
    ["WARRIOR:1"] = { "PHYSICAL_DPS" },
    ["WARRIOR:2"] = { "PHYSICAL_DPS" },
    ["WARRIOR:3"] = { "TANK" },
    ["PALADIN:1"] = { "HEALER" },
    -- Schutz-Paladine verzaubern auf Zaubermacht, weil ihre Bedrohung daran
    -- haengt: Die BiS-Liste nennt Glyphe der Macht, Grosse Zaubermacht auf den
    -- Handschuhen und den Runenzauberfaden. Ohne den zweiten Archetyp wuerde
    -- der Audit genau die empfohlene Ausruestung nicht wiedererkennen.
    ["PALADIN:2"] = { "TANK", "CASTER_DPS" },
    ["PALADIN:3"] = { "PHYSICAL_DPS" },
    ["HUNTER:1"] = { "PHYSICAL_DPS" },
    ["HUNTER:2"] = { "PHYSICAL_DPS" },
    ["HUNTER:3"] = { "PHYSICAL_DPS" },
    ["ROGUE:1"] = { "PHYSICAL_DPS" },
    ["ROGUE:2"] = { "PHYSICAL_DPS" },
    ["ROGUE:3"] = { "PHYSICAL_DPS" },
    ["PRIEST:1"] = { "HEALER" },
    ["PRIEST:2"] = { "HEALER" },
    ["PRIEST:3"] = { "CASTER_DPS" },
    ["SHAMAN:1"] = { "CASTER_DPS" },
    ["SHAMAN:2"] = { "PHYSICAL_DPS" },
    ["SHAMAN:3"] = { "HEALER" },
    ["MAGE:1"] = { "CASTER_DPS" },
    ["MAGE:2"] = { "CASTER_DPS" },
    ["MAGE:3"] = { "CASTER_DPS" },
    ["WARLOCK:1"] = { "CASTER_DPS" },
    ["WARLOCK:2"] = { "CASTER_DPS" },
    ["WARLOCK:3"] = { "CASTER_DPS" },
    ["DRUID:1"] = { "CASTER_DPS" },
    ["DRUID:2"] = { "PHYSICAL_DPS", "TANK" },
    ["DRUID:3"] = { "HEALER" },
}

-- Content-Phasen von TBC. Der Regelsatz nennt je Regel die Phase, ab der eine
-- Verzauberung überhaupt zu haben ist; die Gilde stellt ihre laufende Phase in
-- den Einstellungen ein. Eine Verzauberung aus einer späteren Phase wird
-- deshalb nie eingefordert, solange die Gilde noch nicht so weit ist.
GC.ContentPhases = {
    { key = "T4", label = "T4 – Karazhan, Gruul, Magtheridon", order = 1 },
    { key = "T5", label = "T5 – Serpentinhöhle, Auge", order = 2 },
    { key = "T6", label = "T6 – Hyjal, Schwarzer Tempel", order = 3 },
    { key = "T6.5", label = "T6.5 – Sonnenbrunnen", order = 4 },
}

GC.ContentPhaseByKey = {}
for _, phase in ipairs(GC.ContentPhases) do
    GC.ContentPhaseByKey[phase.key] = phase
end

GC.DefaultContentPhase = "T5"

-- Versionierte Regeln für die Bewertung vorhandener Verzauberungen.
--
-- Format je Eintrag:
--   [enchantID] = {
--       verdict    = "OPTIMAL" | "SOLID" | "IMPROVABLE",
--       name       = "Anzeigename der Verzauberung",
--       slots      = { "HANDS", "BACK" },      -- optional, sonst für alle Slots
--       roles      = { "TANK", "HEALER" },     -- optional, sonst für alle Rollen
--       archetypes = { "CASTER_DPS" },         -- optional, sonst für alle
--       phase      = "T4",                     -- ab welcher Phase erhältlich
--       source     = "Quelle der Empfehlung",
--   }
--
-- Jede Enchant-ID unten ist einzeln auf ihrer Wowhead-Seite nachgeschlagen: die
-- Zahl ist die Klammer-ID aus der Zeile "Enchant Item: ... (ID)", also genau
-- das, was auch im Item-Link steht. Geraten wurde nichts - beim Nachschlagen
-- haben sich mehrere aus dem Gedaechtnis angenommene Spell-IDs als falsch
-- erwiesen und wurden verworfen.
--
-- Welche Verzauberung fuer welchen Archetyp die beste ist, stammt aus den
-- BiS-Listen von wowtbc.gg (Stand Phase T5).
--
-- Die Stufen bedeuten:
--   OPTIMAL     - aktuelle Empfehlung fuer diesen Archetyp;
--   SOLID       - wirkungsvolle, raidtaugliche Alternative;
--   IMPROVABLE  - funktional, aber fuer den Raid deutlich schwaecher
--                 (PvP-Werte und Widerstandsverzauberungen).
--
-- Was hier fehlt, wird nicht als schlecht gewertet: Unbekannte IDs gelten je
-- nach Einstellung als anerkannt oder als "Unbekannt", nie als Fund.
GC.EnchantRuleSet = {
    version = 2,
    phase = "T5",
    source = "wowhead.com (IDs) + wowtbc.gg (Empfehlungen)",
    rules = {
        -- === Kopf: Arkanum/Glyphe aus dem Ruf ===========================
        [3002] = { verdict = "OPTIMAL", name = "Glyph of Power",
            slots = { "HEAD" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [3001] = { verdict = "OPTIMAL", name = "Glyph of Renewal",
            slots = { "HEAD" }, archetypes = { "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2999] = { verdict = "OPTIMAL", name = "Glyph of the Defender",
            slots = { "HEAD" }, archetypes = { "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [3003] = { verdict = "OPTIMAL", name = "Glyph of Ferocity",
            slots = { "HEAD" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [3000] = { verdict = "IMPROVABLE", name = "Glyph of the Wild",
            slots = { "HEAD" }, phase = "T4",
            source = "PvP-Werte (Abhärtung) zählen im Raid nicht" },

        -- === Schulter: Inschriften ======================================
        [2995] = { verdict = "OPTIMAL", name = "Greater Inscription of the Orb",
            slots = { "SHOULDER" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2997] = { verdict = "OPTIMAL", name = "Greater Inscription of the Blade",
            slots = { "SHOULDER" }, archetypes = { "PHYSICAL_DPS", "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2993] = { verdict = "OPTIMAL", name = "Greater Inscription of the Oracle",
            slots = { "SHOULDER" }, archetypes = { "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2991] = { verdict = "OPTIMAL", name = "Greater Inscription of the Knight",
            slots = { "SHOULDER" }, archetypes = { "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2996] = { verdict = "SOLID", name = "Inscription of the Blade",
            slots = { "SHOULDER" }, archetypes = { "PHYSICAL_DPS", "TANK" }, phase = "T4",
            source = "kleinere Fassung der Großen Inschrift" },
        [2994] = { verdict = "SOLID", name = "Inscription of the Orb",
            slots = { "SHOULDER" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "kleinere Fassung der Großen Inschrift" },
        [2998] = { verdict = "IMPROVABLE", name = "Inscription of Endurance",
            slots = { "SHOULDER" }, phase = "T4",
            source = "Widerstandsinschrift, außerhalb von Widerstandskämpfen schwach" },

        -- === Rücken =====================================================
        [2621] = { verdict = "OPTIMAL", name = "Cloak - Subtlety",
            slots = { "BACK" }, archetypes = { "CASTER_DPS", "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [368] = { verdict = "OPTIMAL", name = "Cloak - Greater Agility",
            slots = { "BACK" }, archetypes = { "PHYSICAL_DPS", "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2664] = { verdict = "IMPROVABLE", name = "Cloak - Major Resistance",
            slots = { "BACK" }, phase = "T4",
            source = "Widerstandsverzauberung, nur für Widerstandskämpfe" },

        -- === Brust ======================================================
        [2661] = { verdict = "OPTIMAL", name = "Chest - Exceptional Stats",
            slots = { "CHEST" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [1144] = { verdict = "SOLID", name = "Chest - Major Spirit",
            slots = { "CHEST" }, archetypes = { "HEALER", "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg Alternative" },
        [3150] = { verdict = "SOLID", name = "Chest - Restore Mana Prime",
            slots = { "CHEST" }, archetypes = { "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS für Heilig-Paladine" },
        [2659] = { verdict = "SOLID", name = "Chest - Exceptional Health",
            slots = { "CHEST" }, archetypes = { "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS für Schutz-Paladine" },
        [2933] = { verdict = "IMPROVABLE", name = "Chest - Major Resilience",
            slots = { "CHEST" }, phase = "T4",
            source = "PvP-Werte (Abhärtung) zählen im Raid nicht" },

        -- === Handgelenke ================================================
        [2650] = { verdict = "OPTIMAL", name = "Bracer - Spellpower",
            slots = { "WRIST" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2617] = { verdict = "OPTIMAL", name = "Bracer - Superior Healing",
            slots = { "WRIST" }, archetypes = { "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [1593] = { verdict = "OPTIMAL", name = "Bracer - Assault",
            slots = { "WRIST" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2648] = { verdict = "OPTIMAL", name = "Bracer - Major Defense",
            slots = { "WRIST" }, archetypes = { "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2647] = { verdict = "SOLID", name = "Bracer - Brawn",
            slots = { "WRIST" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg Alternative" },
        -- Dieselbe Enchant-ID sitzt auf Handgelenken und Stiefeln: Die ID
        -- beschreibt den Effekt (+12 Ausdauer), nicht den Ausrüstungsplatz.
        -- Beide Slots gehören deshalb in dieselbe Regel.
        [2649] = { verdict = "SOLID", name = "Fortitude (+12 Ausdauer)",
            slots = { "WRIST", "FEET" }, archetypes = { "TANK" }, phase = "T4",
            source = "wowtbc.gg Alternative" },

        -- === Hände ======================================================
        [2937] = { verdict = "OPTIMAL", name = "Gloves - Major Spellpower",
            slots = { "HANDS" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2322] = { verdict = "OPTIMAL", name = "Gloves - Major Healing",
            slots = { "HANDS" }, archetypes = { "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [1594] = { verdict = "OPTIMAL", name = "Gloves - Assault",
            slots = { "HANDS" }, archetypes = { "PHYSICAL_DPS", "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2564] = { verdict = "OPTIMAL", name = "Gloves - Superior Agility",
            slots = { "HANDS" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [684] = { verdict = "SOLID", name = "Gloves - Major Strength",
            slots = { "HANDS" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg Alternative" },
        [2934] = { verdict = "SOLID", name = "Gloves - Blasting",
            slots = { "HANDS" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg Alternative" },
        [2935] = { verdict = "SOLID", name = "Gloves - Spell Strike",
            slots = { "HANDS" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg Alternative, solange Trefferwertung fehlt" },

        -- === Beine: Beinrüstung und Zauberfaden =========================
        [2748] = { verdict = "OPTIMAL", name = "Runic Spellthread",
            slots = { "LEGS" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2746] = { verdict = "OPTIMAL", name = "Golden Spellthread",
            slots = { "LEGS" }, archetypes = { "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [3012] = { verdict = "OPTIMAL", name = "Nethercobra Leg Armor",
            slots = { "LEGS" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [3013] = { verdict = "OPTIMAL", name = "Nethercleft Leg Armor",
            slots = { "LEGS" }, archetypes = { "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2747] = { verdict = "SOLID", name = "Mystic Spellthread",
            slots = { "LEGS" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "kleinere Fassung des Runenzauberfadens" },

        -- === Füße =======================================================
        [2939] = { verdict = "OPTIMAL", name = "Boots - Cat's Swiftness",
            slots = { "FEET" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2940] = { verdict = "OPTIMAL", name = "Boots - Boar's Speed",
            slots = { "FEET" }, archetypes = { "TANK", "CASTER_DPS", "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2657] = { verdict = "SOLID", name = "Boots - Dexterity",
            slots = { "FEET" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS für Vergelter-Paladine" },

        -- === Waffe ======================================================
        [2673] = { verdict = "OPTIMAL", name = "Weapon - Mongoose",
            slots = { "MAINHAND", "OFFHAND" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2671] = { verdict = "OPTIMAL", name = "Weapon - Sunfire",
            slots = { "MAINHAND" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2672] = { verdict = "OPTIMAL", name = "Weapon - Soulfrost",
            slots = { "MAINHAND" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS, gleichwertig zu Sunfire" },
        [2343] = { verdict = "OPTIMAL", name = "Weapon - Major Healing",
            slots = { "MAINHAND" }, archetypes = { "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2669] = { verdict = "OPTIMAL", name = "Weapon - Major Spellpower",
            slots = { "MAINHAND" }, archetypes = { "CASTER_DPS" }, phase = "T4",
            source = "wowtbc.gg BiS für Elementar-Schamanen und Schutz-Paladine" },
        [963] = { verdict = "IMPROVABLE", name = "Weapon - Major Striking",
            slots = { "MAINHAND", "OFFHAND" }, archetypes = { "PHYSICAL_DPS" }, phase = "T4",
            source = "deutlich schwächer als Mongoose" },

        -- === Schild =====================================================
        [2655] = { verdict = "SOLID", name = "Shield - Shield Block",
            slots = { "OFFHAND" }, archetypes = { "TANK" }, phase = "T4",
            source = "wowtbc.gg Alternative" },

        -- === Ringe (nur für Verzauberer selbst) =========================
        [2928] = { verdict = "OPTIMAL", name = "Ring - Spellpower",
            slots = { "FINGER1", "FINGER2" }, archetypes = { "CASTER_DPS", "HEALER" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2929] = { verdict = "OPTIMAL", name = "Ring - Striking",
            slots = { "FINGER1", "FINGER2" }, archetypes = { "PHYSICAL_DPS", "TANK" }, phase = "T4",
            source = "wowtbc.gg BiS" },
        [2931] = { verdict = "SOLID", name = "Ring - Stats",
            slots = { "FINGER1", "FINGER2" }, phase = "T4",
            source = "allgemeine Alternative für alle Rollen" },
    },
}

-- Bekannte Luecke: Die Aldor-Schulterinschriften (Vengeance, Faith,
-- Discipline) haben eigene Enchant-IDs, die sich bei der Recherche nicht
-- belegen liessen - nur die Scryer-Gegenstuecke (Blade, Oracle, Orb) und die
-- rangunabhaengige Inschrift des Ritters stehen oben. Aldor-Inschriften werden
-- deshalb nicht falsch bewertet, sondern gar nicht: Sie gelten als unbewertete
-- Verzauberung und damit als in Ordnung. Wer sie einstufen will, klickt sie in
-- der Ausruestungspruefung einmal an - die Gildenregel sticht diesen Satz.

-- Entscheidungen zu Pflegevorschlägen. Sie werden gildenweit synchronisiert,
-- damit nicht mehrere Offiziere denselben Fall doppelt bearbeiten.
GC.MemberCareDecisions = {
    IGNORED = { key = "IGNORED", label = "Ausnahme", help = "Erscheint nie wieder als Vorschlag." },
    POSTPONED = { key = "POSTPONED", label = "Zurückgestellt", help = "Erscheint erst nach dem Datum wieder." },
    DONE = { key = "DONE", label = "Erledigt", help = "Fall wurde bearbeitet." },
}

GC.MemberCarePostponeDays = 30
GC.MemberCareMaxDecisions = 40

GC.ClassOrder = {
    "WARRIOR",
    "PALADIN",
    "HUNTER",
    "ROGUE",
    "PRIEST",
    "SHAMAN",
    "MAGE",
    "WARLOCK",
    "DRUID",
}

GC.Classes = {
    WARRIOR = {
        id = 1,
        name = "Krieger",
        plural = "Krieger",
        color = { 0.78, 0.61, 0.43 },
        specs = {
            { key = "WARRIOR:1", name = "Waffen", recruitLabel = "Waffen-Krieger", role = "DAMAGER" },
            { key = "WARRIOR:2", name = "Furor", recruitLabel = "Furor-Krieger", role = "DAMAGER" },
            { key = "WARRIOR:3", name = "Schutz", recruitLabel = "Schutz-Krieger", role = "TANK" },
        },
    },
    PALADIN = {
        id = 2,
        name = "Paladin",
        plural = "Paladine",
        color = { 0.96, 0.55, 0.73 },
        specs = {
            { key = "PALADIN:1", name = "Heilig", recruitLabel = "Heilig-Paladine", role = "HEALER" },
            { key = "PALADIN:2", name = "Schutz", recruitLabel = "Schutz-Paladine", role = "TANK" },
            { key = "PALADIN:3", name = "Vergeltung", recruitLabel = "Vergelter-Paladine", role = "DAMAGER" },
        },
    },
    HUNTER = {
        id = 3,
        name = "Jäger",
        plural = "Jäger",
        color = { 0.67, 0.83, 0.45 },
        specs = {
            { key = "HUNTER:1", name = "Tierherrschaft", recruitLabel = "Tierherrschafts-Jäger", role = "DAMAGER" },
            { key = "HUNTER:2", name = "Treffsicherheit", recruitLabel = "Treffsicherheits-Jäger", role = "DAMAGER" },
            { key = "HUNTER:3", name = "Überleben", recruitLabel = "Überlebens-Jäger", role = "DAMAGER" },
        },
    },
    ROGUE = {
        id = 4,
        name = "Schurke",
        plural = "Schurken",
        color = { 1.00, 0.96, 0.41 },
        specs = {
            { key = "ROGUE:1", name = "Meucheln", recruitLabel = "Meucheln-Schurken", role = "DAMAGER" },
            { key = "ROGUE:2", name = "Kampf", recruitLabel = "Kampf-Schurken", role = "DAMAGER" },
            { key = "ROGUE:3", name = "Täuschung", recruitLabel = "Täuschungs-Schurken", role = "DAMAGER" },
        },
    },
    PRIEST = {
        id = 5,
        name = "Priester",
        plural = "Priester",
        color = { 1.00, 1.00, 1.00 },
        specs = {
            { key = "PRIEST:1", name = "Disziplin", recruitLabel = "Disziplin-Priester", role = "HEALER" },
            { key = "PRIEST:2", name = "Heilig", recruitLabel = "Heilig-Priester", role = "HEALER" },
            { key = "PRIEST:3", name = "Schatten", recruitLabel = "Schattenpriester", role = "DAMAGER" },
        },
    },
    SHAMAN = {
        id = 7,
        name = "Schamane",
        plural = "Schamanen",
        color = { 0.00, 0.44, 0.87 },
        specs = {
            { key = "SHAMAN:1", name = "Elementar", recruitLabel = "Elementar-Schamanen", role = "DAMAGER" },
            { key = "SHAMAN:2", name = "Verstärkung", recruitLabel = "Verstärker-Schamanen", role = "DAMAGER" },
            { key = "SHAMAN:3", name = "Wiederherstellung", recruitLabel = "Wiederherstellungs-Schamanen", role = "HEALER" },
        },
    },
    MAGE = {
        id = 8,
        name = "Magier",
        plural = "Magier",
        color = { 0.25, 0.78, 0.92 },
        specs = {
            { key = "MAGE:1", name = "Arkan", recruitLabel = "Arkan-Magier", role = "DAMAGER" },
            { key = "MAGE:2", name = "Feuer", recruitLabel = "Feuer-Magier", role = "DAMAGER" },
            { key = "MAGE:3", name = "Frost", recruitLabel = "Frost-Magier", role = "DAMAGER" },
        },
    },
    WARLOCK = {
        id = 9,
        name = "Hexenmeister",
        plural = "Hexenmeister",
        color = { 0.53, 0.53, 0.93 },
        specs = {
            { key = "WARLOCK:1", name = "Gebrechen", recruitLabel = "Gebrechen-Hexenmeister", role = "DAMAGER" },
            { key = "WARLOCK:2", name = "Dämonologie", recruitLabel = "Dämonologie-Hexenmeister", role = "DAMAGER" },
            { key = "WARLOCK:3", name = "Zerstörung", recruitLabel = "Zerstörungs-Hexenmeister", role = "DAMAGER" },
        },
    },
    DRUID = {
        id = 11,
        name = "Druide",
        plural = "Druiden",
        color = { 1.00, 0.49, 0.04 },
        specs = {
            { key = "DRUID:1", name = "Gleichgewicht", recruitLabel = "Gleichgewichts-Druiden", role = "DAMAGER" },
            { key = "DRUID:2", name = "Wildheit", recruitLabel = "Wildheits-Druiden", role = "FLEX" },
            { key = "DRUID:3", name = "Wiederherstellung", recruitLabel = "Wiederherstellungs-Druiden", role = "HEALER" },
        },
    },
}

GC.SpecByKey = {}
for classFile, classInfo in pairs(GC.Classes) do
    for index, spec in ipairs(classInfo.specs) do
        spec.classFile = classFile
        spec.index = index
        GC.SpecByKey[spec.key] = spec
    end
end

GC.CoverageRules = {
    { specKey = "SHAMAN:2", priority = "HOCH", reason = "Melee-Gruppen profitieren stark von Verstärker-Support." },
    { specKey = "SHAMAN:1", priority = "MITTEL", reason = "Caster-Gruppen profitieren von Elementar-Support." },
    { specKey = "PRIEST:3", priority = "HOCH", reason = "Schattenpriester stabilisieren die Mana-Versorgung." },
    { specKey = "HUNTER:3", priority = "MITTEL", reason = "Überlebens-Jäger bringen Expose Weakness." },
    { specKey = "WARRIOR:1", priority = "MITTEL", reason = "Waffen-Krieger unterstützen physischen Schaden mit Blood Frenzy." },
    { specKey = "PALADIN:3", priority = "MITTEL", reason = "Vergelter bringen zusätzlichen Paladin-Support." },
    { specKey = "DRUID:1", priority = "MITTEL", reason = "Gleichgewichts-Druiden unterstützen Caster-Gruppen." },
}

GC.ChannelKinds = {
    RECRUITMENT = {
        label = "Gildenrekrutierung",
        aliases = { "gildenrekrutierung", "gilden rekrutierung", "guildrecruitment", "guild recruitment" },
    },
    LFG = {
        label = "SucheNachGruppe",
        aliases = { "suchenachgruppe", "suche nach gruppe", "lookingforgroup", "looking for group" },
    },
    TRADE = {
        label = "Handel",
        aliases = { "handel", "trade" },
    },
    GENERAL = {
        label = "Allgemein",
        aliases = { "allgemein", "general" },
    },
}

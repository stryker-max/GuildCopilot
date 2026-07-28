local _, GC = ...

GC.Constants = {
    ADDON_NAME = "Guild Copilot",
    VERSION = "0.9.13",
    SCHEMA_VERSION = 7,
    INTERFACE_VERSION = 20506,
    COMM_PREFIX = "GuildCopilot",
    MAX_CHAT_BYTES = 255,
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
    "membercare",
}

GC.ProfessionOptions = {
    "",
    "Alchemie",
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
    { key = "MAP_PING", name = "Karten-Ping", soundID = 3175 },
}

-- Verbrauchsgegenstände werden nach Spell-ID gezählt. "repeatable" trennt
-- Gegenstände, die pro Anwendung zählen (Tränke, Runen, Trommeln), von
-- dauerhaften Buffs, die pro Sitzung nur einmal zählen sollen.
GC.ConsumableCategories = {
    { key = "POTION", label = "Tränke", repeatable = true },
    { key = "RUNE", label = "Runen", repeatable = true },
    { key = "DRUM", label = "Trommeln", repeatable = true },
    { key = "FLASK", label = "Fläschchen", repeatable = false },
    { key = "ELIXIR", label = "Elixiere", repeatable = false },
    { key = "FOOD", label = "Essen", repeatable = false },
    { key = "OIL", label = "Öle/Steine", repeatable = false },
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
    [28495] = { category = "POTION", name = "Übermächtiger Heiltrank" },
    [28499] = { category = "POTION", name = "Übermächtiger Manatrank" },
    [28507] = { category = "POTION", name = "Hasttrank" },
    [28508] = { category = "POTION", name = "Zerstörungstrank" },
    [28494] = { category = "POTION", name = "Trank der irren Stärke" },
    [28511] = { category = "POTION", name = "Heldentrank" },
    [28512] = { category = "POTION", name = "Eisenschildtrank" },
    [38908] = { category = "POTION", name = "Teufelsmanatrank" },
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
    [28490] = { category = "ELIXIR", name = "Elixier der Stärke" },
    [28497] = { category = "ELIXIR", name = "Elixier der Beweglichkeit" },
    [28491] = { category = "ELIXIR", name = "Elixier der Heilkraft" },
    [28493] = { category = "ELIXIR", name = "Elixier der Frostmacht" },
    [28501] = { category = "ELIXIR", name = "Elixier der Feuermacht" },
    [28502] = { category = "ELIXIR", name = "Elixier der Verteidigung" },
    [28503] = { category = "ELIXIR", name = "Elixier der Schattenmacht" },
    [28509] = { category = "ELIXIR", name = "Elixier des Magierbluts" },
    [39625] = { category = "ELIXIR", name = "Elixier der Standhaftigkeit" },
    [39627] = { category = "ELIXIR", name = "Elixier der Draeneiweisheit" },
    [28017] = { category = "OIL", name = "Überlegenes Zaubereröl" },
    [28019] = { category = "OIL", name = "Überlegenes Manaöl" },
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
}

-- Versionierte Regeln für die Bewertung vorhandener Verzauberungen.
--
-- Format je Eintrag:
--   [enchantID] = {
--       verdict = "OPTIMAL" | "SOLID" | "IMPROVABLE",
--       name    = "Anzeigename der Verzauberung",
--       slots   = { "HANDS", "BACK" },   -- optional, sonst für alle Slots
--       roles   = { "TANK", "HEALER" },  -- optional, sonst für alle Rollen
--       source  = "Quelle der Empfehlung",
--   }
--
-- Die Tabelle ist bewusst leer: Enchant-IDs müssen aus einer belegbaren Quelle
-- übernommen werden, sonst bewertet der Audit falsch. Unbekannte IDs werden
-- als "Unbekannt" ausgewiesen und nie als schlecht gewertet. Fehlende
-- Verzauberungen und leere Sockel erkennt der Audit auch ohne diese Regeln
-- exakt, weil sie direkt aus dem Item-Link hervorgehen.
GC.EnchantRuleSet = {
    version = 1,
    phase = "",
    source = "",
    rules = {},
}

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

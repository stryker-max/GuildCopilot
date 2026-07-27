local _, GC = ...

GC.Constants = {
    ADDON_NAME = "Guild Copilot",
    VERSION = "0.4.6",
    SCHEMA_VERSION = 7,
    INTERFACE_VERSION = 20506,
    COMM_PREFIX = "GuildCopilot",
    MAX_CHAT_BYTES = 255,
    DEFAULT_POST_COOLDOWN = 120,
    DEFAULT_LFG_COOLDOWN = 120,
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

import fs from "node:fs";
import path from "node:path";

const repositoryRoot = path.resolve(".");
const root = path.join(repositoryRoot, "GuildCopilot");
const tocPath = path.join(root, "GuildCopilot.toc");
const toc = fs.readFileSync(tocPath, "utf8");
const constants = fs.readFileSync(path.join(root, "Constants.lua"), "utf8");
const readme = fs.readFileSync(path.join(repositoryRoot, "README.md"), "utf8");
const logoPath = path.join(root, "Media", "GuildCopilotLogo.tga");
const wordmarkPath = path.join(root, "Media", "GuildCopilotWordmark.tga");

const requiredMetadata = [
  "## Interface: 20506",
  "## Title: Guild Copilot",
  "## SavedVariables: GuildCopilotDB",
  "## Version: 0.9.27",
];

for (const entry of requiredMetadata) {
  if (!toc.includes(entry)) {
    throw new Error(`Fehlender TOC-Eintrag: ${entry}`);
  }
}

const tocVersion = toc.match(/^## Version:\s*(\S+)/m)?.[1];
const constantsVersion = constants.match(/\bVERSION\s*=\s*"([^"]+)"/)?.[1];
const readmeVersion = readme.match(/^# Guild Copilot\s+(\S+)/m)?.[1];
if (!tocVersion || tocVersion !== constantsVersion || tocVersion !== readmeVersion) {
  throw new Error(
    `Addon-Versionen widersprechen sich: TOC=${tocVersion}, Constants=${constantsVersion}, README=${readmeVersion}`
  );
}

const installerProject = fs.readFileSync(
  path.join(repositoryRoot, "Installer", "GuildCopilot-Installer.csproj"),
  "utf8"
);
const installerVersion = installerProject.match(/<Version>([^<]+)<\/Version>/)?.[1];
const publishedVersion = fs
  .readFileSync(path.join(repositoryRoot, "Installer", "dist", "version.txt"), "utf8")
  .trim();
const installerExe = path.join(repositoryRoot, "Installer", "dist", "GuildCopilot-Installer.exe");
const installerProgram = fs.readFileSync(
  path.join(repositoryRoot, "Installer", "Program.cs"),
  "utf8"
);
const installerSelfUpdate = fs.readFileSync(
  path.join(repositoryRoot, "Installer", "SelfUpdate.cs"),
  "utf8"
);
if (!installerVersion || installerVersion !== publishedVersion) {
  throw new Error(
    `Installer-Versionen widersprechen sich: Projekt=${installerVersion}, version.txt=${publishedVersion}`
  );
}
if (!fs.existsSync(installerExe) || fs.statSync(installerExe).size < 1_000_000) {
  throw new Error("Die veröffentlichte Installer-EXE fehlt oder ist offensichtlich unvollständig.");
}
if (!readme.includes(`Installer bei ${installerVersion}`) || !readme.includes(`Addon bei ${tocVersion}`)) {
  throw new Error("README nennt nicht die tatsächlich veröffentlichten Addon- und Installer-Versionen.");
}
if (
  !installerProgram.includes("SingleInstanceMutex") ||
  !installerProgram.includes("WaitForPreviousInstance") ||
  !installerProgram.includes("WaitForLegacySelfUpdate") ||
  !installerSelfUpdate.includes("--wait-for-pid")
) {
  throw new Error("Der Installer-Neustart verhindert doppelte Fenster nicht vollständig.");
}

if (!fs.existsSync(logoPath)) {
  throw new Error("Das WoW-taugliche Guild-Copilot-Logo fehlt.");
}
const logo = fs.readFileSync(logoPath);
const logoWidth = logo.readUInt16LE(12);
const logoHeight = logo.readUInt16LE(14);
const logoDepth = logo.readUInt8(16);
if (logoWidth !== 256 || logoHeight !== 256 || logoDepth !== 32) {
  throw new Error(`Unerwartetes TGA-Format: ${logoWidth}x${logoHeight}, ${logoDepth} Bit`);
}

if (!fs.existsSync(wordmarkPath)) {
  throw new Error("Das Schriftlogo für die Addon-Optionen fehlt.");
}
const wordmark = fs.readFileSync(wordmarkPath);
const wordmarkWidth = wordmark.readUInt16LE(12);
const wordmarkHeight = wordmark.readUInt16LE(14);
const wordmarkDepth = wordmark.readUInt8(16);
if (wordmarkWidth !== 512 || wordmarkHeight !== 512 || wordmarkDepth !== 32) {
  throw new Error(`Unerwartetes Schriftlogo-TGA: ${wordmarkWidth}x${wordmarkHeight}, ${wordmarkDepth} Bit`);
}

const luaFiles = toc
  .split(/\r?\n/)
  .map((line) => line.trim())
  .filter((line) => line.endsWith(".lua"));

for (const file of luaFiles) {
  const fullPath = path.join(root, file);
  if (!fs.existsSync(fullPath)) {
    throw new Error(`TOC referenziert fehlende Datei: ${file}`);
  }
  const source = fs.readFileSync(fullPath, "utf8");
  if (!source.includes("local _, GC = ...") && file !== "Core.lua") {
    throw new Error(`Addon-Namespace fehlt in ${file}`);
  }
  if (/SendChatMessage\s*\([^)]*\)\s*(?:;|\n)\s*SendChatMessage/.test(source)) {
    throw new Error(`Verdächtiges mehrfaches Posting in ${file}`);
  }
}

const forbidden = [
  ["automatisches Timer-Posting", /C_Timer\.(?:After|NewTicker)[\s\S]{0,250}StartSearch/],
  ["wiederholendes Timer-Posting", /C_Timer\.NewTicker/],
  ["direkter Warcraft-Logs-Webzugriff", /C_HTTP|socket\.http|HttpRequest/i],
];

const allSource = luaFiles
  .map((file) => fs.readFileSync(path.join(root, file), "utf8"))
  .join("\n");

for (const [name, pattern] of forbidden) {
  if (pattern.test(allSource)) {
    throw new Error(`Unerlaubtes Muster gefunden: ${name}`);
  }
}

const requiredLabels = ["Bestätigen", "Text bestätigen", "Suche starten", "SucheNachGruppe"];
for (const label of requiredLabels) {
  if (!allSource.includes(label)) {
    throw new Error(`Benötigte UI-Beschriftung fehlt: ${label}`);
  }
}

const requiredImplementations = [
  ["explizites Zuklappen der Klassenkarte", /if page\.expandedClass == currentClass then\s+page\.expandedClass = nil/],
  ["sichtbares Kanal-Häkchen", /UI-CheckBox-Check/],
  ["sortierbare Auswahl", /MoveSelectedClass/],
  ["Priorität im Werbetext", /dringend/],
  ["editierbare Antwortvorschau", /Antwortvorschau\s+•\s+editierbar/],
  ["Antwort-Symbole", /DecorateReply/],
  ["Berufssynchronisierung", /RefreshProfessions/],
  ["aktive Level-70-Spieler", /GetActiveRaiders/],
  ["Raider-Rangfilter", /SetRankActive/],
  ["Postfach einzeln leeren", /RemoveLead/],
  ["Postfach vollständig leeren", /ClearInbox/],
  ["Statistik-Roadmap", /Gildenwerkstatt/],
  ["Rezeptscan", /ScanOpenProfession/],
  ["Werkstatt-Synchronisierung", /BuildProfessionMessages/],
  ["Werkstattsuche", /GetCatalog/],
  ["Craft-API für Verzauberkunst", /CRAFT_SHOW[\s\S]*CRAFT_UPDATE/],
  ["Berufsfilter", /workshopProfession/],
  ["Gildenprofil-Rangrechte", /SetGuildProfileRankActive/],
  ["Gildenprofil-Synchronisierung", /BuildGuildProfileMessages/],
  ["bearbeitbare Antwortvorlagen", /replyTemplates/],
  ["wählbarer Erfolgssound", /successSoundKey/],
  ["manuelle Roster-Aktualisierung", /Roster:Refresh/],
  ["Eintrag in den Blizzard-Addon-Optionen", /InterfaceOptions_AddCategory/],
  ["eigenes Addon-Logo", /GuildCopilotLogo/],
  ["Berufssymbole", /ProfessionIcons/],
  ["suchbasierte Werkstatt", /Gezielte Rezeptsuche/],
  ["Rezeptfavoriten", /workshopFavorites/],
  ["Minimap-Schalter", /Minimap-Symbol anzeigen/],
  ["Minimap-Button", /GuildCopilotMinimapButton/],
  ["statische Addon-Optionsseite", /Guild Copilot öffnen/],
  ["TBC-kompatibler Sound-Fallback", /soundID = 3081/],
  ["Mitgliederpflege", /BuildMemberCarePage/],
  ["Abmeldung von bis", /SetAbsence/],
  ["Abmeldung in Profilsynchronisierung", /absence\.from/],
  ["Inaktivitätsvorschläge", /GetMemberCareCandidates/],
  ["geschützte Ränge", /SetMemberCareRankProtected/],
  ["explizite Escape-Behandlung", /key == "ESCAPE"/],
  ["echtes Favoritensymbol", /SetRaidMarkerIcon\(page\.workshopFavorites\.favoriteIcon, 1\)/],
  ["Profil als erster Tab", /local TAB_DEFINITIONS = \{\s+\{ key = "ROSTER", section = "COPILOT", label = "Profil"/],
  ["Abmeldung im persönlichen Profil", /BuildRosterPage[\s\S]*Deine Abmeldung/],
  ["Mitgliederpflege-Rangfreigabe", /SetMemberCareAccessRank/],
  ["direkter Werkstatt-Sendeburst", /while #self\.syncQueue > 0 do/],
  ["kompakte Werkstattpakete", /BuildCompactRecipeRecord/],
  ["vollständiger klassischer Rezeptscan", /PrepareClassicTradeSkill[\s\S]*SetTradeSkillItemNameFilter[\s\S]*isExpanded == false/],
  ["Wiederholung fehlgeschlagener Werkstattpakete", /RELIABLE_MAX_ATTEMPTS/],
  ["bestätigte Werkstatt-Teilpakete", /SendReliableAck\("W"/],
  ["gildenweiter Rekrutierungs-Datensatz", /BuildRecruitmentSyncMessages/],
  ["TBC-Schreibweise Alchimie", /value == "alchemie"/],
  ["Schutz des eigenen Editor-Rangs", /OWN_RANK/],
  ["Einmalige Editor-Lockout-Reparatur", /CanUseEditorRecovery/],
  ["Blizzard-Offiziersprüfung für Lockout-Reparatur", /HasBlizzardOfficerAuthority/],
  ["Versions-Handshake", /BuildVersionMessage/],
  ["Handshake ohne Dauerbroadcast", /MIN_ANNOUNCE_INTERVAL/],
  ["Erkennung abweichender Datenversionen", /GetAddonUserStats/],
  ["Handshake-Fähigkeiten", /GC\.Capabilities/],
  ["Raidsitzung mit ausdrücklichem Start", /function GC\.RaidMonitor:BeginSession/],
  ["Rechteprüfung für die Raidauswertung", /CanControlSession/],
  ["Auswertung ohne Rohdatenspeicher", /function GC\.RaidMonitor:BuildSummary/],
  ["Consumables nach Spell-ID", /GC\.Consumables\[/],
  ["Auswertung über Raid- und Flüsterkanal", /DistributeSummary/],
  ["Anwesenheitszeit", /presentSince/],
  ["Gear Audit über die Inspect-API", /function GC\.GearAudit:StartRaidScan/],
  ["automatischer Ausrüstungsabgleich", /function GC\.GearAudit:QueueEquipmentSnapshot/],
  ["Ausrüstungs-Rohdaten statt synchronisierter Bewertung", /function GC\.GearAudit:BuildSyncedAudit/],
  ["Inspect-Rückfall überspringt synchronisierte Daten", /function GC\.GearAudit:HasFreshSyncedAudit/],
  ["unvollständige Eigendaten werden nicht synchronisiert", /audit\.unreadableSlots/],
  ["vollständige scrollbare Gear-Spielerliste", /EnsureGearPlayerRow/],
  ["Inventaränderung erneuert Eigendaten", /UNIT_INVENTORY_CHANGED/],
  ["Verzauberungen und Sockel je Slot", /function GC\.GearAudit:BuildAudit/],
  ["versionierter Regelsatz", /GC\.EnchantRuleSet/],
  ["umschaltbare Behandlung unbewerteter Verzauberungen", /AcceptsUnratedEnchants/],
  ["kein Gesamtscore im Gear Audit", /keine Gesamtnote/],
  ["Ausnahmen und zurückgestellte Vorschläge", /SetMemberCareDecision/],
  ["manuelle Ausnahmeliste", /GetMemberCareDecisions/],
  ["Ausschluss nur mit Berechtigungsprüfung", /function GC\.Roster:CanRemoveMember/],
  ["echte Blizzard-Prüfung vor dem Ausschluss", /HasBlizzardRemovePermission/],
  ["zweite Bestätigung vor dem Ausschluss", /removeArmed/],
  ["Nachanalyse aus Warcraft Logs", /GCPWCL%d\+/],
  ["Companion-Zeilen werden tolerant zerlegt", /local function SplitFields/],
  ["Wiederbelebungen aus Logs", /resurrects = tonumber\(fields\[9\]\)/],
  ["Klick ins Importfeld setzt den Cursor", /container:SetScript\("OnMouseDown", FocusEdit\)/],
  ["Bestätigung vor dem Überschreiben", /Wirklich ersetzen/],
  ["Rückmeldung mit Uhrzeit", /date\("%H:%M:%S"\)/],
  ["Hinweis auf verwaiste Teilnehmerzeilen", /ohne zugehörige Sitzungszeile/],
  ["verlorene Zeilenumbrüche werden repariert", /local function RepairLineBreaks/],
  ["Logs-Auswertungen als eigene Quelle", /source = "WCL"/],
  ["Consumables aus Logs über die Addon-Tabelle", /DecodeConsumables/],
  ["Quellen werden nicht vermischt", /stored\.source ~= summary\.source/],
  ["aufbereitete Ausrüstungsfunde", /function GC\.GearAudit:GetFindings/],
  ["Gesamtübersicht der Ausrüstungsprüfung", /function GC\.GearAudit:GetOverview/],
  ["eigene Ausrüstung im Profil", /profileGearFindings/],
  ["Verzauberungsname aus dem Tooltip", /function GC\.GearAudit:ResolveEnchantName/],
  ["Tooltip-Vergleich ohne Verzauberung", /local plainLink = tostring\(link\):gsub/],
  ["gildeneigener Verzauberungs-Regelsatz", /function GC\.GearAudit:SetEnchantRule/],
  ["Bewertung per Klick durchschalten", /function GC\.GearAudit:CycleEnchantRule/],
  ["Regelsatz nur mit Einstellungsrecht", /function GC\.GearAudit:CanEditEnchantRules/],
  ["Regelsatz wird gildenweit geteilt", /EncodeEnchantRules/],
  ["Werbebalken als eigenes Fenster", /function GC\.UI:CreatePostBar/],
  ["Werbebalken mit Countdown", /s Cooldown"\)/],
  ["Werbebalken sendet nur per Klick", /bar\.sendButton = CreateButton/],
];

for (const [name, pattern] of requiredImplementations) {
  if (!pattern.test(allSource)) {
    throw new Error(`Implementierung fehlt: ${name}`);
  }
}

if (/\bSYNC_INTERVAL\b/.test(allSource)) {
  throw new Error("Die Werkstatt enthält noch eine künstliche Paketpause.");
}

if (allSource.includes("RefreshOverview")) {
  throw new Error("Veralteter RefreshOverview-Aufruf ist noch vorhanden.");
}

const uiSource = fs.readFileSync(path.join(root, "UI.lua"), "utf8");
if (uiSource.includes("gearAutoSelfToggle") || uiSource.includes("Eigene Ausrüstung selbst prüfen")) {
  throw new Error("Der feste Ausrüstungs-Hintergrundabgleich ist noch abschaltbar.");
}
const settingsPosition = uiSource.indexOf('{ key = "SETTINGS"');
const statisticsPosition = uiSource.indexOf('{ key = "STATISTICS"');
if (settingsPosition < statisticsPosition) {
  throw new Error("Einstellungen stehen nicht als letzter Navigationspunkt.");
}

// Zusammengehoerendes soll beieinander stehen: In der Mitgliederpflege gehoert
// der Inaktivitaets-Ablauf (Regeln, Vorschlaege, Entscheidungen) zusammen, die
// Abmeldungen sind ein eigenes Thema und stehen darunter.
const memberCarePage = uiSource.slice(
  uiSource.indexOf("function GC.UI:BuildMemberCarePage"),
  uiSource.indexOf("function GC.UI:RefreshMemberCare")
);
const cardOffset = (name) => {
  const match = memberCarePage.match(
    new RegExp(`${name}:SetPoint\\("TOPLEFT", content, "TOPLEFT", 0, -(\\d+)\\)`)
  );
  if (!match) throw new Error(`Karte ${name} fehlt in der Mitgliederpflege.`);
  return Number(match[1]);
};
if (!(cardOffset("suggestionsCard") < cardOffset("decisionsCard"))) {
  throw new Error("Die Entscheidungen stehen nicht direkt unter den Pflegevorschlägen.");
}
if (!(cardOffset("decisionsCard") < cardOffset("absencesCard"))) {
  throw new Error("Die Abmeldungen stehen wieder zwischen den zusammengehörenden Karten.");
}

// Die Antwortvorlagen gehoeren ins Postfach, wo die Knoepfe sind.
const inboxPage = uiSource.slice(
  uiSource.indexOf("function GC.UI:BuildInboxPage"),
  uiSource.indexOf("function GC.UI:RefreshInbox")
);
if (!inboxPage.includes("page.templateEdits = {}") || !inboxPage.includes("page.saveTemplates")) {
  throw new Error("Die Antwortvorlagen fehlen im Postfach.");
}
const settingsPage = uiSource.slice(
  uiSource.indexOf("function GC.UI:BuildSettingsPage"),
  uiSource.indexOf("function GC.UI:RefreshSettings")
);
if (settingsPage.includes("page.templateEdits")) {
  throw new Error("Die Antwortvorlagen stehen wieder in den Einstellungen.");
}

// Die Seitenleiste hat keine Bildlaufleiste. Ein neuer Navigationspunkt darf
// deshalb nicht unten aus dem Fenster ragen - genau das war mit dem Eintrag
// "Ausruestung" passiert.
const navNumber = (name) => {
  const match = uiSource.match(new RegExp(`local ${name} = (\\d+)`));
  if (!match) throw new Error(`Seitenleisten-Mass ${name} fehlt in UI.lua.`);
  return Number(match[1]);
};
const frameHeight = Number(uiSource.match(/frame:SetSize\(\d+, (\d+)\)/)[1]);
const sidebarTop = Number(uiSource.match(/sidebar:SetPoint\("TOPLEFT", frame, "TOPLEFT", 1, -(\d+)\)/)[1]);
const tabBlock = uiSource.slice(
  uiSource.indexOf("local TAB_DEFINITIONS = {"),
  uiSource.indexOf("local function SetTextColor")
);
const tabCount = (tabBlock.match(/\{ key = "/g) || []).length;
const sections = new Set([...tabBlock.matchAll(/section = "([A-ZÄÖÜ]+)"/g)].map((m) => m[1]));
const navHeight =
  navNumber("NAV_TOP") +
  sections.size * navNumber("NAV_SECTION_HEIGHT") +
  (sections.size - 1) * navNumber("NAV_SECTION_GAP") +
  (tabCount - 1) * navNumber("NAV_TAB_SPACING") +
  navNumber("NAV_TAB_HEIGHT");
const sidebarHeight = frameHeight - sidebarTop - 1;
if (navHeight > sidebarHeight) {
  throw new Error(
    `Die Seitenleiste ist zu klein: ${tabCount} Navigationspunkte brauchen ${navHeight} px, ` +
      `verfuegbar sind ${sidebarHeight} px.`
  );
}

// Beide Detailkarten heissen intern "detailCard". Ein Suchen-und-Ersetzen ohne
// Bereichsgrenze trifft deshalb leicht die falsche Seite. Diese Pruefung haelt
// die Ausruestungsseite auf ihrem groesseren Kopfabstand, weil dort ueber der
// Tabelle noch der Funde-Block steht.
const statisticsPage = uiSource.slice(
  uiSource.indexOf("function GC.UI:BuildStatisticsPage"),
  uiSource.indexOf("function GC.UI:RefreshStatistics")
);
const gearPage = uiSource.slice(
  uiSource.indexOf("function GC.UI:BuildGearPage"),
  uiSource.indexOf("function GC.UI:RefreshGear")
);
if (!statisticsPage.includes("headerDefinition.x, -66)")) {
  throw new Error("Die Raidauswertung hat nicht mehr ihren eigenen Tabellenkopf-Abstand.");
}
if (!gearPage.includes("headerDefinition.x, -122)")) {
  throw new Error("Auf der Ausrüstungsseite überlappt der Funde-Block den Tabellenkopf.");
}
if (!gearPage.includes("page.gearFindings:SetPoint")) {
  throw new Error("Der Funde-Block fehlt auf der Ausrüstungsseite.");
}

if (uiSource.includes("☆") || uiSource.includes("★")) {
  throw new Error("Nicht unterstützte Unicode-Sterne werden noch als Favoritensymbole verwendet.");
}

console.log(`OK: ${luaFiles.length} Lua-Dateien und die TOC-Struktur wurden geprüft.`);

// Die Auswertung des Warcraft-Logs-Companions wird gegen eine aufgezeichnete
// Antwort geprüft, damit der Importcode ohne API-Zugang belegbar bleibt.
await import("./companion.mjs");

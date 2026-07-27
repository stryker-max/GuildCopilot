import fs from "node:fs";
import path from "node:path";

const root = path.resolve("GuildCopilot");
const tocPath = path.join(root, "GuildCopilot.toc");
const toc = fs.readFileSync(tocPath, "utf8");
const logoPath = path.join(root, "Media", "GuildCopilotLogo.tga");
const wordmarkPath = path.join(root, "Media", "GuildCopilotWordmark.tga");

const requiredMetadata = [
  "## Interface: 20506",
  "## Title: Guild Copilot",
  "## SavedVariables: GuildCopilotDB",
  "## Version: 0.4.3",
];

for (const entry of requiredMetadata) {
  if (!toc.includes(entry)) {
    throw new Error(`Fehlender TOC-Eintrag: ${entry}`);
  }
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
];

for (const [name, pattern] of requiredImplementations) {
  if (!pattern.test(allSource)) {
    throw new Error(`Implementierung fehlt: ${name}`);
  }
}

if (allSource.includes("RefreshOverview")) {
  throw new Error("Veralteter RefreshOverview-Aufruf ist noch vorhanden.");
}

const uiSource = fs.readFileSync(path.join(root, "UI.lua"), "utf8");
const settingsPosition = uiSource.indexOf('{ key = "SETTINGS"');
const statisticsPosition = uiSource.indexOf('{ key = "STATISTICS"');
if (settingsPosition < statisticsPosition) {
  throw new Error("Einstellungen stehen nicht als letzter Navigationspunkt.");
}

console.log(`OK: ${luaFiles.length} Lua-Dateien und die TOC-Struktur wurden geprüft.`);

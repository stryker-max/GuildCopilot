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
  "## Version: 0.9.81",
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
// Die zweite README wurde jahrelang übersehen: Sie stand noch auf 1.0.3/0.9.22,
// als längst 1.0.5/0.9.44 ausgeliefert war. Ungeprüfte Doku veraltet leise.
const installerReadme = fs.readFileSync(
  path.join(repositoryRoot, "Installer", "README.md"),
  "utf8"
);
if (!installerReadme.includes(`Installer ${installerVersion}, Addon ${tocVersion}`)) {
  throw new Error(
    `Installer/README.md nennt nicht den ausgelieferten Stand (erwartet: „Installer ${installerVersion}, Addon ${tocVersion}“).`
  );
}
// Der abschaltbare Selbstupdate-Haken ist seit 1.0.4 weg; die README hatte ihn
// noch beschrieben.
if (/optional automatische Aktualisierung beim Öffnen/.test(installerReadme)) {
  throw new Error("Installer/README.md beschreibt noch die abschaltbare Aktualisierung beim Öffnen.");
}
if (
  !installerProgram.includes("SingleInstanceMutex") ||
  !installerProgram.includes("WaitForPreviousInstance") ||
  !installerProgram.includes("WaitForLegacySelfUpdate") ||
  !installerSelfUpdate.includes("--wait-for-pid")
) {
  throw new Error("Der Installer-Neustart verhindert doppelte Fenster nicht vollständig.");
}

// Der Installer soll sich ohne Rückfragen aktuell halten: beim Öffnen und auf
// Knopfdruck. Der frühere Haken dafür ist bewusst entfernt.
const installerMainForm = fs.readFileSync(
  path.join(repositoryRoot, "Installer", "MainForm.cs"),
  "utf8"
);
if (installerMainForm.includes("_autoUpdate")) {
  throw new Error("Die abschaltbare Aktualisierung beim Öffnen ist noch vorhanden.");
}
if (!/if \(_updateAvailable\)[\s\S]{0,400}await InstallAsync\(\)/.test(installerMainForm)) {
  throw new Error("Ein gefundenes Update wird nicht ohne Rückfrage installiert.");
}
// Eine ältere Fassung im Repository darf nie automatisch eingespielt werden.
if (!/comparison < 0[\s\S]{0,400}_updateAvailable = true/.test(installerMainForm)) {
  throw new Error("Die automatische Installation hängt nicht mehr allein an einer neueren Fassung.");
}
if (!/ButtonRow\(_checkButton, _removeButton, _installButton\)/.test(installerMainForm)) {
  throw new Error("„Nach Updates suchen“ steht nicht mehr vorn.");
}
if (!/MakeButton\("Nach Updates suchen", \d+, primary: true\)/.test(installerMainForm)) {
  throw new Error("„Nach Updates suchen“ ist nicht mehr der hervorgehobene Knopf.");
}

// Der Offline-Import aus WoWCombatLog.txt. Die drei Zusicherungen hier sind
// gegen die echte 46-MB-Datei aus dieser Installation gemessen und jede stand
// vorher als Fehler in der Auswertung.
const combatLogImporter = fs.readFileSync(
  path.join(repositoryRoot, "Installer", "CombatLog", "CombatLogImporter.cs"),
  "utf8"
);
if (!combatLogImporter.includes("File.ReadLines")) {
  throw new Error("Der Offline-Import liest die Protokolldatei nicht mehr streamend.");
}
if (/ReadAllText|ReadAllLines/.test(combatLogImporter)) {
  throw new Error("Der Offline-Import lädt die Protokolldatei am Stück; sie ist mehrere Dutzend MB groß.");
}
// Wiederbelebungen: nur SPELL_RESURRECT. Zusammen mit dem gewirkten Zauber
// wurde jede Wiederbelebung doppelt gezählt - gemessen 47 statt 24 bei nur 39
// Spielertoden.
if (/SPELL_CAST_SUCCESS" when SpellIds\.ResurrectSet/.test(combatLogImporter)) {
  throw new Error("Wiederbelebungen werden wieder doppelt gezählt (Ereignis und gewirkter Zauber).");
}
// Ereignisse zählen aus dem ganzen Abend, auch vor dem Pull. Ohne diese Grenze
// standen elf Umstehende mit null Anwesenheit in der Teilnehmerliste.
if (!/participant\.Seconds <= 0\) continue/.test(combatLogImporter)) {
  throw new Error("Teilnehmer ohne Anwesenheit im Bosskampf landen wieder in der Auswertung.");
}
// COMBATANT_INFO hat kein Namensfeld. Wer die Zeile wie ein gewöhnliches
// Ereignis liest, erzeugt einen Teilnehmer namens "0".
if (!combatLogImporter.includes('subevent == "COMBATANT_INFO"')) {
  throw new Error("COMBATANT_INFO wird nicht mehr eigens behandelt.");
}
if (!installerMainForm.includes("CombatLogPanel")) {
  throw new Error("Der Offline-Import fehlt im Installer-Fenster.");
}

// Dateisymbol im Explorer: eine echte .ico mit mehreren Größen.
const iconPath = path.join(repositoryRoot, "Installer", "Assets", "GuildCopilot.ico");
if (!installerProject.includes("<ApplicationIcon>")) {
  throw new Error("Der Installer hat kein Dateisymbol eingebunden.");
}
if (!fs.existsSync(iconPath)) {
  throw new Error("Die Symboldatei des Installers fehlt.");
}
const icon = fs.readFileSync(iconPath);
if (icon.readUInt16LE(0) !== 0 || icon.readUInt16LE(2) !== 1) {
  throw new Error("Die Symboldatei ist keine gültige .ico.");
}
if (icon.readUInt16LE(4) < 4) {
  throw new Error("Die Symboldatei führt zu wenige Größen; der Explorer skaliert dann sichtbar.");
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
  ["getrennter Rezeptkatalog", /StoreCatalogRecipe/],
  ["Herstellerindex ohne Rezeptkopien", /ClaimRecipes/],
  ["Aufräumen ausgetretener Hersteller", /PruneDepartedCrafters/],
  ["Berufs-Manifest statt Vollbroadcast", /BuildKeyManifestMessages/],
  ["Materialbestand aus Taschen und Bank", /GetOwnCounts/],
  ["Gildenbank je Tab", /ScanGuildBankTab/],
  ["Gildenbank-Manifest zuerst", /BuildManifestMessage[\s\S]*BuildTabMessages/],
  ["Ampel für Reagenzien", /GetReagentStatus/],
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
  // Die Kopfzeile deckt beide Companion-Formate ab: GCPWCL aus Warcraft Logs
  // und GCPLOG aus dem Offline-Import.
  ["Nachanalyse aus Companion-Importen", /GCP%u\+%d\+/],
  ["Offline-Import aus dem Combat Log", /GCPLOG/],
  ["Companion-Zeilen werden tolerant zerlegt", /local function SplitFields/],
  ["Wiederbelebungen aus Logs", /resurrects = tonumber\(fields\[9\]\)/],
  ["Klick ins Importfeld setzt den Cursor", /container:SetScript\("OnMouseDown", FocusEdit\)/],
  ["Bestätigung vor dem Überschreiben", /Wirklich ersetzen/],
  ["Rückmeldung mit Uhrzeit", /date\("%H:%M:%S"\)/],
  ["Hinweis auf verwaiste Teilnehmerzeilen", /keine einzige/],
  ["verwaiste Teilnehmerzeilen werden gerettet", /pendingParticipants/],
  ["Diagnose nennt die erste unlesbare Zeile", /firstUnknownLine/],
  ["verlorene Zeilenumbrüche werden repariert", /local function RepairLineBreaks/],
  // Warcraft Logs und der Offline-Import bleiben getrennte Quellen; welche
  // gilt, entscheidet die Kopfzeile des Importcodes.
  ["Importquelle folgt der Kopfzeile", /local sessionSource = "WCL"/],
  ["Offline-Import als eigene Quelle", /sessionSource = "LOG"/],
  ["Consumables aus Logs über die Addon-Tabelle", /DecodeConsumables/],
  // Kennung UND Quelle identifizieren eine Auswertung. Vorher genuegte die
  // Kennung, und die SYNC-Fassung des Raidleiters wurde bei Teilnehmern
  // verworfen, weil dort schon die eigene LIVE-Fassung mit derselben Kennung
  // lag - der Quellenvergleich hatte damit nie zwei Seiten.
  ["Quellen werden nicht vermischt", /stored\.id == summary\.id and stored\.source == summary\.source/],
  ["Auswertung wird über Kennung und Quelle gewählt", /function GC\.RaidMonitor:SummaryKey/],
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
  ["Empfangszeit im Postfach", /local function FormatInboxTime/],
  ["kanonische Realm-Zuordnung", /local function CanonicalLeadName/],
  ["einsehbare Ignorierliste", /GetInboxFilterList/],
  ["Profilbestätigung als Haken", /profileStatusMark/],
  ["eigener Ton für die Profilbestätigung", /function GC\.Chat:PlayProfileSound/],
  ["Bosserkennung über eine gepflegte Liste", /function GC\.RaidMonitor:ResolveBoss/],
  ["Boss überlebt den Wipe in der Auswertung", /segment\.bossName or segment\.lastNPCDeath/],
  ["Ausnahmen für Farmgear und Widerstandssets", /function GC\.GearAudit:CycleSlotException/],
  ["Content-Phase der Gilde", /function GC\.GearAudit:GetContentPhase/],
  ["Checkliste statt Wizard-Fenster", /function GC\.UI:BuildOnboardingCard/],
  ["abgeleiteter Zustand der Einrichtung", /function GC\.Onboarding:GetStepState/],
  ["jeder Schritt einzeln überspringbar", /function GC\.Onboarding:SetStepSkipped/],
  ["Einrichtung jederzeit erneut aufrufbar", /function GC\.Onboarding:Reopen/],
  ["einmaliges Auto-Öffnen je Charakter", /function GC\.Onboarding:ShouldAutoOpen/],
  ["Karten wandern mit der Checkliste", /function GC\.UI:LayoutRosterPage/],
  ["erneute Bestätigung nach Profiländerung", /local function ProfileSelectionChanged/],
  ["Willkommensfenster beim ersten Login", /function GC\.UI:CreateWelcomeFrame/],
  ["Berufe aus den Classic-Fähigkeitszeilen", /local function ReadSkillLineProfessions/],
  ["Herkunft der Berufsangabe", /function GC\.Profile:GetProfessionSource/],
  ["Marker am Minimap-Symbol", /function GC\.UI:RefreshMinimapMarker/],
  ["Slash-Befehle aus einer Tabelle", /local SLASH_COMMANDS = \{/],
  ["Hilfe aus derselben Tabelle", /function GC\.UI:PrintSlashHelp[\s\S]{0,300}ipairs\(SLASH_COMMANDS\)/],
  ["Befehle auf der Addon-Optionsseite", /panel\.commandRows/],
  ["Profiländerung frischt die Karte auf", /page\.selectedFlex = enabled\s+GC\.UI:RefreshRoster\(\)/],
  // Gildenprofil: Sender und Empfaenger teilen sich eine Obergrenze, und was
  // nicht durchpasst, wird gemeldet statt stillschweigend zerschnitten.
  ["gemeinsame Obergrenze für das Gildenprofil", /GUILD_PROFILE_MAX_CHUNKS/],
  ["Nutzlast getrennt vom Zerlegen", /function GC\.Sync:BuildGuildProfilePayload/],
  ["zu großes Gildenprofil wird gemeldet", /GUILD_PROFILE_TOO_LARGE/],
  ["Schutz gegen verstellte Uhren", /MAX_CLOCK_SKEW/],
  ["Zeitstempel aus der Serverzeit", /if GetServerTime then/],
  // Postfach: Der Entwurf gehoert zu einem Interessenten, und die Liste laesst
  // sich ueber die neunte Zeile hinaus bedienen.
  ["Antwortentwurf je Interessent", /page\.replyDrafts/],
  ["Entwurf wechselt mit dem Interessenten", /function GC\.UI:SelectLead/],
  ["Postfach lässt sich blättern", /function GC\.UI:GetLeadIndexForSlot/],
  // Rekrutierung: Abdeckung nur aus Spielern, die wirklich raiden koennen.
  ["Abdeckung nur aus aktiven Raidern", /function GC\.Roster:CountsForCoverage/],
  ["ein Maßstab für aktive Raider", /function GC\.Roster:CountsAsActiveRaider/],
  // Suche, Gruppenkanal und Werkstatt.
  ["Suchsitzung läuft ab", /function GC\.Chat:IsSessionActive/],
  ["Gruppenkanal folgt der Gruppe", /function GC\.Sync:GroupChannel/],
  ["Werkstattkatalog wird zwischengespeichert", /function GC\.Workshop:GetCatalogIndex/],
  ["Katalog-Cache wird gezielt verworfen", /function GC\.Workshop:InvalidateCatalog/],
  ["Rezeptsuche wird entprellt", /function GC\.UI:QueueWorkshopSearch/],
  // Gearcheck: unvollstaendig Gelesenes zaehlt nicht als geprueft.
  ["Inspect wird bei Lücken wiederholt", /MAX_INSPECT_RETRIES/],
  ["Verzauberungsname auch ohne Item-Link", /function GC\.GearAudit:ResolveEnchantNameByID/],
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

// Der Knopf im Blizzard-Gildenfenster ist ersatzlos entfallen: Er verdeckte
// Inhalte, ließ sich nicht verschieben und es bleiben genug Aufrufwege.
if (allSource.includes("AddGuildWindowButton") || allSource.includes("GuildFrame")) {
  throw new Error("Der Knopf im Blizzard-Gildenfenster ist wieder vorhanden.");
}
if (readme.includes("Button im Blizzard-Gildenfenster")) {
  throw new Error("Die README nennt den entfernten Knopf im Gildenfenster noch als Aufrufweg.");
}

// Trigger- und Ausschlusswoerter gehoeren in die Einstellungen. Fest
// verdrahtete Listen in Chat.lua wuerden sie stillschweigend uebergehen.
const chatSource = fs.readFileSync(path.join(root, "Chat.lua"), "utf8");
if (/local\s+(WHISPER_)?RECRUITMENT_TRIGGERS\s*=/.test(chatSource)) {
  throw new Error("Die Trigger-Wörter sind wieder fest in Chat.lua verdrahtet.");
}
for (const list of ["chatTriggers", "chatExclusions", "whisperTriggers", "whisperExclusions"]) {
  if (!settingsPage.includes(`"${list}"`)) {
    throw new Error(`Die Liste ${list} fehlt auf der Einstellungsseite.`);
  }
}
if (!chatSource.includes('GetRecruitmentWords("chatExclusions")')
  || !chatSource.includes('GetRecruitmentWords("whisperExclusions")')) {
  throw new Error("Die Ausschlusswörter werden nicht auf beiden Wegen ausgewertet.");
}

// Der Bewerberton haengt am Gildenrang. Die Erfassung darf er nicht anfassen:
// Wer spaeter ins Postfach sieht, soll nichts verpasst haben.
if (!chatSource.includes("GC.Roster:HearsInboxSound()")) {
  throw new Error("Der Bewerberton ist nicht mehr an den Gildenrang gebunden.");
}
const captureLead = chatSource.slice(
  chatSource.indexOf("function GC.Chat:CaptureLead"),
  chatSource.indexOf("function GC.Chat:CaptureWhisper")
);
if (/HearsInboxSound\(\)[\s\S]*?\breturn\b/.test(captureLead.split("PlaySuccessSound")[0])) {
  throw new Error("Die Rangfreigabe für den Ton verhindert jetzt die Erfassung.");
}
if (!settingsPage.includes("page.inboxSoundRankToggles")) {
  throw new Error("Die Rangfreigabe für den Bewerberton fehlt auf der Einstellungsseite.");
}

// Die Einstellungsseite scrollt, ihr Inhalt muss aber hoch genug sein: eine
// neue Karte unter der letzten waere sonst nicht erreichbar.
const settingsContentHeight = Number(
  settingsPage.match(/content:SetHeight\((\d+)\)/)?.[1]
);
const settingsCards = [];
for (const match of settingsPage.matchAll(
  /(\w+):SetSize\(752, (\d+)\)\s*\n\s*\1:SetPoint\("TOPLEFT", content, "TOPLEFT", 0, -(\d+)\)/g
)) {
  settingsCards.push({
    name: match[1],
    top: Number(match[3]),
    bottom: Number(match[3]) + Number(match[2]),
  });
}
settingsCards.sort((left, right) => left.top - right.top);
const settingsBottom = settingsCards.length > 0 ? settingsCards[settingsCards.length - 1].bottom : 0;
if (!settingsContentHeight || settingsBottom === 0) {
  throw new Error("Die Kartenmaße der Einstellungsseite lassen sich nicht mehr ablesen.");
}
// Wächst eine Karte, müssen die darunter mitwandern. Sonst schiebt sie sich in
// die nächste, und das fällt erst im Spiel auf.
for (let index = 1; index < settingsCards.length; index++) {
  const previous = settingsCards[index - 1];
  const current = settingsCards[index];
  if (current.top < previous.bottom) {
    throw new Error(
      `Die Karten ${previous.name} und ${current.name} der Einstellungen überlappen sich: ` +
        `${previous.name} endet bei ${previous.bottom}, ${current.name} beginnt bei ${current.top}.`
    );
  }
}
if (settingsContentHeight < settingsBottom) {
  throw new Error(
    `Der Scrollbereich der Einstellungen ist zu kurz: Karten reichen bis ${settingsBottom} px, ` +
      `der Inhalt ist ${settingsContentHeight} px hoch.`
  );
}

// Die Profilseite trägt die Checkliste „Erste Schritte“ ganz oben. Sie kommt
// und geht, alle Karten darunter wandern um denselben Betrag mit - deshalb
// stehen deren Maße in einer Tabelle statt verstreut im Aufbau. Geprüft wird
// dasselbe wie bei den Einstellungen: Wächst eine Karte, darf sie sich nicht in
// die nächste schieben, und der Scrollbereich muss beide Zustände tragen.
const rosterNumber = (name) => {
  const match = uiSource.match(new RegExp(`local ${name} = (\\d+)`));
  if (!match) throw new Error(`Maß ${name} der Profilseite fehlt in UI.lua.`);
  return Number(match[1]);
};
const onboardingHeight = rosterNumber("ROSTER_ONBOARDING_HEIGHT");
const rosterGap = rosterNumber("ROSTER_CARD_GAP");
const rosterContentHeight = rosterNumber("ROSTER_CONTENT_HEIGHT");
const rosterCardBlock = uiSource.slice(
  uiSource.indexOf("local ROSTER_CARDS = {"),
  uiSource.indexOf("local TAB_DEFINITIONS = {")
);
const rosterRows = [...rosterCardBlock.matchAll(
  /\{ key = "(\w+)", top = (\d+), height = (\d+)/g
)].map((match) => ({
  name: match[1],
  top: Number(match[2]),
  bottom: Number(match[2]) + Number(match[3]),
}));
if (rosterRows.length < 4) {
  throw new Error("Die Kartenmaße der Profilseite lassen sich nicht mehr ablesen.");
}
// Karten mit demselben Abstand stehen nebeneinander (Raidprofil und Berufe);
// maßgeblich ist deshalb die unterste Kante je Reihe.
const rosterLevels = new Map();
for (const row of rosterRows) {
  rosterLevels.set(row.top, {
    top: row.top,
    bottom: Math.max(rosterLevels.get(row.top)?.bottom ?? 0, row.bottom),
    name: rosterLevels.get(row.top) ? `${rosterLevels.get(row.top).name}/${row.name}` : row.name,
  });
}
const rosterOrder = [...rosterLevels.values()].sort((left, right) => left.top - right.top);
for (let index = 1; index < rosterOrder.length; index++) {
  const previous = rosterOrder[index - 1];
  const current = rosterOrder[index];
  if (current.top < previous.bottom) {
    throw new Error(
      `Die Karten ${previous.name} und ${current.name} der Profilseite überlappen sich: ` +
        `${previous.name} endet bei ${previous.bottom}, ${current.name} beginnt bei ${current.top}.`
    );
  }
}
const rosterBottom = rosterOrder[rosterOrder.length - 1].bottom;
if (rosterContentHeight < rosterBottom) {
  throw new Error(
    `Der Scrollbereich des Profils ist zu kurz: Karten reichen bis ${rosterBottom} px, ` +
      `der Inhalt ist ${rosterContentHeight} px hoch.`
  );
}
// Die Checkliste muss vollständig über die erste Karte passen, sonst schiebt
// sie sich beim Einblenden ins Raidprofil.
if (!uiSource.includes("(ROSTER_ONBOARDING_HEIGHT + ROSTER_CARD_GAP) or 0")) {
  throw new Error("Die Karten der Profilseite wandern nicht mehr um die volle Höhe der Checkliste.");
}
if (onboardingHeight <= 0 || rosterGap <= 0) {
  throw new Error("Die Checkliste hat keine brauchbare Höhe oder keinen Abstand zur ersten Karte.");
}
// Ein eigener Navigationspunkt für die Einrichtung würde die volle
// Seitenleiste sprengen; der Knopf sitzt deshalb im Fensterkopf.
if (/\{ key = "ONBOARDING"/.test(uiSource)) {
  throw new Error("Die Einrichtung hat wieder einen eigenen Navigationspunkt.");
}
if (!/CreateButton\(header, "Einrichtung"/.test(uiSource)) {
  throw new Error("Der Knopf „Einrichtung“ fehlt im Fensterkopf.");
}
// Die Spielschrift kennt weder Haken noch Pfeil und zeichnet leere Kästen -
// dieselbe Lektion wie bei der Profilbestätigung in 0.9.39.
const onboardingCard = uiSource.slice(
  uiSource.indexOf("function GC.UI:BuildOnboardingCard"),
  uiSource.indexOf("function GC.UI:RefreshOnboarding")
);
for (const glyph of ["✓", "►", "○"]) {
  if (onboardingCard.includes(glyph)) {
    throw new Error(`Die Checkliste zeichnet ihre Zustände wieder als Schriftzeichen (${glyph}).`);
  }
}
if (!onboardingCard.includes("UI-CheckBox-Check")) {
  throw new Error("Der erledigte Schritt wird nicht mehr mit der Hakentextur markiert.");
}

// GetProfessions ist eine Retail-API und im Anniversary-Client nicht
// vorhanden. Wer sich allein darauf verlaesst, erfasst nie einen Beruf - und
// merkt es nicht, weil die zuletzt von Hand eingetragene Angabe stehen bleibt.
const profileSource = fs.readFileSync(path.join(root, "Profile.lua"), "utf8");
if (!/GetNumSkillLines/.test(profileSource) || !/GetSkillLineInfo/.test(profileSource)) {
  throw new Error("Die Berufserfassung nutzt die Classic-Fähigkeitszeilen nicht mehr.");
}
// Eine eingeklappte Kategorie zaehlt ihre Zeilen nicht mit.
if (!/ExpandSkillHeader/.test(profileSource) || !/CollapseSkillHeader/.test(profileSource)) {
  throw new Error("Eingeklappte Fähigkeitskategorien werden nicht mehr geöffnet und zurückgesetzt.");
}
// „Nichts gefunden“ und „kann nicht nachsehen“ duerfen nicht dieselbe Antwort
// sein: Nur die erste heisst, dass dieser Charakter keinen Beruf hat.
for (const state of ["UNAVAILABLE", "EMPTY", "MANUAL"]) {
  if (!profileSource.includes(`"${state}"`)) {
    throw new Error(`Die Berufserfassung unterscheidet den Zustand ${state} nicht mehr.`);
  }
}
if (uiSource.includes("Automatische Synchronisierung aktiv")) {
  throw new Error("Die Berufskarte behauptet wieder Erfolg, ohne ihn zu belegen.");
}

// Entlastung beim Ein- und Ausloggen vieler Gildenmitglieder. Beide Stellen
// waren die Ursache der gemeldeten Ruckler; sie dürfen nicht zurückfallen.
const rosterSource = fs.readFileSync(path.join(root, "Roster.lua"), "utf8");
if (!/GUILD_ROSTER_UPDATE[\s\S]{0,400}ScheduleScan\(\)/.test(rosterSource)) {
  throw new Error("Der Roster-Scan läuft wieder ungedrosselt bei jedem Gildenereignis.");
}
if (!rosterSource.includes("if self.scanPending then")) {
  throw new Error("Die Entprellung des Roster-Scans sammelt keine Ereignisse mehr.");
}
// Refresh baute früher alle dreizehn Seiten neu auf, auch bei geschlossenem
// Fenster. Genau das ist der teure Fall.
const refreshBody = uiSource.slice(
  uiSource.indexOf("function GC.UI:Refresh()"),
  uiSource.indexOf("function GC.UI:CreatePostBar")
);
for (const method of ["RefreshWorkshop", "RefreshStatistics", "RefreshGear", "RefreshInbox"]) {
  if (refreshBody.includes(`self:${method}()`)) {
    throw new Error(`GC.UI:Refresh baut wieder unsichtbare Seiten auf (${method}).`);
  }
}
if (!refreshBody.includes("if not self:IsVisible() then")) {
  throw new Error("GC.UI:Refresh zeichnet wieder bei geschlossenem Fenster.");
}
if (!uiSource.includes("function GC.UI:Invalidate(")) {
  throw new Error("Die Vormerkung veralteter Seiten fehlt.");
}
// Grosse Uebertragungen pausieren im Kampf.
const syncSource = fs.readFileSync(path.join(root, "Sync.lua"), "utf8");
if (!/#self\.bulkQueue > 0 and InCombat\(\)/.test(syncSource)) {
  throw new Error("Werkstatt- und Gildenbankpakete laufen wieder mitten im Kampf.");
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

// Das Auftragsboard hat drei Abschnitte untereinander in einer Ansicht ohne
// Bildlaufleiste. Seit die eigenen Auftraege eine dritte Zeile fuer den
// Preisrahmen tragen, sind ihre Zeilen hoeher als die der offenen Auftraege -
// alles darunter rutscht mit. Hier wird nachgerechnet, dass der Inhalt ueber
// der Statuszeile bleibt.
const ordersNumber = (name) => {
  const match = uiSource.match(new RegExp(`local ${name} = (\\d+)`));
  if (!match) throw new Error(`Mass ${name} des Auftragsboards fehlt in UI.lua.`);
  return Number(match[1]);
};
const pageTop = Number(
  uiSource.match(/page:SetPoint\("TOPLEFT", frame, "TOPLEFT", \d+, -(\d+)\)/)[1]
);
const pageBottom = Number(
  uiSource.match(/page:SetPoint\("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -\d+, (\d+)\)/)[1]
);
const ordersRows = ordersNumber("ORDERS_ROWS_PER_SECTION");
const ordersRowGap = ordersNumber("ORDERS_ROW_GAP");
const ordersSection = (headerHeight, rowHeight) =>
  headerHeight + ordersRows * rowHeight + (ordersRows - 1) * ordersRowGap;
const ordersContentHeight =
  ordersSection(ordersNumber("ORDERS_HEADER_HEIGHT"), ordersNumber("ORDERS_MINE_ROW_HEIGHT")) +
  ordersNumber("ORDERS_SECTION_GAP") +
  ordersSection(
    ordersNumber("ORDERS_FILTER_HEADER_HEIGHT"),
    ordersNumber("ORDERS_OPEN_ROW_HEIGHT")
  ) +
  ordersNumber("ORDERS_SECTION_GAP") +
  ordersNumber("ORDERS_HEADER_HEIGHT") +
  ordersRows * ordersNumber("ORDERS_CLOSED_LINE_HEIGHT");
// Unten stehen Statuszeile und die Knoepfe "Statistik"/"Tracker" (30 px hoch,
// am unteren Rand verankert); so viel Platz muss frei bleiben.
const ordersViewHeight =
  frameHeight - pageTop - pageBottom - ordersNumber("ORDERS_VIEW_TOP") - 30;
if (ordersContentHeight > ordersViewHeight) {
  throw new Error(
    `Das Auftragsboard ist zu hoch: Die Abschnitte brauchen ${ordersContentHeight} px, ` +
      `ueber der Statuszeile stehen ${ordersViewHeight} px zur Verfuegung.`
  );
}
// Die Preiszeile muss in ihre Karte passen - sonst haengt sie in die naechste.
const orderRowBlock = uiSource.slice(
  uiSource.indexOf("local function BuildOrderRow("),
  uiSource.indexOf("function GC.UI:BuildOrdersView")
);
const priceLine = orderRowBlock.match(
  /row\.price[\s\S]{0,200}?height = (\d+),[\s\S]{0,200}?row\.price:SetPoint\("TOPLEFT", row, "TOPLEFT", \d+, -(\d+)\)/
);
if (!priceLine) {
  throw new Error("Die Preisrahmen-Zeile der eigenen Auftraege fehlt in BuildOrderRow.");
}
const priceBottom = Number(priceLine[2]) + Number(priceLine[1]);
if (priceBottom > ordersNumber("ORDERS_MINE_ROW_HEIGHT")) {
  throw new Error(
    `Die Preisrahmen-Zeile ragt aus ihrer Karte: Sie endet bei ${priceBottom} px, ` +
      `die Karte ist ${ordersNumber("ORDERS_MINE_ROW_HEIGHT")} px hoch.`
  );
}
// Sie darf auch nicht stumm verschwinden: Nur die eigenen Auftraege bekommen
// sie, und gefuellt wird sie beim Zeichnen jeder Zeile.
if (!/BuildOrderRow\(view, ORDERS_MINE_ROW_HEIGHT, true, true\)/.test(uiSource)) {
  throw new Error("Die Zeilen der eigenen Auftraege werden ohne Preisrahmen-Zeile gebaut.");
}
if (!/row\.price:SetText\(OrderPriceFrameLine\(order\)\)/.test(uiSource)) {
  throw new Error("Der Preisrahmen wird beim Zeichnen der Auftragszeilen nicht mehr gesetzt.");
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

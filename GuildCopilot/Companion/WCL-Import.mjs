import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const CLIENT_ID = process.env.WCL_CLIENT_ID;
const CLIENT_SECRET = process.env.WCL_CLIENT_SECRET;
const guildURL = process.argv[2];

if (!CLIENT_ID || !CLIENT_SECRET) {
  throw new Error(
    "WCL_CLIENT_ID und WCL_CLIENT_SECRET fehlen. Siehe Companion/README.md."
  );
}
if (!guildURL) {
  throw new Error("Bitte den Warcraft-Logs-Gildenlink als Argument übergeben.");
}

const parsedURL = new URL(guildURL);
if (!parsedURL.hostname.endsWith("warcraftlogs.com")) {
  throw new Error("Der Link gehört nicht zu Warcraft Logs.");
}
const match = parsedURL.pathname.match(/^\/guild\/([^/]+)\/([^/]+)\/([^/]+)/);
if (!match) {
  throw new Error("Der Link ist keine Warcraft-Logs-Gildenseite.");
}

const [, region, serverSlug, encodedGuildName] = match;
const guildName = decodeURIComponent(encodedGuildName.replaceAll("+", " "));
const apiOrigin = parsedURL.hostname.includes("fresh.")
  ? "https://fresh.warcraftlogs.com"
  : "https://www.warcraftlogs.com";

async function getAccessToken() {
  const response = await fetch("https://www.warcraftlogs.com/oauth/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString("base64")}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });
  if (!response.ok) {
    throw new Error(`WCL-Anmeldung fehlgeschlagen (${response.status}).`);
  }
  const payload = await response.json();
  if (!payload.access_token) {
    throw new Error("Warcraft Logs hat kein Zugriffstoken geliefert.");
  }
  return payload.access_token;
}

async function graphql(token, query, variables) {
  const response = await fetch(`${apiOrigin}/api/v2/client`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ query, variables }),
  });
  const payload = await response.json();
  if (!response.ok || payload.errors?.length) {
    const details = payload.errors?.map((error) => error.message).join("; ");
    throw new Error(details || `WCL-API-Fehler (${response.status}).`);
  }
  return payload.data;
}

const REPORTS_QUERY = `
  query GuildCopilotReports(
    $guildName: String!,
    $serverSlug: String!,
    $region: String!,
    $limit: Int!
  ) {
    reportData {
      reports(
        guildName: $guildName,
        guildServerSlug: $serverSlug,
        guildServerRegion: $region,
        limit: $limit
      ) {
        total
        data {
          code
          endTime
        }
      }
    }
  }
`;

const PLAYERS_QUERY = `
  query GuildCopilotPlayers($code: String!) {
    reportData {
      report(code: $code) {
        playerDetails
      }
    }
  }
`;

const SESSION_QUERY = `
  query GuildCopilotSession($code: String!) {
    reportData {
      report(code: $code) {
        startTime
        endTime
        zone { name }
        masterData { actors(type: "Player") { id name } }
        fights(killType: Encounters) {
          id
          name
          kill
          startTime
          endTime
          friendlyPlayers
        }
        deaths: table(dataType: Deaths, hostilityType: Friendlies)
        interrupts: table(dataType: Interrupts, hostilityType: Friendlies)
        dispels: table(dataType: Dispels, hostilityType: Friendlies)
        casts: table(dataType: Casts, hostilityType: Friendlies)
        buffs: table(dataType: Buffs, hostilityType: Friendlies)
      }
    }
  }
`;

// Spell-IDs, die als Verbrauchsgegenstand uebertragen werden duerfen. Diese
// Liste entscheidet ausschliesslich, WAS uebertragen wird - in welche
// Kategorie eine ID faellt, entscheidet allein GC.Consumables im Addon.
// Unbekannte IDs werden dort ignoriert und erzeugen nie falsche Zahlen.
// Die Liste darf daher grosszuegiger sein als die Addon-Tabelle.
const CONSUMABLE_IDS = new Set([
  28495, 28499, 28507, 28508, 28494, 28511, 28512, 38908,
  16666, 27869,
  35476, 35475, 35478, 35477, 35474,
  28518, 28519, 28520, 28521, 28540,
  28490, 28497, 28491, 28493, 28501, 28502, 28503, 28509, 39625, 39627,
  28017, 28019,
]);

const CLASS_KEYS = new Map([
  ["warrior", "WARRIOR"],
  ["paladin", "PALADIN"],
  ["hunter", "HUNTER"],
  ["rogue", "ROGUE"],
  ["priest", "PRIEST"],
  ["shaman", "SHAMAN"],
  ["mage", "MAGE"],
  ["warlock", "WARLOCK"],
  ["druid", "DRUID"],
]);

const SPEC_KEYS = new Map([
  ["warrior:arms", "WARRIOR:1"],
  ["warrior:fury", "WARRIOR:2"],
  ["warrior:protection", "WARRIOR:3"],
  ["paladin:holy", "PALADIN:1"],
  ["paladin:protection", "PALADIN:2"],
  ["paladin:retribution", "PALADIN:3"],
  ["hunter:beastmastery", "HUNTER:1"],
  ["hunter:marksmanship", "HUNTER:2"],
  ["hunter:survival", "HUNTER:3"],
  ["rogue:assassination", "ROGUE:1"],
  ["rogue:combat", "ROGUE:2"],
  ["rogue:subtlety", "ROGUE:3"],
  ["priest:discipline", "PRIEST:1"],
  ["priest:holy", "PRIEST:2"],
  ["priest:shadow", "PRIEST:3"],
  ["shaman:elemental", "SHAMAN:1"],
  ["shaman:enhancement", "SHAMAN:2"],
  ["shaman:restoration", "SHAMAN:3"],
  ["mage:arcane", "MAGE:1"],
  ["mage:fire", "MAGE:2"],
  ["mage:frost", "MAGE:3"],
  ["warlock:affliction", "WARLOCK:1"],
  ["warlock:demonology", "WARLOCK:2"],
  ["warlock:destruction", "WARLOCK:3"],
  ["druid:balance", "DRUID:1"],
  ["druid:feral", "DRUID:2"],
  ["druid:guardian", "DRUID:2"],
  ["druid:restoration", "DRUID:3"],
]);

function normalize(value) {
  return String(value || "").toLowerCase().replace(/[^a-z]/g, "");
}

function classFromObject(value) {
  for (const candidate of [value.type, value.class, value.className]) {
    const classKey = CLASS_KEYS.get(normalize(candidate));
    if (classKey) return classKey;
  }
  const iconClass = String(value.icon || "").split("-")[0];
  return CLASS_KEYS.get(normalize(iconClass));
}

function collectSpecNames(value) {
  const names = [];
  for (const candidate of [value.spec, value.specName, value.specialization]) {
    if (typeof candidate === "string") names.push(candidate);
  }
  if (Array.isArray(value.specs)) {
    for (const spec of value.specs) {
      if (typeof spec === "string") names.push(spec);
      else if (spec && typeof spec === "object") {
        names.push(spec.spec, spec.name, spec.specialization);
      }
    }
  }
  const iconParts = String(value.icon || "").split("-");
  if (iconParts.length > 1) names.push(iconParts.slice(1).join(""));
  return names.filter(Boolean);
}

function collectPlayers(root, reportTime, players) {
  const visited = new Set();
  function visit(value) {
    if (!value || typeof value !== "object" || visited.has(value)) return;
    visited.add(value);
    if (Array.isArray(value)) {
      value.forEach(visit);
      return;
    }

    const classFile = classFromObject(value);
    if (classFile && typeof value.name === "string") {
      const className = classFile.toLowerCase();
      const specs = collectSpecNames(value)
        .map((name) => SPEC_KEYS.get(`${className}:${normalize(name)}`))
        .filter(Boolean);
      if (specs.length) {
        const safeName = value.name.replace(/[;\r\n]/g, "");
        const player = players.get(safeName) || {
          name: safeName,
          classFile,
          specs: new Map(),
        };
        for (const specKey of specs) {
          player.specs.set(specKey, Math.max(player.specs.get(specKey) || 0, reportTime));
        }
        players.set(safeName, player);
      }
    }
    Object.values(value).forEach(visit);
  }
  visit(root);
}

// Die WCL-Tabellen liefern je nach Datentyp unterschiedlich verschachtelte
// Strukturen. Statt auf eine feste Form zu setzen, wird nach Eintraegen mit
// Namen gesucht und deren Zaehler aufsummiert. Fehlt eine Tabelle, bleibt der
// Wert schlicht null - dann wird nichts exportiert statt etwas geraten.
function collectTableTotals(table) {
  const totals = new Map();
  if (!table) return totals;
  const entries = table?.data?.entries ?? table?.entries ?? table?.data ?? [];
  if (!Array.isArray(entries)) return totals;
  for (const entry of entries) {
    const name = entry?.name;
    if (typeof name !== "string") continue;
    const amount = Number(entry.total ?? entry.count ?? entry.uses ?? 1) || 0;
    totals.set(name, (totals.get(name) || 0) + amount);
  }
  return totals;
}

// Casts- und Buffs-Tabellen listen je Spieler dessen Faehigkeiten. Nur IDs aus
// CONSUMABLE_IDS werden uebernommen.
function collectConsumables(table, perPlayer) {
  const entries = table?.data?.entries ?? table?.entries ?? [];
  if (!Array.isArray(entries)) return;
  for (const entry of entries) {
    const name = entry?.name;
    if (typeof name !== "string") continue;
    const abilities = entry.abilities ?? entry.spells ?? [];
    if (!Array.isArray(abilities)) continue;
    const counts = perPlayer.get(name) || new Map();
    for (const ability of abilities) {
      const abilityID = Number(ability?.guid ?? ability?.id ?? ability?.abilityIcon);
      if (!CONSUMABLE_IDS.has(abilityID)) continue;
      const amount = Number(ability.total ?? ability.uses ?? ability.hitCount ?? 1) || 0;
      if (amount > 0) counts.set(abilityID, (counts.get(abilityID) || 0) + amount);
    }
    if (counts.size) perPlayer.set(name, counts);
  }
}

function buildSessionLines(code, report) {
  if (!report) return [];

  const actorNames = new Map();
  for (const actor of report.masterData?.actors || []) {
    if (actor?.id != null && typeof actor.name === "string") {
      actorNames.set(actor.id, actor.name.replace(/[|;,\r\n]/g, ""));
    }
  }

  const fights = Array.isArray(report.fights) ? report.fights : [];
  let kills = 0;
  let wipes = 0;
  const secondsByPlayer = new Map();
  for (const fight of fights) {
    if (fight.kill === true) kills += 1;
    else if (fight.kill === false) wipes += 1;
    const duration = Math.max(0, Number(fight.endTime || 0) - Number(fight.startTime || 0)) / 1000;
    for (const actorID of fight.friendlyPlayers || []) {
      const name = actorNames.get(actorID);
      if (name) secondsByPlayer.set(name, (secondsByPlayer.get(name) || 0) + duration);
    }
  }

  const deaths = collectTableTotals(report.deaths);
  const interrupts = collectTableTotals(report.interrupts);
  const dispels = collectTableTotals(report.dispels);
  const consumables = new Map();
  collectConsumables(report.casts, consumables);
  collectConsumables(report.buffs, consumables);

  const names = new Set([
    ...secondsByPlayer.keys(),
    ...deaths.keys(),
    ...interrupts.keys(),
    ...dispels.keys(),
  ]);
  if (!names.size) return [];

  const zone = String(report.zone?.name || "").replace(/[|;,\r\n]/g, "");
  const startedAt = Math.floor(Number(report.startTime || 0) / 1000);
  const endedAt = Math.floor(Number(report.endTime || 0) / 1000);
  const lines = [
    `S|${code}|${startedAt}|${endedAt}|${zone}|${fights.length}|${kills}|${wipes}`,
  ];

  for (const name of [...names].sort((a, b) => a.localeCompare(b))) {
    const counts = consumables.get(name);
    const consumableText = counts
      ? [...counts.entries()].map(([id, count]) => `${id}:${count}`).join(",")
      : "";
    lines.push([
      "P",
      name,
      "",
      Math.round(secondsByPlayer.get(name) || 0),
      deaths.get(name) || 0,
      interrupts.get(name) || 0,
      dispels.get(name) || 0,
      consumableText,
    ].join("|"));
  }
  return lines;
}

const token = await getAccessToken();
const reportData = await graphql(token, REPORTS_QUERY, {
  guildName,
  serverSlug,
  region: region.toLowerCase(),
  limit: 12,
});
const reports = reportData.reportData?.reports?.data || [];
if (!reports.length) {
  throw new Error("Für diese Gilde wurden keine öffentlichen Reports gefunden.");
}

reports.sort((left, right) => (right.endTime || 0) - (left.endTime || 0));
const players = new Map();
for (const report of reports) {
  const reportResult = await graphql(token, PLAYERS_QUERY, { code: report.code });
  collectPlayers(
    reportResult.reportData?.report?.playerDetails,
    Number(report.endTime) || 0,
    players
  );
}

const lines = [`GCPWCL2|${reports.length}`];
for (const player of [...players.values()].sort((a, b) => a.name.localeCompare(b.name))) {
  const specs = [...player.specs.entries()]
    .sort((left, right) => right[1] - left[1])
    .map(([specKey]) => specKey);
  lines.push(`${player.name};${player.classFile};${specs[0]};${specs[1] || ""}`);
}

const profileCount = lines.length - 1;

// Nachanalyse je Report. Faellt eine Abfrage aus, bleibt der Profilexport
// trotzdem nutzbar.
let sessionCount = 0;
for (const report of reports) {
  try {
    const sessionResult = await graphql(token, SESSION_QUERY, { code: report.code });
    const sessionLines = buildSessionLines(
      report.code,
      sessionResult.reportData?.report
    );
    if (sessionLines.length > 1) {
      lines.push(...sessionLines);
      sessionCount += 1;
    }
  } catch (error) {
    console.warn(`Report ${report.code} ohne Nachanalyse: ${error.message}`);
  }
}

if (profileCount === 0 && sessionCount === 0) {
  throw new Error("In den Reports konnten weder Spieler noch Raiddaten erkannt werden.");
}

const outputPath = path.join(
  process.env.TEMP || path.dirname(fileURLToPath(import.meta.url)),
  "GuildCopilot-WCL-Import.txt"
);
fs.writeFileSync(outputPath, `${lines.join("\n")}\n`, "utf8");
console.log(
  `Fertig: ${profileCount} Spieler und ${sessionCount} Raidauswertungen aus ${reports.length} Reports.`
);
console.log(`Importdatei: ${outputPath}`);

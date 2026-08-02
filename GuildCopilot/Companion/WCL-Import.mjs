// Guild-Copilot-Companion fuer Warcraft Logs.
//
// Ein WoW-Addon darf nicht ins Netz. Dieses Programm liest oeffentliche
// Reports ueber die offizielle GraphQL-API v2 und schreibt einen Importcode,
// der im Addon unter "Warcraft Logs" eingefuegt wird.
//
// Aufruf:
//   node WCL-Import.mjs "<Gildenlink>"        alle juengsten Reports der Gilde
//   node WCL-Import.mjs --report <Code>       genau ein Report (zum Testen)
//
// Optionen:
//   --reports <n>   Anzahl der juengsten Reports (Standard 3, Maximum 12)
//   --profiles      nur Spielerprofile, keine Raidauswertung
//   --sessions      nur Raidauswertung, keine Spielerprofile
//   --debug         schreibt jede Rohantwort nach GuildCopilot-WCL-Debug.json
//   --out <Pfad>    Zieldatei fuer den Importcode
//
// Zwei Dinge sind an der WCL-API leicht zu uebersehen und haben den Import
// frueher zuverlaessig scheitern lassen:
//   1. "playerDetails" und "table" brauchen ein echtes Zeitfenster. Sind
//      startTime und endTime beide 0, antwortet die API mit einem Fehler
//      statt mit leeren Daten.
//   2. Die JSON-Form der "table"-Antworten haengt am Datentyp. Deshalb wird
//      hier ueber "events" aggregiert: dort steht je Ereignis eine Akteurs-ID
//      und eine Spell-ID, das ist unabhaengig von der Tabellenform.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const FORMAT_HEADER = "GCPWCL3";

// Spell-IDs, die als Verbrauchsgegenstand uebertragen werden duerfen. Diese
// Liste entscheidet ausschliesslich, WAS uebertragen wird - in welche
// Kategorie eine ID faellt, entscheidet allein GC.Consumables im Addon.
// Unbekannte IDs werden dort ignoriert und erzeugen nie falsche Zahlen.
// Die Liste darf daher grosszuegiger sein als die Addon-Tabelle.
export const CONSUMABLE_IDS = [
  28495, 28499, 28507, 28508, 28494, 28506, 28511, 28512, 38908,
  // Salben und Flaschen aus Zangarmarschen und Netherstrum - in TBC der
  // meistbenutzte Manatrank ueberhaupt. Sie fehlten, und was hier fehlt,
  // filtert die Abfrage weg: In einem Vergleichslog blieben so 146
  // Anwendungen unsichtbar.
  41617, 41618, 41619, 41620,
  16666, 27869,
  35476, 35475, 35478, 35477, 35474,
  28518, 28519, 28520, 28521, 28540,
  28490, 28497, 28491, 28493, 28501, 28502, 28503, 28509, 39625, 39627,
  17539, 33720, 33721,
  28017, 28019,
  // Sattgegessen-Buffs. Jedes Gericht hat eine eigene ID; die reinen
  // "Food"-Regenerationsauren stehen bewusst nicht hier, weil sie keine Werte
  // geben und damit kein Raidbuff sind.
  33254, 33256, 33257, 33259, 33261, 33263, 33265, 33268, 43764, 45245,
];

const CONSUMABLE_SET = new Set(CONSUMABLE_IDS);

// Warcraft Logs kennt keinen Ereignistyp "Resurrects" - das Enum EventDataType
// hat ihn schlicht nicht. Wiederbelebungen werden deshalb wie in der
// Livesitzung ueber den gewirkten Zauber gezaehlt.
//
// Jede ID hier ist einzeln gegen die TBC-Spelldatenbank geprueft. Das ist
// keine Formsache: eine aus dem Gedaechtnis eingetragene ID (25235) war in
// Wirklichkeit "Flash Heal" und hat den Priestern 349, 256 und 209
// Wiederbelebungen angedichtet. Eine falsche ID erzeugt falsche Zahlen, eine
// fehlende nur unvollstaendige - deshalb kommt hier nichts Ungeprueftes rein.
export const RESURRECT_IDS = [
  // Wiedergeburt (Druide), Raenge 1-6
  20484, 20739, 20742, 20747, 20748, 26994,
  // Auferstehung (Priester), Raenge 1-6
  2006, 2010, 10880, 10881, 20770, 25435,
  // Erloesung (Paladin), Raenge 1-5
  7328, 10322, 10324, 20772, 20773,
  // Ahnengeist (Schamane), Raenge 1-6
  2008, 20609, 20610, 20776, 20777, 25590,
  // Selbstwiederbelebung: Reinkarnation und Seelenstein
  20608,
  20707, 20762, 20763, 20764, 20765, 27239,
];

const RESURRECT_SET = new Set(RESURRECT_IDS);

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

// ---------------------------------------------------------------------------
// Reine Hilfsfunktionen. Sie kennen kein Netz und werden in tests/companion.mjs
// gegen eine aufgezeichnete Antwort geprueft.
// ---------------------------------------------------------------------------

export function normalize(value) {
  return String(value || "").toLowerCase().replace(/[^a-z]/g, "");
}

function sanitize(value) {
  return String(value || "").replace(/[|;,\r\n]/g, "");
}

export function classFromObject(value) {
  for (const candidate of [value.type, value.class, value.className, value.subType]) {
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

// playerDetails liefert je nach Report unterschiedlich verschachtelte Objekte
// (tanks/healers/dps, teilweise noch eine Ebene "data" darueber). Statt auf
// eine feste Form zu setzen wird der Baum nach Eintraegen mit Klasse und Name
// durchsucht.
export function collectPlayers(root, reportTime, players) {
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
        const safeName = sanitize(value.name);
        const playerKey = safeName.toLowerCase();
        const player = players.get(playerKey) || {
          name: safeName,
          classFile,
          specs: new Map(),
        };
        for (const specKey of specs) {
          player.specs.set(specKey, Math.max(player.specs.get(specKey) || 0, reportTime));
        }
        players.set(playerKey, player);
      }
    }
    Object.values(value).forEach(visit);
  }
  visit(root);
  return players;
}

export function buildActorIndex(masterData) {
  const actors = new Map();
  for (const actor of masterData?.actors || []) {
    if (actor?.id == null || typeof actor.name !== "string") continue;
    actors.set(actor.id, {
      name: sanitize(actor.name),
      classFile: classFromObject(actor) || "",
    });
  }
  return actors;
}

// Ein Ereignis nennt entweder den Verursacher (sourceID) oder das Ziel
// (targetID). Welches Feld zaehlt, entscheidet der Aufrufer - damit stimmen
// die Zahlen mit der Livesitzung ueberein: Wiederbelebungen zaehlen beim
// Wirkenden, Tode beim Gestorbenen.
export function countEventsByActor(events, field, allowedTypes) {
  const counts = new Map();
  for (const event of events || []) {
    if (allowedTypes && !allowedTypes.has(event?.type)) continue;
    const actorID = event?.[field];
    if (actorID == null) continue;
    counts.set(actorID, (counts.get(actorID) || 0) + 1);
  }
  return counts;
}

// Zaehlt gewirkte Zauber aus einer ID-Liste beim Wirkenden. Wird fuer
// Wiederbelebungen gebraucht, weil Warcraft Logs dafuer keinen eigenen
// Ereignistyp kennt.
export function countCastsOfSpells(events, allowedIDs) {
  const counts = new Map();
  for (const event of events || []) {
    if (event?.type !== "cast") continue;
    if (!allowedIDs.has(Number(event.abilityGameID))) continue;
    const actorID = event.sourceID;
    if (actorID == null) continue;
    counts.set(actorID, (counts.get(actorID) || 0) + 1);
  }
  return counts;
}

// Verbrauchsgegenstaende tauchen je nach Gegenstand als Zauber (Traenke,
// Runen, Trommeln) oder nur als Buff (Elixiere, Flaeschchen, Essen, Oele) auf.
//
// Entscheidend ist die Richtung: Ein Zauber nennt den Verursacher, ein Buff
// nur den Beschenkten. Trommeln buffen die ganze Gruppe - wer den Buff
// bekommt, hat deshalb noch lange nichts verbraucht. Ein frueheres
// "Maximum aus beidem" hat genau daran vier Trommler zu vierzehn gemacht und
// einem Krieger 19 Trommeln angedichtet, die er nie benutzt hat.
//
// Die Regel lautet deshalb je Spell-ID: Gibt es ueberhaupt Zauber dazu, ist
// der Zauber massgeblich und der Buff wird ignoriert. Nur wenn ein Gegenstand
// gar keinen Zauber erzeugt, wird der Buff beim Ziel gezaehlt. Das kann
// untererfassen - etwa wenn vor Logbeginn getrunken wurde -, aber es schreibt
// niemandem etwas zu, das er nicht selbst verbraucht hat.
export function collectConsumables(castEvents, buffEvents) {
  const castsByActor = new Map();
  const buffsByActor = new Map();
  const abilitiesWithCasts = new Set();

  function tally(events, field, allowedTypes, target) {
    for (const event of events || []) {
      if (!allowedTypes.has(event?.type)) continue;
      const abilityID = Number(event.abilityGameID);
      if (!CONSUMABLE_SET.has(abilityID)) continue;
      const actorID = event[field];
      if (actorID == null) continue;
      const counts = target.get(actorID) || new Map();
      counts.set(abilityID, (counts.get(abilityID) || 0) + 1);
      target.set(actorID, counts);
      if (target === castsByActor) abilitiesWithCasts.add(abilityID);
    }
  }

  tally(castEvents, "sourceID", new Set(["cast"]), castsByActor);
  // "refreshbuff" gehoert dazu: Wer nach einem Wipe dasselbe Gericht noch
  // einmal isst, waehrend der Buff noch laeuft, erzeugt keine neue Anwendung,
  // sondern eine Auffrischung. Ohne sie zaehlte ein ganzer Raidabend Essen
  // als ein einziges Essen.
  tally(buffEvents, "targetID", new Set(["applybuff", "refreshbuff"]), buffsByActor);

  const merged = new Map();
  for (const [actorID, counts] of castsByActor) {
    merged.set(actorID, new Map(counts));
  }
  for (const [actorID, counts] of buffsByActor) {
    for (const [abilityID, amount] of counts) {
      if (abilitiesWithCasts.has(abilityID)) continue;
      const flat = merged.get(actorID) || new Map();
      flat.set(abilityID, Math.max(flat.get(abilityID) || 0, amount));
      merged.set(actorID, flat);
    }
  }
  return merged;
}

// Anwesenheitszeit: Summe der Kampfdauern, in denen der Spieler als
// freundlicher Teilnehmer gefuehrt wird. Trash zaehlt nicht mit, weil nur
// Encounter-Kaempfe abgefragt werden.
export function buildAttendance(fights, actors) {
  const seconds = new Map();
  let kills = 0;
  let wipes = 0;
  for (const fight of fights || []) {
    if (fight.kill === true) kills += 1;
    else if (fight.kill === false) wipes += 1;
    const duration = Math.max(0, Number(fight.endTime || 0) - Number(fight.startTime || 0)) / 1000;
    for (const actorID of fight.friendlyPlayers || []) {
      if (!actors.has(actorID)) continue;
      seconds.set(actorID, (seconds.get(actorID) || 0) + duration);
    }
  }
  return { seconds, kills, wipes, pulls: (fights || []).length };
}

export function buildSessionLines(code, report, aggregates) {
  if (!report) return [];

  const actors = buildActorIndex(report.masterData);
  const fights = Array.isArray(report.fights) ? report.fights : [];
  const { seconds, kills, wipes, pulls } = buildAttendance(fights, actors);

  const deaths = countEventsByActor(aggregates.deaths, "targetID", new Set(["death"]));
  const resurrects = countCastsOfSpells(aggregates.resurrects, RESURRECT_SET);
  const interrupts = countEventsByActor(aggregates.interrupts, "sourceID", new Set(["interrupt"]));
  const dispels = countEventsByActor(aggregates.dispels, "sourceID", new Set(["dispel"]));
  const consumables = collectConsumables(aggregates.casts, aggregates.buffs);

  // Ereignisse werden absichtlich über den ganzen Report gelesen. In die
  // Sitzung gehören trotzdem nur Akteure, die an mindestens einem Encounter
  // teilgenommen haben; sonst würden Trash-Helfer und Zuschauer als Spieler
  // mit null Anwesenheit auftauchen.
  const actorIDs = new Set(seconds.keys());
  if (!actorIDs.size) return [];

  const zone = sanitize(report.zone?.name);
  const startedAt = Math.floor(Number(report.startTime || 0) / 1000);
  const endedAt = Math.floor(Number(report.endTime || 0) / 1000);
  const lines = [
    `S|${code}|${startedAt}|${endedAt}|${zone}|${pulls}|${kills}|${wipes}`,
  ];

  const rows = [];
  for (const actorID of actorIDs) {
    const actor = actors.get(actorID);
    if (!actor || actor.name === "") continue;
    const counts = consumables.get(actorID);
    const consumableText = counts
      ? [...counts.entries()]
          .filter(([, count]) => count > 0)
          .map(([id, count]) => `${id}:${count}`)
          .join(",")
      : "";
    rows.push([
      "P",
      actor.name,
      actor.classFile,
      Math.round(seconds.get(actorID) || 0),
      deaths.get(actorID) || 0,
      interrupts.get(actorID) || 0,
      dispels.get(actorID) || 0,
      consumableText,
      resurrects.get(actorID) || 0,
    ].join("|"));
  }
  if (!rows.length) return [];

  rows.sort();
  lines.push(...rows);
  return lines;
}

export function buildProfileLines(players) {
  const lines = [];
  for (const player of [...players.values()].sort((a, b) => a.name.localeCompare(b.name))) {
    const specs = [...player.specs.entries()]
      .sort((left, right) => right[1] - left[1])
      .map(([specKey]) => specKey);
    lines.push(`${player.name};${player.classFile};${specs[0]};${specs[1] || ""}`);
  }
  return lines;
}

// Aus einem Link wird entweder eine Gilde oder ein einzelner Report. Der
// Gildenname steht in der URL nur als Slug ("die-waechter"); die API erwartet
// den echten Namen. Deshalb werden mehrere Schreibweisen als Kandidaten
// zurueckgegeben und spaeter die erste ausprobiert, die Reports liefert.
export function parseTarget(input) {
  const raw = String(input || "").trim();
  if (raw === "") {
    throw new Error("Bitte einen Warcraft-Logs-Link oder einen Reportcode angeben.");
  }

  if (!raw.includes("/") && /^[a-zA-Z0-9]{10,}$/.test(raw)) {
    return { kind: "report", code: raw, origins: defaultOrigins("") };
  }

  let url;
  try {
    url = new URL(/^https?:\/\//i.test(raw) ? raw : `https://${raw}`);
  } catch {
    throw new Error("Der Warcraft-Logs-Link ist ungültig.");
  }
  if (!["http:", "https:"].includes(url.protocol)
      || (url.hostname !== "warcraftlogs.com" && !url.hostname.endsWith(".warcraftlogs.com"))) {
    throw new Error("Der Link gehoert nicht zu Warcraft Logs.");
  }
  const origins = defaultOrigins(url.hostname);

  const reportMatch = url.pathname.match(/^\/reports\/([a-zA-Z0-9]+)\/?$/);
  if (reportMatch) {
    return { kind: "report", code: reportMatch[1], origins };
  }

  const guildIDMatch = url.pathname.match(/^\/guild\/id\/(\d+)\/?$/);
  if (guildIDMatch) {
    return { kind: "guild", guildID: Number(guildIDMatch[1]), origins };
  }

  const guildMatch = url.pathname.match(/^\/guild\/([^/]+)\/([^/]+)\/([^/]+)\/?$/);
  if (!guildMatch) {
    throw new Error("Der Link ist weder eine Warcraft-Logs-Gildenseite noch ein Report.");
  }
  const [, region, serverSlug, encodedName] = guildMatch;
  const decoded = decodeURIComponent(encodedName.replaceAll("+", " "));
  if (!["eu", "us", "kr", "tw", "cn"].includes(region.toLowerCase())
      || decoded === "" || /[\/\\\u0000-\u001f]/.test(decoded)) {
    throw new Error("Der Warcraft-Logs-Gildenlink enthält ungültige Angaben.");
  }
  const names = [decoded];
  if (decoded.includes("-")) names.push(decoded.replaceAll("-", " "));
  const titled = names[names.length - 1]
    .split(" ")
    .map((word) => (word ? word[0].toUpperCase() + word.slice(1) : word))
    .join(" ");
  if (!names.includes(titled)) names.push(titled);

  return {
    kind: "guild",
    region: region.toLowerCase(),
    serverSlug: serverSlug.toLowerCase(),
    guildNames: names,
    origins,
  };
}

// Warcraft Logs betreibt je Spielvariante eine eigene Seite mit eigener API.
// Der Link nennt die richtige, aber wenn dort nichts gefunden wird, sind die
// anderen einen Versuch wert - das ist der haeufigste Grund fuer "keine
// Reports gefunden".
export function defaultOrigins(hostname) {
  const origins = [];
  const push = (origin) => {
    if (!origins.includes(origin)) origins.push(origin);
  };
  const host = String(hostname || "");
  if (host.includes("fresh.")) push("https://fresh.warcraftlogs.com");
  if (host.includes("classic.")) push("https://classic.warcraftlogs.com");
  if (host.includes("sod.")) push("https://sod.warcraftlogs.com");
  if (host.includes("vanilla.")) push("https://vanilla.warcraftlogs.com");
  push("https://fresh.warcraftlogs.com");
  push("https://classic.warcraftlogs.com");
  push("https://www.warcraftlogs.com");
  return origins;
}

export function parseArguments(argv) {
  const options = {
    target: "",
    reports: 3,
    profiles: true,
    sessions: true,
    debug: false,
    out: "",
  };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--report") {
      options.target = argv[++index] || "";
    } else if (argument === "--reports") {
      const value = Number(argv[++index]);
      if (!Number.isFinite(value) || value < 1) {
        throw new Error("--reports braucht eine Zahl ab 1.");
      }
      options.reports = Math.min(12, Math.floor(value));
    } else if (argument === "--profiles") {
      options.sessions = false;
    } else if (argument === "--sessions") {
      options.profiles = false;
    } else if (argument === "--debug") {
      options.debug = true;
    } else if (argument === "--out") {
      options.out = argv[++index] || "";
    } else if (argument.startsWith("--")) {
      throw new Error(`Unbekannte Option: ${argument}`);
    } else if (options.target === "") {
      options.target = argument;
    }
  }
  return options;
}

// ---------------------------------------------------------------------------
// Netzzugriff
// ---------------------------------------------------------------------------

const REPORTS_QUERY = `
  query GuildCopilotReports(
    $guildName: String,
    $serverSlug: String,
    $region: String,
    $guildID: Int,
    $limit: Int!
  ) {
    reportData {
      reports(
        guildName: $guildName,
        guildServerSlug: $serverSlug,
        guildServerRegion: $region,
        guildID: $guildID,
        limit: $limit
      ) {
        total
        data { code startTime endTime title }
      }
    }
  }
`;

const META_QUERY = `
  query GuildCopilotMeta($code: String!) {
    reportData {
      report(code: $code) {
        code
        title
        startTime
        endTime
        zone { name }
        masterData { actors(type: "Player") { id name subType } }
        fights(killType: Encounters) {
          id
          name
          kill
          startTime
          endTime
          friendlyPlayers
        }
      }
    }
  }
`;

const DETAILS_QUERY = `
  query GuildCopilotDetails($code: String!, $start: Float!, $end: Float!) {
    reportData {
      report(code: $code) {
        playerDetails(startTime: $start, endTime: $end)
      }
    }
  }
`;

const EVENTS_QUERY = `
  query GuildCopilotEvents(
    $code: String!,
    $dataType: EventDataType!,
    $start: Float!,
    $end: Float!,
    $fightIDs: [Int],
    $filter: String
  ) {
    reportData {
      report(code: $code) {
        events(
          dataType: $dataType,
          startTime: $start,
          endTime: $end,
          fightIDs: $fightIDs,
          hostilityType: Friendlies,
          filterExpression: $filter,
          limit: 10000
        ) {
          data
          nextPageTimestamp
        }
      }
    }
  }
`;

class Client {
  constructor(token, origin, debug) {
    this.token = token;
    this.origin = origin;
    this.debug = debug;
    this.calls = 0;
  }

  async query(label, query, variables) {
    this.calls += 1;
    const response = await fetch(`${this.origin}/api/v2/client`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ query, variables }),
    });

    let payload;
    const text = await response.text();
    try {
      payload = JSON.parse(text);
    } catch {
      throw new Error(`${label}: unlesbare Antwort (${response.status}).`);
    }

    if (this.debug) {
      recordDebug({ label, origin: this.origin, variables, status: response.status, payload });
    }
    if (!response.ok || payload.errors?.length) {
      const details = payload.errors?.map((error) => error.message).join("; ");
      throw new Error(details || `${label}: WCL-API-Fehler (${response.status}).`);
    }
    return payload.data;
  }

  async events(code, dataType, window, fightIDs, filter) {
    const collected = [];
    let start = window.start;
    for (let page = 0; page < 40; page += 1) {
      const data = await this.query(
        `events(${dataType})`,
        EVENTS_QUERY,
        { code, dataType, start, end: window.end, fightIDs, filter: filter || null }
      );
      const paginator = data.reportData?.report?.events;
      const rows = Array.isArray(paginator?.data) ? paginator.data : [];
      collected.push(...rows);
      const next = Number(paginator?.nextPageTimestamp);
      if (!Number.isFinite(next) || next <= start) break;
      start = next;
    }
    return collected;
  }
}

let debugEntries = null;

function recordDebug(entry) {
  if (!debugEntries) debugEntries = [];
  debugEntries.push(entry);
}

async function getAccessToken(clientID, clientSecret) {
  const response = await fetch("https://www.warcraftlogs.com/oauth/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${Buffer.from(`${clientID}:${clientSecret}`).toString("base64")}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });
  if (!response.ok) {
    const hint = response.status === 401
      ? " Client ID oder Client Secret stimmen nicht."
      : "";
    throw new Error(`WCL-Anmeldung fehlgeschlagen (${response.status}).${hint}`);
  }
  const payload = await response.json();
  if (!payload.access_token) {
    throw new Error("Warcraft Logs hat kein Zugriffstoken geliefert.");
  }
  return payload.access_token;
}

// Probiert Seite fuer Seite und - bei einer Gilde - Schreibweise fuer
// Schreibweise, bis Reports auftauchen. Was probiert wurde, steht danach im
// Protokoll, damit ein Fehlschlag erklaerbar bleibt.
async function resolveReports(token, target, limit, debug, log) {
  const attempts = [];
  for (const origin of target.origins) {
    const client = new Client(token, origin, debug);

    if (target.kind === "report") {
      try {
        const data = await client.query("report", META_QUERY, { code: target.code });
        const report = data.reportData?.report;
        if (report?.code) {
          log(`Report ${target.code} auf ${origin} gefunden.`);
          return { client, reports: [report], meta: new Map([[report.code, report]]) };
        }
        attempts.push(`${origin}: Report unbekannt`);
      } catch (error) {
        attempts.push(`${origin}: ${error.message}`);
      }
      continue;
    }

    const nameCandidates = target.guildID ? [null] : target.guildNames;
    for (const guildName of nameCandidates) {
      try {
        const data = await client.query("reports", REPORTS_QUERY, {
          guildName,
          serverSlug: guildName ? target.serverSlug : null,
          region: guildName ? target.region : null,
          guildID: target.guildID ?? null,
          limit,
        });
        const reports = data.reportData?.reports?.data || [];
        if (reports.length) {
          log(`${reports.length} Reports auf ${origin}${guildName ? ` fuer "${guildName}"` : ""} gefunden.`);
          reports.sort((left, right) => (right.endTime || 0) - (left.endTime || 0));
          return { client, reports, meta: new Map() };
        }
        attempts.push(`${origin}${guildName ? ` / "${guildName}"` : ""}: 0 Reports`);
      } catch (error) {
        attempts.push(`${origin}${guildName ? ` / "${guildName}"` : ""}: ${error.message}`);
      }
    }
  }

  throw new Error(
    `Keine oeffentlichen Reports gefunden.\nVersucht wurde:\n  ${attempts.join("\n  ")}`
  );
}

async function main() {
  const options = parseArguments(process.argv.slice(2));
  const clientID = process.env.WCL_CLIENT_ID;
  const clientSecret = process.env.WCL_CLIENT_SECRET;
  if (!clientID || !clientSecret) {
    throw new Error("WCL_CLIENT_ID und WCL_CLIENT_SECRET fehlen. Siehe Companion/README.md.");
  }

  const log = (message) => console.log(`  ${message}`);
  const target = parseTarget(options.target);

  console.log("Guild Copilot - Warcraft-Logs-Import");
  console.log(`Schritt 1: Anmeldung`);
  const token = await getAccessToken(clientID, clientSecret);
  log("Zugriffstoken erhalten.");

  console.log("Schritt 2: Reports suchen");
  const { client, reports, meta } = await resolveReports(
    token,
    target,
    options.reports,
    options.debug,
    log
  );
  const selected = reports.slice(0, options.reports);

  const players = new Map();
  const sessionBlocks = [];
  const warnings = [];

  for (const [index, report] of selected.entries()) {
    const code = report.code;
    console.log(`Schritt 3.${index + 1}: Report ${code}`);

    let detail = meta.get(code);
    if (!detail) {
      const data = await client.query("report", META_QUERY, { code });
      detail = data.reportData?.report;
    }
    if (!detail) {
      warnings.push(`Report ${code} liess sich nicht laden.`);
      continue;
    }

    const duration = Math.max(1, Number(detail.endTime || 0) - Number(detail.startTime || 0));
    const window = { start: 0, end: duration };
    const fights = Array.isArray(detail.fights) ? detail.fights : [];
    const fightIDs = fights.map((fight) => fight.id).filter((id) => id != null);
    // masterData fuehrt jeden Akteur, den das Log je gesehen hat - auch
    // Umstehende und Trash. Ausgewertet wird nur, wer in einem Encounter
    // steht; deshalb werden beide Zahlen getrennt genannt.
    const participants = new Set();
    for (const fight of fights) {
      for (const actorID of fight.friendlyPlayers || []) participants.add(actorID);
    }
    log(`${fights.length} Encounter-Kaempfe, ${participants.size} Teilnehmer `
      + `(${detail.masterData?.actors?.length || 0} Akteure im Log).`);

    if (options.profiles) {
      try {
        const data = await client.query("playerDetails", DETAILS_QUERY, {
          code,
          start: window.start,
          end: window.end,
        });
        const before = players.size;
        collectPlayers(
          data.reportData?.report?.playerDetails,
          Number(detail.endTime) || 0,
          players
        );
        log(`Profile: ${players.size - before} neu, ${players.size} gesamt.`);
      } catch (error) {
        warnings.push(`Report ${code} ohne Profile: ${error.message}`);
      }
    }

    if (options.sessions && fightIDs.length) {
      // Jede Ereignisart wird einzeln abgesichert. Vorher riss eine einzige
      // fehlgeschlagene Abfrage die komplette Auswertung mit - aus einem
      // fehlenden Feld wurde so ein vollstaendiger Datenverlust.
      const consumableFilter = `ability.id in (${CONSUMABLE_IDS.join(", ")})`;
      const resurrectFilter = `ability.id in (${RESURRECT_IDS.join(", ")})`;
      const requests = [
        ["deaths", "Deaths", null],
        ["resurrects", "Casts", resurrectFilter],
        ["interrupts", "Interrupts", null],
        ["dispels", "Dispels", null],
        ["casts", "Casts", consumableFilter],
        ["buffs", "Buffs", consumableFilter],
      ];

      // Bewusst ueber den ganzen Report statt nur ueber die Bosskaempfe:
      // wiederbelebt wird fast immer zwischen den Pulls, dispelt und
      // unterbrochen wird auch auf Trash, und getrunken wird vor dem Pull.
      // Auf die Kaempfe eingegrenzt fehlte davon der groesste Teil. Die
      // Anwesenheitszeit bleibt kampfbasiert, sie misst genau das.
      const aggregates = {};
      const failed = [];
      for (const [key, dataType, filter] of requests) {
        try {
          aggregates[key] = await client.events(code, dataType, window, null, filter);
        } catch (error) {
          aggregates[key] = [];
          failed.push(key);
          warnings.push(`Report ${code}, ${key}: ${error.message}`);
        }
      }

      const lines = buildSessionLines(code, detail, aggregates);
      if (lines.length > 1) {
        sessionBlocks.push(lines);
        const missing = failed.length ? `, ohne ${failed.join("/")}` : "";
        log(`Auswertung: ${lines.length - 1} Teilnehmer, ${aggregates.deaths.length} Tode${missing}.`);
      } else {
        warnings.push(`Report ${code} enthielt keine auswertbaren Teilnehmer.`);
      }
    } else if (options.sessions) {
      warnings.push(`Report ${code} hat keine Encounter-Kaempfe.`);
    }
  }

  const profileLines = buildProfileLines(players);
  if (!profileLines.length && !sessionBlocks.length) {
    const detail = warnings.length ? `\n  ${warnings.join("\n  ")}` : "";
    throw new Error(`In den Reports konnten weder Spieler noch Raiddaten erkannt werden.${detail}`);
  }

  const lines = [`${FORMAT_HEADER}|${selected.length}`, ...profileLines];
  for (const block of sessionBlocks) lines.push(...block);
  const output = `${lines.join("\n")}\n`;

  const outputPath = options.out || path.join(
    process.env.TEMP || path.dirname(fileURLToPath(import.meta.url)),
    "GuildCopilot-WCL-Import.txt"
  );
  fs.writeFileSync(outputPath, output, "utf8");

  if (debugEntries) {
    const debugPath = path.join(path.dirname(outputPath), "GuildCopilot-WCL-Debug.json");
    fs.writeFileSync(debugPath, JSON.stringify(debugEntries, null, 2), "utf8");
    console.log(`Diagnosedatei: ${debugPath}`);
  }

  console.log("");
  console.log(
    `Fertig: ${profileLines.length} Spieler und ${sessionBlocks.length} Raidauswertungen aus ${selected.length} Reports.`
  );
  for (const warning of warnings) console.log(`Hinweis: ${warning}`);
  console.log(`Importdatei: ${outputPath}`);
  const bytes = Buffer.byteLength(output, "utf8");
  console.log(`Groesse: ${bytes} Zeichen (das Addon nimmt bis zu 60000).`);
  if (bytes > 60000) {
    console.log("Zu gross fuer ein Einfuegen. Bitte mit --reports 1 erneut laufen lassen.");
  }
}

const invokedDirectly = process.argv[1]
  && path.resolve(process.argv[1]) === path.resolve(fileURLToPath(import.meta.url));

if (invokedDirectly) {
  try {
    await main();
  } catch (error) {
    console.error("");
    console.error(`Fehlgeschlagen: ${error.message}`);
    process.exitCode = 1;
  }
}

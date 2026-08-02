// Prüft die Auswertung des Warcraft-Logs-Companions gegen eine aufgezeichnete
// Antwortform - ohne Netz und ohne API-Zugangsdaten. Damit ist belegt, dass
// aus einer gültigen WCL-Antwort genau die Zeilen entstehen, die der
// Addon-Import erwartet.

import assert from "node:assert/strict";
import {
  CONSUMABLE_IDS,
  FORMAT_HEADER,
  RESURRECT_IDS,
  buildProfileLines,
  buildSessionLines,
  collectConsumables,
  collectPlayers,
  defaultOrigins,
  parseArguments,
  parseTarget,
} from "../GuildCopilot/Companion/WCL-Import.mjs";

// --- Report in der Form, die reportData.report liefert ---------------------

const report = {
  code: "abc123XYZ",
  startTime: 1700000000000,
  endTime: 1700000600000,
  zone: { name: "Karazhan" },
  masterData: {
    actors: [
      { id: 1, name: "Nexarius", subType: "Mage" },
      { id: 2, name: "Thulgor", subType: "Warrior" },
      { id: 3, name: "Unbeteiligt", subType: "Priest" },
    ],
  },
  fights: [
    { id: 1, name: "Attumen", kill: true, startTime: 1000, endTime: 61000, friendlyPlayers: [1, 2] },
    { id: 2, name: "Moroes", kill: false, startTime: 70000, endTime: 100000, friendlyPlayers: [1] },
  ],
};

const aggregates = {
  deaths: [{ type: "death", targetID: 2 }],
  // Warcraft Logs hat keinen Ereignistyp "Resurrects"; gezählt wird der
  // gewirkte Zauber. 20484 ist Wiedergeburt, 999999 gehört nicht dazu.
  resurrects: [
    { type: "cast", sourceID: 1, abilityGameID: 20484 },
    { type: "cast", sourceID: 1, abilityGameID: 999999 },
    { type: "begincast", sourceID: 1, abilityGameID: 20484 },
  ],
  interrupts: [
    { type: "interrupt", sourceID: 2 },
    { type: "interrupt", sourceID: 2 },
    // Dieser Akteur war nur auf Trash aktiv und darf keine Teilnehmerzeile
    // mit null Encounter-Anwesenheit erzeugen.
    { type: "interrupt", sourceID: 3 },
  ],
  dispels: [{ type: "dispel", sourceID: 1 }],
  casts: [
    { type: "cast", sourceID: 1, abilityGameID: 28499 },
    { type: "cast", sourceID: 1, abilityGameID: 28499 },
    { type: "cast", sourceID: 1, abilityGameID: 999999 },
    { type: "begincast", sourceID: 1, abilityGameID: 28499 },
  ],
  buffs: [
    { type: "applybuff", targetID: 1, abilityGameID: 28518 },
    { type: "refreshbuff", targetID: 1, abilityGameID: 28518 },
  ],
};

const sessionLines = buildSessionLines(report.code, report, aggregates);

assert.equal(
  sessionLines[0],
  "S|abc123XYZ|1700000000|1700000600|Karazhan|2|1|1",
  "Die Sitzungszeile stimmt nicht."
);
assert.deepEqual(
  sessionLines.slice(1),
  [
    "P|Nexarius|MAGE|90|0|0|1|28499:2,28518:2|1",
    "P|Thulgor|WARRIOR|60|1|2|0||0",
  ],
  "Die Teilnehmerzeilen stimmen nicht."
);

// Eine fehlgeschlagene Abfrage darf nur ihre eigene Spalte kosten, nicht die
// ganze Auswertung: genau daran ist der erste Lauf gegen echte Reports
// gescheitert.
const teilweise = buildSessionLines(report.code, report, {
  ...aggregates,
  interrupts: [],
  casts: [],
  buffs: [],
});
assert.equal(teilweise.length, 3, "Ohne einzelne Ereignisarten fehlt die ganze Auswertung.");
assert.equal(
  teilweise[1],
  "P|Nexarius|MAGE|90|0|0|1||1",
  "Die verbliebenen Spalten wurden nicht übernommen."
);
assert.ok(
  teilweise[2].startsWith("P|Thulgor|WARRIOR|60|1|0|0|"),
  "Die ausgefallene Interrupt-Spalte steht nicht auf 0."
);

// Wer an keinem Encounter teilnimmt und nichts ausloest, taucht auch nicht auf.
assert.ok(
  !sessionLines.some((line) => line.includes("Unbeteiligt")),
  "Ein unbeteiligter Spieler wurde in die Auswertung aufgenommen."
);

// begincast darf nicht mitzaehlen - ein angefangener Zauber ist kein Verbrauch.
assert.ok(
  sessionLines[1].includes("28499:2"),
  "Ein begonnener Zauber wurde als Verbrauch gezaehlt."
);

// refreshbuff dagegen SCHON: Wer ein zweites Mal isst oder trinkt, waehrend der
// Buff noch laeuft, erzeugt eine Auffrischung statt einer neuen Anwendung. Ohne
// sie zaehlte ein ganzer Raidabend Essen als ein einziges Essen.
assert.ok(
  sessionLines[1].includes("28518:2"),
  "Die Auffrischung eines Dauerbuffs wurde nicht als zweiter Verbrauch gezaehlt."
);

// Ohne Kaempfe und ohne Ereignisse entsteht keine leere Auswertung.
assert.deepEqual(
  buildSessionLines("leer", { ...report, fights: [] }, {
    deaths: [], resurrects: [], interrupts: [], dispels: [], casts: [], buffs: [],
  }),
  [],
  "Aus einem leeren Report entstand trotzdem eine Auswertung."
);

// --- playerDetails in der verschachtelten Form der API ---------------------

const playerDetails = {
  data: {
    playerDetails: {
      dps: [
        {
          name: "Nexarius",
          type: "Mage",
          icon: "Mage-Frost",
          specs: [{ spec: "Frost", count: 4 }, { spec: "Fire", count: 1 }],
        },
      ],
      tanks: [
        { name: "Thulgor", type: "Warrior", icon: "Warrior-Protection", specs: [{ spec: "Protection" }] },
      ],
      healers: [
        { name: "Sanitas", type: "Priest", icon: "Priest-Holy", specs: [{ spec: "Holy" }] },
      ],
    },
  },
};

const players = collectPlayers(playerDetails, report.endTime, new Map());
collectPlayers({
  dps: [{ name: "nexarius", type: "Mage", icon: "Mage-Arcane", specs: [{ spec: "Arcane" }] }],
}, report.endTime + 1, players);
const profileLines = buildProfileLines(players);

assert.deepEqual(
  profileLines,
  [
    "Nexarius;MAGE;MAGE:1;MAGE:3",
    "Sanitas;PRIEST;PRIEST:2;",
    "Thulgor;WARRIOR;WARRIOR:3;",
  ],
  "Die Profilzeilen stimmen nicht."
);

// --- Linkerkennung --------------------------------------------------------

const guild = parseTarget("https://de.fresh.warcraftlogs.com/guild/eu/thunderstrike/aftermath");
assert.equal(guild.kind, "guild");
assert.equal(guild.region, "eu");
assert.equal(guild.serverSlug, "thunderstrike");
assert.ok(guild.guildNames.includes("aftermath"), "Der Gildenname aus dem Link fehlt.");
assert.equal(guild.origins[0], "https://fresh.warcraftlogs.com");

// Mehrwortnamen stehen im Link nur als Slug. Beide Schreibweisen muessen
// probiert werden, sonst findet die API die Gilde nie.
const multiWord = parseTarget("https://fresh.warcraftlogs.com/guild/eu/lakeshire/die-waechter");
assert.ok(multiWord.guildNames.includes("die waechter"), "Die entkoppelte Schreibweise fehlt.");
assert.ok(multiWord.guildNames.includes("Die Waechter"), "Die grossgeschriebene Schreibweise fehlt.");

const single = parseTarget("https://fresh.warcraftlogs.com/reports/aBcD1234efGH5678");
assert.equal(single.kind, "report");
assert.equal(single.code, "aBcD1234efGH5678");

const bareCode = parseTarget("aBcD1234efGH5678");
assert.equal(bareCode.kind, "report");

assert.throws(() => parseTarget("https://example.com/guild/eu/x/y"), /Warcraft Logs/);
assert.throws(
  () => parseTarget("https://evilwarcraftlogs.com/guild/eu/x/y"),
  /Warcraft Logs/,
  "Eine fremde Domain mit passendem Namensende wurde akzeptiert."
);
assert.throws(
  () => parseTarget("https://fresh.warcraftlogs.com/guild/eu/x/y/extra"),
  /weder|ungültig/,
  "Ein Link mit zusätzlichem Pfad wurde als Gilde akzeptiert."
);
assert.throws(
  () => parseTarget("https://fresh.warcraftlogs.com/guild/xx/x/y"),
  /ungültige/,
  "Eine unbekannte Region wurde akzeptiert."
);
assert.throws(() => parseTarget(""), /Reportcode/);

assert.deepEqual(
  defaultOrigins("classic.warcraftlogs.com")[0],
  "https://classic.warcraftlogs.com"
);

// --- Optionen -------------------------------------------------------------

const options = parseArguments(["--report", "abc", "--reports", "7", "--debug"]);
assert.equal(options.target, "abc");
assert.equal(options.reports, 7);
assert.equal(options.debug, true);
assert.equal(parseArguments(["x", "--reports", "99"]).reports, 12, "Die Obergrenze greift nicht.");
assert.throws(() => parseArguments(["--unsinn"]), /Unbekannte Option/);

// --- Gruppenweite Verbrauchsgegenstände ------------------------------------

// Trommeln buffen die ganze Gruppe. Verbraucht hat sie nur, wer sie gewirkt
// hat. Aus einem echten Report: Attilus trommelte 27 mal, Neynmanyo kein
// einziges Mal - bekam aber 19 Trommelbuffs ab.
const trommeln = collectConsumables(
  [
    ...Array.from({ length: 27 }, () => ({ type: "cast", sourceID: 1, abilityGameID: 35476 })),
    { type: "begincast", sourceID: 1, abilityGameID: 35476 },
  ],
  [
    ...Array.from({ length: 27 }, () => ({ type: "applybuff", targetID: 1, abilityGameID: 35476 })),
    ...Array.from({ length: 19 }, () => ({ type: "applybuff", targetID: 2, abilityGameID: 35476 })),
    // Ein Elixier erzeugt keinen Zauber - der Buff bleibt hier die Quelle.
    { type: "applybuff", targetID: 2, abilityGameID: 28503 },
  ]
);

assert.equal(trommeln.get(1).get(35476), 27, "Der Trommler wurde falsch gezählt.");
assert.equal(
  trommeln.get(2).get(35476),
  undefined,
  "Ein Gruppenmitglied bekam die Trommeln des Trommlers zugeschrieben."
);
assert.equal(
  trommeln.get(2).get(28503),
  1,
  "Ein Gegenstand ohne Zauberereignis wurde gar nicht gezählt."
);

// --- Geprüfte Spell-IDs ---------------------------------------------------

// 25235 ist "Flash Heal", nicht "Erlösung". Die falsche ID hat Priestern
// dreistellige Wiederbelebungszahlen angedichtet. Sie darf nie zurückkommen.
assert.ok(!RESURRECT_IDS.includes(25235), "Flash Heal steht wieder in der Wiederbelebungsliste.");
assert.equal(
  new Set(RESURRECT_IDS).size,
  RESURRECT_IDS.length,
  "Die Wiederbelebungsliste enthält Dubletten."
);
assert.equal(
  new Set(CONSUMABLE_IDS).size,
  CONSUMABLE_IDS.length,
  "Die Verbrauchsliste enthält Dubletten."
);
for (const id of [...RESURRECT_IDS, ...CONSUMABLE_IDS]) {
  assert.ok(Number.isInteger(id) && id > 0, `Ungültige Spell-ID: ${id}`);
}
assert.ok(
  !RESURRECT_IDS.some((id) => CONSUMABLE_IDS.includes(id)),
  "Eine ID steht in beiden Listen."
);

// --- Format ---------------------------------------------------------------

assert.equal(FORMAT_HEADER, "GCPWCL3");

console.log("OK: Der Warcraft-Logs-Companion erzeugt die erwarteten Importzeilen.");

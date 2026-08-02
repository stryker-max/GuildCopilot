// Laedt ein fertiges Addon-Zip ueber die CurseForge-Upload-API hoch.
//
// Aufgerufen wird das Skript aus .github/workflows/curseforge.yml. Es steht
// bewusst als eigene Datei daneben und nicht als Shell-Gefrickel im Workflow:
// Die Spielversion muss zur Laufzeit aufgeloest werden, und ein Fehlschlag
// soll sagen, WAS falsch ist - nicht nur, dass ein curl-Aufruf 400 lieferte.
//
// Umgebung:
//   CURSEFORGE_TOKEN         Pflicht, Repository-Secret
//   CURSEFORGE_PROJECT_ID    Pflicht, Projektnummer (steht auf der Projektseite)
//   CURSEFORGE_GAME_VERSION  Pflicht, Name der Spielversion, z. B. "2.5.6"
//   CURSEFORGE_VERSION_TYPE  optional, Name des Versionstyps zur Abgrenzung,
//                            falls derselbe Name in mehreren Zweigen vorkommt
//   ZIP_PATH, VERSION, RELEASE_TYPE, CHANGELOG_PATH
//
// API-Beschreibung:
// https://support.curseforge.com/support/solutions/articles/9000197321

import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

const BASE_URL = "https://wow.curseforge.com";

function required(name) {
  const value = (process.env[name] ?? "").trim();
  if (value === "") {
    fail(`${name} fehlt. Token gehoert in die Repository-Secrets, `
      + `Projektnummer und Spielversion in die Repository-Variablen.`);
  }
  return value;
}

function fail(message) {
  console.error(`\nFEHLER: ${message}\n`);
  process.exit(1);
}

// Holt den Abschnitt dieser Version aus CHANGELOG.md - also alles zwischen
// "## <version>" und der naechsten Ueberschrift derselben Ebene. Fehlt der
// Abschnitt, bricht der Upload ab: Ein Release ohne Changelog ist genau das,
// was hier nicht mehr passieren soll.
export function changelogSection(changelogPath, version) {
  const text = fs.readFileSync(changelogPath, "utf8");
  const lines = text.split(/\r?\n/);
  const startIndex = lines.findIndex(
    (line) => line.startsWith("## ") && line.includes(version),
  );
  if (startIndex === -1) {
    fail(`${path.basename(changelogPath)} hat keinen Abschnitt fuer ${version}. `
      + `Erwartet wird eine Ueberschrift der Form "## ${version} - ...".`);
  }
  const rest = lines.slice(startIndex + 1);
  const endOffset = rest.findIndex((line) => line.startsWith("## "));
  const body = (endOffset === -1 ? rest : rest.slice(0, endOffset)).join("\n").trim();
  if (body === "") {
    fail(`Der Changelog-Abschnitt fuer ${version} ist leer.`);
  }
  return body;
}

// Ein abgelehnter Aufruf muss sagen, WER abgelehnt hat.
//
// Ein 403 kann zweierlei heissen, und die Gegenmassnahmen haben nichts
// miteinander zu tun: Entweder weist CurseForge den Token zurueck - dann hilft
// ein neuer Token -, oder ein vorgelagerter Schutz laesst die Anfrage gar nicht
// bis zur API durch; dann ist der Token in Ordnung und ein neuer aendert nichts.
// Zu unterscheiden sind die beiden am Antwortkoerper: Die API antwortet knapp
// und in JSON, ein Schutzwall mit einer HTML-Seite.
function describeRejection(status, statusText, headers, body, token) {
  const server = headers.get("server") ?? "?";
  const rayID = headers.get("cf-ray");
  const looksLikeHTML = /^\s*<(?:!doctype|html)/i.test(body);
  const snippet = body.replace(/\s+/g, " ").trim().slice(0, 300);

  const lines = [`Antwort ${status} ${statusText} (Server: ${server}`
    + `${rayID ? `, cf-ray: ${rayID}` : ""})`];
  if (looksLikeHTML || rayID) {
    lines.push(
      ``,
      `Das ist eine HTML-Seite, keine Antwort der Upload-API. Die Anfrage kommt`,
      `also gar nicht bis zur API durch, sondern wird davor abgewiesen - ein`,
      `neuer Token aendert daran nichts.`,
      ``,
      `Was hilft: den Upload nicht aus GitHub Actions fahren, sondern das`,
      `Archiv von Hand hochladen (es liegt als Artefakt an diesem Lauf), oder`,
      `bei CurseForge nachfragen, ob der Zugriff aus Rechenzentrums-IPs`,
      `freigeschaltet werden kann.`,
    );
  } else {
    // Die Laenge gehoert direkt hierher, nicht nur in einen frueheren Schritt:
    // Wer diese Meldung liest, will als naechstes wissen, ob ueberhaupt ein
    // vollstaendiger Token ankam - und soll dafuer nicht im Log hochscrollen.
    const length = (token ?? "").length;
    lines.push(
      ``,
      `Die API selbst weist den Token zurueck - erreichbar ist sie also.`,
      `Der hinterlegte Token ist ${length} Zeichen lang; richtig sind 36.`,
      length === 36
        ? `Die Laenge stimmt, er ist also vollstaendig eingefuegt - dann ist er`
          + ` schlicht nicht mehr gueltig (widerrufen oder ersetzt).`
        : `Die Laenge stimmt NICHT - er wurde beim Einfuegen abgeschnitten.`,
      ``,
      `Neuen Token holen: authors.curseforge.com -> Konto -> API Tokens.`,
      `Er muss von dort stammen, nicht aus der CurseForge-Core-API-Konsole.`,
    );
  }
  lines.push(``, `Antwortanfang: ${snippet || "(leer)"}`);
  return lines.join("\n");
}

async function api(pathname, token) {
  const response = await fetch(`${BASE_URL}${pathname}`, {
    headers: { "X-Api-Token": token },
  });
  if (!response.ok) {
    // Der Koerper enthaelt keine Zugangsdaten - der Token steht im Kopf der
    // ANFRAGE, nicht in der Antwort.
    const body = await response.text().catch(() => "");
    fail(`${pathname}: ${describeRejection(response.status, response.statusText, response.headers, body, token)}`);
  }
  return response.json();
}

// CurseForge will Zahlen, keine Namen. Die Zuordnung Name -> ID aendert sich
// mit jedem Spielpatch, deshalb wird sie bei jedem Lauf frisch geholt.
async function resolveGameVersion(token, wantedName, wantedType) {
  const [versions, types] = await Promise.all([
    api("/api/game/versions", token),
    api("/api/game/version-types", token),
  ]);
  const typeName = new Map(types.map((entry) => [entry.id, entry.name]));

  let matches = versions.filter((entry) => entry.name === wantedName);
  if (wantedType) {
    matches = matches.filter(
      (entry) => (typeName.get(entry.gameVersionTypeID) ?? "") === wantedType,
    );
  }

  if (matches.length === 0) {
    const candidates = versions
      .filter((entry) => entry.name.startsWith(wantedName.split(".")[0]))
      .slice(-25)
      .map((entry) => `  ${entry.name}  (Typ: ${typeName.get(entry.gameVersionTypeID) ?? "?"})`)
      .join("\n");
    fail(`Keine Spielversion "${wantedName}"`
      + `${wantedType ? ` im Typ "${wantedType}"` : ""} gefunden.\n`
      + `Moegliche Werte fuer CURSEFORGE_GAME_VERSION:\n${candidates}`);
  }
  if (matches.length > 1) {
    const shown = matches
      .map((entry) => `  ${entry.name}  (Typ: ${typeName.get(entry.gameVersionTypeID) ?? "?"})`)
      .join("\n");
    fail(`"${wantedName}" ist mehrdeutig. Setze CURSEFORGE_VERSION_TYPE auf einen davon:\n${shown}`);
  }

  const match = matches[0];
  console.log(`Spielversion: ${match.name} (ID ${match.id}, `
    + `Typ ${typeName.get(match.gameVersionTypeID) ?? "?"})`);
  return match.id;
}

async function main() {
  const token = required("CURSEFORGE_TOKEN");
  const projectID = required("CURSEFORGE_PROJECT_ID");
  const gameVersionName = required("CURSEFORGE_GAME_VERSION");
  const versionType = (process.env.CURSEFORGE_VERSION_TYPE ?? "").trim() || null;
  const zipPath = required("ZIP_PATH");
  const version = required("VERSION");
  const releaseType = (process.env.RELEASE_TYPE ?? "release").trim();
  const changelogPath = process.env.CHANGELOG_PATH ?? "CHANGELOG.md";

  if (!["alpha", "beta", "release"].includes(releaseType)) {
    fail(`RELEASE_TYPE muss alpha, beta oder release sein, war "${releaseType}".`);
  }
  if (!fs.existsSync(zipPath)) {
    fail(`Das Paket ${zipPath} gibt es nicht.`);
  }

  const changelog = changelogSection(changelogPath, version);
  const gameVersionID = await resolveGameVersion(token, gameVersionName, versionType);

  const metadata = {
    changelog,
    changelogType: "markdown",
    displayName: `Guild Copilot ${version}`,
    gameVersions: [gameVersionID],
    releaseType,
  };

  const form = new FormData();
  form.append("metadata", JSON.stringify(metadata));
  form.append(
    "file",
    new Blob([fs.readFileSync(zipPath)]),
    path.basename(zipPath),
  );

  const response = await fetch(`${BASE_URL}/api/projects/${projectID}/upload-file`, {
    method: "POST",
    headers: { "X-Api-Token": token },
    body: form,
  });
  const body = await response.text();
  if (!response.ok) {
    fail(`Der Upload wurde mit ${response.status} ${response.statusText} abgelehnt:\n${body}`);
  }

  let fileID = body;
  try {
    fileID = JSON.parse(body).id ?? body;
  } catch {
    // Antwort war kein JSON - dann steht die Rohantwort im Protokoll.
  }
  console.log(`OK: ${path.basename(zipPath)} als ${releaseType} hochgeladen (Datei-ID ${fileID}).`);
}

// Nur beim direkten Aufruf hochladen - so kann tests/validate.mjs die
// Changelog-Auswertung importieren, ohne eine Verbindung aufzubauen.
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  await main();
}

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

async function api(pathname, token) {
  const response = await fetch(`${BASE_URL}${pathname}`, {
    headers: { "X-Api-Token": token },
  });
  if (!response.ok) {
    if (response.status === 401 || response.status === 403) {
      // 403 heisst hier nie "falsches Projekt" - diese Abfrage kennt das
      // Projekt gar nicht. Es geht ausschliesslich um den Token selbst.
      fail(`${pathname} antwortete ${response.status} ${response.statusText}.\n`
        + `CurseForge lehnt den Token ab. Das Projekt spielt hier keine Rolle -\n`
        + `diese Abfrage kennt es nicht, es geht nur um den Token.\n\n`
        + `Der Reihe nach zu pruefen:\n`
        + `  1. Ist der Token noch gueltig? Ein widerrufener Token antwortet genau so.\n`
        + `     authors.curseforge.com -> Konto -> API Tokens.\n`
        + `  2. Ist er vollstaendig eingefuegt? Der Schritt "Zugangsdaten suchen"\n`
        + `     nennt seine Laenge; 36 Zeichen sind richtig.\n`
        + `  3. Stammt er aus dem Autorenkonto (API Tokens) und nicht aus der\n`
        + `     CurseForge-Core-API-Konsole? Nur der erste passt hierher.\n\n`
        + `Ein neuer Token ist in beiden Faellen der kuerzeste Weg.`);
    }
    fail(`${pathname} antwortete ${response.status} ${response.statusText}.`);
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

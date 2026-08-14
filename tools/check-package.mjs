// === Was im Paket ist, wird am Paket geprueft ==============================
//
// Nicht am Bauskript, nicht an der Absicht: an der tatsaechlichen Dateiliste
// des Staging-Verzeichnisses und an der Dateiliste IM fertigen Archiv, samt
// der TOC, die darin liegt. Ein Bauskript, das sich selbst bestaetigt, faellt
// genau dann nicht auf, wenn es kaputt ist.

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import JSZip from "jszip";
import {
  ADDON_DIR,
  EXCLUDED_DIRS,
  EXCLUDED_FILES,
  FORBIDDEN_EXTENSIONS,
  buildZip,
  listFiles,
  readAddonVersion,
  tocFileList,
} from "./curseforge-package.mjs";

const problems = [];
function complain(message) {
  problems.push(message);
}

function extensionOf(path) {
  const match = path.toLowerCase().match(/\.([a-z0-9]+)$/);
  return match ? match[1] : "";
}

// Ein Satz Regeln, zweimal angewendet: einmal auf das Staging-Verzeichnis,
// einmal auf den Inhalt des Archivs. Beide muessen dasselbe zeigen.
function checkFileList(where, files) {
  if (files.length === 0) {
    complain(`${where}: gar keine Dateien.`);
    return;
  }
  for (const file of files) {
    const parts = file.split("/");
    const name = parts[parts.length - 1];

    for (const dir of EXCLUDED_DIRS) {
      if (parts.includes(dir)) {
        complain(`${where}: ${file} liegt im ausgeschlossenen Ordner ${dir}.`);
      }
    }
    if (EXCLUDED_FILES.includes(name)) {
      complain(`${where}: ${file} ist ausdruecklich ausgeschlossen.`);
    }
    if (FORBIDDEN_EXTENSIONS.includes(extensionOf(file))) {
      complain(
        `${where}: ${file} ist eine ausfuehrbare oder Werkzeugdatei - ` +
          "CurseForge lehnt das Archiv damit ab."
      );
    }
    // Der Installer liegt im Repository neben dem Addon, nie darin. Fiele er
    // je hinein, waere es ueber einen dieser Namen.
    if (/^(Installer|tests|Brand|docs|\.vscode|\.github)\//i.test(file)) {
      complain(`${where}: ${file} gehoert nicht ins Addon.`);
    }
  }
}

// Die TOC darf keine Datei nennen, die nicht daneben liegt: Genau daran
// scheitert das Addon sonst beim Laden, und zwar erst im Spiel.
function checkToc(where, toc, files, { reduced = true } = {}) {
  const listed = tocFileList(toc);
  if (listed.length === 0) {
    complain(`${where}: die TOC laedt gar keine Datei.`);
  }
  for (const entry of listed) {
    // Nur im Paket verboten. In der vollstaendigen Fassung MUSS die Zeile
    // stehen - dort wird Warcraft Logs ja geladen.
    if (reduced && EXCLUDED_FILES.includes(entry)) {
      complain(`${where}: die TOC nennt weiterhin ${entry}.`);
    }
    if (!files.includes(entry)) {
      complain(`${where}: die TOC nennt ${entry}, im Paket fehlt die Datei.`);
    }
  }
  // Und die umgekehrte Richtung: eine Lua-Datei, die mitgeliefert, aber nie
  // geladen wird, ist entweder vergessen oder ueberfluessig.
  for (const file of files) {
    if (file.endsWith(".lua") && !file.includes("/") && !listed.includes(file)) {
      complain(`${where}: ${file} liegt im Paket, wird aber von der TOC nicht geladen.`);
    }
  }
  if (!/^##\s*Version:\s*\S/m.test(toc)) {
    complain(`${where}: in der TOC fehlt '## Version:'.`);
  }
  if (!/^##\s*Interface:\s*\d+/m.test(toc)) {
    complain(`${where}: in der TOC fehlt '## Interface:'.`);
  }
}

export async function checkPackage({ quiet = false } = {}) {
  problems.length = 0;

  // === Die vollstaendige Fassung bleibt vollstaendig ======================
  //
  // Die Reduktion darf ausschliesslich im Paket stattfinden. Faende sie im
  // Repository statt, waere die lokale Entwicklungsinstallation still
  // mitreduziert - und genau das soll sie nicht sein.
  for (const name of EXCLUDED_FILES) {
    if (!existsSync(join(ADDON_DIR, name))) {
      complain(`Die vollstaendige Fassung hat ${name} verloren - sie gehoert ins Repository.`);
    }
  }
  for (const name of EXCLUDED_DIRS) {
    if (!existsSync(join(ADDON_DIR, name))) {
      complain(`Die vollstaendige Fassung hat den Ordner ${name} verloren.`);
    }
  }
  const fullToc = readFileSync(join(ADDON_DIR, "GuildCopilot.toc"), "utf8");
  for (const name of EXCLUDED_FILES) {
    if (!tocFileList(fullToc).includes(name)) {
      complain(`Die vollstaendige TOC laedt ${name} nicht mehr.`);
    }
  }
  checkToc("Vollstaendige Fassung", fullToc, listFiles(ADDON_DIR), { reduced: false });

  // === Und jetzt das, was wirklich hochgeht ===============================
  const { zipPath, addonStage, version } = await buildZip({ quiet: true });

  const stageFiles = listFiles(addonStage);
  checkFileList("Staging", stageFiles);
  checkToc("Staging", readFileSync(join(addonStage, "GuildCopilot.toc"), "utf8"), stageFiles);

  const zip = await JSZip.loadAsync(readFileSync(zipPath));
  const zipEntries = Object.keys(zip.files).filter((name) => !zip.files[name].dir);

  // Oberste Ebene ist genau ein Ordner, und der heisst wie das Addon.
  for (const entry of zipEntries) {
    if (!entry.startsWith("GuildCopilot/")) {
      complain(`ZIP: ${entry} liegt neben dem Ordner GuildCopilot.`);
    }
  }
  const zipFiles = zipEntries
    .filter((entry) => entry.startsWith("GuildCopilot/"))
    .map((entry) => entry.slice("GuildCopilot/".length));
  checkFileList("ZIP", zipFiles);

  const zipTocEntry = zip.file("GuildCopilot/GuildCopilot.toc");
  if (!zipTocEntry) {
    complain("ZIP: die TOC fehlt.");
  } else {
    const zipToc = await zipTocEntry.async("string");
    checkToc("ZIP", zipToc, zipFiles);
    const zipVersion = zipToc.match(/^##\s*Version:\s*(.+)$/m);
    if (zipVersion && zipVersion[1].trim() !== version) {
      complain(
        `ZIP: die TOC im Archiv nennt Version ${zipVersion[1].trim()}, ` +
          `erwartet war ${version}.`
      );
    }
  }

  // Staging und Archiv muessen deckungsgleich sein - sonst prueft die eine
  // Haelfte etwas, das die andere gar nicht ausliefert.
  const onlyInZip = zipFiles.filter((file) => !stageFiles.includes(file));
  const onlyInStage = stageFiles.filter((file) => !zipFiles.includes(file));
  for (const file of onlyInZip) {
    complain(`ZIP: ${file} steht im Archiv, aber nicht im Staging.`);
  }
  for (const file of onlyInStage) {
    complain(`ZIP: ${file} steht im Staging, aber nicht im Archiv.`);
  }

  if (problems.length > 0) {
    throw new Error(
      `Das CurseForge-Paket ist nicht in Ordnung:\n  - ${problems.join("\n  - ")}`
    );
  }

  if (!quiet) {
    console.log(`OK: CurseForge-Paket ${version} geprueft - ${zipFiles.length} Dateien.`);
    console.log(`    ohne: ${[...EXCLUDED_DIRS, ...EXCLUDED_FILES].join(", ")}, Installer`);
  }
  return { zipPath, version, zipFiles };
}

if (process.argv[1] && process.argv[1].endsWith("check-package.mjs")) {
  await checkPackage();
}

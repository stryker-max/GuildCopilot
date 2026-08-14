// === Das CurseForge-Paket: dieselbe Fassung, weniger drin ==================
//
// Im Repository und in der lokalen Entwicklungsinstallation bleibt Guild
// Copilot vollstaendig: Installer, Companion und Warcraft Logs gehoeren dazu
// und funktionieren. Nur das VEROEFFENTLICHTE Paket ist ein reines
// Standalone-Addon, und zwar aus einem handfesten Grund: CurseForge lehnt
// Archive mit ausfuehrbaren Dateien ab. Der Companion ist eine .cmd und eine
// .mjs, der Installer eine .exe - und der Warcraft-Logs-Import im Addon ist
// ohne einen der beiden nur eine Seite, die den Nutzer auffordert, etwas
// einzufuegen, das er sich nirgends holen kann.
//
// Reduziert wird deshalb ausschliesslich HIER, beim Paketbau, im
// Staging-Verzeichnis. Die Quelldateien bleiben unangetastet.
//
// Diese Datei ist die einzige Stelle, die weiss, was drin ist und was nicht.
// Der Testlauf und der Veroeffentlichungs-Workflow rufen beide sie auf - eine
// zweite Liste anderswo waere die naechste Abweichung.

import { createHash } from "node:crypto";
import {
  cpSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { dirname, join, posix, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";
import JSZip from "jszip";

export const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const ADDON_DIR = join(REPO_ROOT, "GuildCopilot");
export const BUILD_DIR = join(REPO_ROOT, "build");
export const STAGE_DIR = join(BUILD_DIR, "stage");

// Dateien und Ordner, die im Paket nichts verloren haben. Verzeichnisnamen
// gelten fuer den ganzen Baum darunter.
export const EXCLUDED_DIRS = ["Companion"];
export const EXCLUDED_FILES = ["WarcraftLogs.lua"];

// Ausfuehrbares und Werkzeugkram. CurseForge weist ein Archiv damit zurueck;
// ausserdem gehoert nichts davon in einen WoW-AddOns-Ordner.
export const FORBIDDEN_EXTENSIONS = [
  "exe", "cmd", "bat", "ps1", "mjs", "js", "sh", "vbs", "com",
  "scr", "msi", "dll", "jar", "py", "cs", "csproj", "sln",
];

// Ein fester Zeitstempel macht das Archiv reproduzierbar: Zweimal bauen ergibt
// zweimal dieselben Bytes. Ohne ihn traegt jede Datei die Uhrzeit des Laufs,
// und zwei identische Paketstaende haetten verschiedene Pruefsummen.
const FIXED_DATE = new Date("2020-01-01T00:00:00Z");

export function readAddonVersion() {
  const toc = readFileSync(join(ADDON_DIR, "GuildCopilot.toc"), "utf8");
  const version = toc.match(/^##\s*Version:\s*(.+)$/m);
  if (!version) {
    throw new Error("In GuildCopilot.toc fehlt '## Version:'.");
  }
  return version[1].trim();
}

// Alle Dateien unterhalb von dir, als Pfade mit "/" - so stehen sie auch im
// Archiv, unabhaengig davon, auf welchem Betriebssystem gebaut wurde.
export function listFiles(dir, base = dir) {
  const found = [];
  for (const entry of readdirSync(dir, { withFileTypes: true }).sort((a, b) =>
    a.name.localeCompare(b.name, "en")
  )) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) {
      found.push(...listFiles(full, base));
    } else if (entry.isFile()) {
      found.push(relative(base, full).split(sep).join(posix.sep));
    }
  }
  return found;
}

// === Die reduzierte TOC ====================================================
//
// Sie wird aus der echten abgeleitet, nicht danebengelegt. Eine zweite,
// gepflegte TOC-Datei im Repository waere genau so lange richtig, bis jemand
// eine Lua-Datei hinzufuegt und nur eine der beiden anfasst - und der Fehler
// faellt dann erst im Spiel auf, als fehlende Datei beim Laden.
//
// Entfernt werden ausschliesslich Zeilen, die eine ausgeschlossene Datei
// nennen. Kopfzeilen, Reihenfolge und alles Uebrige bleiben, wie sie sind.
export function reduceToc(toc) {
  const lines = toc.split(/\r?\n/);
  const kept = lines.filter((line) => !EXCLUDED_FILES.includes(line.trim()));
  if (kept.length === lines.length) {
    throw new Error(
      "Die reduzierte TOC ist mit der vollstaendigen identisch - " +
        `keine der Zeilen ${EXCLUDED_FILES.join(", ")} kam darin vor.`
    );
  }
  return kept.join("\n");
}

// Welche Lua-Dateien eine TOC laedt, in ihrer Reihenfolge.
export function tocFileList(toc) {
  return toc
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line !== "" && !line.startsWith("#"));
}

export function buildStage({ stageDir = STAGE_DIR, quiet = false } = {}) {
  rmSync(BUILD_DIR, { recursive: true, force: true });
  const addonStage = join(stageDir, "GuildCopilot");
  mkdirSync(dirname(addonStage), { recursive: true });

  // Erst vollstaendig kopieren, dann wegnehmen. Andersherum - eine Auswahlliste
  // beim Kopieren - vergisst man beim naechsten neuen Ordner.
  cpSync(ADDON_DIR, addonStage, { recursive: true });
  for (const name of EXCLUDED_DIRS) {
    rmSync(join(addonStage, name), { recursive: true, force: true });
  }
  for (const name of EXCLUDED_FILES) {
    rmSync(join(addonStage, name), { force: true });
  }

  const tocPath = join(addonStage, "GuildCopilot.toc");
  writeFileSync(tocPath, reduceToc(readFileSync(tocPath, "utf8")), "utf8");

  if (!quiet) {
    console.log(`Staging gebaut: ${relative(REPO_ROOT, addonStage)}`);
  }
  return addonStage;
}

export async function buildZip({ stageDir = STAGE_DIR, quiet = false } = {}) {
  const addonStage = buildStage({ stageDir, quiet });
  const version = readAddonVersion();
  const zipPath = join(BUILD_DIR, `GuildCopilot-Addon-${version}.zip`);

  const zip = new JSZip();
  for (const file of listFiles(addonStage)) {
    zip.file(`GuildCopilot/${file}`, readFileSync(join(addonStage, file)), {
      date: FIXED_DATE,
    });
  }
  const buffer = await zip.generateAsync({
    type: "nodebuffer",
    compression: "DEFLATE",
    compressionOptions: { level: 9 },
    platform: "UNIX",
  });
  writeFileSync(zipPath, buffer);

  if (!quiet) {
    const sha = createHash("sha256").update(buffer).digest("hex");
    const size = statSync(zipPath).size;
    console.log(`Paket gebaut: ${relative(REPO_ROOT, zipPath)} (${size} Bytes)`);
    console.log(`SHA-256: ${sha}`);
  }
  return { zipPath, version, addonStage };
}

// Direkt aufgerufen: bauen und den Pfad ausgeben, damit ein Workflow ihn
// weiterreichen kann.
if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const { zipPath, version } = await buildZip();
  const out = process.env.GITHUB_OUTPUT;
  if (out) {
    writeFileSync(
      out,
      `zip=${relative(REPO_ROOT, zipPath).split(sep).join(posix.sep)}\nversion=${version}\n`,
      { flag: "a" }
    );
  }
}

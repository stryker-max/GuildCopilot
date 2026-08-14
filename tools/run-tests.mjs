// === Ein Befehl, alle Tests ===============================================
//
//     npm ci && npm test
//
// Mehr braucht es nicht, und ausdruecklich kein installiertes Lua: Die
// Lua-Tests laufen ueber fengari, das als npm-Abhaengigkeit im Repository
// festgeschrieben ist. Derselbe Befehl laeuft auf dem Entwicklungsrechner und
// im GitHub-Workflow - eine zweite Testlogik in der CI waere die naechste
// Stelle, an der beide auseinanderlaufen.
//
// Geprueft werden BEIDE Fassungen:
//   - die vollstaendige Entwicklungsfassung aus dem Repository (mit Installer,
//     Companion und Warcraft Logs)
//   - die reduzierte Fassung, die auf CurseForge geht (ohne all das)
//
// Jeder Schritt, der scheitert, beendet den Lauf mit einem Exitcode ungleich
// null. Ein gruener Lauf mit rotem Inhalt waere schlimmer als gar keiner.

import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");

const STEPS = [
  {
    name: "Statische Prüfung (tests/validate.mjs)",
    args: ["tests/validate.mjs"],
  },
  {
    name: "Companion-Import (tests/companion.mjs)",
    args: ["tests/companion.mjs"],
  },
  {
    name: "Tag-Entscheidung der Veröffentlichung",
    args: ["tools/release-decision.test.mjs"],
  },
  {
    // Baut das Staging und das Archiv und prüft beides an seiner
    // tatsächlichen Dateiliste - vor den Lua-Tests, weil tests/reduced.lua
    // auf dem gebauten Staging läuft.
    name: "CurseForge-Paket bauen und prüfen",
    args: ["tools/check-package.mjs"],
  },
  {
    name: "Lua-Tests: vollständige Fassung und reduziertes Paket",
    args: ["tools/run-lua-tests.mjs"],
  },
];

let failed = 0;
for (const [index, step] of STEPS.entries()) {
  const label = `[${index + 1}/${STEPS.length}] ${step.name}`;
  console.log(`\n=== ${label} ===`);
  const result = spawnSync(process.execPath, step.args, {
    cwd: REPO_ROOT,
    stdio: "inherit",
  });
  if (result.error) {
    console.error(`FEHLGESCHLAGEN: ${step.name} - ${result.error.message}`);
    failed += 1;
    break;
  }
  if (result.status !== 0) {
    console.error(`\nFEHLGESCHLAGEN: ${step.name} (Exitcode ${result.status})`);
    failed += 1;
    break;
  }
}

if (failed > 0) {
  process.exit(1);
}

console.log("\n=== Alle Tests bestanden ===");
console.log("  vollständige Entwicklungsfassung: geprüft");
console.log("  reduziertes CurseForge-Paket:     gebaut und geprüft");

// === Wird veroeffentlicht, und was passiert mit dem Tag? ==================
//
// Der Tag "v<version>" ist das Gedaechtnis der Veroeffentlichung: Steht er,
// war diese Version schon auf CurseForge. Genau daran hing ein Widerspruch:
//
//   force=true durfte trotz vorhandenem Tag hochladen - und der Schritt
//   danach legte denselben Tag noch einmal an. "git tag" scheitert dann, und
//   der Lauf endete rot, OBWOHL der Upload geklappt hatte. Wer den Fehler
//   "beheben" wollte, kam schnell auf "-f" - und haette damit einen bereits
//   veroeffentlichten Tag verschoben.
//
// Die Regel ist deshalb: Ein vorhandener Tag wird nie angefasst. Nicht
// geloescht, nicht verschoben, nicht neu angelegt. Er markiert, dass es diese
// Version schon einmal gab, und das bleibt wahr, auch wenn man dieselbe
// Version noch einmal hochlaedt.
//
// Diese Datei enthaelt nur die Entscheidung, keine Nebenwirkung: kein git,
// kein Netz, keine Dateien. Damit ist sie pruefbar, und tools/
// release-decision.test.mjs prueft sie auch - fruehere Fassungen dieser Logik
// standen als Shell-Schnipsel im Workflow und liessen sich nur dadurch testen,
// dass man veroeffentlicht hat.

export function decideRelease({
  version,
  tagExists = false,
  force = false,
  hasToken = false,
  hasProject = false,
  foundNames = "",
} = {}) {
  const tag = `v${version}`;

  if (!hasToken || !hasProject) {
    const missing = !hasToken && !hasProject
      ? "der API-Token und die Projektnummer"
      : !hasToken
        ? "der API-Token"
        : "die Projektnummer";
    return {
      tag,
      publish: false,
      createTag: false,
      reason: "NOT_CONFIGURED",
      missing,
      headline: `CurseForge: ${tag} wurde nicht veroeffentlicht`,
      message:
        `CurseForge ist nicht eingerichtet - es fehlt ${missing}. ` +
        `Version ${tag} wurde NICHT veroeffentlicht.` +
        (foundNames ? ` Gefunden wurde: ${foundNames}` : ""),
    };
  }

  if (tagExists && !force) {
    return {
      tag,
      publish: false,
      createTag: false,
      reason: "ALREADY_PUBLISHED",
      headline: `CurseForge: ${tag} steht bereits`,
      message: `${tag} steht bereits - diese Version ist veroeffentlicht. Nichts zu tun.`,
    };
  }

  if (tagExists && force) {
    return {
      tag,
      publish: true,
      // Der Kern der Sache: hochladen ja, Tag anfassen nein.
      createTag: false,
      reason: "FORCED_REUPLOAD",
      headline: `CurseForge: ${tag} erneut hochgeladen`,
      message:
        `Erzwungen: ${tag} wird erneut hochgeladen. Der vorhandene Tag bleibt ` +
        "unveraendert stehen - er wird weder geloescht noch verschoben.",
    };
  }

  return {
    tag,
    publish: true,
    createTag: true,
    reason: "NEW_VERSION",
    headline: `Auf CurseForge veroeffentlicht: ${tag}`,
    message: `${tag} fehlt - Version ist neu. Nach dem Upload wird der Tag gesetzt.`,
  };
}

// Wie die Zusammenfassung des Laufs den Tag beschreibt. Sie muss die Wahrheit
// sagen: "gesetzt" fuer einen neuen, "beibehalten" fuer einen, der schon stand.
export function describeTagOutcome(decision) {
  if (decision.createTag) {
    return `Tag \`${decision.tag}\` neu erstellt und gepusht.`;
  }
  if (decision.reason === "FORCED_REUPLOAD") {
    return `Tag \`${decision.tag}\` bestand bereits und wurde unveraendert beibehalten.`;
  }
  return `Kein Tag gesetzt (${decision.reason}).`;
}

// === Aufruf aus dem Workflow ==============================================
//
// Alles kommt aus Umgebungsvariablen, alles geht nach GITHUB_OUTPUT. Der
// Workflow entscheidet damit nichts mehr selbst - er fuehrt nur noch aus.
if (process.argv[1] && process.argv[1].endsWith("release-decision.mjs")) {
  const { appendFileSync } = await import("node:fs");
  const truthy = (value) => String(value ?? "").toLowerCase() === "true";

  const decision = decideRelease({
    version: process.env.ADDON_VERSION,
    tagExists: truthy(process.env.TAG_EXISTS),
    force: truthy(process.env.FORCE),
    hasToken: truthy(process.env.HAS_TOKEN),
    hasProject: truthy(process.env.HAS_PROJECT),
    foundNames: process.env.FOUND_NAMES ?? "",
  });

  console.log(decision.message);
  console.log(describeTagOutcome(decision));

  if (process.env.GITHUB_OUTPUT) {
    appendFileSync(
      process.env.GITHUB_OUTPUT,
      [
        `publish=${decision.publish}`,
        `createTag=${decision.createTag}`,
        `tag=${decision.tag}`,
        `reason=${decision.reason}`,
        `tagOutcome=${describeTagOutcome(decision)}`,
        "",
      ].join("\n")
    );
  }

  // Nur die Faelle, in denen NICHT veroeffentlicht wird, schreiben hier schon
  // in die Zusammenfassung. Der Erfolgsfall tut das erst nach dem Upload -
  // vorher waere es eine Behauptung.
  if (!decision.publish && process.env.GITHUB_STEP_SUMMARY) {
    appendFileSync(
      process.env.GITHUB_STEP_SUMMARY,
      `## ${decision.headline}\n\n${decision.message}\n\n${describeTagOutcome(decision)}\n`
    );
  }
}

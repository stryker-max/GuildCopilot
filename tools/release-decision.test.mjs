// Prueft die Tag-Entscheidung aus tools/release-decision.mjs. Der Fall, um den
// es hier vor allem geht, steht als dritter: force=true bei vorhandenem Tag.

import assert from "node:assert/strict";
import { decideRelease, describeTagOutcome } from "./release-decision.mjs";

const configured = { version: "0.9.129", hasToken: true, hasProject: true };
let checks = 0;
function check(name, fn) {
  fn();
  checks += 1;
  void name;
}

check("Neue Version: hochladen und Tag setzen", () => {
  const decision = decideRelease({ ...configured, tagExists: false, force: false });
  assert.equal(decision.publish, true);
  assert.equal(decision.createTag, true);
  assert.equal(decision.tag, "v0.9.129");
  assert.match(describeTagOutcome(decision), /neu erstellt/);
});

check("Tag steht, ohne force: gar nichts tun", () => {
  const decision = decideRelease({ ...configured, tagExists: true, force: false });
  assert.equal(decision.publish, false);
  assert.equal(decision.createTag, false);
  assert.equal(decision.reason, "ALREADY_PUBLISHED");
});

check("Tag steht, mit force: hochladen, aber den Tag NICHT anfassen", () => {
  const decision = decideRelease({ ...configured, tagExists: true, force: true });
  assert.equal(decision.publish, true);
  // Das ist der reparierte Fehler: Frueher lief der Tag-Schritt trotzdem und
  // scheiterte an "tag already exists" - nach erfolgreichem Upload.
  assert.equal(decision.createTag, false);
  assert.equal(decision.reason, "FORCED_REUPLOAD");
  assert.match(describeTagOutcome(decision), /beibehalten/);
  assert.doesNotMatch(describeTagOutcome(decision), /neu erstellt/);
});

check("force ohne vorhandenen Tag setzt ihn trotzdem", () => {
  const decision = decideRelease({ ...configured, tagExists: false, force: true });
  assert.equal(decision.publish, true);
  assert.equal(decision.createTag, true);
  assert.equal(decision.reason, "NEW_VERSION");
});

check("Ohne Zugangsdaten wird nichts veroeffentlicht und nichts getaggt", () => {
  for (const [hasToken, hasProject, missing] of [
    [false, true, "der API-Token"],
    [true, false, "die Projektnummer"],
    [false, false, "der API-Token und die Projektnummer"],
  ]) {
    const decision = decideRelease({
      version: "0.9.129", hasToken, hasProject, tagExists: false, force: true,
    });
    assert.equal(decision.publish, false);
    assert.equal(decision.createTag, false);
    assert.equal(decision.reason, "NOT_CONFIGURED");
    assert.equal(decision.missing, missing);
  }
});

check("Ein Tag wird in keinem einzigen Fall angelegt, wenn er schon steht", () => {
  // Die Regel als Ganzes, ueber alle Eingaben: Ein vorhandener Tag ist
  // unantastbar. Ohne diese Runde koennte ein spaeterer Sonderfall sie
  // aushebeln, ohne dass ein Einzeltest anschlaegt.
  for (const force of [true, false]) {
    for (const hasToken of [true, false]) {
      for (const hasProject of [true, false]) {
        const decision = decideRelease({
          version: "1.2.3", tagExists: true, force, hasToken, hasProject,
        });
        assert.equal(decision.createTag, false,
          `createTag bei vorhandenem Tag (force=${force}, token=${hasToken}, project=${hasProject})`);
      }
    }
  }
});

check("Veroeffentlicht wird nur mit vollstaendigen Zugangsdaten", () => {
  for (const tagExists of [true, false]) {
    for (const force of [true, false]) {
      for (const [hasToken, hasProject] of [[false, false], [true, false], [false, true]]) {
        assert.equal(
          decideRelease({ version: "1.2.3", tagExists, force, hasToken, hasProject }).publish,
          false
        );
      }
    }
  }
});

console.log(`OK: Tag-Entscheidung geprueft (${checks} Faelle).`);

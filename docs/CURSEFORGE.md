# CurseForge listing

Copy-and-paste source for the CurseForge project page. Keep it in sync with
`README.md` when features change — the German README is the master, this is the
English shop window.

Project settings that belong with it:

- **Game:** World of Warcraft — **Game version:** Burning Crusade Classic (Anniversary, interface 20506)
- **Categories:** Guild, Roster & Player Info, Professions, Raid Frames (whichever the current tree offers)
- **License:** MIT
- **Source / Issues:** https://github.com/stryker-max/GuildCopilot
- **Uploaded file:** `GuildCopilot-Addon-<version>.zip` — top level is the folder `GuildCopilot`,
  no `.cmd`/`.exe`/`.mjs` anywhere in the archive (CurseForge rejects executables).

## Releasing

There is no manual release step. **Raise `## Version:` in the TOC, push to
`main`, done** — the rest happens by itself.

What decides whether a push publishes is the version number, not the push: if
no tag `v<version>` exists yet, the version is new and goes out, and the run
sets the tag afterwards. A second push on the same version does nothing. That
survives re-runs and force-pushes, and it keeps CurseForge from receiving the
same version twice.

The workflow is `.github/workflows/curseforge.yml`, the upload itself
`.github/scripts/curseforge-upload.mjs`. It runs `tests/validate.mjs` first,
builds the archive without the `Companion` folder (that is where the `.cmd` and
`.mjs` live), refuses an archive that still contains executables, and takes the
release notes from the section of `CHANGELOG.md` that matches the version — a
missing section fails the run before anything is uploaded. The tag is set only
after a successful upload, so a failed run can simply be repeated.

`workflow_dispatch` exists for the rare case: choose alpha/beta instead of
release, or force a re-upload of a version whose tag already stands.

Configure once under **Settings → Secrets and variables → Actions**:

| Kind | Name | Value |
| --- | --- | --- |
| Secret | `CURSEFORGE_TOKEN` | API token from the CurseForge account |
| Variable | `CURSEFORGE_PROJECT_ID` | project number from the project page |
| Variable | `CURSEFORGE_GAME_VERSION` | only as an override — normally derived |
| Variable | `CURSEFORGE_VERSION_TYPE` | only if that name is ambiguous |

**Those names are a recommendation, not a requirement.** Setup failed three
times over naming: the token sat there as `CURSEFORGE`, the project number in
the other of the two tabs — everything entered, everything correct, and the run
still claimed nothing was there, because it looked up a vocabulary word instead
of looking around.

So it looks around. The run scans **every** secret and **every** variable and
tells them apart by the shape of the value: the project number is digits only,
the token is not. The recommended name wins if it exists; after that, shape
decides. Values are never printed, only names — and a token that ends up in the
plaintext Variables tab gets masked explicitly before anything else runs.

When something really is missing, the summary lists the names that **were**
found, so the next attempt is not another guess.

To check the setup without a push: **Actions → CurseForge → Run workflow**. It
publishes the current TOC version if no tag for it exists yet, so a version
that was skipped while the setup was incomplete goes out afterwards.

The game version normally needs no configuration: it comes from
`## Interface:` in the TOC (`20506` → `2.5.6`). Its numeric CurseForge ID is
resolved at runtime, because that mapping changes with every game patch — and
if the name does not exist, the run prints the available ones instead of
failing blind.

The installer is untouched by all of this — it keeps pulling the addon straight
from `main`.

Keep it short. Nobody reads a project page top to bottom — one line per feature,
no installation steps (the app does that), no explanation of how the sync works.
If something needs a paragraph, it belongs in the GitHub README instead.

**Which format to paste:** the description editor has several modes and they do
not all behave the same. **HTML is the reliable one** — take that version.
Markdown mode has repeatedly failed to render headings and lists; BBCode is the
fallback if HTML is unavailable. All three below say exactly the same thing.

---

## Summary

> One line, shown under the project title and in search results. Plain text, no
> formatting — paste as is.

```
Guild assistant for TBC Anniversary: recruitment, roster and member care, a shared profession catalogue with crafting orders, raid tracking and enchant/gem checks.
```

### Shorter alternative

```
Recruitment, roster, professions, crafting orders, raid tracking and gear checks for your TBC Anniversary guild.
```

---

## Description — HTML (use this one)

```html
<h1>Guild Copilot</h1>

<p><strong>Guild assistant for World of Warcraft: Burning Crusade Classic Anniversary.</strong></p>

<p>Who plays what, who is missing from the raid, who can craft that recipe, whose gear is missing an enchant, who applied last night.</p>

<blockquote><p>&#9888;&#65039; <strong>German interface.</strong> Works on any client locale, but menus and texts are German only.</p></blockquote>

<ul>
  <li><strong>Recruitment</strong> &mdash; your guild profile feeds every advert and reply, and Guild Copilot tells you which specs your raid is actually missing</li>
  <li><strong>Applicant inbox</strong> &mdash; whispers and &ldquo;looking for guild&rdquo; messages collect themselves; answer from guild-wide templates</li>
  <li><strong>Roster &amp; member care</strong> &mdash; who raids, who is on leave, who stopped logging in; officers share their decisions</li>
  <li><strong>Guild workshop</strong> &mdash; everyone&rsquo;s recipes in one searchable catalogue, with mats from your bags, your alts and the guild bank</li>
  <li><strong>Crafting orders</strong> &mdash; order from a guildmate and both of you see where it stands, including who owes whom</li>
  <li><strong>Raid tracking</strong> &mdash; attendance, attempts, wipes, deaths, interrupts and consumables per raider, boss fights only</li>
  <li><strong>Gear checks</strong> &mdash; missing enchants and empty sockets for the whole raid, rated by archetype and your content phase</li>
</ul>

<p>Works on its own, better the more of your guild runs it.</p>

<p><strong>Source, issues, changelog:</strong> <a href="https://github.com/stryker-max/GuildCopilot">github.com/stryker-max/GuildCopilot</a> &middot; MIT</p>
```

---

## Description — BBCode (fallback)

```
[size=6][b]Guild Copilot[/b][/size]

[b]Guild assistant for World of Warcraft: Burning Crusade Classic Anniversary.[/b]

Who plays what, who is missing from the raid, who can craft that recipe, whose gear is missing an enchant, who applied last night.

[quote][b]⚠️ German interface.[/b] Works on any client locale, but menus and texts are German only.[/quote]

[list]
[*][b]Recruitment[/b] — your guild profile feeds every advert and reply, and Guild Copilot tells you which specs your raid is actually missing
[*][b]Applicant inbox[/b] — whispers and "looking for guild" messages collect themselves; answer from guild-wide templates
[*][b]Roster & member care[/b] — who raids, who is on leave, who stopped logging in; officers share their decisions
[*][b]Guild workshop[/b] — everyone's recipes in one searchable catalogue, with mats from your bags, your alts and the guild bank
[*][b]Crafting orders[/b] — order from a guildmate and both of you see where it stands, including who owes whom
[*][b]Raid tracking[/b] — attendance, attempts, wipes, deaths, interrupts and consumables per raider, boss fights only
[*][b]Gear checks[/b] — missing enchants and empty sockets for the whole raid, rated by archetype and your content phase
[/list]

Works on its own, better the more of your guild runs it.

[b]Source, issues, changelog:[/b] [url=https://github.com/stryker-max/GuildCopilot]github.com/stryker-max/GuildCopilot[/url] · MIT
```

---

## Description — Markdown (reference)

```markdown
# Guild Copilot

**Guild assistant for World of Warcraft: Burning Crusade Classic Anniversary.**

Who plays what, who is missing from the raid, who can craft that recipe, whose gear is missing an enchant, who applied last night.

> ⚠️ **German interface.** Works on any client locale, but menus and texts are German only.

- **Recruitment** — your guild profile feeds every advert and reply, and Guild Copilot tells you which specs your raid is actually missing
- **Applicant inbox** — whispers and "looking for guild" messages collect themselves; answer from guild-wide templates
- **Roster & member care** — who raids, who is on leave, who stopped logging in; officers share their decisions
- **Guild workshop** — everyone's recipes in one searchable catalogue, with mats from your bags, your alts and the guild bank
- **Crafting orders** — order from a guildmate and both of you see where it stands, including who owes whom
- **Raid tracking** — attendance, attempts, wipes, deaths, interrupts and consumables per raider, boss fights only
- **Gear checks** — missing enchants and empty sockets for the whole raid, rated by archetype and your content phase

Works on its own, better the more of your guild runs it.

**Source, issues, changelog:** https://github.com/stryker-max/GuildCopilot · MIT
```

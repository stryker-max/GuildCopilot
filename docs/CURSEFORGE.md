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

---

## Summary

> One line, shown under the project title and in search results. CurseForge
> allows ~255 characters; this one is well under it.

```
Guild assistant for TBC Anniversary: recruitment, roster and member care, a shared profession catalogue with crafting orders, raid tracking and enchant/gem checks — shared across your guild over the addon channel.
```

### Shorter alternative

```
Recruitment, roster, professions, crafting orders, raid tracking and gear checks for your TBC Anniversary guild — automatically shared between guild members.
```

---

## Description

> The full project page. CurseForge's editor accepts Markdown; paste from the
> horizontal rule below.

---

# Guild Copilot

**A guild assistant for World of Warcraft: Burning Crusade Classic Anniversary.**

Guild Copilot takes the bookkeeping off your officers' hands: who plays what, who is missing from the raid, who can craft that recipe, whose gear is missing an enchant, who applied last night. It gathers the data from the game in the background and shares it with every guild member who also runs the addon, over WoW's hidden addon channel.

No web access, no account, no cost. Nothing is sent outside your guild.

> **Note:** the in-game interface is **German**. The addon reads the client's own item and spell names, so it works on any client locale, but menus and texts are German only.

## What it does

### Recruitment

Fill in your guild profile once — raid times, progress, loot system, Discord, contact — and it flows into every advertisement and reply automatically.

Guild Copilot compares your raiders' specs against the support roles a TBC raid actually needs and tells you what is missing. It only counts players who can genuinely raid: level 70, an approved rank, not inactive for months. A level 12 alt does not cover a spec.

The advertisement editor keeps you inside the 255-byte chat limit, verges class selection down sensibly (three specs of a class collapse into the class, seven classes become "all classes") and lets you mark classes as high priority. Posting is a single explicit click that serves every selected channel at once, with a 120-second cooldown per channel.

A small movable **broadcast bar** shows the confirmed text, how many channels are ready and the running cooldown as a countdown — so you do not need the full window open just to advertise.

### Applicant inbox

Incoming whispers and recognised "looking for guild" chat messages land in an inbox automatically, with class colour, level and timestamp.

- Three reply buttons — thanks, guild info, Discord — backed by guild-wide templates with placeholders like `{name}` and `{raidtimes}`
- Every draft belongs to its applicant and survives switching back and forth, even if a new whisper arrives and reshuffles the list
- Copyable armory and Warcraft Logs links per applicant
- An ignore list for repeat writers, permanent or time-limited
- Your own trigger and exclusion words, separately for public messages and whispers
- The applicant sound is tied to guild rank: officers hear it, everyone else still sees the entry

### Roster and member care

The roster shows recently active level 70 players with their raid profile, main/alt status, professions and last login. Each player confirms their own profile — spec, dual spec, main or alt, "flexible" — and a changed selection counts as unconfirmed until they confirm again.

Member care (rank-protected) lists active leave-of-absence entries and inactivity suggestions sorted by how long someone has been gone. Every suggestion can be filed as an **exception**, **postponed** or **done**, and those decisions are shared guild-wide so two officers never work the same case twice.

Removing someone from the guild is always a deliberate single action: a second explicit confirmation, real WoW permission, and only against a lower, unprotected rank. Nothing happens automatically or in bulk.

### Guild workshop

When a guild member opens their profession window, Guild Copilot reads the entire known recipe list — it temporarily clears restrictive filters and expands collapsed categories to do it. After that, anyone can search the guild's full catalogue by recipe, profession or crafter, complete with reagents. Your own alts are included straight away.

Each recipe shows a **material breakdown**: what it needs, what you already have (bags, bank and your alts) and what the guild bank holds, with a traffic light — green you have yourself, yellow only with the guild bank, red missing either way.

The guild bank is read per tab when you visit it and shared guild-wide. Because tab visibility depends on rank, everything is tracked per tab and a restricted view never wipes someone else's tabs. Your own bags and personal bank stay on your account and are never sent.

### Crafting orders

The workshop's second tab turns "can somebody craft this?" into a tracked process.

- **Place an order** from the recipe card: quantity, who supplies materials (you, the guild bank, or the crafter with a cost limit), hand-over in person or by mail, tip and a note. Accepting means agreeing to exactly those terms.
- **Status with a full history**: open → accepted → in progress → crafted → sent → received → completed. Every order shows whose turn it is.
- **Accounts accept, characters craft.** Your alt may accept; the character who actually knows the recipe does the work. Simultaneous acceptance is resolved deterministically and the loser gets a clear message.
- **Requested crafter**: reserved for them for 24 hours, then open to everyone
- **Cost reimbursement** with partial payments and a running balance, closed off by both sides
- **Templates per recipe** — the weekly "15 primal mights" order becomes one click
- A compact **tracker window** that only appears when it is your turn

### Raid tracking

Start a session before the raid and end it afterwards. In between, Guild Copilot records attendance time, attempts, kills, wipes, deaths, resurrects, interrupts, dispels and consumables per participant. Boss fights are recognised through the client's own encounter events, so trash pulls do not inflate your attempt count. Clicking a participant opens their consumable log — what they used, and when.

The same raid night can exist from three sources — **live session**, **Warcraft Logs** and **combat log file**. It still appears once in the list: the most complete version is shown, the others are one click away and can be compared side by side. Numbers from different sources are never mixed.

Only summaries are stored. Raw combat log data never is.

### Gear checks

Missing enchants and empty sockets, slot by slot, for your whole group — and for yourself without any group at all.

Every addon user publishes a compact snapshot of their gear: slot, item ID, enchant ID, number of empty sockets. Nothing else — no verdicts, no tooltip text, no inventory. For raiders without the addon, **inspect the group** remains as a manual fallback, and anyone out of range is explicitly reported as skipped rather than silently passed.

Verdicts follow **archetype rather than role**. A shadow priest and a rogue are both "damage" but need completely different enchants, so Guild Copilot distinguishes spell damage, healing, physical damage and tanking. It ships with a rule set built from verified TBC enchant IDs, and your guild's **content phase** (T4 through T6.5) decides which rules apply at all — nobody is asked for an enchant that does not exist yet.

- **Your guild's own rules**: one click on a slot rates an enchant as optimal, solid or improvable — optionally for one specific spec. Guild rules always beat the shipped set.
- **Exemptions** for farm gear and resistance sets: right-click takes a slot out of scoring, visibly and with a reason
- A rule that does not apply to the player being checked is treated as if it did not exist. An unrated enchant is never counted as bad.
- There is deliberately **no overall score**. Findings read as sentences: "2 missing enchants: head, shoulder".

## How the sharing works

Guild Copilot is useful on its own and considerably more useful the more of your guild runs it.

- Everything travels over the **hidden addon channel**, never as visible chat, and only within your own guild
- Data is sent on login, on change and on request — no constant broadcasting. Large transfers pause during combat.
- Someone logging in **asks for the current state** and receives the profiles of everyone already online
- The guild overview shows who runs the addon and whose data version differs. It counts **players, not characters**: mains and alts appear as one.
- Anything guild-wide — guild profile, reply templates, care decisions, enchant rules, rank permissions — is maintained by one authorised officer and everyone has it

## Installation

Unzip so that `GuildCopilot.toc` ends up directly in
`World of Warcraft\_anniversary_\Interface\AddOns\GuildCopilot\`.
A doubly nested folder is the most common installation mistake.

Then type `/gcp` in game. A welcome window walks you through the rest.

### Optional companion installer

Two things an in-game addon is not allowed to do: reach the internet, and post chat on a timer. The first is why an optional Windows helper lives in the GitHub repository. It installs and updates the addon, pulls **Warcraft Logs** reports through the official API, and can turn a local `WoWCombatLog.txt` into an import code with no upload and no account at all. It is entirely optional — the addon works without it.

The helper is **not** distributed here, because CurseForge does not accept executables. Get it from the GitHub project page.

## Links

- **Source code and issues:** https://github.com/stryker-max/GuildCopilot
- **Full changelog:** ROADMAP.md in the repository
- **License:** MIT

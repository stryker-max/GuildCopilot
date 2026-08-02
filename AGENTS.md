# Project workflow

- **Never push to `main` without the owner's explicit go-ahead.** A push to `main` is a publication, not a commit: `.github/workflows/curseforge.yml` uploads every new TOC version to CurseForge automatically and sets the `v<version>` tag. Finish the work, run the tests, then ask.
- Always bring the local files up to the finished state, whether or not a push follows: the repository working tree, and the Anniversary installation at `C:\Program Files (x86)\World of Warcraft\_anniversary_\Interface\AddOns\GuildCopilot` if it exists — mirror the repository's `GuildCopilot` directory into it.
- Before copying, verify the exact source and target paths. After copying, verify the installed TOC version and compare every installed file with the repository by relative path and SHA-256 hash.
- Never copy repository-only files such as `Installer`, `tests`, `Brand`, or `.vscode` into the WoW AddOns directory.
- Never modify or remove the user's `WTF` SavedVariables while updating the addon.
- Every change gets a `CHANGELOG.md` entry as well as the detailed `ROADMAP.md` section, as requested by the repository owner.
- The local rights override lives outside this repository, as a separate addon at `C:\Program Files (x86)\World of Warcraft\_anniversary_\Interface\AddOns\GuildCopilotLocalRights`. It must never be added to the repository. It hooks `Roster:CanEditGuildProfile`, `Roster:CanAccessMemberCare` and `GearAudit:CanEditEnchantRules`; when any of those are renamed, update it.

# Project workflow

- Push completed, verified release changes directly to `main`, as requested by the repository owner.
- After every successful release push, if the local Anniversary installation exists at `C:\Program Files (x86)\World of Warcraft\_anniversary_\Interface\AddOns\GuildCopilot`, mirror the repository's `GuildCopilot` directory into it automatically.
- Before copying, verify the exact source and target paths. After copying, verify the installed TOC version and compare every installed file with the repository by relative path and SHA-256 hash.
- Never copy repository-only files such as `Installer`, `tests`, `Brand`, or `.vscode` into the WoW AddOns directory.
- Never modify or remove the user's `WTF` SavedVariables while updating the addon.

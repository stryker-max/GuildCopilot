@echo off
setlocal
title Guild Copilot - Warcraft Logs Import

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js 18 oder neuer wurde nicht gefunden.
  echo Download: https://nodejs.org/
  echo.
  pause
  exit /b 1
)

echo Guild Copilot - Warcraft Logs Import
echo.
echo Die API-Zugangsdaten werden nur fuer diesen Programmlauf verwendet.
echo Sie werden nicht in einer Datei gespeichert.
echo.

if not defined WCL_CLIENT_ID (
  set /p "WCL_CLIENT_ID=WCL Client ID: "
)
if not defined WCL_CLIENT_SECRET (
  for /f "usebackq delims=" %%S in (`powershell -NoProfile -Command "$secure=Read-Host 'WCL Client Secret' -AsSecureString; $ptr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure); try {[Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)} finally {[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)}"`) do set "WCL_CLIENT_SECRET=%%S"
)

echo.
set /p "WCL_GUILD_URL=Warcraft-Logs-Gildenlink: "
echo.
node "%~dp0WCL-Import.mjs" "%WCL_GUILD_URL%"
if errorlevel 1 (
  echo.
  echo Der Import ist fehlgeschlagen. Bitte die Meldung oben pruefen.
  pause
  exit /b 1
)

if exist "%TEMP%\GuildCopilot-WCL-Import.txt" (
  type "%TEMP%\GuildCopilot-WCL-Import.txt" | clip
  echo.
  echo Der Importcode wurde in die Zwischenablage kopiert.
  echo In WoW: Guild Copilot - Warcraft Logs - Companion-Import - Strg+V.
)

echo.
pause

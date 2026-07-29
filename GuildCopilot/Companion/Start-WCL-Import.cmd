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
echo Moeglich ist ein Gildenlink oder - zum ersten Ausprobieren - der Link
echo eines einzelnen Reports (.../reports/abcDEF123...).
echo.
set /p "WCL_GUILD_URL=Warcraft-Logs-Link: "
echo.
echo Wieviele der juengsten Reports sollen gelesen werden?
echo Fuer den ersten Versuch reicht 1. Leer lassen bedeutet 3.
set "WCL_REPORT_COUNT="
set /p "WCL_REPORT_COUNT=Anzahl [3]: "
if not defined WCL_REPORT_COUNT set "WCL_REPORT_COUNT=3"
echo.

node "%~dp0WCL-Import.mjs" "%WCL_GUILD_URL%" --reports %WCL_REPORT_COUNT% %*
if errorlevel 1 (
  echo.
  echo Der Import ist fehlgeschlagen. Bitte die Meldung oben pruefen.
  echo.
  echo Fuer eine genauere Fehlersuche denselben Aufruf mit --debug wiederholen:
  echo   node "%~dp0WCL-Import.mjs" "%WCL_GUILD_URL%" --reports 1 --debug
  echo Die Datei GuildCopilot-WCL-Debug.json im Ordner %%TEMP%% enthaelt dann
  echo die Rohantworten von Warcraft Logs - sie enthaelt keine Zugangsdaten.
  echo.
  pause
  exit /b 1
)

if exist "%TEMP%\GuildCopilot-WCL-Import.txt" (
  rem "type ... | clip" liest die Datei mit der Codepage der Konsole. Die
  rem Importdatei ist UTF-8, dabei zerfaellt jeder Umlaut in zwei falsche
  rem Zeichen - aus "Aepfelbaum" mit A-Umlaut wird ein Kaestchen plus Buchstabe,
  rem und der Name passt danach zu keinem Gildenmitglied mehr. Deshalb wird
  rem die Datei ausdruecklich als UTF-8 gelesen und als Unicode in die
  rem Zwischenablage gelegt.
  powershell -NoProfile -Command "Set-Clipboard -Value ([IO.File]::ReadAllText((Join-Path $env:TEMP 'GuildCopilot-WCL-Import.txt'), [Text.Encoding]::UTF8))"
  echo.
  echo Der Importcode wurde in die Zwischenablage kopiert.
  echo In WoW: Guild Copilot - Warcraft Logs - Companion-Import - Strg+V.
)

echo.
pause

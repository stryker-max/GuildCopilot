@echo off
setlocal
title Guild Copilot - Installation

echo.
echo   Guild Copilot - Installation fuer TBC Classic Anniversary
echo   =========================================================
echo.

set "QUELLE=%~dp0GuildCopilot"
if not exist "%QUELLE%\GuildCopilot.toc" (
    echo   FEHLER: Neben dieser Datei fehlt der Ordner "GuildCopilot".
    echo.
    echo   Bitte das ZIP vollstaendig entpacken und Install.cmd aus dem
    echo   entpackten Ordner starten - nicht direkt aus dem ZIP heraus.
    echo.
    pause
    exit /b 1
)

set "ZIEL="
for %%P in (
    "%ProgramFiles(x86)%\World of Warcraft\_anniversary_"
    "%ProgramFiles%\World of Warcraft\_anniversary_"
    "C:\Program Files (x86)\World of Warcraft\_anniversary_"
    "C:\Program Files\World of Warcraft\_anniversary_"
    "C:\World of Warcraft\_anniversary_"
    "D:\World of Warcraft\_anniversary_"
    "D:\Games\World of Warcraft\_anniversary_"
    "E:\World of Warcraft\_anniversary_"
) do (
    if not defined ZIEL if exist "%%~P\Interface" set "ZIEL=%%~P"
)

if not defined ZIEL (
    echo   Die WoW-Installation wurde nicht automatisch gefunden.
    echo.
    echo   Bitte den Pfad zum Ordner "_anniversary_" eingeben.
    echo   Beispiel: C:\Program Files ^(x86^)\World of Warcraft\_anniversary_
    echo.
    set /p "ZIEL=Pfad: "
)

set "ZIEL=%ZIEL:"=%"
if not exist "%ZIEL%\Interface" (
    echo.
    echo   FEHLER: In "%ZIEL%" gibt es keinen Ordner "Interface".
    echo   Das ist vermutlich nicht der richtige Pfad.
    echo.
    pause
    exit /b 1
)

set "ADDONS=%ZIEL%\Interface\AddOns"
if not exist "%ADDONS%" mkdir "%ADDONS%"
if not exist "%ADDONS%" (
    echo.
    echo   FEHLER: Der AddOns-Ordner konnte nicht angelegt werden.
    echo   Bitte Install.cmd per Rechtsklick als Administrator ausfuehren.
    echo.
    pause
    exit /b 1
)

echo   Ziel: %ADDONS%\GuildCopilot
echo.

if exist "%ADDONS%\GuildCopilot" (
    echo   Eine vorhandene Version wird aktualisiert.
    echo   Gespeicherte Einstellungen liegen im WTF-Ordner und bleiben erhalten.
    echo   Der Ordner wird nicht vorab geloescht, damit ein Kopierfehler die
    echo   funktionierende Installation nicht vollstaendig entfernt.
)

xcopy /E /I /Q /Y "%QUELLE%" "%ADDONS%\GuildCopilot" >nul
if errorlevel 1 (
    echo.
    echo   FEHLER: Das Kopieren ist fehlgeschlagen.
    echo   Bitte Install.cmd per Rechtsklick als Administrator ausfuehren.
    echo.
    pause
    exit /b 1
)

if not exist "%ADDONS%\GuildCopilot\GuildCopilot.toc" (
    echo.
    echo   FEHLER: Nach dem Kopieren fehlt die Datei GuildCopilot.toc.
    echo.
    pause
    exit /b 1
)

echo   Fertig. Guild Copilot ist installiert.
echo.
echo   Naechste Schritte:
echo     1. WoW neu starten
echo     2. Am Charakterbildschirm auf "AddOns" klicken und Guild Copilot aktivieren
echo     3. Im Spiel /gcp eingeben
echo.
pause

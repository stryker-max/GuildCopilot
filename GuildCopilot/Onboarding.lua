local _, GC = ...

-- === Erste Schritte ========================================================
--
-- Kein eigenes Wizard-Fenster, sondern eine Checkliste oben auf der
-- Profilseite: Alle drei Schritte leben dort ohnehin. Ein Fenster daneben
-- muesste dieselben Karten entweder verdoppeln oder ueberdecken - und weil die
-- echte Aktion der Uebergang sein soll, muesste es die echten Karten trotzdem
-- beobachten. Dann kann es auch gleich dorthin fuehren.
--
-- Der Zustand wird aus den echten Daten abgeleitet und nicht in Merkern
-- gefuehrt. Ein Merker, der behauptet, was noch zu tun sei, laeuft der
-- Wirklichkeit hinterher, sobald jemand seinen Beruf auf einem anderen Weg
-- eintraegt. Nebenbei beantwortet sich damit die Frage "kontoweit oder pro
-- Charakter?" von selbst: Spec, Berufe und Ausruestung gelten pro Charakter,
-- also sieht ein frischer Twink die Liste und ein fertiger Charakter nicht.
--
-- Gespeichert wird nur, was sich aus den Daten nicht ablesen laesst:
-- Uebersprungenes, Ausgeblendetes und die beiden einmaligen Ereignisse. Es
-- gibt dafuer keinen Sendeweg - die Einrichtung ist die eigene Sache.

GC.Onboarding = {}

-- Ein paar Sekunden nach dem Betreten der Welt. Frueher faellt es in die
-- Login-Lastspitze und andere Addons bauen noch ihre Fenster auf.
local AUTO_OPEN_DELAY = 6

local STEPS = {
    {
        key = "PROFILE",
        label = "Raidprofil bestätigen",
        hint = "Primär-Spec wählen und auf „Bestätigen“ klicken – das ist der ganze Schritt.",
    },
    {
        key = "PROFESSIONS",
        label = "Berufe einlesen",
        hint = "Öffne einmal jedes deiner Berufsfenster; Guild Copilot liest den Bestand von selbst.",
    },
    {
        key = "GEAR",
        label = "Ausrüstung ansehen",
        hint = "Die Prüfung läuft im Hintergrund – hier steht gleich ihr Ergebnis.",
    },
}

local function InCombat()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        return true
    end
    return type(UnitAffectingCombat) == "function" and UnitAffectingCombat("player") == true
end

-- Welche Berufe dieser Charakter hat. Der Weg ist gleichgueltig: aus dem
-- geoeffneten Berufsfenster gescannt oder von Hand gewaehlt - es zaehlt das
-- Ergebnis, nicht wie es zustande kam.
local function KnownProfessions()
    local profile = GC.Profile:Get()
    local names = {}
    local seen = {}
    local function Add(name)
        name = GC.Util.Trim(name or "")
        if name == "" or seen[name] then
            return
        end
        seen[name] = true
        names[#names + 1] = name
    end
    for slot = 1, 2 do
        local profession = profile.professions and profile.professions[slot]
        Add(profession and profession.name)
    end
    for _, profession in pairs((profile.workshop and profile.workshop.professions) or {}) do
        Add(profession and profession.name)
    end
    return names
end

-- Ist der Schritt erledigt, und was ist dabei herausgekommen? Der zweite
-- Rueckgabewert steht als Rueckmeldung an der Zeile: Wer gerade sein
-- Berufsfenster geoeffnet hat, soll den erkannten Beruf lesen, nicht nur
-- einen Haken sehen.
function GC.Onboarding:GetStepState(stepKey)
    if stepKey == "PROFILE" then
        local profile = GC.Profile:Get()
        if profile.confirmed ~= true then
            return false, nil
        end
        local spec = GC.SpecByKey[profile.raidSpecKey or ""]
        return true, spec and (spec.name .. " bestätigt") or "Bestätigt"
    elseif stepKey == "PROFESSIONS" then
        local names = KnownProfessions()
        if #names == 0 then
            return false, nil
        end
        return true, table.concat(names, ", ") .. " erkannt"
    elseif stepKey == "GEAR" then
        local audit = GC.GearAudit and GC.GearAudit:GetAudit(GC:GetPlayerFullName())
        if not audit then
            return false, nil
        end
        local findings = GC.GearAudit:GetFindings(audit)
        return true, findings[1] and findings[1].text or nil
    end
    return false, nil
end

function GC.Onboarding:GetData()
    local character = GC.DB:GetCharacter()
    character.onboarding = GC.Util.MergeDefaults(character.onboarding, {
        skipped = {},
        dismissedAt = 0,
        autoOpenedAt = 0,
        doneShownAt = 0,
    })
    return character.onboarding
end

-- Die drei Zeilen der Checkliste. Aktiv ist immer die erste, die weder
-- erledigt noch uebersprungen ist - einen "Weiter"-Knopf gibt es bewusst
-- nicht, die echte Aktion schiebt die Liste weiter.
function GC.Onboarding:GetSteps()
    local data = self:GetData()
    local steps = {}
    local activeFound = false
    for index, definition in ipairs(STEPS) do
        local done, detail = self:GetStepState(definition.key)
        -- Uebersprungen heisst "nicht draengeln", nicht "nicht wahrnehmen":
        -- Passiert die echte Aktion spaeter doch, gewinnt sie.
        local skipped = not done and data.skipped[definition.key] == true
        local step = {
            key = definition.key,
            label = definition.label,
            hint = definition.hint,
            detail = detail,
            done = done,
            skipped = skipped,
            active = false,
        }
        if not done and not skipped and not activeFound then
            step.active = true
            activeFound = true
        end
        steps[index] = step
    end
    return steps
end

function GC.Onboarding:IsFinished()
    for _, step in ipairs(self:GetSteps()) do
        if not step.done and not step.skipped then
            return false
        end
    end
    return true
end

function GC.Onboarding:SetStepSkipped(stepKey, skipped)
    local data = self:GetData()
    for _, definition in ipairs(STEPS) do
        if definition.key == stepKey then
            if skipped == true then
                data.skipped[stepKey] = true
            else
                data.skipped[stepKey] = nil
            end
            return true
        end
    end
    return false
end

-- Das × der Karte: weg fuer diese Sitzung, beim naechsten Login wieder da.
function GC.Onboarding:HideForSession()
    self.hiddenForSession = true
end

-- „Nicht mehr anzeigen“: dauerhaft weg, aber nur fuer diesen Charakter.
function GC.Onboarding:Dismiss()
    self:GetData().dismissedAt = GC.Util.Now()
    self.completionVisible = nil
end

-- Der Knopf „Einrichtung“ im Fensterkopf. Er faengt die Liste neu an, statt
-- sie nur wieder einzublenden: Wer sie ausdruecklich aufruft, will sie
-- durchgehen - eine Liste aus lauter uebersprungenen Zeilen waere dafuer
-- nutzlos. Was tatsaechlich erledigt ist, bleibt erledigt; das steht in den
-- echten Daten und nicht in diesen Merkern.
function GC.Onboarding:Reopen()
    local data = self:GetData()
    data.skipped = {}
    data.dismissedAt = 0
    self.hiddenForSession = nil
    self.completionVisible = true
    return true
end

function GC.Onboarding:ShouldShow()
    local data = self:GetData()
    if self.hiddenForSession == true then
        return false
    end
    if (data.dismissedAt or 0) > 0 then
        return false
    end
    if self:IsFinished() then
        -- Die Erfolgsmeldung soll man lesen koennen: Sie bleibt bis zum
        -- Schliessen des Fensters stehen und ist beim naechsten Oeffnen weg.
        return self.completionVisible == true or (data.doneShownAt or 0) == 0
    end
    return true
end

-- Vom UI beim Zeichnen der fertigen Liste. Der Rueckgabewert sagt, ob es das
-- erste Mal ist - nur dann gibt es den Ton dazu.
function GC.Onboarding:NoteCompleted()
    local data = self:GetData()
    self.completionVisible = true
    if (data.doneShownAt or 0) > 0 then
        return false
    end
    data.doneShownAt = GC.Util.Now()
    return true
end

function GC.Onboarding:NoteWindowClosed()
    self.completionVisible = nil
end

-- Beim ersten Login eines Charakters ohne bestaetigtes Profil oeffnet sich
-- das Fenster einmal von selbst - Twinks eingeschlossen, das ist die
-- ausdrueckliche Entscheidung des Owners.
function GC.Onboarding:ShouldAutoOpen()
    local data = self:GetData()
    if (data.autoOpenedAt or 0) > 0 or (data.dismissedAt or 0) > 0 then
        return false
    end
    -- Wer sein Profil laengst bestaetigt hat, wird nicht behelligt: Das sind
    -- genau die Charaktere, die es vor dieser Fassung schon gab.
    local profileDone = self:GetStepState("PROFILE")
    if profileDone then
        return false
    end
    return not InCombat()
end

-- Der Merker wird beim tatsaechlichen Oeffnen gesetzt, nicht davor. Dadurch
-- kann das Fenster nie zweimal aufspringen, und ein Login mitten im Kampf
-- verschiebt es auf das naechste Mal, statt es zu verbrauchen.
function GC.Onboarding:AutoOpen()
    if not GC.DB or not GC.DB.data or not GC.UI then
        return false
    end
    if not self:ShouldAutoOpen() then
        return false
    end
    self:GetData().autoOpenedAt = GC.Util.Now()
    GC.UI:CreateMainFrame()
    GC.UI.frame:Show()
    -- Ueber ShowPage statt ueber activePage: Nur so werden auch die Sichtbarkeit
    -- der Seiten und der aktive Reiter mitgezogen.
    GC.UI:ShowPage("ROSTER")
    return true
end

local onboardingEvents = CreateFrame("Frame")
onboardingEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
onboardingEvents:SetScript("OnEvent", function(frame)
    -- PLAYER_ENTERING_WORLD feuert auch bei jedem Zonenwechsel. Fuer die
    -- Einrichtung zaehlt nur das erste Mal.
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(AUTO_OPEN_DELAY, function()
        GC.Onboarding:AutoOpen()
    end)
end)

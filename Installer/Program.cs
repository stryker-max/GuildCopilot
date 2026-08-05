using System.Diagnostics;
using System.Text.Json;
using GuildCopilot.Installer.CombatLog;
using GuildCopilot.Installer.Wcl;

namespace GuildCopilot.Installer;

internal static class Program
{
    private const string SingleInstanceMutex = @"Local\GuildCopilotInstaller";
    private const int RestartWaitMilliseconds = 30_000;
    private const int LegacyRestartWaitMilliseconds = 5_000;

    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length > 0 && args[0] == "--wait-for-pid")
        {
            if (!TryGetPreviousProcessId(args, out var previousProcessId))
            {
                return 2;
            }
            if (!WaitForPreviousInstance(previousProcessId))
            {
                return 3;
            }
            args = args.Skip(2).ToArray();
        }

        // Verborgener Selbsttest: spielt eine mit --debug aufgezeichnete
        // Antwort durch die Auswertung und gibt die Importzeilen aus. So laesst
        // sich diese Fassung gegen die zuvor gegen echte Reports geprueften
        // Zeilen vergleichen, ohne Zugangsdaten und ohne Netz.
        if (args.Length == 2 && args[0] == "--selftest")
        {
            return RunSelfTest(args[1]);
        }
        if (args.Length == 1 && args[0] == "--selftest-core")
        {
            return RunCoreSelfTest();
        }
        if (!WaitForLegacySelfUpdate())
        {
            // Versionen vor 1.0.3 starten die neue EXE noch ohne PID-Handoff.
            // Auch bei genau diesem ersten Update darf kein zweites Fenster
            // erscheinen: Die neue Instanz beendet sich, falls die alte nach
            // fünf Sekunden wider Erwarten noch immer läuft.
            return 0;
        }
        if (args.Length == 1 && args[0] == "--selftest-startup")
        {
            return 0;
        }

        ApplicationConfiguration.Initialize();
        using var singleInstance = new Mutex(initiallyOwned: false, SingleInstanceMutex);
        var ownsMutex = false;
        try
        {
            try
            {
                ownsMutex = singleInstance.WaitOne(0);
            }
            catch (AbandonedMutexException)
            {
                ownsMutex = true;
            }

            // Auch ein normaler Doppelklick darf nie ein zweites Fenster
            // erzeugen. Beim Selbstupdate wartet die neue Instanz vorher auf
            // die alte und erwirbt den Mutex erst nach deren Ende.
            if (!ownsMutex)
            {
                return 0;
            }

            Application.Run(new MainForm());
            return 0;
        }
        finally
        {
            if (ownsMutex)
            {
                singleInstance.ReleaseMutex();
            }
        }
    }

    private static bool TryGetPreviousProcessId(string[] args, out int processId)
    {
        processId = 0;
        return args.Length >= 2
            && args[0] == "--wait-for-pid"
            && int.TryParse(args[1], out processId)
            && processId > 0
            && processId != Environment.ProcessId;
    }

    private static bool WaitForPreviousInstance(int processId)
    {
        try
        {
            using var previous = Process.GetProcessById(processId);
            return previous.WaitForExit(RestartWaitMilliseconds);
        }
        catch (ArgumentException)
        {
            // Der alte Prozess war bereits beendet, bevor die neue Instanz
            // seinen Handle öffnen konnte: genau der gewünschte Zustand.
            return true;
        }
        catch (InvalidOperationException)
        {
            return true;
        }
    }

    private static bool WaitForLegacySelfUpdate()
    {
        var currentPath = Environment.ProcessPath;
        if (currentPath is null || !File.Exists(currentPath + ".old"))
        {
            return true;
        }

        using var current = Process.GetCurrentProcess();
        foreach (var candidate in Process.GetProcessesByName(current.ProcessName))
        {
            using (candidate)
            {
                if (candidate.Id == current.Id)
                {
                    continue;
                }
                try
                {
                    if (!candidate.WaitForExit(LegacyRestartWaitMilliseconds))
                    {
                        return false;
                    }
                }
                catch (InvalidOperationException)
                {
                    // Zwischen Prozesssuche und WaitForExit bereits beendet.
                }
            }
        }
        return true;
    }

    private static int RunSelfTest(string debugFile)
    {
        try
        {
            // Ohne das schreibt die Konsole in der Codepage des Fensters und
            // zerlegt jeden Umlaut - der Vergleich schlüge dann fehl, obwohl
            // die Daten stimmen.
            Console.OutputEncoding = System.Text.Encoding.UTF8;
            using var document = JsonDocument.Parse(File.ReadAllText(debugFile));
            JsonElement report = default;
            var order = new[] { "deaths", "resurrects", "interrupts", "dispels", "casts", "buffs" };
            var eventLists = new List<List<JsonElement>>();

            foreach (var entry in document.RootElement.EnumerateArray())
            {
                if (!entry.TryGetProperty("payload", out var payload)
                    || !payload.TryGetProperty("data", out var data)
                    || !data.TryGetProperty("reportData", out var reportData)
                    || !reportData.TryGetProperty("report", out var current)
                    || current.ValueKind != JsonValueKind.Object)
                {
                    continue;
                }

                if (current.TryGetProperty("fights", out _))
                {
                    report = current.Clone();
                }
                else if (current.TryGetProperty("events", out var events)
                         && events.TryGetProperty("data", out var rows)
                         && rows.ValueKind == JsonValueKind.Array)
                {
                    eventLists.Add(rows.EnumerateArray().Select(row => row.Clone()).ToList());
                }
            }

            if (report.ValueKind != JsonValueKind.Object || eventLists.Count < order.Length)
            {
                Console.Error.WriteLine(
                    $"Die Aufzeichnung ist unvollständig: {eventLists.Count} Ereignisabfragen, erwartet {order.Length}.");
                return 1;
            }

            var events2 = new Dictionary<string, List<JsonElement>>();
            for (var index = 0; index < order.Length; index++)
            {
                events2[order[index]] = eventLists[index];
            }

            foreach (var line in WclImporter.ReplayRecorded(report, events2))
            {
                Console.WriteLine(line);
            }
            return 0;
        }
        catch (Exception error)
        {
            Console.Error.WriteLine($"Selbsttest fehlgeschlagen: {error.Message}");
            return 1;
        }
    }

    private static int RunCoreSelfTest()
    {
        try
        {
            if (!TryGetPreviousProcessId(["--wait-for-pid", "12345"], out var parsedProcessId)
                || parsedProcessId != 12345
                || TryGetPreviousProcessId(["--wait-for-pid", "kein-prozess"], out _)
                || TryGetPreviousProcessId(["--wait-for-pid"], out _))
            {
                throw new InvalidOperationException("Der Neustart-Handoff wird falsch ausgewertet.");
            }

            var reportTarget = WclTarget.Parse("HTTPS://fresh.warcraftlogs.com/reports/aBcD1234efGH5678");
            if (reportTarget.Kind != TargetKind.Report || reportTarget.ReportCode != "aBcD1234efGH5678")
            {
                throw new InvalidOperationException("Ein gültiger Reportlink wurde falsch ausgewertet.");
            }

            AssertRejected("https://warcraftlogs.com.evil.example/reports/aBcD1234efGH5678");
            AssertRejected("https://fresh.warcraftlogs.com/reports/aBcD1234efGH5678/extra");
            AssertRejected("https://fresh.warcraftlogs.com/guild/moon/thunderstrike/aftermath");

            using var reportDocument = JsonDocument.Parse("""
                {
                  "code": "aBcD1234efGH5678",
                  "startTime": 100000,
                  "endTime": 170000,
                  "zone": { "name": "Karazhan" },
                  "masterData": { "actors": [
                    { "id": 1, "name": "Nexarius", "subType": "Mage" },
                    { "id": 2, "name": "Unbeteiligt", "subType": "Priest" }
                  ] },
                  "fights": [
                    { "id": 1, "name": "Attumen", "kill": true,
                      "startTime": 1000, "endTime": 61000, "friendlyPlayers": [1] }
                  ]
                }
                """);
            using var outsiderEventDocument = JsonDocument.Parse(
                """[{ "type": "interrupt", "sourceID": 2 }]""");
            var events = new Dictionary<string, List<JsonElement>>
            {
                ["deaths"] = [],
                ["resurrects"] = [],
                ["interrupts"] = outsiderEventDocument.RootElement.EnumerateArray()
                    .Select(row => row.Clone()).ToList(),
                ["dispels"] = [],
                ["casts"] = [],
                ["buffs"] = [],
            };
            var lines = WclImporter.ReplayRecorded(reportDocument.RootElement, events);
            if (lines.Count != 2
                || !lines[1].StartsWith("P|Nexarius|MAGE|60|", StringComparison.Ordinal)
                || lines.Any(line => line.Contains("Unbeteiligt", StringComparison.Ordinal)))
            {
                throw new InvalidOperationException("Die Encounter-Teilnehmerauswahl ist fehlerhaft.");
            }

            AssertCombatLogImport();

            Console.WriteLine("OK: Installer-Kernprüfungen bestanden.");
            return 0;
        }
        catch (Exception error)
        {
            Console.Error.WriteLine($"Kernselbsttest fehlgeschlagen: {error.Message}");
            return 1;
        }
    }

    /// <summary>
    /// Prueft den Offline-Import an einem von Hand gebauten Kampfprotokoll.
    /// Beide Fehler, die hier abgesichert werden, waren im Vergleichslog vom
    /// 02.08.2026 sichtbar und sind live laengst behoben - der Importer hat
    /// sie bis 1.0.6 weitergemacht:
    ///
    ///   - Eine Trommel bufft die ganze Gruppe. Gezaehlt wird nur, wer sie
    ///     wirft; der Buff beim Empfaenger ist kein Verbrauch.
    ///   - Ein Trank mit Buff erzeugt Zauber UND Aura. Nur der Zauber zaehlt.
    ///   - Essen erzeugt nie einen Zauber. Dort zaehlt allein der Buff.
    ///
    /// Dazu der Jahreswechsel: Ein Abend, der ueber Silvester reicht, gehoert
    /// ins alte Jahr und nicht ins Jahr des Dateidatums.
    /// </summary>
    private static void AssertCombatLogImport()
    {
        var path = Path.Combine(Path.GetTempPath(), $"GuildCopilot-Selbsttest-{Guid.NewGuid():N}.txt");
        try
        {
            File.WriteAllLines(path,
            [
                "12/31 23:50:00.000  ENCOUNTER_START,652,\"Attumen\",2,10",
                "12/31 23:50:05.000  SPELL_CAST_SUCCESS,Player-1-01,\"Alex-Thunderstrike\",0,0,"
                    + "Player-1-01,\"Alex-Thunderstrike\",0,0,35476,\"Trommeln der Schlacht\",0",
                "12/31 23:50:05.100  SPELL_AURA_APPLIED,Player-1-01,\"Alex-Thunderstrike\",0,0,"
                    + "Player-1-02,\"Bea-Thunderstrike\",0,0,35476,\"Trommeln der Schlacht\",0",
                "12/31 23:50:06.000  SPELL_CAST_SUCCESS,Player-1-01,\"Alex-Thunderstrike\",0,0,"
                    + "Player-1-01,\"Alex-Thunderstrike\",0,0,28507,\"Hasttrank\",0",
                "12/31 23:50:06.500  SPELL_AURA_APPLIED,Player-1-01,\"Alex-Thunderstrike\",0,0,"
                    + "Player-1-01,\"Alex-Thunderstrike\",0,0,28507,\"Hasttrank\",0",
                "12/31 23:50:07.000  SPELL_AURA_APPLIED,Player-1-02,\"Bea-Thunderstrike\",0,0,"
                    + "Player-1-02,\"Bea-Thunderstrike\",0,0,33257,\"Sattgegessen\",0",
                "12/31 23:51:00.000  ENCOUNTER_END,652,\"Attumen\",2,10,1",
                "1/1 00:10:00.000  ENCOUNTER_START,653,\"Moroes\",2,10",
                "1/1 00:11:00.000  ENCOUNTER_END,653,\"Moroes\",2,10,1",
            ]);
            File.SetLastWriteTime(path, new DateTime(2027, 1, 1, 1, 0, 0));

            var result = new CombatLogImporter().Run(path, new Progress<string>(_ => { }), CancellationToken.None);
            var lines = result.Text.Split('\n', StringSplitOptions.RemoveEmptyEntries);

            var alex = lines.FirstOrDefault(line => line.StartsWith("P|Alex|", StringComparison.Ordinal));
            var bea = lines.FirstOrDefault(line => line.StartsWith("P|Bea|", StringComparison.Ordinal));
            if (alex is null || bea is null)
            {
                throw new InvalidOperationException("Der Offline-Import hat nicht beide Teilnehmer erzeugt.");
            }

            // Feld 7 der P-Zeile haelt die Verbrauchsgegenstaende, nach
            // Spell-ID aufsteigend.
            var alexConsumables = alex.Split('|')[7];
            if (alexConsumables != "28507:1,35476:1")
            {
                throw new InvalidOperationException(
                    $"Trommel oder Trank zaehlen falsch: \"{alexConsumables}\" statt \"28507:1,35476:1\".");
            }

            var beaConsumables = bea.Split('|')[7];
            if (beaConsumables != "33257:1")
            {
                throw new InvalidOperationException(
                    "Der Trommelbuff wurde dem Empfaenger gutgeschrieben oder das Essen fehlt: "
                    + $"\"{beaConsumables}\" statt \"33257:1\".");
            }

            if (!lines[1].StartsWith("S|20261231-2350|", StringComparison.Ordinal))
            {
                throw new InvalidOperationException(
                    $"Der Abend ueber Silvester steht im falschen Jahr: \"{lines[1]}\".");
            }
        }
        finally
        {
            try
            {
                File.Delete(path);
            }
            catch
            {
                // Eine liegengebliebene Testdatei im Temp-Ordner ist harmlos.
            }
        }
    }

    private static void AssertRejected(string link)
    {
        try
        {
            WclTarget.Parse(link);
        }
        catch (ArgumentException)
        {
            return;
        }
        throw new InvalidOperationException($"Ungültiger Link wurde akzeptiert: {link}");
    }
}

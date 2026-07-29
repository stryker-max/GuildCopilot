using System.Text.Json;
using GuildCopilot.Installer.Wcl;

namespace GuildCopilot.Installer;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
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

        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
        return 0;
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

            Console.WriteLine("OK: Installer-Kernprüfungen bestanden.");
            return 0;
        }
        catch (Exception error)
        {
            Console.Error.WriteLine($"Kernselbsttest fehlgeschlagen: {error.Message}");
            return 1;
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

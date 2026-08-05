namespace GuildCopilot.Installer;

/// <summary>
/// Was das Importfeld im Addon aufnehmen kann. Beide Importwege - Warcraft
/// Logs und das Offline-Kampfprotokoll - schreiben in dasselbe Feld und
/// muessen sich deshalb an dieselbe Zahl halten.
/// </summary>
public static class AddonImport
{
    /// <summary>
    /// So viele Zeichen nimmt das Importfeld im Addon entgegen
    /// (SetMaxLetters in UI.lua, Seite "Warcraft Logs"). WoW schneidet
    /// laengeren Text beim Einfuegen stillschweigend ab, und der Parser
    /// akzeptiert den Rest als gueltigen Teilimport - der Abend fehlt dann
    /// halb, ohne dass irgendwo ein Fehler steht.
    ///
    /// Wer diese Zahl aendert, aendert sie auch in UI.lua und in
    /// Companion/WCL-Import.mjs.
    /// </summary>
    public const int Limit = 60000;
}

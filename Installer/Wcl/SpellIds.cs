namespace GuildCopilot.Installer.Wcl;

/// <summary>
/// Spell-IDs, die uebertragen werden duerfen. In welche Kategorie eine ID
/// faellt, entscheidet allein GC.Consumables im Addon; unbekannte IDs werden
/// dort ignoriert und erzeugen nie falsche Zahlen. Diese Liste darf deshalb
/// grosszuegiger sein als die Addon-Tabelle.
/// </summary>
public static class SpellIds
{
    public static readonly int[] Consumables =
    {
        28495, 28499, 28507, 28508, 28494, 28511, 28512, 38908,
        16666, 27869,
        35476, 35475, 35478, 35477, 35474,
        28518, 28519, 28520, 28521, 28540,
        28490, 28497, 28491, 28493, 28501, 28502, 28503, 28509, 39625, 39627,
        28017, 28019,
    };

    /// <summary>
    /// Warcraft Logs kennt keinen Ereignistyp "Resurrects" - das Enum
    /// EventDataType hat ihn nicht. Wiederbelebungen werden deshalb wie in der
    /// Livesitzung ueber den gewirkten Zauber gezaehlt.
    ///
    /// Jede ID ist einzeln gegen die TBC-Spelldatenbank geprueft. Das ist keine
    /// Formsache: eine aus dem Gedaechtnis eingetragene ID (25235) war in
    /// Wirklichkeit "Flash Heal" und hat drei Priestern 349, 256 und 209
    /// Wiederbelebungen angedichtet.
    /// </summary>
    public static readonly int[] Resurrects =
    {
        // Wiedergeburt (Druide), Raenge 1-6
        20484, 20739, 20742, 20747, 20748, 26994,
        // Auferstehung (Priester), Raenge 1-6
        2006, 2010, 10880, 10881, 20770, 25435,
        // Erloesung (Paladin), Raenge 1-5
        7328, 10322, 10324, 20772, 20773,
        // Ahnengeist (Schamane), Raenge 1-6
        2008, 20609, 20610, 20776, 20777, 25590,
        // Selbstwiederbelebung: Reinkarnation und Seelenstein
        20608,
        20707, 20762, 20763, 20764, 20765, 27239,
    };

    public static readonly HashSet<int> ConsumableSet = new(Consumables);
    public static readonly HashSet<int> ResurrectSet = new(Resurrects);
}

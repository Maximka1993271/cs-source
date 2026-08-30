/*
    Iron Sentinel AntiCheat - Cached Banlist Checker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Локальные кэшированные Steam2-списки. Без фиктивных HTTP-загрузок и без утверждений о внешних сервисах.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Cached Banlist Checker",
    author = "Maxim Melnikov",
    description = "Local cached Steam2 banlist checker",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

ConVar g_hEacEnabled;
ConVar g_hEacKick;
ConVar g_hEseaEnabled;
ConVar g_hEseaKick;
ConVar g_hLogging;
bool g_bEacEnabled;
bool g_bEacKick;
bool g_bEseaEnabled;
bool g_bEseaKick;
bool g_bLogging;
Handle g_hBanlistEAC = INVALID_HANDLE;
Handle g_hBanlistESEA = INVALID_HANDLE;
char g_sEacPath[PLATFORM_MAX_PATH];
char g_sEseaPath[PLATFORM_MAX_PATH];
int g_iEacFileTime = -1;
int g_iEseaFileTime = -1;
int g_iReloadCount = 0;
Handle g_hRefreshTimer = INVALID_HANDLE;

public void OnPluginStart()
{
    g_hEacEnabled = FindConVar("is_banlist_eac_enabled");
    g_hEacKick = FindConVar("is_banlist_eac_kick");
    g_hEseaEnabled = FindConVar("is_banlist_esea_enabled");
    g_hEseaKick = FindConVar("is_banlist_esea_kick");
    g_hLogging = FindConVar("is_banlist_logging");
    if (g_hEacEnabled == null) g_hEacEnabled = CreateConVar("is_banlist_eac_enabled", "0", "Enable local EAC-compatible cache check", 0, true, 0.0, true, 1.0);
    if (g_hEacKick == null) g_hEacKick = CreateConVar("is_banlist_eac_kick", "0", "Kick on local EAC-compatible cache hit", 0, true, 0.0, true, 1.0);
    if (g_hEseaEnabled == null) g_hEseaEnabled = CreateConVar("is_banlist_esea_enabled", "0", "Enable local ESEA-compatible cache check", 0, true, 0.0, true, 1.0);
    if (g_hEseaKick == null) g_hEseaKick = CreateConVar("is_banlist_esea_kick", "0", "Kick on local ESEA-compatible cache hit", 0, true, 0.0, true, 1.0);
    if (g_hLogging == null) g_hLogging = CreateConVar("is_banlist_logging", "1", "Log cached banlist checks", 0, true, 0.0, true, 1.0);
    g_hEacEnabled.AddChangeHook(OnSettingsChanged);
    g_hEacKick.AddChangeHook(OnSettingsChanged);
    g_hEseaEnabled.AddChangeHook(OnSettingsChanged);
    g_hEseaKick.AddChangeHook(OnSettingsChanged);
    g_hLogging.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");

    // Инициализация путей и кэшей должна завершиться до первого ReloadCaches().
    BuildPath(Path_SM, g_sEacPath, sizeof(g_sEacPath), "configs/iron_sentinel/banlist_eac.txt");
    BuildPath(Path_SM, g_sEseaPath, sizeof(g_sEseaPath), "configs/iron_sentinel/banlist_esea.txt");
    g_hBanlistEAC = CreateTrie();
    g_hBanlistESEA = CreateTrie();
    RegAdminCmd("is_banlist_reload", Command_Reload, ADMFLAG_ROOT, "Reload cached banlists");
    RegAdminCmd("is_banlist_status", Command_Status, ADMFLAG_GENERIC, "Show cached banlist status");
    // Defer initial reload until all plugins/natives are initialized.
    CreateTimer(0.2, Timer_InitialReload, _, TIMER_FLAG_NO_MAPCHANGE);
    // Must survive map changes: created once here and never re-armed anywhere else, so
    // TIMER_FLAG_NO_MAPCHANGE would leave g_hRefreshTimer holding a stale handle after
    // the first map change, silently stopping the 60s mtime-based reload check for the
    // rest of the server's uptime and making OnPluginEnd()'s KillTimer() throw.
    g_hRefreshTimer = CreateTimer(60.0, Timer_CheckFiles, _, TIMER_REPEAT);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bEacEnabled = g_hEacEnabled.BoolValue;
    g_bEacKick = g_hEacKick.BoolValue;
    g_bEseaEnabled = g_hEseaEnabled.BoolValue;
    g_bEseaKick = g_hEseaKick.BoolValue;
    g_bLogging = g_hLogging.BoolValue;
}

public void OnClientPostAdminCheck(int client)
{
    if (!g_bEacEnabled && !g_bEseaEnabled) return;
    if (!IsClientInGame(client) || IsFakeClient(client)) return;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return;

    char auth[MAX_AUTHID_LENGTH];
    if (!GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth), true)) return;

    int dummy;
    if (g_bEacEnabled && GetTrieValue(g_hBanlistEAC, auth, dummy))
    {
        HandleHit(client, "EAC-cache", g_bEacKick);
        return;
    }
    if (g_bEseaEnabled && GetTrieValue(g_hBanlistESEA, auth, dummy))
    {
        HandleHit(client, "ESEA-cache", g_bEseaKick);
    }
}

void HandleHit(int client, const char[] listName, bool doKick)
{
    if (g_bLogging) IS_LogAction(client, "cached banlist hit: %s", listName);
    IS_PrintAdminNotice("{red}[BANLIST]{default} %N matched local cached list {orange}%s{default}", client, listName);
    if (doKick) KickClient(client, "[AntiCheat] Local banlist match: %s", listName);
}

void ReloadCaches(bool force = false)
{
    int eacTime = GetFileTime(g_sEacPath, FileTime_LastChange);
    int eseaTime = GetFileTime(g_sEseaPath, FileTime_LastChange);
    bool reloadEac = force || eacTime != g_iEacFileTime;
    bool reloadEsea = force || eseaTime != g_iEseaFileTime;

    if (!reloadEac && !reloadEsea) return;

    int eac = -1;
    int esea = -1;
    if (reloadEac)
    {
        ClearTrie(g_hBanlistEAC);
        eac = LoadList(g_sEacPath, g_hBanlistEAC);
        g_iEacFileTime = eacTime;
    }
    if (reloadEsea)
    {
        ClearTrie(g_hBanlistESEA);
        esea = LoadList(g_sEseaPath, g_hBanlistESEA);
        g_iEseaFileTime = eseaTime;
    }

    g_iReloadCount++;
    if (g_bLogging) IS_LogAction(0, "cached banlists refreshed: EAC=%i ESEA=%i", eac, esea);
}

public Action Timer_InitialReload(Handle timer)
{
    ReloadCaches(true);
    return Plugin_Stop;
}

public Action Timer_CheckFiles(Handle timer)
{
    ReloadCaches(false);
    return Plugin_Continue;
}

int LoadList(const char[] path, Handle trie)
{
    if (!FileExists(path)) return 0;
    File file = OpenFile(path, "r");
    if (file == null) return 0;
    int count = 0;
    char line[64];
    while (!file.EndOfFile() && file.ReadLine(line, sizeof(line)))
    {
        TrimString(line);
        if (line[0] == '\0' || line[0] == ';' || line[0] == '#') continue;
        if (StrContains(line, "STEAM_0:", false) != 0) continue;
        if (strlen(line) >= 11)
        {
            SetTrieValue(trie, line, 1, true);
            count++;
        }
    }
    delete file;
    return count;
}

public Action Command_Reload(int client, int args)
{
    ReloadCaches(true);
    ReplyToCommand(client, "[IS] Cached banlists reloaded.");
    return Plugin_Handled;
}

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "[IS Banlist] EAC enabled=%s kick=%s entries=%i", g_bEacEnabled ? "ON" : "OFF", g_bEacKick ? "ON" : "OFF", GetTrieSize(g_hBanlistEAC));
    PrintToConsole(client, "[IS Banlist] ESEA enabled=%s kick=%s entries=%i", g_bEseaEnabled ? "ON" : "OFF", g_bEseaKick ? "ON" : "OFF", GetTrieSize(g_hBanlistESEA));
    PrintToConsole(client, "[IS Banlist] cache reloads=%i next file scan=60s", g_iReloadCount);
    return Plugin_Handled;
}


public void OnPluginEnd()
{
    if (g_hRefreshTimer != INVALID_HANDLE)
    {
        KillTimer(g_hRefreshTimer);
        g_hRefreshTimer = INVALID_HANDLE;
    }
    if (g_hBanlistEAC != INVALID_HANDLE) delete g_hBanlistEAC;
    if (g_hBanlistESEA != INVALID_HANDLE) delete g_hBanlistESEA;
}

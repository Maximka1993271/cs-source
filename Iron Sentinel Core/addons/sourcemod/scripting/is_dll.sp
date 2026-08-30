/*
    Iron Sentinel AntiCheat - DLL Detection
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Обнаруживает подозрительные DLL через AntiDLL расширение
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

// ===========================
//  ПОДКЛЮЧЕНИЕ АНТИДЛЛ
// ===========================

#undef REQUIRE_EXTENSIONS
#tryinclude <antidll>
#undef REQUIRE_PLUGIN
#tryinclude <sourcebanspp>
#tryinclude <materialadmin>

public Plugin myinfo =
{
    name = "Iron Sentinel DLL Detection",
    author = "Maxim Melnikov",
    description = "Обнаруживает подозрительные DLL",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarEnabled;
ConVar g_hCvarKick;
ConVar g_hCvarBan;
ConVar g_hCvarLogging;
ConVar g_hCvarAction;

bool g_bEnabled;
bool g_bKick;
bool g_bBan;
bool g_bLogging;
int g_iAction; // 0 = kick, 1 = ban, 2 = sbpp, 3 = ma

ArrayList g_hWhitelist;
bool g_bAntiDLLLoaded = false;

// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    // ===== КОНФИГИ =====
    g_hCvarEnabled = FindConVar("is_dll_enabled");
    g_hCvarKick = FindConVar("is_dll_kick");
    g_hCvarBan = FindConVar("is_dll_ban");
    g_hCvarLogging = FindConVar("is_dll_logging");
    g_hCvarAction = FindConVar("is_dll_action");
    
    if (g_hCvarEnabled == null)
        g_hCvarEnabled = CreateConVar("is_dll_enabled", "1", "Enable DLL detection", 0, true, 0.0, true, 1.0);
    if (g_hCvarKick == null)
        g_hCvarKick = CreateConVar("is_dll_kick", "0", "Kick for suspicious DLL", 0, true, 0.0, true, 1.0);
    if (g_hCvarBan == null)
        g_hCvarBan = CreateConVar("is_dll_ban", "0", "Ban for suspicious DLL", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null)
        g_hCvarLogging = CreateConVar("is_dll_logging", "1", "Log DLL detection", 0, true, 0.0, true, 1.0);
    if (g_hCvarAction == null)
        g_hCvarAction = CreateConVar("is_dll_action", "1", "Action: 0=kick, 1=ban, 2=SBPP, 3=MA", 0, true, 0.0, true, 3.0);
    
    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarKick.AddChangeHook(OnSettingsChanged);
    g_hCvarBan.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarAction.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
    
    // ===== ИНИЦИАЛИЗАЦИЯ =====
    g_hWhitelist = new ArrayList(32);
    
    LoadWhitelist();
    
    // ===== ПРОВЕРКА НАЛИЧИЯ АНТИДЛЛ =====
    g_bAntiDLLLoaded = LibraryExists("AntiDLL");
    
    if (g_bAntiDLLLoaded)
    {
        PrintToServer("[IRON SENTINEL] AntiDLL extension detected! Full DLL detection enabled.");
    }
    else
    {
        PrintToServer("[IRON SENTINEL] AntiDLL extension not found. DLL detection in limited mode.");
    }
    
    // ===== КОМАНДЫ =====
    RegAdminCmd("is_dll_status", Command_Status, ADMFLAG_GENERIC, "Show DLL detection status");
    RegAdminCmd("is_dll_whitelist_add", Command_AddWhitelist, ADMFLAG_ROOT, "Add SteamID to whitelist");
    RegAdminCmd("is_dll_whitelist_remove", Command_RemoveWhitelist, ADMFLAG_ROOT, "Remove SteamID from whitelist");
    RegAdminCmd("is_dll_whitelist_list", Command_ListWhitelist, ADMFLAG_GENERIC, "List whitelisted SteamIDs");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_bKick = g_hCvarKick.BoolValue;
    g_bBan = g_hCvarBan.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
    g_iAction = g_hCvarAction.IntValue;
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "AntiDLL"))
    {
        g_bAntiDLLLoaded = true;
        PrintToServer("[IRON SENTINEL] AntiDLL extension loaded!");
    }
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, "AntiDLL"))
    {
        g_bAntiDLLLoaded = false;
        PrintToServer("[IRON SENTINEL] AntiDLL extension unloaded!");
    }
}

// ===========================
//  ФОРВАРД ОТ АНТИДЛЛ
// ===========================

public void AD_OnCheatDetected(const int client)
{
    if (!g_bEnabled) return;
    if (!IS_CLIENT(client) || !IsClientInGame(client)) return;
    if (IsFakeClient(client)) return;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return;
    
    // Проверяем белый список
    char sAuthID[MAX_AUTHID_LENGTH];
    GetClientAuthId(client, AuthId_Steam2, sAuthID, sizeof(sAuthID));
    if (IsInWhitelist(sAuthID)) return;
    
    HandleDLLDetection(client, "Suspicious DLL detected by AntiDLL");
}

// ===========================
//  ОБРАБОТКА ДЕТЕКЦИИ
// ===========================

void HandleDLLDetection(int client, const char[] reason)
{
    if (g_bLogging)
    {
        IS_LogAction(client, "DLL detected: %s", reason);
    }
    
    IS_PrintAdminNotice("{red}[DLL]{default} %N detected: %s", client, reason);
    
    // Действие
    switch (g_iAction)
    {
        case 0: // Kick
        {
            if (g_bKick)
            {
                KickClient(client, "[AntiCheat] Suspicious DLL detected");
            }
        }
        case 1: // Ban
        {
            if (g_bBan)
            {
                IS_BanClient(client, "Suspicious DLL detected");
            }
            else if (g_bKick)
            {
                KickClient(client, "[AntiCheat] Suspicious DLL detected");
            }
        }
        case 2: // SourceBans++
        {
            #if defined _sourcebanspp_included
            SBPP_BanPlayer(0, client, 0, "Suspicious DLL detected");
            #else
            IS_BanClient(client, "Suspicious DLL detected");
            #endif
        }
        case 3: // MaterialAdmin
        {
            #if defined _materialadmin_included
            MABanPlayer(0, client, MA_BAN_STEAM, 0, "Suspicious DLL detected");
            #else
            IS_BanClient(client, "Suspicious DLL detected");
            #endif
        }
        default:
        {
            if (g_bKick)
            {
                KickClient(client, "[AntiCheat] Suspicious DLL detected");
            }
        }
    }
}

// ===========================
//  БЕЛЫЙ СПИСОК
// ===========================

void LoadWhitelist()
{
    g_hWhitelist.Clear();
    
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/iron_sentinel/antidll_whitelist.ini");
    
    if (!FileExists(sPath))
    {
        // Создаём файл если нет
        File hFile = OpenFile(sPath, "w");
        if (hFile != null)
        {
            hFile.WriteLine("// SteamID Whitelist for AntiDLL");
            hFile.WriteLine("// Add SteamIDs below, one per line");
            hFile.WriteLine("// Example: STEAM_0:0:12345678");
            hFile.Close();
        }
        return;
    }
    
    File hFile = OpenFile(sPath, "r");
    if (hFile == null) return;
    
    char sBuffer[64];
    while (!hFile.EndOfFile() && hFile.ReadLine(sBuffer, sizeof(sBuffer)))
    {
        TrimString(sBuffer);
        if (sBuffer[0] == '\0' || sBuffer[0] == '/' || sBuffer[0] == ';') continue;
        g_hWhitelist.PushString(sBuffer);
    }
    hFile.Close();
}

bool IsInWhitelist(const char[] auth)
{
    char sBuffer[64];
    for (int i = 0; i < g_hWhitelist.Length; i++)
    {
        g_hWhitelist.GetString(i, sBuffer, sizeof(sBuffer));
        if (StrEqual(auth, sBuffer))
        {
            return true;
        }
    }
    return false;
}

// AntiDLL is the source of the actual detection signal. This plugin does not
// maintain a second, unused filename blacklist that could create stale/false matches.

// ===========================
//  КОМАНДЫ АДМИНА
// ===========================

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "|       DLL DETECTION STATUS              |");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "");
    PrintToConsole(client, "Enabled:           %s", g_bEnabled ? "ON" : "OFF");
    PrintToConsole(client, "AntiDLL loaded:    %s", g_bAntiDLLLoaded ? "YES" : "NO");
    PrintToConsole(client, "Action:            %s", g_iAction == 0 ? "Kick" : g_iAction == 1 ? "Ban" : g_iAction == 2 ? "SBPP" : "MA");
    PrintToConsole(client, "Kick:              %s", g_bKick ? "ON" : "OFF");
    PrintToConsole(client, "Ban:               %s", g_bBan ? "ON" : "OFF");
    PrintToConsole(client, "Logging:           %s", g_bLogging ? "ON" : "OFF");
    PrintToConsole(client, "Whitelist entries: %i", g_hWhitelist.Length);
    PrintToConsole(client, "+------------------------------------------+");
    return Plugin_Handled;
}

public Action Command_AddWhitelist(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Usage: is_dll_whitelist_add <steamid>");
        return Plugin_Handled;
    }
    
    char sAuthID[MAX_AUTHID_LENGTH];
    GetCmdArg(1, sAuthID, sizeof(sAuthID));
    TrimString(sAuthID);
    
    if (IsInWhitelist(sAuthID))
    {
        ReplyToCommand(client, "[AntiCheat] %s already in whitelist.", sAuthID);
        return Plugin_Handled;
    }
    
    // Добавляем в файл
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/iron_sentinel/antidll_whitelist.ini");
    
    File hFile = OpenFile(sPath, "a");
    if (hFile == null)
    {
        ReplyToCommand(client, "[AntiCheat] Failed to open whitelist file.");
        return Plugin_Handled;
    }
    
    hFile.WriteLine(sAuthID);
    hFile.Close();
    
    g_hWhitelist.PushString(sAuthID);
    ReplyToCommand(client, "[AntiCheat] %s added to whitelist.", sAuthID);
    
    return Plugin_Handled;
}

public Action Command_RemoveWhitelist(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Usage: is_dll_whitelist_remove <steamid>");
        return Plugin_Handled;
    }
    
    char sAuthID[MAX_AUTHID_LENGTH];
    GetCmdArg(1, sAuthID, sizeof(sAuthID));
    TrimString(sAuthID);
    
    if (!IsInWhitelist(sAuthID))
    {
        ReplyToCommand(client, "[AntiCheat] %s not in whitelist.", sAuthID);
        return Plugin_Handled;
    }
    
    // Удаляем из массива
    char sBuffer[64];
    for (int i = 0; i < g_hWhitelist.Length; i++)
    {
        g_hWhitelist.GetString(i, sBuffer, sizeof(sBuffer));
        if (StrEqual(sAuthID, sBuffer))
        {
            g_hWhitelist.Erase(i);
            break;
        }
    }
    
    // Перезаписываем файл
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), "configs/iron_sentinel/antidll_whitelist.ini");
    
    File hFile = OpenFile(sPath, "w");
    if (hFile != null)
    {
        for (int i = 0; i < g_hWhitelist.Length; i++)
        {
            g_hWhitelist.GetString(i, sBuffer, sizeof(sBuffer));
            hFile.WriteLine(sBuffer);
        }
        hFile.Close();
    }
    
    ReplyToCommand(client, "[AntiCheat] %s removed from whitelist.", sAuthID);
    return Plugin_Handled;
}

public Action Command_ListWhitelist(int client, int args)
{
    ReplyToCommand(client, "[AntiCheat] Whitelist (%i entries):", g_hWhitelist.Length);
    
    char sBuffer[64];
    for (int i = 0; i < g_hWhitelist.Length; i++)
    {
        g_hWhitelist.GetString(i, sBuffer, sizeof(sBuffer));
        ReplyToCommand(client, "  %s", sBuffer);
    }
    
    return Plugin_Handled;
}
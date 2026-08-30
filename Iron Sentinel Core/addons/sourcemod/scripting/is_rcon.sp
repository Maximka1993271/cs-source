/*
    Iron Sentinel AntiCheat - RCON Locker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Блокирует RCON-команды клиентов и защищает пароль без утечки в лог.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Rcon Locker",
    author = "Maxim Melnikov",
    description = "Защита RCON от клиентских эксплойтов",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

ConVar g_hCvarLocked;
ConVar g_hCvarLogging;
ConVar g_hCvarWhitelistEnabled;

bool g_bLocked;
bool g_bLogging;
bool g_bWhitelistEnabled;
StringMap g_hWhitelist;
char g_sRconRealPass[128];
bool g_bRconInitialized;

public void OnPluginStart()
{
    g_hCvarLocked = FindConVar("is_rcon_locked");
    g_hCvarLogging = FindConVar("is_rcon_logging");
    g_hCvarWhitelistEnabled = FindConVar("is_rcon_whitelist_enabled");

    if (g_hCvarLocked == null) g_hCvarLocked = CreateConVar("is_rcon_locked", "1", "Блокировать изменение rcon_password клиентом", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_rcon_logging", "1", "Логировать RCON попытки без записи паролей", 0, true, 0.0, true, 1.0);
    if (g_hCvarWhitelistEnabled == null) g_hCvarWhitelistEnabled = CreateConVar("is_rcon_whitelist_enabled", "0", "Разрешать RCON клиентам из IP whitelist", 0, true, 0.0, true, 1.0);

    g_hCvarLocked.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarWhitelistEnabled.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");

    g_hWhitelist = new StringMap();
    LoadWhitelist();

    CaptureRconPassword();
    AddCommandListener(Command_Rcon, "rcon");
    AddCommandListener(Command_Rcon, "rcon_password");

    RegAdminCmd("is_rcon_addip", Command_AddIP, ADMFLAG_ROOT, "Add IP to RCON whitelist");
    RegAdminCmd("is_rcon_removeip", Command_RemoveIP, ADMFLAG_ROOT, "Remove IP from RCON whitelist");
    RegAdminCmd("is_rcon_status", Command_Status, ADMFLAG_GENERIC, "Show RCON protection status");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bLocked = g_hCvarLocked.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
    g_bWhitelistEnabled = g_hCvarWhitelistEnabled.BoolValue;
}

public void OnConfigsExecuted()
{
    CaptureRconPassword();
}

void CaptureRconPassword()
{
    ConVar pass = FindConVar("rcon_password");
    if (pass == null) return;

    // Only hook once. This function is intentionally called again from
    // OnConfigsExecuted() to re-capture the real password after server.cfg applies it,
    // but the change hook itself must not be registered a second time on the same
    // ConVar -- SourceMod does not deduplicate AddChangeHook/HookConVarChange, so a
    // second registration would fire OnRconPassChanged twice per actual change and
    // double every log line and admin notice for a single blocked attempt.
    if (!g_bRconInitialized)
        HookConVarChange(pass, OnRconPassChanged);

    GetConVarString(pass, g_sRconRealPass, sizeof(g_sRconRealPass));
    g_bRconInitialized = true;
}

public void OnRconPassChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    if (!g_bRconInitialized || !g_bLocked) return;
    if (StrEqual(newValue, g_sRconRealPass)) return;

    if (g_bLogging)
        LogToFile("logs/is_rcon.log", "[RCON] Password change blocked (old/new values intentionally omitted)");

    IS_PrintAdminNotice("{red}[RCON]{default} Попытка изменения RCON пароля ЗАБЛОКИРОВАНА!");
    SetConVarString(convar, g_sRconRealPass);
}

public Action Command_Rcon(int client, const char[] command, int argc)
{
    if (!IS_CLIENT(client) || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Continue;

    char ip[32];
    GetClientIP(client, ip, sizeof(ip), true);

    if (g_bWhitelistEnabled && IsIPInWhitelist(ip))
        return Plugin_Continue;

    if (g_bLogging)
        LogToFile("logs/is_rcon.log", "[RCON] Client command blocked from %s (%s)", ip, command);

    IS_PrintAdminNotice("{red}[RCON]{default} Заблокирована клиентская команда %s от IP %s", command, ip);
    PrintToConsole(client, "[AntiCheat] Client-side RCON is disabled on this server.");
    return Plugin_Stop;
}

void LoadWhitelist()
{
    char path[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "configs/iron_sentinel/rcon_whitelist.ini");
    if (!FileExists(path)) return;

    File file = OpenFile(path, "r");
    if (file == null) return;

    char line[64];
    while (!file.EndOfFile() && file.ReadLine(line, sizeof(line)))
    {
        TrimString(line);
        if (line[0] == '\0' || line[0] == '/' || line[0] == ';') continue;
        if (IsValidIP(line)) g_hWhitelist.SetValue(line, 1, true);
    }
    delete file;
}

bool IsIPInWhitelist(const char[] ip)
{
    int dummy;
    return g_hWhitelist.GetValue(ip, dummy);
}

bool IsValidIP(const char[] ip)
{
    int len = strlen(ip);
    if (len < 7 || len > 15) return false;

    int dots = 0;
    int value = 0;
    int digits = 0;
    for (int i = 0; i <= len; i++)
    {
        if (ip[i] == '.' || ip[i] == '\0')
        {
            if (digits < 1 || digits > 3 || value > 255) return false;
            if (ip[i] == '.') dots++;
            value = 0;
            digits = 0;
        }
        else if (IsCharNumeric(ip[i]))
        {
            value = (value * 10) + (ip[i] - '0');
            digits++;
        }
        else return false;
    }
    return dots == 3;
}

public Action Command_AddIP(int client, int args)
{
    if (args != 1) { ReplyToCommand(client, "Usage: is_rcon_addip <ip>"); return Plugin_Handled; }
    char ip[32]; GetCmdArg(1, ip, sizeof(ip));
    if (!IsValidIP(ip)) { ReplyToCommand(client, "[IS] Invalid IPv4 address."); return Plugin_Handled; }
    g_hWhitelist.SetValue(ip, 1, true);
    ReplyToCommand(client, "[IS] %s added to whitelist.", ip);
    return Plugin_Handled;
}

public Action Command_RemoveIP(int client, int args)
{
    if (args != 1) { ReplyToCommand(client, "Usage: is_rcon_removeip <ip>"); return Plugin_Handled; }
    char ip[32]; GetCmdArg(1, ip, sizeof(ip));
    int dummy;
    if (g_hWhitelist.GetValue(ip, dummy))
    {
        g_hWhitelist.Remove(ip);
        ReplyToCommand(client, "[IS] %s removed from whitelist.", ip);
    }
    else
    {
        ReplyToCommand(client, "[IS] %s not found.", ip);
    }
    return Plugin_Handled;
}

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "[IS RCON] locked=%s logging=%s whitelist=%s initialized=%s",
        g_bLocked ? "ON" : "OFF", g_bLogging ? "ON" : "OFF", g_bWhitelistEnabled ? "ON" : "OFF", g_bRconInitialized ? "YES" : "NO");
    return Plugin_Handled;
}

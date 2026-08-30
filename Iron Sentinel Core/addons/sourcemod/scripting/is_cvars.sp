/*
    Iron Sentinel AntiCheat - ConVar Checker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Проверяет только аномальные client-side debug cvars; query errors не считаются читом.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel ConVar Checker",
    author = "Maxim Melnikov",
    description = "Проверяет безопасный набор подозрительных настроек игроков",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

enum CvarCheckType { Check_Greater = 0, Check_Less };
enum CvarAction { Action_Kick = 0, Action_Ban, Action_Warn };

enum struct CvarCheck
{
    char sCvar[64];
    char sValue[32];
    CvarCheckType Type;
    CvarAction Action;
    char sReason[128];
}

ConVar g_hCvarAutoKick;
ConVar g_hCvarAutoBan;
ConVar g_hCvarLogEnabled;
ConVar g_hCvarCheckInterval;

bool g_bLogEnabled;
float g_fCheckInterval;
ArrayList g_hCvarList;
bool g_bChecking[MAXPLAYERS+1];
int g_iCheckIndex[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarAutoKick = FindConVar("is_cvars_autokick");
    g_hCvarAutoBan = FindConVar("is_cvars_autoban");
    g_hCvarLogEnabled = FindConVar("is_cvars_logging");
    g_hCvarCheckInterval = FindConVar("is_cvars_check_interval");

    if (g_hCvarAutoKick == null) g_hCvarAutoKick = CreateConVar("is_cvars_autokick", "0", "Кикать за подтверждённые подозрительные настройки", 0, true, 0.0, true, 1.0);
    if (g_hCvarAutoBan == null) g_hCvarAutoBan = CreateConVar("is_cvars_autoban", "0", "Банить за подтверждённые подозрительные настройки", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogEnabled == null) g_hCvarLogEnabled = CreateConVar("is_cvars_logging", "1", "Логировать подозрительные настройки", 0, true, 0.0, true, 1.0);
    if (g_hCvarCheckInterval == null) g_hCvarCheckInterval = CreateConVar("is_cvars_check_interval", "60.0", "Интервал полного прохода списка (секунд)", 0, true, 10.0, true, 120.0);

    g_hCvarAutoKick.AddChangeHook(OnSettingsChanged);
    g_hCvarAutoBan.AddChangeHook(OnSettingsChanged);
    g_hCvarLogEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarCheckInterval.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");

    g_hCvarList = new ArrayList(sizeof(CvarCheck));
    LoadCvarList();

    RegAdminCmd("is_cvars_reload", Command_Reload, ADMFLAG_ROOT, "Reload cvar list");
    RegAdminCmd("is_cvars_check", Command_CheckPlayer, ADMFLAG_GENERIC, "Check a player manually");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bLogEnabled = g_hCvarLogEnabled.BoolValue;
    g_fCheckInterval = g_hCvarCheckInterval.FloatValue;
}

void AddCheck(const char[] cvar, CvarCheckType type, const char[] value, CvarAction action, const char[] reason)
{
    CvarCheck check;
    strcopy(check.sCvar, sizeof(check.sCvar), cvar);
    strcopy(check.sValue, sizeof(check.sValue), value);
    check.Type = type;
    check.Action = action;
    strcopy(check.sReason, sizeof(check.sReason), reason);
    g_hCvarList.PushArray(check);
}

void LoadCvarList()
{
    ClearArray(g_hCvarList);

    // These are only anomalous when raised above normal debug/off values.
    // Default enforcement is disabled in core because client cvar queries are not proof by themselves.
    AddCheck("r_drawothermodels", Check_Greater, "1", Action_Warn, "Wallhack/debug mode (r_drawothermodels > 1)");
    AddCheck("mat_wireframe", Check_Greater, "0", Action_Warn, "Wallhack/debug mode (mat_wireframe > 0)");
    AddCheck("mat_fullbright", Check_Greater, "0", Action_Warn, "Debug lighting (mat_fullbright > 0)");
    AddCheck("mat_norendering", Check_Greater, "0", Action_Warn, "Rendering disabled (mat_norendering > 0)");
    AddCheck("r_drawrenderboxes", Check_Greater, "0", Action_Warn, "Render boxes enabled");
    AddCheck("r_drawmodelstatsoverlay", Check_Greater, "0", Action_Warn, "Model statistics overlay enabled");
    AddCheck("r_drawlightinfo", Check_Greater, "0", Action_Warn, "Light debug overlay enabled");
    AddCheck("r_drawlights", Check_Greater, "0", Action_Warn, "Light debug rendering enabled");
}

public void OnClientPutInServer(int client)
{
    if (!IsFakeClient(client))
        CreateTimer(5.0, Timer_StartChecking, GetClientSerial(client));
}

public void OnClientDisconnect(int client)
{
    g_bChecking[client] = false;
    g_iCheckIndex[client] = 0;
}

public Action Timer_StartChecking(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if (!IS_CLIENT(client) || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Stop;

    CheckNextCvar(client);
    // Must survive map changes: a connected client's session normally spans many maps,
    // and nothing else re-arms this loop. TIMER_FLAG_NO_MAPCHANGE silently stops cvar
    // checking for every currently-connected client at the very first map change.
    CreateTimer(g_fCheckInterval, Timer_CheckLoop, serial, TIMER_REPEAT);
    return Plugin_Stop;
}

public Action Timer_CheckLoop(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if (!IS_CLIENT(client) || !IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Stop;
    CheckNextCvar(client);
    return Plugin_Continue;
}

void CheckNextCvar(int client)
{
    if (!IS_CLIENT(client) || !IsClientInGame(client) || g_bChecking[client] || g_hCvarList.Length == 0)
        return;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
        return;

    int index = g_iCheckIndex[client] % g_hCvarList.Length;
    CvarCheck check;
    g_hCvarList.GetArray(index, check);
    g_iCheckIndex[client] = index + 1;
    g_bChecking[client] = true;
    QueryClientConVar(client, check.sCvar, OnCvarQueryFinished, GetClientSerial(client));
}

public void OnCvarQueryFinished(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any serial)
{
    if (!IS_CLIENT(client) || GetClientFromSerial(serial) != client || !IsClientInGame(client) || IsFakeClient(client))
        return;

    g_bChecking[client] = false;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
        return;

    if (result != ConVarQuery_Okay)
    {
        // NotFound/Protected/NotACvar and transient query errors are inconclusive, never a violation.
        return;
    }

    for (int i = 0; i < g_hCvarList.Length; i++)
    {
        CvarCheck check;
        g_hCvarList.GetArray(i, check);
        if (!StrEqual(check.sCvar, cvarName, false))
            continue;

        float value = StringToFloat(cvarValue);
        float expected = StringToFloat(check.sValue);
        bool violation = (check.Type == Check_Greater) ? (value > expected) : (value < expected);
        if (violation)
        {
            HandleViolation(client, check, cvarValue);
        }
        return;
    }
}

void HandleViolation(int client, CvarCheck check, const char[] cvarValue)
{
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return;

    if (g_bLogEnabled)
        IS_LogAction(client, "cvar warning: %s = %s; threshold %s; reason: %s", check.sCvar, cvarValue, check.sValue, check.sReason);

    IS_PrintAdminNotice("{orange}[CVAR]{default} %N: {orange}%s{default} = %s", client, check.sCvar, cvarValue);

    CvarAction finalAction = Action_Warn;
    if (g_hCvarAutoBan.BoolValue && check.Action == Action_Ban)
        finalAction = Action_Ban;
    else if (g_hCvarAutoKick.BoolValue && check.Action != Action_Warn)
        finalAction = Action_Kick;

    if (finalAction == Action_Ban)
        IS_BanClient(client, check.sReason);
    else if (finalAction == Action_Kick)
        KickClient(client, "[IS] Suspicious client setting: %s", check.sCvar);
    else
        PrintToChat(client, "{orange}[IS]{default} Diagnostic setting detected: {orange}%s{default} = %s", check.sCvar, cvarValue);
}

public Action Command_Reload(int client, int args)
{
    LoadCvarList();
    ReplyToCommand(client, "[IS] Cvar list reloaded (%i checks).", g_hCvarList.Length);
    return Plugin_Handled;
}

public Action Command_CheckPlayer(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Usage: is_cvars_check <#userid|name>");
        return Plugin_Handled;
    }

    char targetName[64];
    GetCmdArg(1, targetName, sizeof(targetName));
    int target = FindTarget(client, targetName, true, false);
    if (target == -1) return Plugin_Handled;

    g_iCheckIndex[target] = 0;
    g_bChecking[target] = false;
    CheckNextCvar(target);
    ReplyToCommand(client, "[IS] Check started for %N.", target);
    return Plugin_Handled;
}

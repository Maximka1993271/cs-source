/*
    Iron Sentinel AntiCheat - Wallhack Blocker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Ограничивает передачу информации о противниках за непрозрачными препятствиями с bounded trace budget и fail-open.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Wallhack Blocker",
    author = "Maxim Melnikov",
    description = "Стабильный SetTransmit wall blocking для CS:S",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

#define CACHE_TICKS 4
#define CHECK_INTERVAL 0.05

ConVar g_hCvarEnabled;
ConVar g_hCvarMaxTraces;
ConVar g_hCvarMode;

bool g_bEnabled;
int g_iMaxTraces;
int g_iMode;

bool g_bIsVisible[MAXPLAYERS+1][MAXPLAYERS+1];
int g_iPVSCache[MAXPLAYERS+1][MAXPLAYERS+1];
float g_vEyePos[MAXPLAYERS+1][3];
float g_vTargetPos[MAXPLAYERS+1][3];
float g_vMins[MAXPLAYERS+1][3];
float g_vMaxs[MAXPLAYERS+1][3];
int g_iTeam[MAXPLAYERS+1];
bool g_bProcess[MAXPLAYERS+1];
bool g_bImmune[MAXPLAYERS+1];

int g_iTickCount;
int g_iTracesUsed;
int g_iTraceBudgetDrops;
int g_iVisibilityChecks;
int g_iBlockedTransmits;
int g_iLastWindowTraces;
int g_iLastWindowBudgetDrops;
int g_iLastWindowChecks;
int g_iTotalTraces;
int g_iTotalBudgetDrops;
int g_iTotalVisibilityChecks;
int g_iTotalBlockedTransmits;
float g_fLastWindowMs;
float g_fMaxWindowMs;
float g_fWindowStartedAt;
Handle g_hTimer = INVALID_HANDLE;

public void OnPluginStart()
{
    g_hCvarEnabled = FindConVar("is_wallhack_enabled");
    g_hCvarMaxTraces = FindConVar("is_wallhack_maxtraces");
    g_hCvarMode = FindConVar("is_wallhack_mode");

    if (g_hCvarEnabled == null) g_hCvarEnabled = CreateConVar("is_wallhack_enabled", "1", "Включить wall blocking", 0, true, 0.0, true, 1.0);
    if (g_hCvarMaxTraces == null) g_hCvarMaxTraces = CreateConVar("is_wallhack_maxtraces", "192", "Максимум trace операций за 50ms окно", 0, true, 32.0, true, 1024.0);
    if (g_hCvarMode == null) g_hCvarMode = CreateConVar("is_wallhack_mode", "0", "0 = fail-open soft, 1 = experimental aggressive", 0, true, 0.0, true, 1.0);

    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarMaxTraces.AddChangeHook(OnSettingsChanged);
    g_hCvarMode.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");

    HookEvent("player_spawn", Event_PlayerStateChanged, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerStateChanged, EventHookMode_Post);
    HookEvent("player_team", Event_PlayerStateChanged, EventHookMode_Post);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);

    RegAdminCmd("is_wallhack_status", Command_Status, ADMFLAG_GENERIC, "Show wall blocking status");
    RegAdminCmd("is_wallhack_reload", Command_Reload, ADMFLAG_ROOT, "Apply wall blocking settings");

    if (!LibraryExists("sdkhooks"))
        SetFailState("Требуется расширение SDKHooks!");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    bool wasEnabled = g_bEnabled;
    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_iMaxTraces = g_hCvarMaxTraces.IntValue;
    g_iMode = g_hCvarMode.IntValue;

    if (g_bEnabled && !wasEnabled) EnableWallhack();
    else if (!g_bEnabled && wasEnabled) DisableWallhack();
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "sdkhooks") && g_bEnabled) EnableWallhack();
}

public void OnLibraryRemoved(const char[] name)
{
    if (StrEqual(name, "sdkhooks")) DisableWallhack();
}

void EnableWallhack()
{
    if (!g_bEnabled || g_hTimer != INVALID_HANDLE) return;
    g_iTickCount = GetGameTickCount();
    g_iTracesUsed = 0;
    g_iTraceBudgetDrops = 0;
    g_iTotalTraces = 0;
    g_iTotalBudgetDrops = 0;
    g_iTotalVisibilityChecks = 0;
    g_iTotalBlockedTransmits = 0;
    // g_hTimer is a plugin-lifetime background loop, not something tied to one map.
    // It is only ever re-created by EnableWallhack()'s own INVALID_HANDLE guard, and
    // nothing else re-arms it after a map change. TIMER_FLAG_NO_MAPCHANGE would let the
    // engine silently kill it at the very next map change while leaving g_hTimer holding
    // a stale (non-INVALID_HANDLE) value, which would (a) permanently stop visibility
    // rechecks for the rest of the server's uptime and (b) throw "Invalid handle" the
    // next time DisableWallhack()/Command_Reload tries to KillTimer() it. Must persist.
    g_hTimer = CreateTimer(CHECK_INTERVAL, Timer_CheckVisibility, _, TIMER_REPEAT);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        g_bImmune[i] = CheckCommandAccess(i, "is_immunity", ADMFLAG_CUSTOM1, true);
        UpdateClientCache(i);
        SDKHook(i, SDKHook_SetTransmit, Hook_SetTransmit);
    }
}

void DisableWallhack()
{
    if (g_hTimer != INVALID_HANDLE)
    {
        KillTimer(g_hTimer);
        g_hTimer = INVALID_HANDLE;
    }
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bProcess[i] = false;
        g_bImmune[i] = false;
        if (IsClientInGame(i)) SDKUnhook(i, SDKHook_SetTransmit, Hook_SetTransmit);
    }
}

public void OnClientPutInServer(int client)
{
    g_bProcess[client] = false;
    g_bImmune[client] = false;
    ResetPairCache(client);
    if (g_bEnabled)
    {
        SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
        CreateTimer(0.5, Timer_UpdateClient, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public void OnClientPostAdminCheck(int client)
{
    if (IS_CLIENT(client))
        g_bImmune[client] = CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true);
}

public void OnRebuildAdminCache(AdminCachePart part)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i)) g_bImmune[i] = CheckCommandAccess(i, "is_immunity", ADMFLAG_CUSTOM1, true);
    }
}

public void OnClientDisconnect(int client)
{
    g_bProcess[client] = false;
    g_bImmune[client] = false;
    ResetPairCache(client);
    if (g_bEnabled) SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
}

void ResetPairCache(int client)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bIsVisible[client][i] = true;
        g_bIsVisible[i][client] = true;
        g_iPVSCache[client][i] = 0;
        g_iPVSCache[i][client] = 0;
    }
}

public Action Event_PlayerStateChanged(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IS_CLIENT(client) && IsClientInGame(client))
    {
        UpdateClientCache(client);
        ResetPairCache(client);
    }
    return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_iTickCount = GetGameTickCount();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i)) UpdateClientCache(i);
        for (int j = 1; j <= MaxClients; j++)
        {
            g_bIsVisible[i][j] = true;
            g_iPVSCache[i][j] = 0;
        }
    }
    return Plugin_Continue;
}

public Action Timer_UpdateClient(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if (IS_CLIENT(client) && IsClientInGame(client)) UpdateClientCache(client);
    return Plugin_Stop;
}

void UpdateClientCache(int client)
{
    if (!IS_CLIENT(client) || !IsClientInGame(client))
    {
        g_bProcess[client] = false;
        return;
    }
    g_iTeam[client] = GetClientTeam(client);
    g_bProcess[client] = IsPlayerAlive(client) && !IsFakeClient(client) && g_iTeam[client] >= 2;
    if (g_bProcess[client])
    {
        GetClientEyePosition(client, g_vEyePos[client]);
        GetClientAbsOrigin(client, g_vTargetPos[client]);
        GetClientMins(client, g_vMins[client]);
        GetClientMaxs(client, g_vMaxs[client]);
    }
}

public Action Timer_CheckVisibility(Handle timer)
{
    float now = GetEngineTime();
    if (g_fWindowStartedAt > 0.0)
    {
        g_fLastWindowMs = (now - g_fWindowStartedAt) * 1000.0;
        if (g_fLastWindowMs > g_fMaxWindowMs) g_fMaxWindowMs = g_fLastWindowMs;
    }
    g_iLastWindowTraces = g_iTracesUsed;
    g_iLastWindowBudgetDrops = g_iTraceBudgetDrops;
    g_iLastWindowChecks = g_iVisibilityChecks;
    g_iTickCount = GetGameTickCount();
    g_iTracesUsed = 0;
    g_iTraceBudgetDrops = 0;
    g_iVisibilityChecks = 0;
    g_fWindowStartedAt = now;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_bProcess[i] && IsClientInGame(i))
        {
            GetClientEyePosition(i, g_vEyePos[i]);
            GetClientAbsOrigin(i, g_vTargetPos[i]);
        }
    }
    return Plugin_Continue;
}

public Action Hook_SetTransmit(int entity, int client)
{
    if (!g_bEnabled || g_iMode < 0) return Plugin_Continue;
    if (entity < 1 || entity > MaxClients || client < 1 || client > MaxClients) return Plugin_Continue;
    if (entity == client || !g_bProcess[entity] || !g_bProcess[client] || g_bImmune[client]) return Plugin_Continue;
    if (g_iTeam[entity] == g_iTeam[client]) return Plugin_Continue;

    if (g_iPVSCache[entity][client] > g_iTickCount)
        return g_bIsVisible[entity][client] ? Plugin_Continue : Plugin_Handled;

    // Fail-open when the bounded trace budget is exhausted. Never hide data just because this client was not scheduled.
    if (g_iTracesUsed >= g_iMaxTraces)
    {
        g_iTraceBudgetDrops++;
        g_iTotalBudgetDrops++;
        return Plugin_Continue;
    }

    g_iVisibilityChecks++;
    g_iTotalVisibilityChecks++;
    bool visible = IsAbleToSee(entity, client);
    g_bIsVisible[entity][client] = visible;
    g_iPVSCache[entity][client] = g_iTickCount + CACHE_TICKS;
    if (!visible) { g_iBlockedTransmits++; g_iTotalBlockedTransmits++; }
    return visible ? Plugin_Continue : Plugin_Handled;
}

bool IsAbleToSee(int entity, int client)
{
    float distanceSq = GetVectorDistance(g_vEyePos[client], g_vTargetPos[entity], true);
    if (distanceSq < 4096.0) return true;
    // Fail-open for very distant targets: never hide data solely because the optimization skipped a trace.
    if (distanceSq > 6250000.0) return true;

    if (IsPointVisible(g_vEyePos[client], g_vTargetPos[entity])) return true;

    float center[3];
    center[0] = g_vTargetPos[entity][0];
    center[1] = g_vTargetPos[entity][1];
    center[2] = g_vTargetPos[entity][2] + ((g_vMins[entity][2] + g_vMaxs[entity][2]) * 0.5);
    if (IsPointVisible(g_vEyePos[client], center)) return true;

    float top[3];
    top[0] = center[0];
    top[1] = center[1];
    top[2] = g_vTargetPos[entity][2] + g_vMaxs[entity][2];
    if (IsPointVisible(g_vEyePos[client], top)) return true;

    return false;
}

bool IsPointVisible(const float start[3], const float end[3])
{
    if (g_iTracesUsed >= g_iMaxTraces)
    {
        g_iTraceBudgetDrops++;
        g_iTotalBudgetDrops++;
        return true;
    }
    g_iTracesUsed++;
    g_iTotalTraces++;
    TR_TraceRayFilter(start, end, MASK_VISIBLE, RayType_EndPoint, Filter_NoPlayers);
    return TR_GetFraction() >= 0.9999;
}

public bool Filter_NoPlayers(int entity, int mask)
{
    if (entity >= 1 && entity <= MaxClients) return false;
    return true;
}

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "[IS Wallhack] enabled=%s mode=%s budget=%i used=%i last=%i checks=%i drops=%i blocked=%i", g_bEnabled ? "ON" : "OFF", g_iMode ? "AGGRESSIVE-BOUND" : "SOFT-FAILOPEN", g_iMaxTraces, g_iTracesUsed, g_iLastWindowTraces, g_iLastWindowChecks, g_iLastWindowBudgetDrops, g_iBlockedTransmits);
    float utilization = g_iMaxTraces > 0 ? (float(g_iLastWindowTraces) / float(g_iMaxTraces)) * 100.0 : 0.0;
    PrintToConsole(client, "[IS Wallhack] window_elapsed_ms=%.3f max_window_ms=%.3f trace_utilization=%.1f%%", g_fLastWindowMs, g_fMaxWindowMs, utilization);
    PrintToConsole(client, "[IS Wallhack] map totals: traces=%i budget_drops=%i visibility_checks=%i blocked=%i", g_iTotalTraces, g_iTotalBudgetDrops, g_iTotalVisibilityChecks, g_iTotalBlockedTransmits);
    return Plugin_Handled;
}

public Action Command_Reload(int client, int args)
{
    if (g_bEnabled) { DisableWallhack(); EnableWallhack(); }
    ReplyToCommand(client, "[IS] Wallhack settings re-applied.");
    return Plugin_Handled;
}

public void OnPluginEnd()
{
    DisableWallhack();
}

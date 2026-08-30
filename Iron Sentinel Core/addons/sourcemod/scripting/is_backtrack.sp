/*
    Iron Sentinel AntiCheat - Backtrack/Latency Telemetry
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Не считает высокий ping доказательством backtrack. Только диагностический журнал.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Backtrack Telemetry",
    author = "Maxim Melnikov",
    description = "Latency telemetry without false-positive enforcement",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

ConVar g_hCvarEnabled;
ConVar g_hCvarLogging;
bool g_bEnabled;
bool g_bLogging;
float g_fLastWarn[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarEnabled = FindConVar("is_backtrack_enabled");
    g_hCvarLogging = FindConVar("is_backtrack_logging");
    if (g_hCvarEnabled == null) g_hCvarEnabled = CreateConVar("is_backtrack_enabled", "1", "Enable backtrack telemetry", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_backtrack_logging", "1", "Log latency telemetry", 0, true, 0.0, true, 1.0);
    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Post);
}

public void OnClientPutInServer(int client) { g_fLastWarn[client] = 0.0; }
public void OnClientDisconnect(int client) { g_fLastWarn[client] = 0.0; }

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled) return Plugin_Continue;
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (!IS_CLIENT(attacker) || !IsClientInGame(attacker) || IsFakeClient(attacker)) return Plugin_Continue;
    if (CheckCommandAccess(attacker, "is_immunity", ADMFLAG_CUSTOM1, true)) return Plugin_Continue;

    float latency = GetClientLatency(attacker, NetFlow_Outgoing);
    if (latency < 0.300) return Plugin_Continue;

    float now = GetTickedTime();
    if (now - g_fLastWarn[attacker] < 10.0) return Plugin_Continue;
    g_fLastWarn[attacker] = now;

    if (g_bLogging)
        IS_LogAction(attacker, "latency telemetry during hit: %.0fms (not a backtrack verdict)", latency * 1000.0);
    return Plugin_Continue;
}

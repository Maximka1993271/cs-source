/*
    Iron Sentinel AntiCheat - Max Ping Kicker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Кикает игроков с высоким пингом
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Max Ping Kicker",
    author = "Maxim Melnikov",
    description = "Кикает за высокий пинг",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  КОНСТАНТЫ
// ===========================

#define PING_CHECK_INTERVAL 10.0

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarMaxPing;
ConVar g_hCvarKick;
ConVar g_hCvarLogging;

int g_iMaxPing;
bool g_bKick;
bool g_bLogging;

int g_iPingDetections[MAXPLAYERS+1];
float g_fLastPingNotice[MAXPLAYERS+1];

// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    g_hCvarMaxPing = FindConVar("is_ping_max");
    g_hCvarKick = FindConVar("is_ping_kick");
    g_hCvarLogging = FindConVar("is_ping_logging");
    
    if (g_hCvarMaxPing == null)
        g_hCvarMaxPing = CreateConVar("is_ping_max", "200", "Max allowed ping (ms)", 0, true, 50.0, true, 500.0);
    if (g_hCvarKick == null)
        g_hCvarKick = CreateConVar("is_ping_kick", "0", "Kick for high ping", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null)
        g_hCvarLogging = CreateConVar("is_ping_logging", "1", "Log high ping", 0, true, 0.0, true, 1.0);
    
    g_hCvarMaxPing.AddChangeHook(OnSettingsChanged);
    g_hCvarKick.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
    
    CreateTimer(PING_CHECK_INTERVAL, Timer_CheckPing, _, TIMER_REPEAT);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_iMaxPing = g_hCvarMaxPing.IntValue;
    g_bKick = g_hCvarKick.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
}

// Without these, a client slot that changes occupants mid-map (player A disconnects,
// player B takes the same slot) would let player B inherit player A's leftover
// detection count and notification cooldown, so a single high-ping reading of their
// own could push them straight to the kick threshold.
public void OnClientPutInServer(int client)
{
    g_iPingDetections[client] = 0;
    g_fLastPingNotice[client] = 0.0;
}

public void OnClientDisconnect(int client)
{
    g_iPingDetections[client] = 0;
    g_fLastPingNotice[client] = 0.0;
}

public Action Timer_CheckPing(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i))
            continue;
        
        if (CheckCommandAccess(i, "is_immunity", ADMFLAG_CUSTOM1, true))
            continue;
        
        float latency = GetClientLatency(i, NetFlow_Outgoing);
        if (latency < 0.0) continue;
        int iPing = RoundToNearest(latency * 1000.0);
        
        if (iPing > g_iMaxPing)
        {
            g_iPingDetections[i]++;
            
            if (g_bLogging)
            {
                IS_LogAction(i, "high ping: %i ms (detections: %i)", iPing, g_iPingDetections[i]);
            }
            
            if (GetTickedTime() - g_fLastPingNotice[i] >= 30.0)
            {
                IS_PrintAdminNotice("{orange}[PING]{default} %N has high ping: {orange}%i ms{default}", i, iPing);
                g_fLastPingNotice[i] = GetTickedTime();
            }
            
            if (g_bKick && g_iPingDetections[i] >= 3)
            {
                KickClient(i, "[AntiCheat] High ping: %i ms", iPing);
                g_iPingDetections[i] = 0;
            }
        }
        else
        {
            g_iPingDetections[i] = 0;
        }
    }
    return Plugin_Continue;
}
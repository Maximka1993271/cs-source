/*
    Iron Sentinel AntiCheat - Auto Trigger Telemetry
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Консервативная телеметрия jump/attack импульсов без ложных банов обычной игры.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel AutoTrigger Telemetry",
    author = "Maxim Melnikov",
    description = "Conservative bunnyhop/autofire telemetry",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

#define METHOD_BUNNYHOP 0
#define METHOD_AUTOFIRE 1
#define METHOD_MAX 2
#define WINDOW_SECONDS 5.0
#define THRESHOLD 12

ConVar g_hCvarBan;
ConVar g_hCvarKick;
ConVar g_hCvarLogging;
ConVar g_hCvarSensitivity;
bool g_bBan;
bool g_bKick;
bool g_bLogging;
float g_fSensitivity;

int g_iDetections[METHOD_MAX][MAXPLAYERS+1];
int g_iPrevButtons[MAXPLAYERS+1];
float g_fJumpWindowStart[MAXPLAYERS+1];
int g_iAirJumpPresses[MAXPLAYERS+1];
float g_fAttackWindowStart[MAXPLAYERS+1];
int g_iAttackEdges[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarBan = FindConVar("is_autotrigger_ban");
    g_hCvarKick = FindConVar("is_autotrigger_kick");
    g_hCvarLogging = FindConVar("is_autotrigger_logging");
    g_hCvarSensitivity = FindConVar("is_autotrigger_sensitivity");
    if (g_hCvarBan == null) g_hCvarBan = CreateConVar("is_autotrigger_ban", "0", "Ban for repeated auto-trigger telemetry (0=off)", 0, true, 0.0, true, 1.0);
    if (g_hCvarKick == null) g_hCvarKick = CreateConVar("is_autotrigger_kick", "0", "Kick for repeated auto-trigger telemetry", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_autotrigger_logging", "1", "Log auto-trigger telemetry", 0, true, 0.0, true, 1.0);
    if (g_hCvarSensitivity == null) g_hCvarSensitivity = CreateConVar("is_autotrigger_sensitivity", "1.0", "Sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    g_hCvarBan.AddChangeHook(OnSettingsChanged);
    g_hCvarKick.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarSensitivity.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
    // Must survive map changes, or detection counts stop decaying after the first map
    // change and stale suspicion from many maps ago keeps counting toward a kick.
    CreateTimer(30.0, Timer_Decay, _, TIMER_REPEAT);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bBan = g_hCvarBan.BoolValue;
    g_bKick = g_hCvarKick.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
    g_fSensitivity = g_hCvarSensitivity.FloatValue;
}

public void OnClientPutInServer(int client) { ResetClient(client); }
public void OnClientDisconnect(int client) { ResetClient(client); }
void ResetClient(int client)
{
    g_iPrevButtons[client] = 0;
    g_fJumpWindowStart[client] = 0.0;
    g_iAirJumpPresses[client] = 0;
    g_fAttackWindowStart[client] = 0.0;
    g_iAttackEdges[client] = 0;
    for (int i = 0; i < METHOD_MAX; i++) g_iDetections[i][client] = 0;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3],
    int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsPlayerAlive(client)) return Plugin_Continue;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return Plugin_Continue;

    float now = GetGameTime();
    bool jumpEdge = ((buttons & IN_JUMP) != 0) && ((g_iPrevButtons[client] & IN_JUMP) == 0);
    bool attackEdge = ((buttons & IN_ATTACK) != 0) && ((g_iPrevButtons[client] & IN_ATTACK) == 0);
    g_iPrevButtons[client] = buttons;

    if (jumpEdge && GetEntityMoveType(client) != MOVETYPE_LADDER)
    {
        if (g_fJumpWindowStart[client] <= 0.0 || now - g_fJumpWindowStart[client] > WINDOW_SECONDS)
        {
            g_fJumpWindowStart[client] = now;
            g_iAirJumpPresses[client] = 0;
        }
        if (!(GetEntityFlags(client) & FL_ONGROUND))
        {
            g_iAirJumpPresses[client]++;
            float scaledThreshold = float(THRESHOLD) / g_fSensitivity;
            if (float(g_iAirJumpPresses[client]) >= scaledThreshold)
            {
                AutoTrigger_Detected(client, METHOD_BUNNYHOP, g_iAirJumpPresses[client], "repeated airborne jump inputs");
                g_iAirJumpPresses[client] = 0;
                g_fJumpWindowStart[client] = now;
            }
        }
    }

    if (attackEdge)
    {
        if (g_fAttackWindowStart[client] <= 0.0 || now - g_fAttackWindowStart[client] > WINDOW_SECONDS)
        {
            g_fAttackWindowStart[client] = now;
            g_iAttackEdges[client] = 0;
        }
        g_iAttackEdges[client]++;
        // This is only a rate warning; automatic weapons remain untouched.
        if (g_iAttackEdges[client] >= RoundToNearest(THRESHOLD * 1.5 / g_fSensitivity))
        {
            AutoTrigger_Detected(client, METHOD_AUTOFIRE, g_iAttackEdges[client], "high attack edge rate");
            g_iAttackEdges[client] = 0;
            g_fAttackWindowStart[client] = now;
        }
    }

    return Plugin_Continue;
}

void AutoTrigger_Detected(int client, int method, int sample, const char[] reason)
{
    g_iDetections[method][client]++;
    if (g_bLogging)
        IS_LogAction(client, "auto-trigger telemetry: method=%i sample=%i reason=%s detections=%i",
            method, sample, reason, g_iDetections[method][client]);
    IS_PrintAdminNotice("{orange}[AUTO-TRIGGER]{default} %N telemetry warning: %s ({orange}%i{default})",
        client, reason, g_iDetections[method][client]);

    int threshold = RoundToNearest(4.0 / g_fSensitivity);
    if (threshold < 4) threshold = 4;
    if (g_iDetections[method][client] >= threshold)
    {
        if (g_bBan)
        {
            IS_BanClient(client, "Repeated auto-trigger telemetry");
            ResetClient(client);
        }
        else if (g_bKick)
        {
            KickClient(client, "[AntiCheat] Repeated auto-trigger telemetry");
            ResetClient(client);
        }
    }
}

public Action Timer_Decay(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
        for (int m = 0; m < METHOD_MAX; m++)
            if (g_iDetections[m][i] > 0) g_iDetections[m][i]--;
    return Plugin_Continue;
}

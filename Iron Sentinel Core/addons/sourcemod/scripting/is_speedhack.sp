/*
    Iron Sentinel AntiCheat - Speedhack Detector
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Скорость по серверной velocity с защитой от лестниц/наблюдателей/телепортов и с decay.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Speedhack Detector",
    author = "Maxim Melnikov",
    description = "Стабильная серверная проверка аномальной скорости",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

#define SPEED_DECAY_INTERVAL 20.0

ConVar g_hCvarMaxSpeed;
ConVar g_hCvarSpeedMultiplier;
ConVar g_hCvarDetectionsToBan;
ConVar g_hCvarAutoKick;
ConVar g_hCvarLogEnabled;
ConVar g_hCvarCheckInterval;

float g_fMaxSpeed;
float g_fSpeedMultiplier;
int g_iDetectionsToBan;
bool g_bAutoKick;
bool g_bLogEnabled;
float g_fCheckInterval;
float g_fAllowedSpeedSq;
float g_fExtremeSpeedSq;

int g_iSpeedDetections[MAXPLAYERS+1];
float g_fMaxSpeedReached[MAXPLAYERS+1];
float g_fMaxSpeedReachedSq[MAXPLAYERS+1];
float g_fLastViolation[MAXPLAYERS+1];
bool g_bIsSuspected[MAXPLAYERS+1];
Handle g_hTimer = INVALID_HANDLE;
Handle g_hDecayTimer = INVALID_HANDLE;

public void OnPluginStart()
{
    g_hCvarMaxSpeed = FindConVar("is_speed_max");
    g_hCvarSpeedMultiplier = FindConVar("is_speed_multiplier");
    g_hCvarDetectionsToBan = FindConVar("is_speed_detections");
    g_hCvarAutoKick = FindConVar("is_speed_autokick");
    g_hCvarLogEnabled = FindConVar("is_speed_logging");
    g_hCvarCheckInterval = FindConVar("is_speed_check_interval");

    if (g_hCvarMaxSpeed == null) g_hCvarMaxSpeed = CreateConVar("is_speed_max", "320.0", "Базовая max speed", 0, true, 100.0, true, 1000.0);
    if (g_hCvarSpeedMultiplier == null) g_hCvarSpeedMultiplier = CreateConVar("is_speed_multiplier", "1.5", "Множитель допуска для детектора", 0, true, 1.0, true, 5.0);
    if (g_hCvarDetectionsToBan == null) g_hCvarDetectionsToBan = CreateConVar("is_speed_detections", "4", "Подтверждений до бана", 0, true, 1.0, true, 10.0);
    if (g_hCvarAutoKick == null) g_hCvarAutoKick = CreateConVar("is_speed_autokick", "0", "Не использовать early kick до порога бана", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogEnabled == null) g_hCvarLogEnabled = CreateConVar("is_speed_logging", "1", "Логировать speed anomalies", 0, true, 0.0, true, 1.0);
    if (g_hCvarCheckInterval == null) g_hCvarCheckInterval = CreateConVar("is_speed_check_interval", "0.5", "Интервал проверки скорости", 0, true, 0.1, true, 2.0);

    g_hCvarMaxSpeed.AddChangeHook(OnSettingsChanged); g_hCvarSpeedMultiplier.AddChangeHook(OnSettingsChanged);
    g_hCvarDetectionsToBan.AddChangeHook(OnSettingsChanged); g_hCvarAutoKick.AddChangeHook(OnSettingsChanged);
    g_hCvarLogEnabled.AddChangeHook(OnSettingsChanged); g_hCvarCheckInterval.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");

    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    RegAdminCmd("is_speed_reset", Command_ResetPlayer, ADMFLAG_GENERIC, "Reset speed detections");
    RegAdminCmd("is_speed_status", Command_Status, ADMFLAG_GENERIC, "Show speed status");
    // Must survive map changes, or detection scores stop decaying after the first map
    // change and stale suspicion from many maps ago keeps counting toward a ban.
    g_hDecayTimer = CreateTimer(SPEED_DECAY_INTERVAL, Timer_Decay, _, TIMER_REPEAT);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_fMaxSpeed = g_hCvarMaxSpeed.FloatValue;
    g_fSpeedMultiplier = g_hCvarSpeedMultiplier.FloatValue;
    g_iDetectionsToBan = g_hCvarDetectionsToBan.IntValue;
    g_bAutoKick = g_hCvarAutoKick.BoolValue;
    g_bLogEnabled = g_hCvarLogEnabled.BoolValue;
    g_fCheckInterval = g_hCvarCheckInterval.FloatValue;
    float allowed = g_fMaxSpeed * g_fSpeedMultiplier;
    g_fAllowedSpeedSq = allowed * allowed;
    g_fExtremeSpeedSq = g_fAllowedSpeedSq * 9.0;

    if (g_hTimer != INVALID_HANDLE) { KillTimer(g_hTimer); g_hTimer = INVALID_HANDLE; }
    // Must survive map changes: this is the primary speedhack check loop. With
    // TIMER_FLAG_NO_MAPCHANGE the engine silently kills it at the first map change,
    // g_hTimer keeps a stale handle, and speed checking stops for good.
    if (g_fCheckInterval > 0.0) g_hTimer = CreateTimer(g_fCheckInterval, Timer_CheckSpeed, _, TIMER_REPEAT);
}

public void OnClientConnected(int client)
{
    ResetClient(client);
}
public void OnClientDisconnect(int client)
{
    ResetClient(client);
}
void ResetClient(int client)
{
    g_iSpeedDetections[client] = 0;
    g_fMaxSpeedReached[client] = 0.0;
    g_fMaxSpeedReachedSq[client] = 0.0;
    g_fLastViolation[client] = 0.0;
    g_bIsSuspected[client] = false;
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IS_CLIENT(client)) ResetClient(client);
    return Plugin_Continue;
}

public Action Timer_CheckSpeed(Handle timer)
{
    float allowed = g_fMaxSpeed * g_fSpeedMultiplier;
    float now = GetTickedTime();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i) || !IsPlayerAlive(i)) continue;
        if (CheckCommandAccess(i, "is_immunity", ADMFLAG_CUSTOM1, true)) continue;

        MoveType moveType = GetEntityMoveType(i);
        if (moveType == MOVETYPE_NONE || moveType == MOVETYPE_NOCLIP || moveType == MOVETYPE_OBSERVER || moveType == MOVETYPE_LADDER)
            continue;
        if (GetEntityFlags(i) & FL_FROZEN) continue;

        float velocity[3];
        GetEntPropVector(i, Prop_Data, "m_vecVelocity", velocity);
        float speedSq = (velocity[0] * velocity[0]) + (velocity[1] * velocity[1]);
        if (speedSq > g_fMaxSpeedReachedSq[i])
        {
            g_fMaxSpeedReachedSq[i] = speedSq;
            g_fMaxSpeedReached[i] = SquareRoot(speedSq);
        }

        if (speedSq > g_fAllowedSpeedSq && speedSq < g_fExtremeSpeedSq)
        {
            float speed = SquareRoot(speedSq);
            HandleSpeedViolation(i, speed, allowed, now);
        }
        else if (speedSq >= g_fExtremeSpeedSq && g_bLogEnabled)
        {
            // Extreme server velocity may be a teleport/knockback; log it but do not auto-punish from one sample.
            IS_LogAction(i, "speed sample ignored as teleport/physics spike: %.1f", SquareRoot(speedSq));
        }
    }
    return Plugin_Continue;
}

void HandleSpeedViolation(int client, float speed, float allowed, float now)
{
    if (now - g_fLastViolation[client] < 0.75) return;
    g_fLastViolation[client] = now;
    g_iSpeedDetections[client]++;
    g_bIsSuspected[client] = true;

    if (g_bLogEnabled) IS_LogAction(client, "speed anomaly: %.1f > %.1f; detections=%i", speed, allowed, g_iSpeedDetections[client]);
    IS_PrintAdminNotice("{orange}[SPEED]{default} %N anomaly: {orange}%.1f{default} > %.1f (%i)", client, speed, allowed, g_iSpeedDetections[client]);

    if (g_iSpeedDetections[client] >= g_iDetectionsToBan)
    {
        IS_BanClient(client, "Repeated abnormal server velocity");
        ResetClient(client);
    }
    else if (g_bAutoKick && g_iDetectionsToBan <= 1)
    {
        KickClient(client, "[AntiCheat] Abnormal speed");
        ResetClient(client);
    }
}

public Action Timer_Decay(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iSpeedDetections[i] > 0) g_iSpeedDetections[i]--;
        if (g_iSpeedDetections[i] == 0) g_bIsSuspected[i] = false;
        g_fMaxSpeedReached[i] = 0.0;
        g_fMaxSpeedReachedSq[i] = 0.0;
    }
    return Plugin_Continue;
}

public Action Command_ResetPlayer(int client, int args)
{
    if (args < 1) { ReplyToCommand(client, "Usage: is_speed_reset <#userid|name>"); return Plugin_Handled; }
    char targetName[64]; GetCmdArg(1, targetName, sizeof(targetName));
    int target = FindTarget(client, targetName, true, false);
    if (target == -1) return Plugin_Handled;
    ResetClient(target); ReplyToCommand(client, "[IS] Speed counters reset for %N.", target); return Plugin_Handled;
}

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "[IS Speed] max=%.1f multiplier=%.2f allowed=%.1f detections=%i autokick=%s", g_fMaxSpeed, g_fSpeedMultiplier, g_fMaxSpeed*g_fSpeedMultiplier, g_iDetectionsToBan, g_bAutoKick ? "ON" : "OFF");
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i) && g_bIsSuspected[i]) PrintToConsole(client, "  %N: detections=%i peak=%.1f", i, g_iSpeedDetections[i], g_fMaxSpeedReached[i]);
    return Plugin_Handled;
}

public void OnPluginEnd()
{
    if (g_hTimer != INVALID_HANDLE) KillTimer(g_hTimer);
    if (g_hDecayTimer != INVALID_HANDLE) KillTimer(g_hDecayTimer);
    g_hTimer = INVALID_HANDLE; g_hDecayTimer = INVALID_HANDLE;
}

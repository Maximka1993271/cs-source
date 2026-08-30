/*
    Iron Sentinel AntiCheat - Aimbot Detector
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Обнаруживает использование аимбота
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Aimbot Detector",
    author = "Maxim Melnikov",
    description = "Обнаруживает использование аимбота",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  КОНСТАНТЫ
// ===========================

#define MAX_ANGLE_HISTORY 64
#define AIM_MIN_DISTANCE 200.0
#define AIM_ANGLE_CHANGE 45.0
#define MAX_SNAPS 6

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarAimbotBan;
ConVar g_hCvarAimbotKick;
ConVar g_hCvarAimbotLogging;
ConVar g_hCvarAimbotSensitivity;

int g_iAimbotBan;
bool g_bAimbotKick;
bool g_bAimbotLogging;
float g_fAimbotSensitivity;

float g_fEyeAngles[MAXPLAYERS+1][MAX_ANGLE_HISTORY][2];
int g_iAngleIndex[MAXPLAYERS+1];
int g_iAngleSamples[MAXPLAYERS+1];

int g_iSnapCount[MAXPLAYERS+1];
int g_iAimDetections[MAXPLAYERS+1];
float g_fLastDetectionTime[MAXPLAYERS+1];
bool g_bIsSuspected[MAXPLAYERS+1];


// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    // ===== КОНФИГИ (ПЕРЕМЕННЫЕ ИЗ ЯДРА) =====
    g_hCvarAimbotBan = FindConVar("is_aimbot_ban");
    g_hCvarAimbotKick = FindConVar("is_aimbot_kick");
    g_hCvarAimbotLogging = FindConVar("is_aimbot_logging");
    g_hCvarAimbotSensitivity = FindConVar("is_aimbot_sensitivity");
    
    if (g_hCvarAimbotBan == null)
    {
        g_hCvarAimbotBan = CreateConVar("is_aimbot_ban", "4", "Количество детекций для бана (0 = выкл, минимум 4)", 0, true, 0.0);
    }
    if (g_hCvarAimbotKick == null)
    {
        g_hCvarAimbotKick = CreateConVar("is_aimbot_kick", "0", "Кикать за аимбот", 0, true, 0.0, true, 1.0);
    }
    if (g_hCvarAimbotLogging == null)
    {
        g_hCvarAimbotLogging = CreateConVar("is_aimbot_logging", "1", "Логировать аимбот", 0, true, 0.0, true, 1.0);
    }
    if (g_hCvarAimbotSensitivity == null)
    {
        g_hCvarAimbotSensitivity = CreateConVar("is_aimbot_sensitivity", "1.0", "Чувствительность детектора (0.5-2.0)", 0, true, 0.5, true, 2.0);
    }
    
    g_hCvarAimbotBan.AddChangeHook(OnSettingsChanged);
    g_hCvarAimbotKick.AddChangeHook(OnSettingsChanged);
    g_hCvarAimbotLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarAimbotSensitivity.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
    
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    
    RegAdminCmd("is_aimbot_reset", Command_ResetPlayer, ADMFLAG_GENERIC, "Reset aimbot counters for a player");
    RegAdminCmd("is_aimbot_status", Command_Status, ADMFLAG_GENERIC, "Show aimbot player status");
    
    CreateTimer(30.0, Timer_DecreaseDetections, _, TIMER_REPEAT);
    
    // ===== СОЗДАЁМ КОНФИГ =====
    // AutoExecConfig(true, "is_aimbot");  // ← УДАЛЕНО
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_iAimbotBan = g_hCvarAimbotBan.IntValue;
    g_bAimbotKick = g_hCvarAimbotKick.BoolValue;
    g_bAimbotLogging = g_hCvarAimbotLogging.BoolValue;
    g_fAimbotSensitivity = g_hCvarAimbotSensitivity.FloatValue;
    
    if (g_iAimbotBan > 0 && g_iAimbotBan < 4)
    {
        g_iAimbotBan = 4;
        g_hCvarAimbotBan.IntValue = 4;
    }
}

public void OnClientConnected(int client)
{
    ClearClientData(client);
}

public void OnClientDisconnect(int client)
{
    ClearClientData(client);
}

void ClearClientData(int client)
{
    g_iSnapCount[client] = 0;
    g_iAimDetections[client] = 0;
    g_bIsSuspected[client] = false;
    g_fLastDetectionTime[client] = 0.0;
    g_iAngleIndex[client] = 0;
    g_iAngleSamples[client] = 0;
    
    for (int i = 0; i < MAX_ANGLE_HISTORY; i++)
    {
        g_fEyeAngles[client][i][0] = 0.0;
        g_fEyeAngles[client][i][1] = 0.0;
    }
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (IS_CLIENT(client) && !IsFakeClient(client))
    {
        g_iAngleIndex[client] = 0;
        g_iAngleSamples[client] = 0;
        for (int i = 0; i < MAX_ANGLE_HISTORY; i++)
        {
            g_fEyeAngles[client][i][0] = 0.0;
            g_fEyeAngles[client][i][1] = 0.0;
            }
    }
    
    return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    
    if (!IS_CLIENT(attacker) || !IS_CLIENT(victim) || attacker == victim)
    {
        return Plugin_Continue;
    }
    
    if (IsFakeClient(attacker) || IsFakeClient(victim))
    {
        return Plugin_Continue;
    }
    
    if (CheckCommandAccess(attacker, "is_immunity", ADMFLAG_CUSTOM1, true))
    {
        return Plugin_Continue;
    }
    
    float vAttacker[3], vVictim[3];
    GetClientAbsOrigin(attacker, vAttacker);
    GetClientAbsOrigin(victim, vVictim);
    
    float fDistance = GetVectorDistance(vAttacker, vVictim);
    
    if (fDistance < AIM_MIN_DISTANCE)
    {
        return Plugin_Continue;
    }
    
    char sWeapon[32];
    GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
    
    if (StrContains(sWeapon, "knife") != -1 || 
        StrContains(sWeapon, "grenade") != -1 ||
        StrContains(sWeapon, "flashbang") != -1 ||
        StrContains(sWeapon, "smoke") != -1)
    {
        return Plugin_Continue;
    }
    
    float attackerEye[3], victimEye[3], toTarget[3], targetAngles[3];
    GetClientEyePosition(attacker, attackerEye);
    GetClientEyePosition(victim, victimEye);
    MakeVectorFromPoints(attackerEye, victimEye, toTarget);
    GetVectorAngles(toTarget, targetAngles);
    AnalyzeAngles(attacker, fDistance, targetAngles);
    
    return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i))
        {
            g_iSnapCount[i] = 0;
        }
    }
    
    return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], 
    int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsPlayerAlive(client))
    {
        return Plugin_Continue;
    }
    
    g_fEyeAngles[client][g_iAngleIndex[client]][0] = angles[0];
    g_fEyeAngles[client][g_iAngleIndex[client]][1] = angles[1];
    if (g_iAngleSamples[client] < MAX_ANGLE_HISTORY)
    {
        g_iAngleSamples[client]++;
    }
    
    if (++g_iAngleIndex[client] >= MAX_ANGLE_HISTORY)
    {
        g_iAngleIndex[client] = 0;
    }
    
    return Plugin_Continue;
}

void AnalyzeAngles(int client, float fDistance, const float targetAngles[3])
{
    int samples = g_iAngleSamples[client];
    if (samples < 12) return;

    int idx = g_iAngleIndex[client] - 1;
    if (idx < 0) idx = MAX_ANGLE_HISTORY - 1;

    float lastPitch = g_fEyeAngles[client][idx][0];
    float lastYaw = g_fEyeAngles[client][idx][1];
    int snaps = 0;
    float maxSnap = 0.0;
    int matchingSnaps = 0;
    float snapThreshold = AIM_ANGLE_CHANGE * g_fAimbotSensitivity;

    for (int i = 1; i < samples; i++)
    {
        if (--idx < 0) idx = MAX_ANGLE_HISTORY - 1;
        float pitch = g_fEyeAngles[client][idx][0];
        float yaw = g_fEyeAngles[client][idx][1];
        float pitchDiff = FloatAbs(pitch - lastPitch);
        float yawDiff = FloatAbs(yaw - lastYaw);
        if (yawDiff > 180.0) yawDiff = 360.0 - yawDiff;
        float totalDiff = pitchDiff + yawDiff;

        if (totalDiff > snapThreshold)
        {
            snaps++;
            if (totalDiff > maxSnap) maxSnap = totalDiff;

            float targetYawDiff = FloatAbs(NormalizeYaw(yaw - targetAngles[1]));
            float targetPitchDiff = FloatAbs(pitch - targetAngles[0]);
            if (targetYawDiff <= 10.0 * g_fAimbotSensitivity && targetPitchDiff <= 8.0 * g_fAimbotSensitivity)
                matchingSnaps++;
        }
        lastPitch = pitch;
        lastYaw = yaw;
    }

    if (snaps >= 3 && matchingSnaps >= 1 && maxSnap > snapThreshold * 1.5)
    {
        g_iSnapCount[client]++;
        
        float fGameTime = GetTickedTime();
        if (fGameTime - g_fLastDetectionTime[client] < 2.0)
        {
            g_iSnapCount[client] += 2;
        }
        g_fLastDetectionTime[client] = fGameTime;
        
        if (g_iSnapCount[client] >= 3)
        {
            HandleAimbotDetection(client, snaps, maxSnap, fDistance);
            g_iSnapCount[client] = 0;
        }
    }
}

float NormalizeYaw(float yaw)
{
    while (yaw > 180.0) yaw -= 360.0;
    while (yaw < -180.0) yaw += 360.0;
    return yaw;
}

void HandleAimbotDetection(int client, int iSnaps, float fMaxSnap, float fDistance)
{
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
    {
        return;
    }
    
    g_iAimDetections[client]++;
    g_bIsSuspected[client] = true;
    
    if (g_bAimbotLogging)
    {
        IS_LogAction(client, "aimbot suspect. Snaps: %i, Max snap: %.1f deg, Distance: %.0f, Detections: %i", 
            iSnaps, fMaxSnap, fDistance, g_iAimDetections[client]);
    }
    
    IS_PrintAdminNotice("{red}[AIMBOT]{default} %N suspected (snap: {orange}%.1f deg{default}, detections: {orange}%i{default})", 
        client, fMaxSnap, g_iAimDetections[client]);
    
    if (g_iAimbotBan > 0 && g_iAimDetections[client] >= g_iAimbotBan)
    {
        if (g_bAimbotLogging)
        {
            IS_LogAction(client, "BANNED for aimbot (%i detections)", g_iAimDetections[client]);
        }
        
        IS_PrintAdminNotice("{red}[AIMBOT]{default} %N BANNED for aimbot!", client);
        IS_BanClient(client, "Aimbot detected");
        
        g_iAimDetections[client] = 0;
        g_bIsSuspected[client] = false;
    }
    else if (g_iAimbotBan <= 0 && g_bAimbotKick)
    {
        KickClient(client, "[AntiCheat] Aimbot detected");
        g_iAimDetections[client] = 0;
        g_bIsSuspected[client] = false;
    }
}

public Action Timer_DecreaseDetections(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iAimDetections[i] > 0)
        {
            g_iAimDetections[i]--;
        }
        if (g_iSnapCount[i] > 0)
        {
            g_iSnapCount[i]--;
        }
    }
    
    return Plugin_Continue;
}

public Action Command_ResetPlayer(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Usage: is_aimbot_reset <#userid|name>");
        return Plugin_Handled;
    }
    
    char sTarget[64];
    GetCmdArg(1, sTarget, sizeof(sTarget));
    
    int target = FindTarget(client, sTarget, true, false);
    
    if (target == -1)
    {
        return Plugin_Handled;
    }
    
    g_iAimDetections[target] = 0;
    g_iSnapCount[target] = 0;
    g_bIsSuspected[target] = false;
    
    ReplyToCommand(client, "[AntiCheat] Aimbot counters reset for %N.", target);
    
    return Plugin_Handled;
}

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "|       AIMBOT DETECTOR STATUS            |");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "");
    PrintToConsole(client, "Detections for ban: %i", g_iAimbotBan);
    PrintToConsole(client, "Auto-kick:         %s", g_bAimbotKick ? "ON" : "OFF");
    PrintToConsole(client, "Sensitivity:       %.1f", g_fAimbotSensitivity);
    PrintToConsole(client, "");
    PrintToConsole(client, "--- Suspected players ---");
    PrintToConsole(client, "  #  | Name              | Detections | Snaps");
    PrintToConsole(client, "-----+-------------------+------------+--------");
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && g_bIsSuspected[i])
        {
            PrintToConsole(client, "  %2d | %-17N | %10i | %6i", 
                i, i, g_iAimDetections[i], g_iSnapCount[i]);
        }
    }
    
    PrintToConsole(client, "");
    return Plugin_Handled;
}
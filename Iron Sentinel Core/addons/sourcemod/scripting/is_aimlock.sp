/*
    Iron Sentinel AntiCheat - Aimlock Detector
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Консервативная эвристика корреляции прицела с жертвой; по умолчанию только логирование.
*/
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Aimlock Detector",
    author = "Maxim Melnikov",
    description = "Conservative aimlock heuristic",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

#define AIMLOCK_DETECTIONS 3
#define AIMLOCK_TARGET_TOLERANCE 5.0
#define AIMLOCK_FRAMES 8

ConVar g_hCvarBan;
ConVar g_hCvarKick;
ConVar g_hCvarLogging;
ConVar g_hCvarSensitivity;

bool g_bBan;
bool g_bKick;
bool g_bLogging;
float g_fSensitivity;
float g_fAimAngles[MAXPLAYERS+1][AIMLOCK_FRAMES][3];
int g_iAimIndex[MAXPLAYERS+1];
int g_iDetections[MAXPLAYERS+1];
bool g_bSuspected[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarBan = FindConVar("is_aimlock_ban");
    g_hCvarKick = FindConVar("is_aimlock_kick");
    g_hCvarLogging = FindConVar("is_aimlock_logging");
    g_hCvarSensitivity = FindConVar("is_aimlock_sensitivity");
    if (g_hCvarBan == null) g_hCvarBan = CreateConVar("is_aimlock_ban", "0", "Ban for aimlock (0=off)", 0, true, 0.0, true, 1.0);
    if (g_hCvarKick == null) g_hCvarKick = CreateConVar("is_aimlock_kick", "0", "Kick only when ban threshold is disabled", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_aimlock_logging", "1", "Log aimlock anomalies", 0, true, 0.0, true, 1.0);
    if (g_hCvarSensitivity == null) g_hCvarSensitivity = CreateConVar("is_aimlock_sensitivity", "1.0", "Sensitivity", 0, true, 0.5, true, 2.0);
    g_hCvarBan.AddChangeHook(OnSettingsChanged); g_hCvarKick.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged); g_hCvarSensitivity.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bBan = g_hCvarBan.BoolValue; g_bKick = g_hCvarKick.BoolValue; g_bLogging = g_hCvarLogging.BoolValue; g_fSensitivity = g_hCvarSensitivity.FloatValue;
}

public void OnClientDisconnect(int client)
{
    g_iAimIndex[client] = 0; g_iDetections[client] = 0; g_bSuspected[client] = false;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsPlayerAlive(client)) return Plugin_Continue;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return Plugin_Continue;
    g_fAimAngles[client][g_iAimIndex[client]] = angles;
    g_iAimIndex[client] = (g_iAimIndex[client] + 1) % AIMLOCK_FRAMES;
    return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (!IS_CLIENT(attacker) || !IS_CLIENT(victim) || attacker == victim || IsFakeClient(attacker) || IsFakeClient(victim)) return Plugin_Continue;
    if (!IsClientInGame(attacker) || !IsClientInGame(victim)) return Plugin_Continue;
    if (CheckCommandAccess(attacker, "is_immunity", ADMFLAG_CUSTOM1, true)) return Plugin_Continue;
    if (!CheckAimlock(attacker, victim)) return Plugin_Continue;
    return Plugin_Continue;
}

bool CheckAimlock(int client, int victim)
{
    float eye[3], targetEye[3], dir[3], targetAngles[3];
    GetClientEyePosition(client, eye); GetClientEyePosition(victim, targetEye);
    MakeVectorFromPoints(eye, targetEye, dir); GetVectorAngles(dir, targetAngles);

    float finalAngles[3];
    int latest = (g_iAimIndex[client] - 1 + AIMLOCK_FRAMES) % AIMLOCK_FRAMES;
    finalAngles[0] = g_fAimAngles[client][latest][0];
    finalAngles[1] = g_fAimAngles[client][latest][1];
    finalAngles[2] = g_fAimAngles[client][latest][2];
    if (finalAngles[0] == 0.0 && finalAngles[1] == 0.0) return false;

    float yawDiff = FloatAbs(NormalizeYaw(finalAngles[1] - targetAngles[1]));
    float pitchDiff = FloatAbs(finalAngles[0] - targetAngles[0]);
    float tolerance = AIMLOCK_TARGET_TOLERANCE * g_fSensitivity;
    if (yawDiff > tolerance || pitchDiff > tolerance) return false;

    int stableFrames = 0;
    for (int i = 0; i < AIMLOCK_FRAMES - 1; i++)
    {
        int a = (g_iAimIndex[client] - 1 - i + AIMLOCK_FRAMES) % AIMLOCK_FRAMES;
        int b = (a - 1 + AIMLOCK_FRAMES) % AIMLOCK_FRAMES;
        float yd = FloatAbs(NormalizeYaw(g_fAimAngles[client][a][1] - g_fAimAngles[client][b][1]));
        float pd = FloatAbs(g_fAimAngles[client][a][0] - g_fAimAngles[client][b][0]);
        if (yd <= 0.20 * g_fSensitivity && pd <= 0.20 * g_fSensitivity) stableFrames++;
    }
    if (stableFrames < 5) return false;

    g_iDetections[client]++;
    g_bSuspected[client] = true;
    if (g_bLogging) IS_LogAction(client, "aimlock heuristic: target-aligned %.2f/%.2f deg, stable_frames=%i, detections=%i", yawDiff, pitchDiff, stableFrames, g_iDetections[client]);
    IS_PrintAdminNotice("{orange}[AIMLOCK]{default} %N target-aligned stability warning ({orange}%i{default})", client, g_iDetections[client]);

    if (g_bBan && g_iDetections[client] >= AIMLOCK_DETECTIONS)
    {
        IS_BanClient(client, "Repeated aimlock heuristic match");
        g_iDetections[client] = 0; g_bSuspected[client] = false;
    }
    else if (!g_bBan && g_bKick)
    {
        KickClient(client, "[AntiCheat] Aimlock heuristic");
        g_iDetections[client] = 0; g_bSuspected[client] = false;
    }
    return true;
}

float NormalizeYaw(float yaw)
{
    while (yaw > 180.0) yaw -= 360.0;
    while (yaw < -180.0) yaw += 360.0;
    return yaw;
}

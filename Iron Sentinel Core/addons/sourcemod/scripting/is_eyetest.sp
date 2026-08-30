/*
    Iron Sentinel AntiCheat - Eye Sanity
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Проверяет только явно невозможные/повреждённые usercmd angles.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Eye Sanity",
    author = "Maxim Melnikov",
    description = "Safe usercmd angle validation",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

#define EYE_HISTORY 16
#define PITCH_LIMIT 100.0
#define ROLL_LIMIT 100.0
#define VIOLATION_THRESHOLD 3

ConVar g_hCvarAutoKick;
ConVar g_hCvarAutoBan;
ConVar g_hCvarLog;
ConVar g_hCvarSensitivity;

bool g_bAutoKick;
bool g_bAutoBan;
bool g_bLog;
float g_fSensitivity;
int g_iViolations[MAXPLAYERS+1];
float g_fLastViolation[MAXPLAYERS+1];
float g_fLastAngles[MAXPLAYERS+1][3];

public void OnPluginStart()
{
    g_hCvarAutoKick = FindConVar("is_eyetest_autokick");
    g_hCvarAutoBan = FindConVar("is_eyetest_autoban");
    g_hCvarLog = FindConVar("is_eyetest_logging");
    g_hCvarSensitivity = FindConVar("is_eyetest_sensitivity");
    if (g_hCvarAutoKick == null) g_hCvarAutoKick = CreateConVar("is_eyetest_autokick", "0", "Kick for repeated invalid angles", 0, true, 0.0, true, 1.0);
    if (g_hCvarAutoBan == null) g_hCvarAutoBan = CreateConVar("is_eyetest_autoban", "0", "Ban for repeated invalid angles", 0, true, 0.0, true, 1.0);
    if (g_hCvarLog == null) g_hCvarLog = CreateConVar("is_eyetest_logging", "1", "Log invalid angles", 0, true, 0.0, true, 1.0);
    if (g_hCvarSensitivity == null) g_hCvarSensitivity = CreateConVar("is_eyetest_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    g_hCvarAutoKick.AddChangeHook(OnSettingsChanged);
    g_hCvarAutoBan.AddChangeHook(OnSettingsChanged);
    g_hCvarLog.AddChangeHook(OnSettingsChanged);
    g_hCvarSensitivity.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
    // Must survive map changes, or detection counts stop decaying after the first map
    // change and stale suspicion from many maps ago keeps counting toward a kick.
    CreateTimer(30.0, Timer_Decay, _, TIMER_REPEAT);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bAutoKick = g_hCvarAutoKick.BoolValue;
    g_bAutoBan = g_hCvarAutoBan.BoolValue;
    g_bLog = g_hCvarLog.BoolValue;
    g_fSensitivity = g_hCvarSensitivity.FloatValue;
}

public void OnClientPutInServer(int client) { ResetClient(client); }
public void OnClientDisconnect(int client) { ResetClient(client); }
void ResetClient(int client)
{
    g_iViolations[client] = 0;
    g_fLastViolation[client] = 0.0;
    g_fLastAngles[client][0] = 0.0;
    g_fLastAngles[client][1] = 0.0;
    g_fLastAngles[client][2] = 0.0;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3],
    int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsClientInGame(client)) return Plugin_Continue;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return Plugin_Continue;

    g_fLastAngles[client][0] = angles[0];
    g_fLastAngles[client][1] = angles[1];
    g_fLastAngles[client][2] = angles[2];

    float pitch = angles[0];
    float yaw = angles[1];
    float roll = angles[2];
    float limitPitch = PITCH_LIMIT * g_fSensitivity;
    float limitRoll = ROLL_LIMIT * g_fSensitivity;

    bool invalid = (pitch != pitch) || (yaw != yaw) || (roll != roll) ||
        (FloatAbs(pitch) > limitPitch) || (FloatAbs(roll) > limitRoll) ||
        (FloatAbs(yaw) > 100000.0);
    if (!invalid) return Plugin_Continue;

    float now = GetTickedTime();
    if (now - g_fLastViolation[client] < 0.75) return Plugin_Continue;
    g_fLastViolation[client] = now;
    g_iViolations[client]++;

    if (g_bLog)
        IS_LogAction(client, "invalid usercmd angles: %.2f %.2f %.2f detections=%i", pitch, yaw, roll, g_iViolations[client]);
    IS_PrintAdminNotice("{orange}[ANGLES]{default} %N sent invalid usercmd angles ({orange}%.1f %.1f %.1f{default})", client, pitch, yaw, roll);

    if (g_iViolations[client] >= VIOLATION_THRESHOLD && g_bAutoBan)
    {
        IS_BanClient(client, "Repeated invalid usercmd angles");
        ResetClient(client);
    }
    else if (g_iViolations[client] >= VIOLATION_THRESHOLD && g_bAutoKick && !g_bAutoBan)
    {
        KickClient(client, "[AntiCheat] Invalid usercmd angles");
        ResetClient(client);
    }

    return Plugin_Continue;
}

public Action Timer_Decay(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_iViolations[i] > 0) g_iViolations[i]--;
    }
    return Plugin_Continue;
}

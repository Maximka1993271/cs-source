/*
    Iron Sentinel AntiCheat - Macro Detector
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Консервативное обнаружение регулярных ручных нажатий атаки.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Macro Detector",
    author = "Maxim Melnikov",
    description = "Conservative attack macro heuristic",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

#define MACRO_DETECTIONS 4
#define MACRO_SAMPLES 12
#define MIN_INTERVAL 0.045
#define MAX_INTERVAL 0.350

ConVar g_hCvarBan;
ConVar g_hCvarKick;
ConVar g_hCvarLogging;
ConVar g_hCvarSensitivity;

bool g_bBan;
bool g_bKick;
bool g_bLogging;
float g_fSensitivity;

float g_fPressTimes[MAXPLAYERS+1][MACRO_SAMPLES];
int g_iPressCount[MAXPLAYERS+1];
int g_iPressIndex[MAXPLAYERS+1];
int g_iMacroDetections[MAXPLAYERS+1];
int g_iLastButtons[MAXPLAYERS+1];
float g_fLastDetection[MAXPLAYERS+1];
bool g_bSuspected[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarBan = FindConVar("is_macro_ban");
    g_hCvarKick = FindConVar("is_macro_kick");
    g_hCvarLogging = FindConVar("is_macro_logging");
    g_hCvarSensitivity = FindConVar("is_macro_sensitivity");

    if (g_hCvarBan == null) g_hCvarBan = CreateConVar("is_macro_ban", "0", "Ban for repeated macro heuristic (0=off)", 0, true, 0.0, true, 1.0);
    if (g_hCvarKick == null) g_hCvarKick = CreateConVar("is_macro_kick", "0", "Kick for repeated macro heuristic", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_macro_logging", "1", "Log macro heuristic matches", 0, true, 0.0, true, 1.0);
    if (g_hCvarSensitivity == null) g_hCvarSensitivity = CreateConVar("is_macro_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);

    g_hCvarBan.AddChangeHook(OnSettingsChanged);
    g_hCvarKick.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarSensitivity.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bBan = g_hCvarBan.BoolValue;
    g_bKick = g_hCvarKick.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
    g_fSensitivity = g_hCvarSensitivity.FloatValue;
}

public void OnClientPutInServer(int client)
{
    ResetClient(client);
}

public void OnClientDisconnect(int client)
{
    ResetClient(client);
}

void ResetClient(int client)
{
    g_iPressCount[client] = 0;
    g_iPressIndex[client] = 0;
    g_iMacroDetections[client] = 0;
    g_iLastButtons[client] = 0;
    g_fLastDetection[client] = 0.0;
    g_bSuspected[client] = false;
    for (int i = 0; i < MACRO_SAMPLES; i++) g_fPressTimes[client][i] = 0.0;
}

public void OnMapStart()
{
    CreateTimer(30.0, Timer_DecayDetections, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_DecayDetections(Handle timer)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (g_iMacroDetections[client] > 0)
            g_iMacroDetections[client]--;
        if (g_iMacroDetections[client] == 0)
            g_bSuspected[client] = false;
    }
    return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3],
    int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsPlayerAlive(client)) return Plugin_Continue;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return Plugin_Continue;

    bool attackPressed = ((buttons & IN_ATTACK) != 0) && ((g_iLastButtons[client] & IN_ATTACK) == 0);
    g_iLastButtons[client] = buttons;

    if (!attackPressed) return Plugin_Continue;

    float now = GetGameTime();
    g_fPressTimes[client][g_iPressIndex[client]] = now;
    g_iPressIndex[client] = (g_iPressIndex[client] + 1) % MACRO_SAMPLES;
    if (g_iPressCount[client] < MACRO_SAMPLES) g_iPressCount[client]++;

    if (g_iPressCount[client] >= MACRO_SAMPLES)
        CheckMacroPattern(client);

    return Plugin_Continue;
}

void CheckMacroPattern(int client)
{
    float intervals[MACRO_SAMPLES - 1];
    float mean = 0.0;
    int valid = 0;

    for (int i = 0; i < MACRO_SAMPLES - 1; i++)
    {
        int newer = (g_iPressIndex[client] - 1 - i + MACRO_SAMPLES) % MACRO_SAMPLES;
        int older = (newer - 1 + MACRO_SAMPLES) % MACRO_SAMPLES;
        float interval = g_fPressTimes[client][newer] - g_fPressTimes[client][older];
        intervals[i] = interval;
        if (interval >= MIN_INTERVAL && interval <= MAX_INTERVAL)
        {
            mean += interval;
            valid++;
        }
    }

    if (valid < MACRO_SAMPLES - 2) return;
    mean /= float(valid);

    float variance = 0.0;
    int matched = 0;
    float tolerance = 0.0045 / g_fSensitivity;
    for (int i = 0; i < MACRO_SAMPLES - 1; i++)
    {
        if (intervals[i] < MIN_INTERVAL || intervals[i] > MAX_INTERVAL) continue;
        float delta = FloatAbs(intervals[i] - mean);
        variance += delta * delta;
        if (delta <= tolerance) matched++;
    }

    float deviation = SquareRoot(variance / float(valid));
    float maxDeviation = 0.0060 / g_fSensitivity;

    // Не реагируем на один ровный участок: нужна устойчивая регулярность во всём окне.
    if (matched < 9 || deviation > maxDeviation || mean <= 0.0) return;

    float now = GetTickedTime();
    if (now - g_fLastDetection[client] < 2.0) return;
    g_fLastDetection[client] = now;

    g_iMacroDetections[client]++;
    g_bSuspected[client] = true;

    if (g_bLogging)
        IS_LogAction(client, "macro heuristic: interval=%.4fs deviation=%.4fs matched=%i/%i detections=%i",
            mean, deviation, matched, MACRO_SAMPLES - 1, g_iMacroDetections[client]);

    IS_PrintAdminNotice("{orange}[MACRO]{default} %N has highly regular attack timing ({orange}%ims{default}, %i matches)",
        client, RoundToNearest(mean * 1000.0), matched);

    if (g_bBan && g_iMacroDetections[client] >= MACRO_DETECTIONS)
    {
        IS_BanClient(client, "Repeated macro timing heuristic");
        ResetClient(client);
    }
    else if (g_bKick && !g_bBan && g_iMacroDetections[client] >= 3)
    {
        KickClient(client, "[AntiCheat] Repeated macro timing heuristic");
        ResetClient(client);
    }
}

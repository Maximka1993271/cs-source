/*
    Iron Sentinel AntiCheat - Interpolation Sanity Check
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Проверяет только явно некорректные значения интерполяции; cl_interp 0 сам по себе НЕ является читом.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Interpolation Sanity",
    author = "Maxim Melnikov",
    description = "Safe client interpolation validation",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

ConVar g_hCvarBan;
ConVar g_hCvarKick;
ConVar g_hCvarLogging;
bool g_bBan;
bool g_bKick;
bool g_bLogging;
int g_iDetections[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarBan = FindConVar("is_nolerp_ban");
    g_hCvarKick = FindConVar("is_nolerp_kick");
    g_hCvarLogging = FindConVar("is_nolerp_logging");
    if (g_hCvarBan == null) g_hCvarBan = CreateConVar("is_nolerp_ban", "0", "Ban for invalid interpolation values (0=off)", 0, true, 0.0, true, 1.0);
    if (g_hCvarKick == null) g_hCvarKick = CreateConVar("is_nolerp_kick", "0", "Kick for repeated invalid interpolation values", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_nolerp_logging", "1", "Log interpolation validation", 0, true, 0.0, true, 1.0);
    g_hCvarBan.AddChangeHook(OnSettingsChanged);
    g_hCvarKick.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bBan = g_hCvarBan.BoolValue;
    g_bKick = g_hCvarKick.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
}

public void OnClientPutInServer(int client)
{
    g_iDetections[client] = 0;
    if (!IsFakeClient(client)) CreateTimer(4.0, Timer_CheckInterp, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientDisconnect(int client)
{
    g_iDetections[client] = 0;
}

public Action Timer_CheckInterp(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if (IS_CLIENT(client) && IsClientInGame(client) && !IsFakeClient(client))
    {
        QueryClientConVar(client, "cl_interp", OnInterpQuery, serial);
    }
    return Plugin_Stop;
}

public void OnInterpQuery(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName,
    const char[] cvarValue, any serial)
{
    if (GetClientFromSerial(serial) != client) return;
    if (!IS_CLIENT(client) || !IsClientInGame(client) || IsFakeClient(client)) return;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return;
    if (result != ConVarQuery_Okay) return;

    float interp = StringToFloat(cvarValue);

    // CS:S allows cl_interp 0; the engine derives an effective interpolation value.
    // Only reject values that are clearly invalid for a Source client cvar.
    if (interp >= 0.0 && interp <= 2.0) return;
    HandleInvalid(client, interp, "cl_interp is outside [0,2]");
}

void HandleInvalid(int client, float interp, const char[] reason)
{
    g_iDetections[client]++;
    if (g_bLogging)
        IS_LogAction(client, "interpolation anomaly: %s (cl_interp=%.4f detections=%i)", reason, interp, g_iDetections[client]);
    IS_PrintAdminNotice("{orange}[INTERP]{default} %N has invalid interpolation setting ({orange}%.4f{default})", client, interp);

    if (g_iDetections[client] >= 2 && g_bBan)
    {
        IS_BanClient(client, "Invalid client interpolation settings");
        g_iDetections[client] = 0;
    }
    else if (g_iDetections[client] >= 2 && g_bKick && !g_bBan)
    {
        KickClient(client, "[AntiCheat] Invalid interpolation settings");
        g_iDetections[client] = 0;
    }
}

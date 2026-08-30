/*
    Iron Sentinel AntiCheat - Spinhack Detector
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Обнаруживает спинхак
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Spinhack Detector",
    author = "Maxim Melnikov",
    description = "Обнаруживает спинхак",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  КОНСТАНТЫ
// ===========================

#define SPIN_DETECTIONS 15
#define SPIN_ANGLE_CHANGE 1440.0
#define SPIN_SENSITIVITY 6

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarBan;
ConVar g_hCvarKick;
ConVar g_hCvarLogging;
ConVar g_hCvarSensitivity;

bool g_bBan;
bool g_bKick;
bool g_bLogging;
float g_fSensitivity;

float g_fPrevAngle[MAXPLAYERS+1];
float g_fAngleDiff[MAXPLAYERS+1];
int g_iSpinCount[MAXPLAYERS+1];

// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    // ===== КОНФИГИ (ПЕРЕМЕННЫЕ ИЗ ЯДРА) =====
    g_hCvarBan = FindConVar("is_spinhack_ban");
    g_hCvarKick = FindConVar("is_spinhack_kick");
    g_hCvarLogging = FindConVar("is_spinhack_logging");
    g_hCvarSensitivity = FindConVar("is_spinhack_sensitivity");
    
    if (g_hCvarBan == null)
    {
        g_hCvarBan = CreateConVar("is_spinhack_ban", "0", "Банить за спинхак (0 = выкл)", 0, true, 0.0, true, 1.0);
    }
    if (g_hCvarKick == null)
    {
        g_hCvarKick = CreateConVar("is_spinhack_kick", "0", "Кикать за спинхак", 0, true, 0.0, true, 1.0);
    }
    if (g_hCvarLogging == null)
    {
        g_hCvarLogging = CreateConVar("is_spinhack_logging", "1", "Логировать спинхак", 0, true, 0.0, true, 1.0);
    }
    if (g_hCvarSensitivity == null)
    {
        g_hCvarSensitivity = CreateConVar("is_spinhack_sensitivity", "1.0", "Чувствительность детектора (0.5-2.0)", 0, true, 0.5, true, 2.0);
    }
    
    g_hCvarBan.AddChangeHook(OnSettingsChanged);
    g_hCvarKick.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarSensitivity.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
    
    CreateTimer(1.0, Timer_CheckSpins, _, TIMER_REPEAT);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bBan = g_hCvarBan.BoolValue;
    g_bKick = g_hCvarKick.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
    g_fSensitivity = g_hCvarSensitivity.FloatValue;
}

public void OnClientDisconnect(int client)
{
    g_iSpinCount[client] = 0;
    g_fAngleDiff[client] = 0.0;
    g_fPrevAngle[client] = 0.0;
}

public Action Timer_CheckSpins(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i))
        {
            continue;
        }
        
        if (CheckCommandAccess(i, "is_immunity", ADMFLAG_CUSTOM1, true))
        {
            continue;
        }
        
        if (g_fAngleDiff[i] > SPIN_ANGLE_CHANGE * g_fSensitivity && IsPlayerAlive(i))
        {
            g_iSpinCount[i]++;
            
            if (g_iSpinCount[i] >= RoundToNearest(SPIN_DETECTIONS / g_fSensitivity))
            {
                Spinhack_Detected(i);
                g_iSpinCount[i] = 0;
            }
        }
        else
        {
            g_iSpinCount[i] = 0;
        }
        
        g_fAngleDiff[i] = 0.0;
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
    
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
    {
        return Plugin_Continue;
    }
    
    // Проверяем только если игрок не нажимает кнопки поворота
    if (!(buttons & IN_LEFT || buttons & IN_RIGHT))
    {
        float fAngle = FloatAbs(angles[1] - g_fPrevAngle[client]);
        
        // Корректируем для перехода через 360°
        if (fAngle > 180.0)
        {
            fAngle = 360.0 - fAngle;
        }
        
        g_fAngleDiff[client] += fAngle;
        g_fPrevAngle[client] = angles[1];
    }
    
    return Plugin_Continue;
}

void Spinhack_Detected(int client)
{
    if (g_bLogging)
    {
        IS_LogAction(client, "spinhack detected (angle diff: %.1f°)", g_fAngleDiff[client]);
    }
    
    IS_PrintAdminNotice("{red}[SPINHACK]{default} %N suspected of spinhack!", client);
    
    if (g_bBan)
    {
        IS_BanClient(client, "Spinhack detected");
    }
    else if (g_bKick)
    {
        KickClient(client, "[AntiCheat] Spinhack detected");
    }
    
    g_iSpinCount[client] = 0;
    g_fAngleDiff[client] = 0.0;
}
/*
    Iron Sentinel AntiCheat - Angle-Cheats Patch
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Исправляет Angle-Cheats (невалидные углы)
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Angle-Cheats Patch",
    author = "Maxim Melnikov",
    description = "Исправляет Angle-Cheats",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  КОНСТАНТЫ
// ===========================

#define ANGLE_FIX_DETECTIONS 3

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarEnabled;
ConVar g_hCvarFixMode;
ConVar g_hCvarLogging;

bool g_bEnabled;
int g_iFixMode; // 0 = log, 1 = fix, 2 = kick
bool g_bLogging;

int g_iAngleViolations[MAXPLAYERS+1];
bool g_bIsFixed[MAXPLAYERS+1];

// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    g_hCvarEnabled = FindConVar("is_anglepatch_enabled");
    g_hCvarFixMode = FindConVar("is_anglepatch_mode");
    g_hCvarLogging = FindConVar("is_anglepatch_logging");
    
    if (g_hCvarEnabled == null)
        g_hCvarEnabled = CreateConVar("is_anglepatch_enabled", "1", "Enable angle-cheats patch", 0, true, 0.0, true, 1.0);
    if (g_hCvarFixMode == null)
        g_hCvarFixMode = CreateConVar("is_anglepatch_mode", "1", "Mode: 0=log, 1=fix, 2=kick", 0, true, 0.0, true, 2.0);
    if (g_hCvarLogging == null)
        g_hCvarLogging = CreateConVar("is_anglepatch_logging", "1", "Log angle-cheats", 0, true, 0.0, true, 1.0);
    
    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarFixMode.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_iFixMode = g_hCvarFixMode.IntValue;
    g_bLogging = g_hCvarLogging.BoolValue;
}

public void OnClientDisconnect(int client)
{
    g_iAngleViolations[client] = 0;
    g_bIsFixed[client] = false;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3],
    int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!g_bEnabled || !IS_CLIENT(client) || IsFakeClient(client) || !IsPlayerAlive(client))
        return Plugin_Continue;
    
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
        return Plugin_Continue;
    
    // Проверяем углы
    bool bInvalid = false;
    char sReason[64];
    
    // Pitch должен быть в пределах ±90°
    if (angles[0] > 90.0 || angles[0] < -90.0)
    {
        bInvalid = true;
        FormatEx(sReason, sizeof(sReason), "invalid pitch: %.1f°", angles[0]);
    }
    // Yaw должен быть в пределах ±180°
    else if (angles[1] > 180.0 || angles[1] < -180.0)
    {
        bInvalid = true;
        FormatEx(sReason, sizeof(sReason), "invalid yaw: %.1f°", angles[1]);
    }
    // Roll должен быть 0 (в CSS)
    else if (angles[2] != 0.0)
    {
        bInvalid = true;
        FormatEx(sReason, sizeof(sReason), "invalid roll: %.1f°", angles[2]);
    }
    
    if (bInvalid)
    {
        g_iAngleViolations[client]++;
        
        if (g_bLogging && !g_bIsFixed[client])
        {
            IS_LogAction(client, "angle-cheat: %s (violations: %i)", sReason, g_iAngleViolations[client]);
        }
        
        if (!g_bIsFixed[client])
        {
            IS_PrintAdminNotice("{red}[ANGLE-CHEAT]{default} %N suspected: %s", client, sReason);
            g_bIsFixed[client] = true;
        }
        
        switch (g_iFixMode)
        {
            case 1: // Исправляем углы
            {
                // Исправляем pitch
                if (angles[0] > 90.0) angles[0] = 90.0;
                else if (angles[0] < -90.0) angles[0] = -90.0;
                
                // Исправляем yaw
                if (angles[1] > 180.0) angles[1] = 180.0;
                else if (angles[1] < -180.0) angles[1] = -180.0;
                
                // Исправляем roll
                angles[2] = 0.0;
            }
            case 2: // Кикаем
            {
                if (g_iAngleViolations[client] >= ANGLE_FIX_DETECTIONS)
                {
                    KickClient(client, "[AntiCheat] Angle-cheat detected");
                    g_iAngleViolations[client] = 0;
                    g_bIsFixed[client] = false;
                }
            }
        }
    }
    else
    {
        if (g_iAngleViolations[client] > 0 && g_iFixMode != 2)
        {
            g_iAngleViolations[client] = 0;
            g_bIsFixed[client] = false;
        }
    }
    
    return Plugin_Continue;
}
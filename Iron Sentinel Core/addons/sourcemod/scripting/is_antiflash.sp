/*
    Iron Sentinel AntiCheat - Anti-Flash Blocker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Восстанавливает нормальный flash state и ограничивает transmit только на время эффекта.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Anti-Flash Blocker",
    author = "Maxim Melnikov",
    description = "Стабильная серверная защита от anti-flash обходов",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

ConVar g_hCvarEnabled;
ConVar g_hCvarLogging;
ConVar g_hCvarMode;
bool g_bEnabled;
bool g_bLogging;
int g_iMode;
bool g_bFlashHooked;
float g_fFlashedUntil[MAXPLAYERS+1];
Handle g_hFlashTimer = INVALID_HANDLE;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    if (GetEngineVersion() != Engine_CSS)
    {
        strcopy(error, err_max, "Этот модуль работает только для CS:S");
        return APLRes_SilentFailure;
    }
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_hCvarEnabled = FindConVar("is_antiflash_enabled");
    g_hCvarLogging = FindConVar("is_antiflash_logging");
    g_hCvarMode = FindConVar("is_antiflash_mode");
    if (g_hCvarEnabled == null) g_hCvarEnabled = CreateConVar("is_antiflash_enabled", "1", "Включить anti-flash block", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_antiflash_logging", "1", "Логировать anti-flash события", 0, true, 0.0, true, 1.0);
    if (g_hCvarMode == null) g_hCvarMode = CreateConVar("is_antiflash_mode", "0", "0 = passive, 1 = enforce normal flash", 0, true, 0.0, true, 1.0);

    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarMode.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
    HookEvent("player_blind", Event_PlayerBlind, EventHookMode_Post);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
    g_iMode = g_hCvarMode.IntValue;
    if (!g_bEnabled || g_iMode == 0) AntiFlash_UnhookAll();
}

public void OnClientPutInServer(int client)
{
    g_fFlashedUntil[client] = 0.0;
    if (g_bEnabled && g_bFlashHooked) SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
}

public void OnClientDisconnect(int client)
{
    g_fFlashedUntil[client] = 0.0;
}

public Action Event_PlayerBlind(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled) return Plugin_Continue;
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (!IS_CLIENT(client) || !IsClientInGame(client) || IsFakeClient(client)) return Plugin_Continue;
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true)) return Plugin_Continue;

    float alpha = GetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha");
    float duration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
    if (duration <= 0.0) return Plugin_Continue;

    if (alpha < 254.0)
    {
        if (g_bLogging)
            IS_LogAction(client, "anti-flash anomaly: alpha=%.0f duration=%.2f", alpha, duration);
        IS_PrintAdminNotice("{orange}[ANTI-FLASH]{default} %N reported abnormal flash alpha %.0f", client, alpha);

        if (g_iMode == 1)
        {
            SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 255.0);
        }
    }

    if (g_iMode == 1)
    {
        // Let the game drive actual duration; only constrain entity transmit for the real flash window.
        g_fFlashedUntil[client] = GetGameTime() + duration;
        if (!g_bFlashHooked) AntiFlash_HookAll();
    }
    return Plugin_Continue;
}

public Action Timer_FlashEnded(Handle timer)
{
    g_hFlashTimer = INVALID_HANDLE;
    float now = GetGameTime();
    bool active = false;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (g_fFlashedUntil[i] > now) { active = true; break; }
        g_fFlashedUntil[i] = 0.0;
    }
    if (!active) AntiFlash_UnhookAll();
    return Plugin_Stop;
}

public Action Hook_SetTransmit(int entity, int client)
{
    if (!g_bEnabled || g_iMode == 0 || !IS_CLIENT(client) || entity == client || entity < 1 || entity > MaxClients)
        return Plugin_Continue;
    if (!IsClientInGame(client) || !IsPlayerAlive(client) || !IsClientInGame(entity)) return Plugin_Continue;

    float now = GetGameTime();
    if (g_fFlashedUntil[client] > now)
        return Plugin_Handled;

    g_fFlashedUntil[client] = 0.0;
    return Plugin_Continue;
}

void AntiFlash_HookAll()
{
    if (g_bFlashHooked) return;
    g_bFlashHooked = true;
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i)) SDKHook(i, SDKHook_SetTransmit, Hook_SetTransmit);

    if (g_hFlashTimer == INVALID_HANDLE)
        g_hFlashTimer = CreateTimer(0.25, Timer_FlashEnded, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

void AntiFlash_UnhookAll()
{
    g_bFlashHooked = false;
    if (g_hFlashTimer != INVALID_HANDLE)
    {
        KillTimer(g_hFlashTimer);
        g_hFlashTimer = INVALID_HANDLE;
    }
    for (int i = 1; i <= MaxClients; i++)
    {
        g_fFlashedUntil[i] = 0.0;
        if (IsClientInGame(i)) SDKUnhook(i, SDKHook_SetTransmit, Hook_SetTransmit);
    }
}


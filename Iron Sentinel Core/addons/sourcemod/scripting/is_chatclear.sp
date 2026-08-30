/*
    Iron Sentinel AntiCheat - Chat-Clear Blocker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Блокирует очистку чата
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Chat-Clear Blocker",
    author = "Maxim Melnikov",
    description = "Блокирует очистку чата",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarEnabled;
ConVar g_hCvarLogging;

bool g_bEnabled;
bool g_bLogging;

// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    g_hCvarEnabled = FindConVar("is_chatclear_enabled");
    g_hCvarLogging = FindConVar("is_chatclear_logging");
    
    if (g_hCvarEnabled == null)
        g_hCvarEnabled = CreateConVar("is_chatclear_enabled", "1", "Enable chat-clear blocking", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null)
        g_hCvarLogging = CreateConVar("is_chatclear_logging", "1", "Log chat-clear", 0, true, 0.0, true, 1.0);
    
    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
    
    AddCommandListener(Command_Clear, "clear");
    AddCommandListener(Command_Clear, "clear_console");
    AddCommandListener(Command_Clear, "cls");
    AddCommandListener(Command_Clear, "clear_console_ts");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_bLogging = g_hCvarLogging.BoolValue;
}

public Action Command_Clear(int client, const char[] command, int argc)
{
    if (!g_bEnabled || client == 0 || IsFakeClient(client))
        return Plugin_Continue;
    
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
        return Plugin_Continue;
    
    if (g_bLogging)
    {
        IS_LogAction(client, "attempted to clear console/chat: %s", command);
    }
    
    IS_PrintAdminNotice("{red}[CHAT-CLEAR]{default} %N attempted to clear chat/console!", client);
    
    // Блокируем только если это не админ
    if (!CheckCommandAccess(client, "is_admin", ADMFLAG_GENERIC, true))
    {
        PrintToChat(client, "[AntiCheat] Chat-clear is blocked!");
        return Plugin_Stop;
    }
    
    return Plugin_Continue;
}
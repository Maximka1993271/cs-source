/*
    Iron Sentinel AntiCheat - AntiSpam
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Защита от спама подключениями, сменой ника и команд
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel AntiSpam",
    author = "Maxim Melnikov",
    description = "Защита от спама подключениями и сменой ника",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarConnectSpam;
ConVar g_hCvarNameChangeLimit;
ConVar g_hCvarTeamChangeLimit;
ConVar g_hCvarAutoKick;
ConVar g_hCvarLogEnabled;

int g_iNameChanges[MAXPLAYERS+1];
float g_fLastNameChange[MAXPLAYERS+1];
int g_iTeamChanges[MAXPLAYERS+1];
float g_fLastTeamChange[MAXPLAYERS+1];

StringMap g_hConnectHistory;
StringMap g_hTransitionIPs;
float g_fConnectBlockTime;

// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    // ===== КОНФИГИ (ПЕРЕМЕННЫЕ ИЗ ЯДРА) =====
    g_hCvarConnectSpam = FindConVar("is_antispam_connect_time");
    g_hCvarNameChangeLimit = FindConVar("is_antispam_name_limit");
    g_hCvarTeamChangeLimit = FindConVar("is_antispam_team_limit");
    g_hCvarAutoKick = FindConVar("is_antispam_autokick");
    g_hCvarLogEnabled = FindConVar("is_antispam_logging");
    
    if (g_hCvarConnectSpam == null)
    {
        g_hCvarConnectSpam = CreateConVar("is_antispam_connect_time", "15.0", "Время блокировки за спам подключениями (секунд, 0 = выкл)", 0, true, 0.0, true, 60.0);
    }
    if (g_hCvarNameChangeLimit == null)
    {
        g_hCvarNameChangeLimit = CreateConVar("is_antispam_name_limit", "3", "Максимум смен ника за раунд", 0, true, 0.0, true, 10.0);
    }
    if (g_hCvarTeamChangeLimit == null)
    {
        g_hCvarTeamChangeLimit = CreateConVar("is_antispam_team_limit", "3", "Максимум смен команд за раунд", 0, true, 0.0, true, 10.0);
    }
    if (g_hCvarAutoKick == null)
    {
        g_hCvarAutoKick = CreateConVar("is_antispam_autokick", "0", "Кикать за спам", 0, true, 0.0, true, 1.0);
    }
    if (g_hCvarLogEnabled == null)
    {
        g_hCvarLogEnabled = CreateConVar("is_antispam_logging", "1", "Логировать спам", 0, true, 0.0, true, 1.0);
    }
    
    g_hCvarConnectSpam.AddChangeHook(OnSettingsChanged);
    g_hCvarNameChangeLimit.AddChangeHook(OnSettingsChanged);
    g_hCvarTeamChangeLimit.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
    
    g_hConnectHistory = new StringMap();
    g_hTransitionIPs = new StringMap();
    
    HookEvent("player_changename", Event_PlayerChangeName, EventHookMode_Post);
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    
    RegAdminCmd("is_antispam_reset", Command_ResetPlayer, ADMFLAG_GENERIC, "Reset anti-spam counters for a player");
    
    // ===== СОЗДАЁМ КОНФИГ =====
    // AutoExecConfig(true, "is_antispam");  // ← УДАЛЕНО
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_fConnectBlockTime = g_hCvarConnectSpam.FloatValue;
}

// Without these, a client slot reused by a new player mid-map would carry over the
// previous occupant's name/team-change counts and timestamps, letting the new player
// get kicked for spam accumulated by someone else.
public void OnClientPutInServer(int client)
{
    g_iNameChanges[client] = 0;
    g_fLastNameChange[client] = 0.0;
    g_iTeamChanges[client] = 0;
    g_fLastTeamChange[client] = 0.0;
}

public void OnClientDisconnect(int client)
{
    g_iNameChanges[client] = 0;
    g_fLastNameChange[client] = 0.0;
    g_iTeamChanges[client] = 0;
    g_fLastTeamChange[client] = 0.0;
}

// SourceMod re-fires the full connect sequence (OnClientConnect -> ... ->
// OnClientPutInServer) for every still-connected player at every map change, exactly
// as if they were connecting fresh. Without this snapshot, the connect-spam check in
// OnClientConnect() below cannot tell that apart from an actual new incoming
// connection, so every legitimate player would be flagged as reconnect spam on every
// single map change. This only records who was legitimately in-game -- it does not
// touch g_hConnectHistory, so a genuine rapid-reconnect spammer within the same map is
// still caught exactly as before.
public void OnMapEnd()
{
    g_hTransitionIPs.Clear();
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i))
        {
            char sIP[64];
            GetClientIP(i, sIP, sizeof(sIP));
            g_hTransitionIPs.SetValue(sIP, true);
        }
    }
}

// ===========================
//  БЛОКИРОВКА ПОДКЛЮЧЕНИЙ
// ===========================

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen)
{
    if (IsFakeClient(client))
    {
        return true;
    }

    char sIP[64];
    GetClientIP(client, sIP, sizeof(sIP));

    bool bDummy;
    bool bIsMapTransition = g_hTransitionIPs.GetValue(sIP, bDummy);

    if (g_fConnectBlockTime > 0.0 && !bIsMapTransition)
    {
        float fLastConnect;
        if (g_hConnectHistory.GetValue(sIP, fLastConnect))
        {
            float fTimeLeft = fLastConnect + g_fConnectBlockTime - GetTickedTime();
            if (fTimeLeft > 0.0)
            {
                FormatEx(rejectmsg, maxlen, "[AntiCheat] Please wait %.0f seconds before reconnecting.", fTimeLeft);
                
                if (g_hCvarLogEnabled.BoolValue)
                {
                    IS_LogAction(client, "blocked for connection spam (IP: %s)", sIP);
                }
                
                return false;
            }
        }
    }
    
    if (g_fConnectBlockTime > 0.0)
    {
        g_hConnectHistory.SetValue(sIP, GetTickedTime(), true);
        
        static int iCleanupCounter = 0;
        if (++iCleanupCounter > 100)
        {
            CleanupConnectHistory();
            iCleanupCounter = 0;
        }
    }
    
    return true;
}

void CleanupConnectHistory()
{
    float fCutoff = GetTickedTime() - 60.0;
    
    StringMapSnapshot snapshot = g_hConnectHistory.Snapshot();
    for (int i = 0; i < snapshot.Length; i++)
    {
        char sKey[32];
        snapshot.GetKey(i, sKey, sizeof(sKey));
        
        float fTime;
        if (g_hConnectHistory.GetValue(sKey, fTime) && fTime < fCutoff)
        {
            g_hConnectHistory.Remove(sKey);
        }
    }
    delete snapshot;
}

// ===========================
//  КОНТРОЛЬ СМЕНЫ НИКА
// ===========================

public Action Event_PlayerChangeName(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }
    
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
    {
        return Plugin_Continue;
    }
    
    int iLimit = g_hCvarNameChangeLimit.IntValue;
    if (iLimit > 0)
    {
        float fGameTime = GetTickedTime();
        
        if (fGameTime - g_fLastNameChange[client] > 30.0)
        {
            g_iNameChanges[client] = 0;
        }
        
        g_iNameChanges[client]++;
        g_fLastNameChange[client] = fGameTime;
        
        if (g_iNameChanges[client] > iLimit)
        {
            if (g_hCvarLogEnabled.BoolValue)
            {
                IS_LogAction(client, "name change spam (%i times)", g_iNameChanges[client]);
            }
            
            IS_PrintAdminNotice("{red}[SPAM]{default} %N is spamming name changes!", client);
            
            if (g_hCvarAutoKick.BoolValue)
            {
                KickClient(client, "[AntiCheat] Name change spam");
            }
            
            g_iNameChanges[client] = 0;
        }
    }
    
    return Plugin_Continue;
}

// ===========================
//  КОНТРОЛЬ СМЕНЫ КОМАНД
// ===========================

public Action Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsClientInGame(client))
    {
        return Plugin_Continue;
    }
    
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
    {
        return Plugin_Continue;
    }
    
    int iLimit = g_hCvarTeamChangeLimit.IntValue;
    if (iLimit > 0)
    {
        float fGameTime = GetTickedTime();
        
        if (fGameTime - g_fLastTeamChange[client] > 30.0)
        {
            g_iTeamChanges[client] = 0;
        }
        
        g_iTeamChanges[client]++;
        g_fLastTeamChange[client] = fGameTime;
        
        if (g_iTeamChanges[client] > iLimit)
        {
            if (g_hCvarLogEnabled.BoolValue)
            {
                IS_LogAction(client, "team change spam (%i times)", g_iTeamChanges[client]);
            }
            
            IS_PrintAdminNotice("{red}[SPAM]{default} %N is spamming team changes!", client);
            
            if (g_hCvarAutoKick.BoolValue)
            {
                KickClient(client, "[AntiCheat] Team change spam");
            }
            
            g_iTeamChanges[client] = 0;
        }
    }
    
    return Plugin_Continue;
}

// ===========================
//  СБРОС СЧЁТЧИКОВ
// ===========================

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i))
        {
            g_iNameChanges[i] = 0;
            g_iTeamChanges[i] = 0;
        }
    }
    
    return Plugin_Continue;
}

// ===========================
//  КОМАНДЫ АДМИНА
// ===========================

public Action Command_ResetPlayer(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "Usage: is_antispam_reset <#userid|name>");
        return Plugin_Handled;
    }
    
    char sTarget[64];
    GetCmdArg(1, sTarget, sizeof(sTarget));
    
    int target = FindTarget(client, sTarget, true, false);
    
    if (target == -1)
    {
        return Plugin_Handled;
    }
    
    g_iNameChanges[target] = 0;
    g_iTeamChanges[target] = 0;
    g_fLastNameChange[target] = 0.0;
    g_fLastTeamChange[target] = 0.0;
    
    ReplyToCommand(client, "[AntiCheat] Spam counters reset for %N.", target);
    
    return Plugin_Handled;
}
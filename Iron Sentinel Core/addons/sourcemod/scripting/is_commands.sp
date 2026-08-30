/*
    Iron Sentinel AntiCheat - Command Blocker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Блокирует опасные команды на сервере без глобального false-positive rate limit.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Command Blocker",
    author = "Maxim Melnikov",
    description = "Блокирует опасные серверные команды",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

ConVar g_hCvarAutoKick;
ConVar g_hCvarAutoBan;
ConVar g_hCvarLogEnabled;

bool g_bAutoKick;
bool g_bAutoBan;
bool g_bLogEnabled;

StringMap g_hBlockedCommands;

public void OnPluginStart()
{
    g_hCvarAutoKick = FindConVar("is_cmd_autokick");
    g_hCvarAutoBan = FindConVar("is_cmd_autoban");
    g_hCvarLogEnabled = FindConVar("is_cmd_logging");

    if (g_hCvarAutoKick == null)
        g_hCvarAutoKick = CreateConVar("is_cmd_autokick", "0", "Кикать за опасные команды", 0, true, 0.0, true, 1.0);
    if (g_hCvarAutoBan == null)
        g_hCvarAutoBan = CreateConVar("is_cmd_autoban", "0", "Банить за опасные команды", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogEnabled == null)
        g_hCvarLogEnabled = CreateConVar("is_cmd_logging", "1", "Логировать опасные команды", 0, true, 0.0, true, 1.0);

    g_hCvarAutoKick.AddChangeHook(OnSettingsChanged);
    g_hCvarAutoBan.AddChangeHook(OnSettingsChanged);
    g_hCvarLogEnabled.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");

    g_hBlockedCommands = new StringMap();
    LoadBlockedCommands();
    static const char commands[][] =
    {
        "ent_create", "ent_fire", "give", "changelevel", "changelevel2",
        "rcon", "rcon_address", "rcon_password", "dump_entity_sizes", "dump_panels",
        "dumpcountedstrings", "dumpentityfactories", "dumpeventqueue", "dumpgamestringtable",
        "sv_cheats", "sv_gravity", "sv_friction", "sv_accelerate", "sv_airaccelerate",
        "dbghist_addline", "dbghist_dump", "drawcross", "drawline", "endround", "mem_dump",
        "physics_budget", "physics_debug_entity", "physics_select", "report_entities",
        "respawn_entities", "speed.toggle", "mp_forcecamera", "mp_restartgame"
    };
    for (int i = 0; i < sizeof(commands); i++)
        AddCommandListener(Command_Listener, commands[i]);
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    g_bAutoKick = g_hCvarAutoKick.BoolValue;
    g_bAutoBan = g_hCvarAutoBan.BoolValue;
    g_bLogEnabled = g_hCvarLogEnabled.BoolValue;
}

void LoadBlockedCommands()
{
    // Entity/debug/server-control commands.
    static const char commands[][] =
    {
        "ent_create", "ent_fire", "give", "changelevel", "changelevel2",
        "rcon", "rcon_address", "rcon_password",
        "dump_entity_sizes", "dump_panels", "dumpcountedstrings", "dumpentityfactories",
        "dumpeventqueue", "dumpgamestringtable", "sv_cheats", "sv_gravity",
        "sv_friction", "sv_accelerate", "sv_airaccelerate", "dbghist_addline",
        "dbghist_dump", "drawcross", "drawline", "endround", "mem_dump",
        "physics_budget", "physics_debug_entity", "physics_select", "report_entities",
        "respawn_entities", "speed.toggle", "mp_forcecamera", "mp_restartgame"
    };

    for (int i = 0; i < sizeof(commands); i++)
    {
        g_hBlockedCommands.SetValue(commands[i], 1);
    }
}

public Action Command_Listener(int client, const char[] command, int argc)
{
    if (!IS_CLIENT(client) || IsFakeClient(client) || !IsClientInGame(client))
        return Plugin_Continue;

    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
        return Plugin_Continue;

    int dummy;
    if (!g_hBlockedCommands.GetValue(command, dummy))
        return Plugin_Continue;

    HandleCommandViolation(client, command, argc);
    return Plugin_Stop;
}

void HandleCommandViolation(int client, const char[] command, int argc)
{
    char sArgs[192] = "";
    if (argc > 0)
        GetCmdArgString(sArgs, sizeof(sArgs));

    if (g_bLogEnabled)
        IS_LogAction(client, "blocked command: %s %s", command, sArgs);

    IS_PrintAdminNotice("{red}[BLOCK]{default} %N tried to use: {orange}%s{default} %s", client, command, sArgs);

    if (g_bAutoBan)
    {
        IS_BanClient(client, "Blocked command used");
    }
    else if (g_bAutoKick)
    {
        KickClient(client, "[IS] Blocked command: %s", command);
    }
    else
    {
        PrintToChat(client, "{red}[IS]{default} Command {orange}%s{default} is blocked!", command);
    }
}

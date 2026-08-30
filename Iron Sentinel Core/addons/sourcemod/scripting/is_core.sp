/*
    Iron Sentinel AntiCheat - Core
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Ядро системы защиты Iron Sentinel
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <multicolors>

// ===========================
//  МАКРОСЫ
// ===========================

#define IS_CLIENT(%1) ((%1) >= 1 && (%1) <= MaxClients)
#define IS_VALID_CLIENT(%1) ((%1) >= 1 && (%1) <= MaxClients && IsClientConnected(%1))

public Plugin myinfo =
{
    name = "Iron Sentinel Core",
    author = "Maxim Melnikov",
    description = "Iron Sentinel AntiCheat Core",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

// --- ЯДРО ---
ConVar g_hCvarVersion;
ConVar g_hCvarBanDuration;
ConVar g_hCvarLogging;
ConVar g_hCvarWelcomeMsg;

// --- КОМАНДЫ ---
ConVar g_hCvarCmdAutokick;
ConVar g_hCvarCmdAutoban;
ConVar g_hCvarCmdLogging;

// --- НАСТРОЙКИ (CVARS) ---
ConVar g_hCvarCvarsAutokick;
ConVar g_hCvarCvarsAutoban;
ConVar g_hCvarCvarsCheckInterval;
ConVar g_hCvarCvarsLogging;

// --- АНТИ-СПАМ ---
ConVar g_hCvarAntispamAutokick;
ConVar g_hCvarAntispamConnectTime;
ConVar g_hCvarAntispamNameLimit;
ConVar g_hCvarAntispamTeamLimit;
ConVar g_hCvarAntispamLogging;

// --- СПИДХАК ---
ConVar g_hCvarSpeedAutokick;
ConVar g_hCvarSpeedDetections;
ConVar g_hCvarSpeedMax;
ConVar g_hCvarSpeedMultiplier;
ConVar g_hCvarSpeedCheckInterval;
ConVar g_hCvarSpeedLogging;

// --- АИМБОТ ---
ConVar g_hCvarAimbotBan;
ConVar g_hCvarAimbotKick;
ConVar g_hCvarAimbotSensitivity;
ConVar g_hCvarAimbotLogging;

// --- ВОЛЛХАК ---
ConVar g_hCvarWallhackEnabled;
ConVar g_hCvarWallhackMode;
ConVar g_hCvarWallhackMaxTraces;

// --- УГЛЫ ---
ConVar g_hCvarEyetestAutoban;
ConVar g_hCvarEyetestAutokick;
ConVar g_hCvarEyetestSensitivity;
ConVar g_hCvarEyetestLogging;

// --- АВТО-ТРИГГЕР ---
ConVar g_hCvarAutotriggerBan;
ConVar g_hCvarAutotriggerKick;
ConVar g_hCvarAutotriggerLogging;
ConVar g_hCvarAutotriggerSensitivity;

// --- СПИНХАК ---
ConVar g_hCvarSpinhackBan;
ConVar g_hCvarSpinhackKick;
ConVar g_hCvarSpinhackLogging;
ConVar g_hCvarSpinhackSensitivity;

// --- АНТИ-ФЛЕШ ---
ConVar g_hCvarAntiflashEnabled;
ConVar g_hCvarAntiflashMode;
ConVar g_hCvarAntiflashLogging;

// --- АНТИ-ДЫМ ---
ConVar g_hCvarAntismokeEnabled;
ConVar g_hCvarAntismokeMode;
ConVar g_hCvarAntismokeLogging;
ConVar g_hCvarAntismokeRadius;

// --- RCON ЗАЩИТА ---
ConVar g_hCvarRconLocked;
ConVar g_hCvarRconLogging;
ConVar g_hCvarRconMaxAttempts;
ConVar g_hCvarRconBanTime;
ConVar g_hCvarRconWhitelistEnabled;

// --- GLOBAL BANLISTS ---
ConVar g_hCvarBanlistEacEnabled;
ConVar g_hCvarBanlistEacKick;
ConVar g_hCvarBanlistEseaEnabled;
ConVar g_hCvarBanlistEseaKick;
ConVar g_hCvarBanlistLogging;

// --- AIMLOCK ---
ConVar g_hCvarAimlockBan;
ConVar g_hCvarAimlockKick;
ConVar g_hCvarAimlockLogging;
ConVar g_hCvarAimlockSensitivity;

// --- MACRO ---
ConVar g_hCvarMacroBan;
ConVar g_hCvarMacroKick;
ConVar g_hCvarMacroLogging;
ConVar g_hCvarMacroSensitivity;

// --- NOLERP ---
ConVar g_hCvarNolerpBan;
ConVar g_hCvarNolerpKick;
ConVar g_hCvarNolerpLogging;

// --- BACKTRACK ---
ConVar g_hCvarBacktrackEnabled;
ConVar g_hCvarBacktrackLogging;

// --- PING ---
ConVar g_hCvarPingMax;
ConVar g_hCvarPingKick;
ConVar g_hCvarPingLogging;

// --- CHAT-CLEAR ---
ConVar g_hCvarChatclearEnabled;
ConVar g_hCvarChatclearLogging;

// --- ANGLE PATCH ---
ConVar g_hCvarAnglepatchEnabled;
ConVar g_hCvarAnglepatchMode;
ConVar g_hCvarAnglepatchLogging;

// --- DLL ---
ConVar g_hCvarDllEnabled;
ConVar g_hCvarDllKick;
ConVar g_hCvarDllBan;
ConVar g_hCvarDllLogging;
ConVar g_hCvarDllAction;

// --- DATABASE ---
ConVar g_hCvarDatabaseEnabled;
ConVar g_hCvarDatabaseName;

char g_sLogPath[PLATFORM_MAX_PATH];
GlobalForward g_hForwardDetection;
bool g_bLateLoad = false;
bool g_bLoggingEnabled = true;


// ===========================
//  ЗАГРУЗКА ПЛАГИНА
// ===========================

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    g_bLateLoad = late;
    
    RegPluginLibrary("is_core");
    
    CreateNative("IS_BanClient", Native_BanClient);
    CreateNative("IS_LogAction", Native_LogAction);
    CreateNative("IS_PrintAdminNotice", Native_PrintAdminNotice);
    CreateNative("IS_CheatDetected", Native_CheatDetected);
    CreateNative("IS_GetBanDuration", Native_GetBanDuration);
    CreateNative("IS_IsLoggingEnabled", Native_IsLoggingEnabled);
    
    return APLRes_Success;
}

public void OnPluginStart()
{
    LoadTranslations("is.phrases");
    
    // ============================================================
    //  1. CORE SETTINGS
    // ============================================================
    
    g_hCvarVersion = CreateConVar("is_version", "1.1.2", "Iron Sentinel AntiCheat Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
    g_hCvarVersion.AddChangeHook(OnVersionChanged);
    
    g_hCvarBanDuration = CreateConVar("is_ban_duration", "0", "Ban duration in minutes (0 = permanent)", 0, true, 0.0);
    g_hCvarLogging = CreateConVar("is_logging", "1", "Enable logging", 0, true, 0.0, true, 1.0);
    g_hCvarLogging.AddChangeHook(OnLoggingChanged);
    g_bLoggingEnabled = g_hCvarLogging.BoolValue;
    g_hCvarWelcomeMsg = CreateConVar("is_welcomemsg", "1", "Show welcome message", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  2. COMMAND BLOCKER
    // ============================================================
    
    g_hCvarCmdAutokick = CreateConVar("is_cmd_autokick", "0", "Kick for dangerous commands", 0, true, 0.0, true, 1.0);
    g_hCvarCmdAutoban = CreateConVar("is_cmd_autoban", "0", "Ban for dangerous commands", 0, true, 0.0, true, 1.0);
    g_hCvarCmdLogging = CreateConVar("is_cmd_logging", "1", "Log dangerous commands", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  3. CVAR CHECKER
    // ============================================================
    
    g_hCvarCvarsAutokick = CreateConVar("is_cvars_autokick", "0", "Kick for suspicious cvars", 0, true, 0.0, true, 1.0);
    g_hCvarCvarsAutoban = CreateConVar("is_cvars_autoban", "0", "Ban for suspicious cvars", 0, true, 0.0, true, 1.0);
    g_hCvarCvarsCheckInterval = CreateConVar("is_cvars_check_interval", "60.0", "Cvar check interval (seconds)", 0, true, 10.0, true, 120.0);
    g_hCvarCvarsLogging = CreateConVar("is_cvars_logging", "1", "Log suspicious cvars", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  4. ANTISPAM
    // ============================================================
    
    g_hCvarAntispamAutokick = CreateConVar("is_antispam_autokick", "0", "Kick for spam", 0, true, 0.0, true, 1.0);
    g_hCvarAntispamConnectTime = CreateConVar("is_antispam_connect_time", "15.0", "Connection spam block time (seconds, 0 = off)", 0, true, 0.0, true, 60.0);
    g_hCvarAntispamNameLimit = CreateConVar("is_antispam_name_limit", "3", "Max name changes per round", 0, true, 0.0, true, 10.0);
    g_hCvarAntispamTeamLimit = CreateConVar("is_antispam_team_limit", "3", "Max team changes per round", 0, true, 0.0, true, 10.0);
    g_hCvarAntispamLogging = CreateConVar("is_antispam_logging", "1", "Log spam", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  5. SPEEDHACK
    // ============================================================
    
    g_hCvarSpeedAutokick = CreateConVar("is_speed_autokick", "0", "Kick for speedhack", 0, true, 0.0, true, 1.0);
    g_hCvarSpeedDetections = CreateConVar("is_speed_detections", "4", "Detections before ban", 0, true, 1.0, true, 10.0);
    g_hCvarSpeedMax = CreateConVar("is_speed_max", "320.0", "Max player speed (units/sec)", 0, true, 100.0, true, 1000.0);
    g_hCvarSpeedMultiplier = CreateConVar("is_speed_multiplier", "1.5", "Speedhack detection multiplier", 0, true, 1.0, true, 5.0);
    g_hCvarSpeedCheckInterval = CreateConVar("is_speed_check_interval", "0.5", "Speed check interval (seconds)", 0, true, 0.1, true, 2.0);
    g_hCvarSpeedLogging = CreateConVar("is_speed_logging", "1", "Log speedhack", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  6. AIMBOT
    // ============================================================
    
    g_hCvarAimbotBan = CreateConVar("is_aimbot_ban", "4", "Detections before ban (0 = off, min 4)", 0, true, 0.0);
    g_hCvarAimbotKick = CreateConVar("is_aimbot_kick", "0", "Kick for aimbot", 0, true, 0.0, true, 1.0);
    g_hCvarAimbotSensitivity = CreateConVar("is_aimbot_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    g_hCvarAimbotLogging = CreateConVar("is_aimbot_logging", "1", "Log aimbot", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  7. WALLHACK
    // ============================================================
    
    g_hCvarWallhackEnabled = CreateConVar("is_wallhack_enabled", "1", "Enable wallhack blocking", 0, true, 0.0, true, 1.0);
    g_hCvarWallhackMode = CreateConVar("is_wallhack_mode", "0", "Mode: 0 = soft, 1 = aggressive", 0, true, 0.0, true, 1.0);
    g_hCvarWallhackMaxTraces = CreateConVar("is_wallhack_maxtraces", "192", "Max traces per tick", 0, true, 32.0, true, 1024.0);
    
    // ============================================================
    //  8. EYE TEST
    // ============================================================
    
    g_hCvarEyetestAutoban = CreateConVar("is_eyetest_autoban", "0", "Ban for angle violations", 0, true, 0.0, true, 1.0);
    g_hCvarEyetestAutokick = CreateConVar("is_eyetest_autokick", "0", "Kick for angle violations", 0, true, 0.0, true, 1.0);
    g_hCvarEyetestSensitivity = CreateConVar("is_eyetest_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    g_hCvarEyetestLogging = CreateConVar("is_eyetest_logging", "1", "Log angle violations", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  9. AUTO-TRIGGER
    // ============================================================
    
    g_hCvarAutotriggerBan = CreateConVar("is_autotrigger_ban", "0", "Ban for auto-trigger (0 = off)", 0, true, 0.0, true, 1.0);
    g_hCvarAutotriggerKick = CreateConVar("is_autotrigger_kick", "0", "Kick for auto-trigger", 0, true, 0.0, true, 1.0);
    g_hCvarAutotriggerLogging = CreateConVar("is_autotrigger_logging", "1", "Log auto-trigger", 0, true, 0.0, true, 1.0);
    g_hCvarAutotriggerSensitivity = CreateConVar("is_autotrigger_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    
    // ============================================================
    //  10. SPINHACK
    // ============================================================
    
    g_hCvarSpinhackBan = CreateConVar("is_spinhack_ban", "0", "Ban for spinhack (0 = off)", 0, true, 0.0, true, 1.0);
    g_hCvarSpinhackKick = CreateConVar("is_spinhack_kick", "0", "Kick for spinhack", 0, true, 0.0, true, 1.0);
    g_hCvarSpinhackLogging = CreateConVar("is_spinhack_logging", "1", "Log spinhack", 0, true, 0.0, true, 1.0);
    g_hCvarSpinhackSensitivity = CreateConVar("is_spinhack_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    
    // ============================================================
    //  11. ANTI-FLASH
    // ============================================================
    
    g_hCvarAntiflashEnabled = CreateConVar("is_antiflash_enabled", "1", "Enable anti-flash blocking", 0, true, 0.0, true, 1.0);
    g_hCvarAntiflashMode = CreateConVar("is_antiflash_mode", "0", "Mode: 0 = log, 1 = block", 0, true, 0.0, true, 1.0);
    g_hCvarAntiflashLogging = CreateConVar("is_antiflash_logging", "1", "Log anti-flash", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  12. ANTI-SMOKE
    // ============================================================
    
    g_hCvarAntismokeEnabled = CreateConVar("is_antismoke_enabled", "1", "Enable anti-smoke blocking", 0, true, 0.0, true, 1.0);
    g_hCvarAntismokeMode = CreateConVar("is_antismoke_mode", "1", "Mode: 0 = log, 1 = block", 0, true, 0.0, true, 1.0);
    g_hCvarAntismokeLogging = CreateConVar("is_antismoke_logging", "1", "Log anti-smoke", 0, true, 0.0, true, 1.0);
    g_hCvarAntismokeRadius = CreateConVar("is_antismoke_radius", "45.0", "Smoke check radius (units)", 0, true, 20.0, true, 80.0);
    
    // ============================================================
    //  13. RCON PROTECTION
    // ============================================================
    
    g_hCvarRconLocked = CreateConVar("is_rcon_locked", "1", "Lock rcon_password changes", 0, true, 0.0, true, 1.0);
    g_hCvarRconLogging = CreateConVar("is_rcon_logging", "1", "Log RCON attempts", 0, true, 0.0, true, 1.0);
    g_hCvarRconMaxAttempts = CreateConVar("is_rcon_max_attempts", "5", "Max failed attempts before ban", 0, true, 1.0, true, 20.0);
    g_hCvarRconBanTime = CreateConVar("is_rcon_ban_time", "60", "Ban time for failed attempts (minutes)", 0, true, 1.0, true, 1440.0);
    g_hCvarRconWhitelistEnabled = CreateConVar("is_rcon_whitelist_enabled", "0", "Enable RCON IP whitelist", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  14. GLOBAL BANLISTS
    // ============================================================
    
    g_hCvarBanlistEacEnabled = CreateConVar("is_banlist_eac_enabled", "0", "Enable EAC banlist check", 0, true, 0.0, true, 1.0);
    g_hCvarBanlistEacKick = CreateConVar("is_banlist_eac_kick", "0", "Kick players on EAC banlist", 0, true, 0.0, true, 1.0);
    g_hCvarBanlistEseaEnabled = CreateConVar("is_banlist_esea_enabled", "0", "Enable ESEA banlist check", 0, true, 0.0, true, 1.0);
    g_hCvarBanlistEseaKick = CreateConVar("is_banlist_esea_kick", "0", "Kick players on ESEA banlist", 0, true, 0.0, true, 1.0);
    g_hCvarBanlistLogging = CreateConVar("is_banlist_logging", "1", "Log global banlist checks", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  15. AIMLOCK
    // ============================================================
    
    g_hCvarAimlockBan = CreateConVar("is_aimlock_ban", "0", "Ban for aimlock (0 = off)", 0, true, 0.0, true, 1.0);
    g_hCvarAimlockKick = CreateConVar("is_aimlock_kick", "0", "Kick for aimlock", 0, true, 0.0, true, 1.0);
    g_hCvarAimlockLogging = CreateConVar("is_aimlock_logging", "1", "Log aimlock", 0, true, 0.0, true, 1.0);
    g_hCvarAimlockSensitivity = CreateConVar("is_aimlock_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    
    // ============================================================
    //  16. MACRO DETECTION
    // ============================================================
    
    g_hCvarMacroBan = CreateConVar("is_macro_ban", "0", "Ban for macros (0 = off)", 0, true, 0.0, true, 1.0);
    g_hCvarMacroKick = CreateConVar("is_macro_kick", "0", "Kick for macros", 0, true, 0.0, true, 1.0);
    g_hCvarMacroLogging = CreateConVar("is_macro_logging", "1", "Log macros", 0, true, 0.0, true, 1.0);
    g_hCvarMacroSensitivity = CreateConVar("is_macro_sensitivity", "1.0", "Detector sensitivity (0.5-2.0)", 0, true, 0.5, true, 2.0);
    
    // ============================================================
    //  17. NOLERP
    // ============================================================
    
    g_hCvarNolerpBan = CreateConVar("is_nolerp_ban", "0", "Ban for NoLerp (0 = off)", 0, true, 0.0, true, 1.0);
    g_hCvarNolerpKick = CreateConVar("is_nolerp_kick", "0", "Kick for NoLerp", 0, true, 0.0, true, 1.0);
    g_hCvarNolerpLogging = CreateConVar("is_nolerp_logging", "1", "Log NoLerp", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  18. BACKTRACK
    // ============================================================
    
    g_hCvarBacktrackEnabled = CreateConVar("is_backtrack_enabled", "1", "Enable backtrack patch", 0, true, 0.0, true, 1.0);
    g_hCvarBacktrackLogging = CreateConVar("is_backtrack_logging", "1", "Log backtrack", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  19. PING
    // ============================================================
    
    g_hCvarPingMax = CreateConVar("is_ping_max", "200", "Max allowed ping (ms)", 0, true, 50.0, true, 500.0);
    g_hCvarPingKick = CreateConVar("is_ping_kick", "0", "Kick for high ping", 0, true, 0.0, true, 1.0);
    g_hCvarPingLogging = CreateConVar("is_ping_logging", "1", "Log high ping", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  20. CHAT-CLEAR
    // ============================================================
    
    g_hCvarChatclearEnabled = CreateConVar("is_chatclear_enabled", "1", "Enable chat-clear blocking", 0, true, 0.0, true, 1.0);
    g_hCvarChatclearLogging = CreateConVar("is_chatclear_logging", "1", "Log chat-clear", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  21. ANGLE PATCH
    // ============================================================
    
    g_hCvarAnglepatchEnabled = CreateConVar("is_anglepatch_enabled", "1", "Enable angle-cheats patch", 0, true, 0.0, true, 1.0);
    g_hCvarAnglepatchMode = CreateConVar("is_anglepatch_mode", "1", "Mode: 0 = log, 1 = fix, 2 = kick", 0, true, 0.0, true, 2.0);
    g_hCvarAnglepatchLogging = CreateConVar("is_anglepatch_logging", "1", "Log angle-cheats", 0, true, 0.0, true, 1.0);
    
    // ============================================================
    //  22. DLL DETECTION
    // ============================================================
    
    g_hCvarDllEnabled = CreateConVar("is_dll_enabled", "1", "Enable DLL detection", 0, true, 0.0, true, 1.0);
    g_hCvarDllKick = CreateConVar("is_dll_kick", "0", "Kick for suspicious DLL", 0, true, 0.0, true, 1.0);
    g_hCvarDllBan = CreateConVar("is_dll_ban", "0", "Ban for suspicious DLL", 0, true, 0.0, true, 1.0);
    g_hCvarDllLogging = CreateConVar("is_dll_logging", "1", "Log DLL detection", 0, true, 0.0, true, 1.0);
    g_hCvarDllAction = CreateConVar("is_dll_action", "1", "Action: 0=kick, 1=ban, 2=SBPP, 3=MA", 0, true, 0.0, true, 3.0);
    
    // ============================================================
    //  23. DATABASE LOGGER
    // ============================================================
    
    g_hCvarDatabaseEnabled = CreateConVar("is_database_enabled", "0", "Enable MySQL logging", 0, true, 0.0, true, 1.0);
    g_hCvarDatabaseName = CreateConVar("is_database_name", "is_anticheat_sqlite", "Database name from databases.cfg", 0);
    
    // Global hook used by the optional database/logger module.
    g_hForwardDetection = CreateGlobalForward("IS_OnCheatDetected", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell);

    // ============================================================
    //  LOG PATH
    // ============================================================
    
    BuildPath(Path_SM, g_sLogPath, sizeof(g_sLogPath), "logs/is_core.log");
    
    // ============================================================
    //  ADMIN COMMANDS
    // ============================================================
    
    RegAdminCmd("is_status", Command_Status, ADMFLAG_GENERIC, "Show Iron Sentinel status");
    RegAdminCmd("is_reload", Command_Reload, ADMFLAG_ROOT, "Reload configuration");
    RegAdminCmd("is_ban", Command_Ban, ADMFLAG_BAN, "Ban player via Iron Sentinel");
    RegAdminCmd("is_config", Command_ShowConfig, ADMFLAG_GENERIC, "Show all settings");
    
    // ============================================================
    //  CREATE CONFIG
    // ============================================================
    
    AutoExecConfig(true, "is_config");
    
    // ============================================================
    //  CHECK EXISTING CLIENTS
    // ============================================================
    
    if (g_bLateLoad)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && !IsFakeClient(i))
            {
                OnClientPutInServer(i);
            }
        }
    }
    
    // Silent startup
}

public void OnVersionChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    if (!StrEqual(newValue, "1.1.2"))
    {
        convar.SetString("1.1.2", false, false);
    }
}

public void OnLoggingChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_bLoggingEnabled = convar.BoolValue;
}

public void OnConfigsExecuted()
{
    // Silent config load
}

// ===========================
//  PLAYER EVENTS
// ===========================

public void OnClientPutInServer(int client)
{
    if (IsFakeClient(client)) return;
    
    if (g_hCvarWelcomeMsg.BoolValue)
    {
        CreateTimer(5.0, Timer_WelcomeMsg, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_WelcomeMsg(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    
    if (IS_CLIENT(client) && IsClientInGame(client))
    {
        SetGlobalTransTarget(client);
        CPrintToChat(client, "{green}[AntiCheat]{default} %t", "IS_Welcome");
        CPrintToChat(client, "{green}[AntiCheat]{default} %t", "IS_Welcome_Line2");
    }
    
    return Plugin_Stop;
}

// ===========================
//  NATIVE: BAN
// ===========================

public int Native_BanClient(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    char sReason[256];
    GetNativeString(2, sReason, sizeof(sReason));
    
    if (!IS_CLIENT(client) || !IsClientConnected(client))
    {
        ThrowNativeError(SP_ERROR_INDEX, "Invalid client index %i", client);
    }
    
    IS_BanClient(client, sReason);
    return 0;
}

public int Native_GetBanDuration(Handle plugin, int numParams)
{
    return g_hCvarBanDuration.IntValue;
}

public int Native_IsLoggingEnabled(Handle plugin, int numParams)
{
    return g_bLoggingEnabled ? 1 : 0;
}

void IS_BanClient(int client, const char[] reason)
{
    int duration = g_hCvarBanDuration.IntValue;
    char sKickMsg[512];
    FormatEx(sKickMsg, sizeof(sKickMsg), "[AntiCheat] %t", "IS_Banned");
    
    KeyValues info = new KeyValues("IronSentinelDetection");
    info.SetNum("detection", 1);
    info.SetString("reason", reason);
    if (g_hForwardDetection != null && g_hForwardDetection.FunctionCount > 0)
    {
        Call_StartForward(g_hForwardDetection);
        Call_PushCell(client);
    Call_PushString("core_ban");
    Call_PushCell(1);
        Call_PushCell(info);
        Call_Finish();
    }
    delete info;

    BanClient(client, duration, BANFLAG_AUTO, reason, sKickMsg, "Iron Sentinel");
    
    if (g_bLoggingEnabled)
    {
        char sAuthID[MAX_AUTHID_LENGTH];
        GetClientAuthId(client, AuthId_Steam2, sAuthID, sizeof(sAuthID), true);
        IS_LogToFile("[BAN] %N (Steam: %s) Reason: %s", client, sAuthID, reason);
    }
    
    IS_PrintAdminNotice("{red}[BAN]{default} %N was banned. Reason: %s", client, reason);
}

// ===========================
//  NATIVE: LOG
// ===========================

public int Native_LogAction(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);

    if (!g_bLoggingEnabled) return 0;

    char sFormat[256];
    GetNativeString(2, sFormat, sizeof(sFormat));

    char sBuffer[512];
    FormatNativeString(0, 2, 3, sizeof(sBuffer), _, sBuffer);

    // client=0 is a valid server/system context (for example, cache reloads).
    // Do not throw a native error here: one bad logging call must not unload a module.
    if (client == 0)
    {
        IS_LogToFile("[SERVER] %s", sBuffer);
        return 0;
    }

    // Stale/disconnected clients are ignored safely instead of crashing the caller plugin.
    if (!IS_CLIENT(client) || !IsClientConnected(client))
    {
        IS_LogToFile("[INVALID CLIENT %i] %s", client, sBuffer);
        return 0;
    }

    char sAuthID[MAX_AUTHID_LENGTH];
    if (!GetClientAuthId(client, AuthId_Steam2, sAuthID, sizeof(sAuthID), true))
    {
        strcopy(sAuthID, sizeof(sAuthID), "UNKNOWN");
    }

    IS_LogToFile("[%N | %s] %s", client, sAuthID, sBuffer);
    return 0;
}

void IS_LogToFile(const char[] format, any ...)
{
    if (!g_bLoggingEnabled) return;
    
    char sBuffer[1024];
    VFormat(sBuffer, sizeof(sBuffer), format, 2);
    
    char sTime[64];
    FormatTime(sTime, sizeof(sTime), "%Y-%m-%d %H:%M:%S");
    
    LogToFileEx(g_sLogPath, "[%s] %s", sTime, sBuffer);
}

// ===========================
//  NATIVE: ADMIN NOTICE
// ===========================

public int Native_PrintAdminNotice(Handle plugin, int numParams)
{
    char sFormat[256];
    GetNativeString(1, sFormat, sizeof(sFormat));
    
    char sBuffer[512];
    FormatNativeString(0, 1, 2, sizeof(sBuffer), _, sBuffer);
    
    IS_PrintAdminNotice("%s", sBuffer);
    
    return 0;
}

void IS_PrintAdminNotice(const char[] format, any ...)
{
    char sBuffer[512];
    VFormat(sBuffer, sizeof(sBuffer), format, 2);
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && CheckCommandAccess(i, "is_admin", ADMFLAG_GENERIC, true))
        {
            CPrintToChat(i, "{green}[AntiCheat]{default} %s", sBuffer);
        }
    }
}

// ===========================
//  NATIVE: CHEAT DETECTED
// ===========================

public int Native_CheatDetected(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);
    char sModule[64];
    GetNativeString(2, sModule, sizeof(sModule));
    char sReason[256];
    GetNativeString(3, sReason, sizeof(sReason));
    
    if (!IS_CLIENT(client) || !IsClientConnected(client))
    {
        ThrowNativeError(SP_ERROR_INDEX, "Invalid client index %i", client);
    }
    
    return IS_CheatDetected(client, sModule, sReason);
}

int IS_CheatDetected(int client, const char[] module, const char[] reason)
{
    if (CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true))
    {
        IS_LogToFile("[IMMUNITY] %N skipped (flag o)", client);
        return 1;
    }

    if (g_hForwardDetection != null && g_hForwardDetection.FunctionCount > 0)
    {
        KeyValues info = new KeyValues("IronSentinelDetection");
        info.SetNum("detection", 1);
        info.SetString("reason", reason);
        Call_StartForward(g_hForwardDetection);
        Call_PushCell(client);
        Call_PushString(module);
        Call_PushCell(1);
        Call_PushCell(info);
        Call_Finish();
        delete info;
    }

    IS_PrintAdminNotice("{red}[CHEAT]{default} %N suspected: %s", client, reason);
    IS_LogToFile("[DETECTED] %N | Module: %s | Reason: %s", client, module, reason);

    return 0;
}

// ===========================
//  ADMIN COMMANDS
// ===========================

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "|       IRON SENTINEL ANTI-CHEAT          |");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "");
    PrintToConsole(client, "Version:          1.1.2");
    PrintToConsole(client, "Ban duration:     %i min.", g_hCvarBanDuration.IntValue);
    PrintToConsole(client, "Logging:          %s", g_bLoggingEnabled ? "ON" : "OFF");
    PrintToConsole(client, "Welcome message:  %s", g_hCvarWelcomeMsg.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    PrintToConsole(client, "--- Active players ---");
    PrintToConsole(client, "  #  | SteamID              | Name");
    PrintToConsole(client, "-----+----------------------+-----------------");
    
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientConnected(i))
        {
            char sAuthID[MAX_AUTHID_LENGTH];
            GetClientAuthId(i, AuthId_Steam2, sAuthID, sizeof(sAuthID), true);
            PrintToConsole(client, "  %2d | %-20s | %N", i, sAuthID, i);
        }
    }
    
    PrintToConsole(client, "");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "|  IRON SENTINEL - PROTECTION ACTIVE      |");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "");
    
    return Plugin_Handled;
}

public Action Command_ShowConfig(int client, int args)
{
    PrintToConsole(client, "");
    PrintToConsole(client, "+==========================================+");
    PrintToConsole(client, "|     IRON SENTINEL - CURRENT SETTINGS    |");
    PrintToConsole(client, "+==========================================+");
    PrintToConsole(client, "");
    
    // === CORE ===
    PrintToConsole(client, "--- CORE ---");
    PrintToConsole(client, "is_ban_duration          = %i", g_hCvarBanDuration.IntValue);
    PrintToConsole(client, "is_logging               = %s", g_bLoggingEnabled ? "ON" : "OFF");
    PrintToConsole(client, "is_welcomemsg            = %s", g_hCvarWelcomeMsg.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === COMMANDS ===
    PrintToConsole(client, "--- COMMAND BLOCKER ---");
    PrintToConsole(client, "is_cmd_autokick          = %s", g_hCvarCmdAutokick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_cmd_autoban           = %s", g_hCvarCmdAutoban.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_cmd_logging           = %s", g_hCvarCmdLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === CVARS ===
    PrintToConsole(client, "--- CVAR CHECKER ---");
    PrintToConsole(client, "is_cvars_autokick        = %s", g_hCvarCvarsAutokick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_cvars_autoban         = %s", g_hCvarCvarsAutoban.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_cvars_check_interval  = %.1f sec", g_hCvarCvarsCheckInterval.FloatValue);
    PrintToConsole(client, "is_cvars_logging         = %s", g_hCvarCvarsLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === ANTISPAM ===
    PrintToConsole(client, "--- ANTISPAM ---");
    PrintToConsole(client, "is_antispam_autokick     = %s", g_hCvarAntispamAutokick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_antispam_connect_time = %.1f sec", g_hCvarAntispamConnectTime.FloatValue);
    PrintToConsole(client, "is_antispam_name_limit   = %i", g_hCvarAntispamNameLimit.IntValue);
    PrintToConsole(client, "is_antispam_team_limit   = %i", g_hCvarAntispamTeamLimit.IntValue);
    PrintToConsole(client, "is_antispam_logging      = %s", g_hCvarAntispamLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === SPEEDHACK ===
    PrintToConsole(client, "--- SPEEDHACK DETECTOR ---");
    PrintToConsole(client, "is_speed_autokick        = %s", g_hCvarSpeedAutokick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_speed_detections      = %i", g_hCvarSpeedDetections.IntValue);
    PrintToConsole(client, "is_speed_max             = %.1f", g_hCvarSpeedMax.FloatValue);
    PrintToConsole(client, "is_speed_multiplier      = %.1f", g_hCvarSpeedMultiplier.FloatValue);
    PrintToConsole(client, "is_speed_check_interval  = %.1f sec", g_hCvarSpeedCheckInterval.FloatValue);
    PrintToConsole(client, "is_speed_logging         = %s", g_hCvarSpeedLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === AIMBOT ===
    PrintToConsole(client, "--- AIMBOT DETECTOR ---");
    PrintToConsole(client, "is_aimbot_ban            = %i", g_hCvarAimbotBan.IntValue);
    PrintToConsole(client, "is_aimbot_kick           = %s", g_hCvarAimbotKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_aimbot_sensitivity    = %.1f", g_hCvarAimbotSensitivity.FloatValue);
    PrintToConsole(client, "is_aimbot_logging        = %s", g_hCvarAimbotLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === WALLHACK ===
    PrintToConsole(client, "--- WALLHACK BLOCKER ---");
    PrintToConsole(client, "is_wallhack_enabled      = %s", g_hCvarWallhackEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_wallhack_mode         = %s", g_hCvarWallhackMode.IntValue ? "Aggressive" : "Soft");
    PrintToConsole(client, "is_wallhack_maxtraces    = %i", g_hCvarWallhackMaxTraces.IntValue);
    PrintToConsole(client, "");
    
    // === EYE TEST ===
    PrintToConsole(client, "--- EYE TEST ---");
    PrintToConsole(client, "is_eyetest_autoban       = %s", g_hCvarEyetestAutoban.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_eyetest_autokick      = %s", g_hCvarEyetestAutokick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_eyetest_sensitivity   = %.1f", g_hCvarEyetestSensitivity.FloatValue);
    PrintToConsole(client, "is_eyetest_logging       = %s", g_hCvarEyetestLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === AUTO-TRIGGER ===
    PrintToConsole(client, "--- AUTO-TRIGGER ---");
    PrintToConsole(client, "is_autotrigger_ban       = %s", g_hCvarAutotriggerBan.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_autotrigger_kick      = %s", g_hCvarAutotriggerKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_autotrigger_logging   = %s", g_hCvarAutotriggerLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_autotrigger_sensitivity = %.1f", g_hCvarAutotriggerSensitivity.FloatValue);
    PrintToConsole(client, "");
    
    // === SPINHACK ===
    PrintToConsole(client, "--- SPINHACK ---");
    PrintToConsole(client, "is_spinhack_ban          = %s", g_hCvarSpinhackBan.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_spinhack_kick         = %s", g_hCvarSpinhackKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_spinhack_logging      = %s", g_hCvarSpinhackLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_spinhack_sensitivity  = %.1f", g_hCvarSpinhackSensitivity.FloatValue);
    PrintToConsole(client, "");
    
    // === ANTI-FLASH ===
    PrintToConsole(client, "--- ANTI-FLASH ---");
    PrintToConsole(client, "is_antiflash_enabled     = %s", g_hCvarAntiflashEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_antiflash_mode        = %s", g_hCvarAntiflashMode.IntValue ? "Block" : "Log");
    PrintToConsole(client, "is_antiflash_logging     = %s", g_hCvarAntiflashLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === ANTI-SMOKE ===
    PrintToConsole(client, "--- ANTI-SMOKE ---");
    PrintToConsole(client, "is_antismoke_enabled     = %s", g_hCvarAntismokeEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_antismoke_mode        = %s", g_hCvarAntismokeMode.IntValue ? "Block" : "Log");
    PrintToConsole(client, "is_antismoke_logging     = %s", g_hCvarAntismokeLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_antismoke_radius      = %.1f", g_hCvarAntismokeRadius.FloatValue);
    PrintToConsole(client, "");
    
    // === RCON ===
    PrintToConsole(client, "--- RCON PROTECTION ---");
    PrintToConsole(client, "is_rcon_locked           = %s", g_hCvarRconLocked.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_rcon_logging          = %s", g_hCvarRconLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_rcon_max_attempts     = %i", g_hCvarRconMaxAttempts.IntValue);
    PrintToConsole(client, "is_rcon_ban_time         = %i min", g_hCvarRconBanTime.IntValue);
    PrintToConsole(client, "is_rcon_whitelist_enabled = %s", g_hCvarRconWhitelistEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === BANLISTS ===
    PrintToConsole(client, "--- GLOBAL BANLISTS ---");
    PrintToConsole(client, "is_banlist_eac_enabled   = %s", g_hCvarBanlistEacEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_banlist_eac_kick      = %s", g_hCvarBanlistEacKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_banlist_esea_enabled  = %s", g_hCvarBanlistEseaEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_banlist_esea_kick     = %s", g_hCvarBanlistEseaKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_banlist_logging       = %s", g_hCvarBanlistLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === AIMLOCK ===
    PrintToConsole(client, "--- AIMLOCK ---");
    PrintToConsole(client, "is_aimlock_ban           = %s", g_hCvarAimlockBan.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_aimlock_kick          = %s", g_hCvarAimlockKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_aimlock_logging       = %s", g_hCvarAimlockLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_aimlock_sensitivity   = %.1f", g_hCvarAimlockSensitivity.FloatValue);
    PrintToConsole(client, "");
    
    // === MACRO ===
    PrintToConsole(client, "--- MACRO DETECTION ---");
    PrintToConsole(client, "is_macro_ban             = %s", g_hCvarMacroBan.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_macro_kick            = %s", g_hCvarMacroKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_macro_logging         = %s", g_hCvarMacroLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_macro_sensitivity     = %.1f", g_hCvarMacroSensitivity.FloatValue);
    PrintToConsole(client, "");
    
    // === NOLERP ===
    PrintToConsole(client, "--- NOLERP ---");
    PrintToConsole(client, "is_nolerp_ban            = %s", g_hCvarNolerpBan.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_nolerp_kick           = %s", g_hCvarNolerpKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_nolerp_logging        = %s", g_hCvarNolerpLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === BACKTRACK ===
    PrintToConsole(client, "--- BACKTRACK ---");
    PrintToConsole(client, "is_backtrack_enabled     = %s", g_hCvarBacktrackEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_backtrack_logging     = %s", g_hCvarBacktrackLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === PING ===
    PrintToConsole(client, "--- PING ---");
    PrintToConsole(client, "is_ping_max              = %i ms", g_hCvarPingMax.IntValue);
    PrintToConsole(client, "is_ping_kick             = %s", g_hCvarPingKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_ping_logging          = %s", g_hCvarPingLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === CHAT-CLEAR ===
    PrintToConsole(client, "--- CHAT-CLEAR ---");
    PrintToConsole(client, "is_chatclear_enabled     = %s", g_hCvarChatclearEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_chatclear_logging     = %s", g_hCvarChatclearLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === ANGLE PATCH ===
    PrintToConsole(client, "--- ANGLE PATCH ---");
    PrintToConsole(client, "is_anglepatch_enabled    = %s", g_hCvarAnglepatchEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_anglepatch_mode       = %i (0=log,1=fix,2=kick)", g_hCvarAnglepatchMode.IntValue);
    PrintToConsole(client, "is_anglepatch_logging    = %s", g_hCvarAnglepatchLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "");
    
    // === DLL ===
    PrintToConsole(client, "--- DLL DETECTION ---");
    PrintToConsole(client, "is_dll_enabled           = %s", g_hCvarDllEnabled.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_dll_kick              = %s", g_hCvarDllKick.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_dll_ban               = %s", g_hCvarDllBan.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_dll_logging           = %s", g_hCvarDllLogging.BoolValue ? "ON" : "OFF");
    PrintToConsole(client, "is_dll_action            = %i (0=kick,1=ban,2=SBPP,3=MA)", g_hCvarDllAction.IntValue);
    PrintToConsole(client, "");
    
    // === DATABASE ===
    PrintToConsole(client, "--- DATABASE LOGGER ---");
    PrintToConsole(client, "is_database_enabled      = %s", g_hCvarDatabaseEnabled.BoolValue ? "ON" : "OFF");
    char sDbName[64];
    g_hCvarDatabaseName.GetString(sDbName, sizeof(sDbName));
    PrintToConsole(client, "is_database_name         = %s", sDbName);
    PrintToConsole(client, "");
    
    PrintToConsole(client, "+==========================================+");
    PrintToConsole(client, "|  Config file: cfg/sourcemod/is_config.cfg  |");
    PrintToConsole(client, "+==========================================+");
    PrintToConsole(client, "");
    
    return Plugin_Handled;
}

public Action Command_Reload(int client, int args)
{
    AutoExecConfig(true, "is_config");
    ReplyToCommand(client, "[AntiCheat] Config reloaded.");
    return Plugin_Handled;
}

public Action Command_Ban(int client, int args)
{
    if (args < 2)
    {
        ReplyToCommand(client, "Usage: is_ban <#userid|name> <reason>");
        return Plugin_Handled;
    }
    
    char sTarget[64];
    GetCmdArg(1, sTarget, sizeof(sTarget));
    
    char sReason[256];
    GetCmdArgString(sReason, sizeof(sReason));
    
    int iPos = FindCharInString(sReason, ' ');
    if (iPos != -1)
    {
        strcopy(sReason, sizeof(sReason), sReason[iPos + 1]);
    }
    
    int target = FindTarget(client, sTarget, true, false);
    
    if (target == -1)
    {
        return Plugin_Handled;
    }
    
    IS_BanClient(target, sReason);
    
    return Plugin_Handled;
}

public void OnPluginEnd()
{
    if (g_hForwardDetection != null)
    {
        delete g_hForwardDetection;
        g_hForwardDetection = null;
    }
}

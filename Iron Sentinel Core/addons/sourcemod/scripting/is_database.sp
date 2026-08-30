/*
    Iron Sentinel AntiCheat - Database Logger
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Логирование детекций в SQLite/MySQL
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Database Logger",
    author = "Maxim Melnikov",
    description = "Логирование детекций в базу данных",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

// ===========================
//  ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
// ===========================

ConVar g_hCvarEnabled;
ConVar g_hCvarDatabase;

bool g_bEnabled;
char g_sDatabase[64];

Database g_hDatabase = null;
bool g_bDatabaseConnected = false;
bool g_bSchemaReady = false;

char g_sTableName[] = "is_detections";
char g_sLogPath[PLATFORM_MAX_PATH];

bool g_bConnecting = false;
int g_iConnectionGeneration = 0;
int g_iReconnectAttempt = 0;
int g_iReconnectCount = 0;
int g_iHealthChecks = 0;
int g_iHealthFailures = 0;
float g_fLastHealthOkTime = 0.0;
char g_sLastDatabaseError[256];
Handle g_hReconnectTimer = INVALID_HANDLE;
Handle g_hHealthTimer = INVALID_HANDLE;

#define DB_RECONNECT_INITIAL 5.0
#define DB_RECONNECT_MAX 60.0
#define DB_HEALTH_INTERVAL 30.0


// ===========================
//  ЗАГРУЗКА
// ===========================

public void OnPluginStart()
{
    BuildPath(Path_SM, g_sLogPath, sizeof(g_sLogPath), "logs/is_database.log");
    
    g_hCvarEnabled = FindConVar("is_database_enabled");
    g_hCvarDatabase = FindConVar("is_database_name");
    
    if (g_hCvarEnabled == null)
        g_hCvarEnabled = CreateConVar("is_database_enabled", "0", "Enable database logging", 0, true, 0.0, true, 1.0);
    if (g_hCvarDatabase == null)
        g_hCvarDatabase = CreateConVar("is_database_name", "is_anticheat_sqlite", "Database name from databases.cfg", 0);
    
    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarDatabase.AddChangeHook(OnSettingsChanged);
    
    OnSettingsChanged(null, "", "");
    
    if (g_bEnabled)
        ConnectDatabase();
    
    RegAdminCmd("is_db_status", Command_Status, ADMFLAG_GENERIC, "Show database status");
    RegAdminCmd("is_db_reconnect", Command_Reconnect, ADMFLAG_ROOT, "Reconnect to database");
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    bool wasEnabled = g_bEnabled;
    char oldDatabase[64];
    strcopy(oldDatabase, sizeof(oldDatabase), g_sDatabase);

    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_hCvarDatabase.GetString(g_sDatabase, sizeof(g_sDatabase));

    bool databaseChanged = !StrEqual(oldDatabase, g_sDatabase);
    if (!g_bEnabled || databaseChanged)
    {
        g_iConnectionGeneration++;
        CancelReconnect();
        if (g_hHealthTimer != INVALID_HANDLE)
        {
            KillTimer(g_hHealthTimer);
            g_hHealthTimer = INVALID_HANDLE;
        }
        if (g_hDatabase != null)
        {
            delete g_hDatabase;
            g_hDatabase = null;
        }
        g_bDatabaseConnected = false;
        g_bSchemaReady = false;
        g_bConnecting = false;
        g_fLastHealthOkTime = 0.0;
    }

    if (g_bEnabled && (wasEnabled == false || databaseChanged || g_hDatabase == null))
        ConnectDatabase();
}

public void OnMapStart()
{
    if (g_bEnabled && g_hDatabase == null)
        ConnectDatabase();
}

// ===========================
//  ПОДКЛЮЧЕНИЕ К БД
// ===========================

void CancelReconnect()
{
    if (g_hReconnectTimer != INVALID_HANDLE)
    {
        KillTimer(g_hReconnectTimer);
        g_hReconnectTimer = INVALID_HANDLE;
    }
}

void ScheduleReconnect()
{
    if (!g_bEnabled || g_hDatabase != null || g_hReconnectTimer != INVALID_HANDLE || g_bConnecting) return;

    float delay = DB_RECONNECT_INITIAL;
    for (int i = 0; i < g_iReconnectAttempt; i++)
    {
        delay *= 2.0;
        if (delay >= DB_RECONNECT_MAX)
        {
            delay = DB_RECONNECT_MAX;
            break;
        }
    }
    if (delay > DB_RECONNECT_MAX) delay = DB_RECONNECT_MAX;
    if (g_iReconnectAttempt < 6) g_iReconnectAttempt++;
    // Must survive map changes: this is a plugin-lifetime reconnect scheduler, not a
    // per-map resource. TIMER_FLAG_NO_MAPCHANGE would let the engine kill it silently at
    // the next map change while g_hReconnectTimer keeps a stale handle value, which
    // permanently blocks ScheduleReconnect()'s "already pending" guard from ever firing
    // a new attempt again, and makes the next KillTimer(g_hReconnectTimer) throw.
    g_hReconnectTimer = CreateTimer(delay, Timer_Reconnect);
}

void ConnectDatabase()
{
    if (!g_bEnabled || g_bConnecting || g_hDatabase != null) return;
    if (g_sDatabase[0] == '\0' || !SQL_CheckConfig(g_sDatabase))
    {
        ScheduleReconnect();
        return;
    }

    g_bConnecting = true;
    int generation = ++g_iConnectionGeneration;
    Database.Connect(OnDatabaseConnected, g_sDatabase, generation);
}

public Action Timer_Reconnect(Handle timer)
{
    g_hReconnectTimer = INVALID_HANDLE;
    if (g_bEnabled && g_hDatabase == null) ConnectDatabase();
    return Plugin_Stop;
}

public void OnDatabaseConnected(Database db, const char[] error, any data)
{
    int generation = data;
    if (generation != g_iConnectionGeneration || !g_bEnabled)
    {
        if (db != null) delete db;
        return;
    }

    g_bConnecting = false;
    if (db == null)
    {
        strcopy(g_sLastDatabaseError, sizeof(g_sLastDatabaseError), error);
        g_bDatabaseConnected = false;
        g_bSchemaReady = false;
        g_iReconnectCount++;
        LogToFile(g_sLogPath, "[DATABASE] Connection failed: %s", error);
        ScheduleReconnect();
        return;
    }

    CancelReconnect();
    g_iReconnectAttempt = 0;
    g_hDatabase = db;
    g_bDatabaseConnected = false;
    g_bSchemaReady = false;
    g_sLastDatabaseError[0] = '\0';
    if (!g_hDatabase.SetCharset("utf8mb4"))
        LogToFile(g_sLogPath, "[DATABASE] Charset setup not applied for driver");

    LogToFile(g_sLogPath, "[DATABASE] Connected to '%s'", g_sDatabase);
    if (g_hHealthTimer != INVALID_HANDLE)
    {
        KillTimer(g_hHealthTimer);
        g_hHealthTimer = INVALID_HANDLE;
    }
    CreateTables();
}

public Action Timer_DatabaseHealth(Handle timer)
{
    if (!g_bEnabled || !g_bDatabaseConnected || !g_bSchemaReady || g_hDatabase == null)
        return Plugin_Continue;

    g_hDatabase.Query(OnDatabaseHealth, "SELECT 1", g_iConnectionGeneration, DBPrio_Low);
    return Plugin_Continue;
}

public void OnDatabaseHealth(Database db, DBResultSet results, const char[] error, any data)
{
    if (data != g_iConnectionGeneration) return;
    if (error[0] != '\0' || results == null)
    {
        g_iHealthFailures++;
        LogToFile(g_sLogPath, "[DATABASE] Health check failed: %s", error);
        DropDatabaseConnection(error[0] != '\0' ? error : "database health check returned no result");
        return;
    }

    g_iHealthChecks++;
    g_fLastHealthOkTime = GetEngineTime();
}

// ===========================
//  СОЗДАНИЕ ТАБЛИЦ
// ===========================

void CreateTables()
{
    if (g_hDatabase == null) return;

    char sDriver[16];
    g_hDatabase.Driver.GetIdentifier(sDriver, sizeof(sDriver));
    char sQuery[4096];

    if (StrEqual(sDriver, "sqlite", false))
    {
        FormatEx(sQuery, sizeof(sQuery),
            "CREATE TABLE IF NOT EXISTS %s (id INTEGER PRIMARY KEY AUTOINCREMENT, steamid TEXT NOT NULL, name TEXT NOT NULL, ip TEXT NOT NULL, cheat TEXT NOT NULL, detection INTEGER NOT NULL, timestamp INTEGER NOT NULL, map TEXT NOT NULL, team INTEGER NOT NULL, weapon TEXT NOT NULL, pos_x REAL NOT NULL, pos_y REAL NOT NULL, pos_z REAL NOT NULL, ang_x REAL NOT NULL, ang_y REAL NOT NULL, ang_z REAL NOT NULL, data1 REAL NOT NULL DEFAULT 0, data2 REAL NOT NULL DEFAULT 0, latency_in REAL NOT NULL, latency_out REAL NOT NULL, loss_in REAL NOT NULL, loss_out REAL NOT NULL, choke_in REAL NOT NULL, choke_out REAL NOT NULL, connection_time REAL NOT NULL, game_time REAL NOT NULL, version TEXT NOT NULL)",
            g_sTableName);
    }
    else
    {
        FormatEx(sQuery, sizeof(sQuery),
            "CREATE TABLE IF NOT EXISTS %s (id INT AUTO_INCREMENT PRIMARY KEY, steamid VARCHAR(64) NOT NULL, name VARCHAR(128) NOT NULL, ip VARCHAR(64) NOT NULL, cheat VARCHAR(64) NOT NULL, detection INT NOT NULL, timestamp INT NOT NULL, map VARCHAR(64) NOT NULL, team INT NOT NULL, weapon VARCHAR(64) NOT NULL, pos_x FLOAT NOT NULL, pos_y FLOAT NOT NULL, pos_z FLOAT NOT NULL, ang_x FLOAT NOT NULL, ang_y FLOAT NOT NULL, ang_z FLOAT NOT NULL, data1 FLOAT NOT NULL DEFAULT 0, data2 FLOAT NOT NULL DEFAULT 0, latency_in FLOAT NOT NULL, latency_out FLOAT NOT NULL, loss_in FLOAT NOT NULL, loss_out FLOAT NOT NULL, choke_in FLOAT NOT NULL, choke_out FLOAT NOT NULL, connection_time FLOAT NOT NULL, game_time FLOAT NOT NULL, version VARCHAR(32) NOT NULL, INDEX idx_steamid (steamid), INDEX idx_cheat (cheat), INDEX idx_timestamp (timestamp)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            g_sTableName);
    }

    g_hDatabase.Query(OnTableCreated, sQuery, g_iConnectionGeneration, DBPrio_Low);
}

void DropDatabaseConnection(const char[] reason)
{
    strcopy(g_sLastDatabaseError, sizeof(g_sLastDatabaseError), reason);
    CancelReconnect();
    if (g_hHealthTimer != INVALID_HANDLE)
    {
        KillTimer(g_hHealthTimer);
        g_hHealthTimer = INVALID_HANDLE;
    }
    g_bDatabaseConnected = false;
    g_bSchemaReady = false;
    g_bConnecting = false;
    g_iConnectionGeneration++;
    if (g_hDatabase != null)
    {
        delete g_hDatabase;
        g_hDatabase = null;
    }
    ScheduleReconnect();
}

public void OnTableCreated(Database db, DBResultSet results, const char[] error, any data)
{
    if (data != g_iConnectionGeneration || g_hDatabase == null) return;
    if (error[0] != '\0' || results == null)
    {
        LogToFile(g_sLogPath, "[DATABASE] Table creation error: %s", error);
        DropDatabaseConnection(error[0] != '\0' ? error : "table creation returned no result");
        return;
    }

    char sDriver[16];
    g_hDatabase.Driver.GetIdentifier(sDriver, sizeof(sDriver));
    if (StrEqual(sDriver, "mysql", false))
    {
        g_bDatabaseConnected = true;
        g_bSchemaReady = true;
        // Must survive map changes (see note on g_hReconnectTimer above): this guard is
        // the ONLY place that recreates the health timer, so if TIMER_FLAG_NO_MAPCHANGE
        // let the engine silently kill it at a map change, g_hHealthTimer would keep a
        // stale handle forever, health checks would stop for the rest of the server's
        // uptime, and the next KillTimer(g_hHealthTimer) (Command_Reconnect,
        // DropDatabaseConnection, OnSettingsChanged) would throw "Invalid handle".
        if (g_hHealthTimer == INVALID_HANDLE)
            g_hHealthTimer = CreateTimer(DB_HEALTH_INTERVAL, Timer_DatabaseHealth, _, TIMER_REPEAT);
        LogToFile(g_sLogPath, "[DATABASE] Table '%s' ready", g_sTableName);
        return;
    }

    LogToFile(g_sLogPath, "[DATABASE] Table '%s' ready; creating indexes", g_sTableName);
    CreateSQLiteIndex(0);
}

void CreateSQLiteIndex(int index)
{
    if (g_hDatabase == null || !g_bEnabled || index >= 3) return;

    char sIndexName[32];
    char sColumn[32];
    switch (index)
    {
        case 0: { strcopy(sIndexName, sizeof(sIndexName), "idx_steamid"); strcopy(sColumn, sizeof(sColumn), "steamid"); }
        case 1: { strcopy(sIndexName, sizeof(sIndexName), "idx_cheat"); strcopy(sColumn, sizeof(sColumn), "cheat"); }
        case 2: { strcopy(sIndexName, sizeof(sIndexName), "idx_timestamp"); strcopy(sColumn, sizeof(sColumn), "timestamp"); }
        default: return;
    }

    char sQuery[512];
    FormatEx(sQuery, sizeof(sQuery), "CREATE INDEX IF NOT EXISTS %s ON %s (%s)", sIndexName, g_sTableName, sColumn);
    int packed = (g_iConnectionGeneration * 10) + index;
    g_hDatabase.Query(OnIndexCreated, sQuery, packed, DBPrio_Low);
}

public void OnIndexCreated(Database db, DBResultSet results, const char[] error, any data)
{
    int generation = data / 10;
    int index = data % 10;
    if (generation != g_iConnectionGeneration || g_hDatabase == null) return;
    if (error[0] != '\0' || results == null)
    {
        LogToFile(g_sLogPath, "[DATABASE] Index creation error: %s", error);
        DropDatabaseConnection(error[0] != '\0' ? error : "index creation returned no result");
        return;
    }

    if (index < 2)
    {
        CreateSQLiteIndex(index + 1);
        return;
    }

    g_bDatabaseConnected = true;
    g_bSchemaReady = true;
    // Must survive map changes -- see the identical guard in OnTableCreated() above.
    if (g_hHealthTimer == INVALID_HANDLE)
        g_hHealthTimer = CreateTimer(DB_HEALTH_INTERVAL, Timer_DatabaseHealth, _, TIMER_REPEAT);
    LogToFile(g_sLogPath, "[DATABASE] SQLite schema ready");
}

// ===========================
//  ЗАПИСЬ В БД
// ===========================

void LogToDatabase(int client, const char[] cheat, int detection)
{
    if (!g_bEnabled || !g_bDatabaseConnected || !g_bSchemaReady || g_hDatabase == null) return;
    if (client < 1 || client > MaxClients || !IsClientInGame(client)) return;
    
    char sSteamID[64];
    char sName[64];
    char sIP[64];
    char sMap[64];
    char sWeapon[32];
    float vOrigin[3], vAngles[3];
    
    GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID), true);
    GetClientName(client, sName, sizeof(sName));
    GetClientIP(client, sIP, sizeof(sIP), true);
    GetCurrentMap(sMap, sizeof(sMap));
    GetClientWeapon(client, sWeapon, sizeof(sWeapon));
    GetClientAbsOrigin(client, vOrigin);
    GetClientEyeAngles(client, vAngles);
    
    char sSafeName[128];
    char sSafeCheat[128];
    char sSafeWeapon[64];
    char sSafeMap[128];
    
    g_hDatabase.Escape(sName, sSafeName, sizeof(sSafeName));
    g_hDatabase.Escape(cheat, sSafeCheat, sizeof(sSafeCheat));
    g_hDatabase.Escape(sWeapon, sSafeWeapon, sizeof(sSafeWeapon));
    g_hDatabase.Escape(sMap, sSafeMap, sizeof(sSafeMap));
    
    char sQuery[2048];
    FormatEx(sQuery, sizeof(sQuery),
        "INSERT INTO %s (steamid, name, ip, cheat, detection, timestamp, map, team, weapon, pos_x, pos_y, pos_z, ang_x, ang_y, ang_z, data1, data2, latency_in, latency_out, loss_in, loss_out, choke_in, choke_out, connection_time, game_time, version) VALUES ('%s', '%s', '%s', '%s', %d, %d, '%s', %d, '%s', %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.1f, %.1f, '1.1.2')",
        g_sTableName,
        sSteamID,
        sSafeName,
        sIP,
        sSafeCheat,
        detection,
        GetTime(),
        sSafeMap,
        GetClientTeam(client),
        sSafeWeapon,
        vOrigin[0], vOrigin[1], vOrigin[2],
        vAngles[0], vAngles[1], vAngles[2],
        0.0, 0.0,
        GetClientAvgLatency(client, NetFlow_Incoming),
        GetClientAvgLatency(client, NetFlow_Outgoing),
        GetClientAvgLoss(client, NetFlow_Incoming),
        GetClientAvgLoss(client, NetFlow_Outgoing),
        GetClientAvgChoke(client, NetFlow_Incoming),
        GetClientAvgChoke(client, NetFlow_Outgoing),
        GetClientTime(client),
        GetGameTime());
    
    g_hDatabase.Query(OnQueryExecuted, sQuery, g_iConnectionGeneration, DBPrio_Low);
}

public void OnQueryExecuted(Database db, DBResultSet results, const char[] error, any data)
{
    if (data != g_iConnectionGeneration) return;
    if (error[0] != '\0' || results == null)
    {
        LogToFile(g_sLogPath, "[DATABASE] Insert error: %s", error);
        DropDatabaseConnection(error[0] != '\0' ? error : "insert returned no result");
    }
}

// ===========================
//  ХУК НА ОБНАРУЖЕНИЕ
// ===========================

public void IS_OnCheatDetected(int client, const char[] module, int type, Handle info)
{
    if (!g_bEnabled || !g_bDatabaseConnected || g_hDatabase == null)
        return;
    
    char sCheat[64];
    strcopy(sCheat, sizeof(sCheat), module);
    
    int iDetection = 1;
    if (info != INVALID_HANDLE)
        iDetection = KvGetNum(info, "detection", 1);
    
    LogToDatabase(client, sCheat, iDetection);
    
    return;
}

public void OnPluginEnd()
{
    CancelReconnect();
    if (g_hHealthTimer != INVALID_HANDLE)
    {
        KillTimer(g_hHealthTimer);
        g_hHealthTimer = INVALID_HANDLE;
    }
    g_bEnabled = false;
    g_bConnecting = false;
    g_iConnectionGeneration++;
    if (g_hDatabase != null)
    {
        delete g_hDatabase;
        g_hDatabase = null;
    }
    g_bDatabaseConnected = false;
    g_bSchemaReady = false;
}

// ===========================
//  КОМАНДЫ
// ===========================

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "|       DATABASE LOGGER STATUS            |");
    PrintToConsole(client, "+------------------------------------------+");
    PrintToConsole(client, "");
    PrintToConsole(client, "Enabled:           %s", g_bEnabled ? "ON" : "OFF");
    PrintToConsole(client, "Database:          %s", g_sDatabase);
    PrintToConsole(client, "Connected:         %s", g_bDatabaseConnected ? "YES" : "NO");
    PrintToConsole(client, "Connecting:        %s", g_bConnecting ? "YES" : "NO");
    PrintToConsole(client, "Reconnect attempt: %i", g_iReconnectAttempt);
    PrintToConsole(client, "Reconnect total:   %i", g_iReconnectCount);
    PrintToConsole(client, "Health checks:      %i", g_iHealthChecks);
    PrintToConsole(client, "Health failures:    %i", g_iHealthFailures);
    PrintToConsole(client, "Last health ok:     %.1f", g_fLastHealthOkTime);
    PrintToConsole(client, "Schema ready:      %s", g_bSchemaReady ? "YES" : "NO");
    PrintToConsole(client, "Last error:        %s", g_sLastDatabaseError[0] != '\0' ? g_sLastDatabaseError : "none");
    PrintToConsole(client, "Table:             %s", g_sTableName);
    PrintToConsole(client, "+------------------------------------------+");
    return Plugin_Handled;
}

public Action Command_Reconnect(int client, int args)
{
    g_iConnectionGeneration++;
    CancelReconnect();
    if (g_hDatabase != null)
    {
        delete g_hDatabase;
        g_hDatabase = null;
    }
    g_bDatabaseConnected = false;
    g_bSchemaReady = false;
    g_bConnecting = false;
    g_iReconnectAttempt = 0;
    if (g_hHealthTimer != INVALID_HANDLE)
    {
        KillTimer(g_hHealthTimer);
        g_hHealthTimer = INVALID_HANDLE;
    }
    ConnectDatabase();
    ReplyToCommand(client, "[AntiCheat] Reconnecting to database...");
    return Plugin_Handled;
}
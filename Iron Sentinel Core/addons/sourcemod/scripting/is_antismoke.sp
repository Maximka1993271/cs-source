/*
    Iron Sentinel AntiCheat - Anti-Smoke Blocker
    Version: 1.1.2
    Author: Maxim Melnikov
    Description: Скрывает противников, находящихся в дыму, без false-positive детекций.
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <is_core>

public Plugin myinfo =
{
    name = "Iron Sentinel Anti-Smoke Blocker",
    author = "Maxim Melnikov",
    description = "Стабильная серверная защита от визуального обхода дыма",
    version = "1.1.2",
    url = "https://github.com/Maximka1993271"
};

#define SMOKE_DELAYTIME 0.75
#define SMOKE_LIFETIME 18.0
#define MAX_SMOKES 64
#define SMOKE_GRID_CELL_SIZE 256.0
#define SMOKE_GRID_BUCKETS 64

enum struct SmokeInfo
{
    float pos[3];
    float expiresAt;
    int cellX;
    int cellY;
}

ConVar g_hCvarEnabled;
ConVar g_hCvarLogging;
ConVar g_hCvarMode;
ConVar g_hCvarRadius;

bool g_bEnabled;
int g_iMode;
float g_fRadius;

ArrayList g_hSmokes;
Handle g_hSmokeLoop = INVALID_HANDLE;
bool g_bIsInSmoke[MAXPLAYERS+1];
bool g_bImmune[MAXPLAYERS+1];
ArrayList g_hSmokeGrid[SMOKE_GRID_BUCKETS];
int g_iSmokeVisit[MAX_SMOKES];
int g_iSmokeVisitToken;

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
    g_hCvarEnabled = FindConVar("is_antismoke_enabled");
    g_hCvarLogging = FindConVar("is_antismoke_logging");
    g_hCvarMode = FindConVar("is_antismoke_mode");
    g_hCvarRadius = FindConVar("is_antismoke_radius");

    if (g_hCvarEnabled == null) g_hCvarEnabled = CreateConVar("is_antismoke_enabled", "1", "Включить анти-smoke visibility block", 0, true, 0.0, true, 1.0);
    if (g_hCvarLogging == null) g_hCvarLogging = CreateConVar("is_antismoke_logging", "1", "Логировать состояние дыма", 0, true, 0.0, true, 1.0);
    if (g_hCvarMode == null) g_hCvarMode = CreateConVar("is_antismoke_mode", "1", "0 = passive, 1 = block enemy player transmit", 0, true, 0.0, true, 1.0);
    if (g_hCvarRadius == null) g_hCvarRadius = CreateConVar("is_antismoke_radius", "45.0", "Радиус дыма в игровых единицах", 0, true, 20.0, true, 80.0);

    // Инициализируем состояние до первого OnSettingsChanged().
    // Иначе callback мог обратиться к g_hSmokes до создания ArrayList.
    g_hSmokes = new ArrayList(sizeof(SmokeInfo));
    for (int i = 0; i < SMOKE_GRID_BUCKETS; i++)
        g_hSmokeGrid[i] = new ArrayList();
    g_iSmokeVisitToken = 0;

    g_hCvarEnabled.AddChangeHook(OnSettingsChanged);
    g_hCvarLogging.AddChangeHook(OnSettingsChanged);
    g_hCvarMode.AddChangeHook(OnSettingsChanged);
    g_hCvarRadius.AddChangeHook(OnSettingsChanged);
    OnSettingsChanged(null, "", "");
    HookEvent("smokegrenade_detonate", Event_SmokeDetonate, EventHookMode_Post);
    HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
    RegAdminCmd("is_antismoke_status", Command_Status, ADMFLAG_GENERIC, "Show anti-smoke status");
}

int SmokeCell(float value)
{
    return RoundToFloor(value / SMOKE_GRID_CELL_SIZE);
}

int SmokeBucket(int cellX, int cellY)
{
    int hash = (cellX * 73856093) ^ (cellY * 19349663);
    return hash & (SMOKE_GRID_BUCKETS - 1);
}

void RebuildSmokeGrid()
{
    for (int i = 0; i < SMOKE_GRID_BUCKETS; i++)
        g_hSmokeGrid[i].Clear();

    for (int i = 0; i < g_hSmokes.Length; i++)
    {
        SmokeInfo smoke;
        g_hSmokes.GetArray(i, smoke);
        g_hSmokeGrid[SmokeBucket(smoke.cellX, smoke.cellY)].Push(i);
    }
}

public void OnSettingsChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    bool wasEnabled = g_bEnabled;
    g_bEnabled = g_hCvarEnabled.BoolValue;
    g_iMode = g_hCvarMode.IntValue;
    g_fRadius = g_hCvarRadius.FloatValue;

    if (g_bEnabled && !wasEnabled && g_hSmokes.Length > 0)
        AntiSmoke_HookAll();
    else if (!g_bEnabled && wasEnabled)
        AntiSmoke_UnhookAll();
}

public void OnMapEnd()
{
    AntiSmoke_UnhookAll();
    if (g_hSmokes != null) g_hSmokes.Clear();
    RebuildSmokeGrid();
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bIsInSmoke[i] = false;
        g_bImmune[i] = false;
    }
}

public void OnClientPutInServer(int client)
{
    g_bIsInSmoke[client] = false;
    g_bImmune[client] = false;
    if (g_bEnabled && g_hSmokeLoop != INVALID_HANDLE)
        SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
}

public void OnClientPostAdminCheck(int client)
{
    if (IS_CLIENT(client))
        g_bImmune[client] = CheckCommandAccess(client, "is_immunity", ADMFLAG_CUSTOM1, true);
}

public void OnRebuildAdminCache(AdminCachePart part)
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i))
            g_bImmune[i] = CheckCommandAccess(i, "is_immunity", ADMFLAG_CUSTOM1, true);
}

public void OnClientDisconnect(int client)
{
    g_bIsInSmoke[client] = false;
    g_bImmune[client] = false;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_hSmokes.Clear();
    RebuildSmokeGrid();
    for (int i = 1; i <= MaxClients; i++) g_bIsInSmoke[i] = false;
    if (g_hSmokeLoop != INVALID_HANDLE) AntiSmoke_UnhookAll();
    return Plugin_Continue;
}

public Action Event_SmokeDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_bEnabled || g_iMode == 0 || g_hSmokes.Length >= MAX_SMOKES)
        return Plugin_Continue;

    Handle pack;
    CreateDataTimer(SMOKE_DELAYTIME, Timer_SmokeDeployed, pack, TIMER_FLAG_NO_MAPCHANGE);
    WritePackFloat(pack, event.GetFloat("x"));
    WritePackFloat(pack, event.GetFloat("y"));
    WritePackFloat(pack, event.GetFloat("z"));
    return Plugin_Continue;
}

public Action Timer_SmokeDeployed(Handle timer, any data)
{
    if (!g_bEnabled) return Plugin_Stop;

    Handle pack = view_as<Handle>(data);
    ResetPack(pack);
    SmokeInfo smoke;
    smoke.pos[0] = ReadPackFloat(pack);
    smoke.pos[1] = ReadPackFloat(pack);
    smoke.pos[2] = ReadPackFloat(pack);
    smoke.expiresAt = GetGameTime() + SMOKE_LIFETIME;
    smoke.cellX = SmokeCell(smoke.pos[0]);
    smoke.cellY = SmokeCell(smoke.pos[1]);
    g_hSmokes.PushArray(smoke);
    g_hSmokeGrid[SmokeBucket(smoke.cellX, smoke.cellY)].Push(g_hSmokes.Length - 1);

    AntiSmoke_HookAll();
    return Plugin_Stop;
}

public Action Timer_SmokeCheck(Handle timer)
{
    float now = GetGameTime();
    bool gridDirty = false;
    for (int idx = g_hSmokes.Length - 1; idx >= 0; idx--)
    {
        SmokeInfo smoke;
        g_hSmokes.GetArray(idx, smoke);
        if (smoke.expiresAt <= now)
        {
            g_hSmokes.Erase(idx);
            gridDirty = true;
        }
    }

    if (gridDirty) RebuildSmokeGrid();

    if (g_hSmokes.Length == 0)
    {
        AntiSmoke_UnhookAll();
        return Plugin_Stop;
    }

    float radiusSq = g_fRadius * g_fRadius;
    float clientPos[3];
    for (int client = 1; client <= MaxClients; client++)
    {
        g_bIsInSmoke[client] = false;
        if (!IsClientInGame(client) || IsFakeClient(client) || !IsPlayerAlive(client)) continue;
        if (g_bImmune[client]) continue;

        GetClientAbsOrigin(client, clientPos);
        int cellX = SmokeCell(clientPos[0]);
        int cellY = SmokeCell(clientPos[1]);
        g_iSmokeVisitToken++;
        if (g_iSmokeVisitToken <= 0)
        {
            g_iSmokeVisitToken = 1;
            for (int i = 0; i < MAX_SMOKES; i++) g_iSmokeVisit[i] = 0;
        }

        for (int dx = -1; dx <= 1 && !g_bIsInSmoke[client]; dx++)
        {
            for (int dy = -1; dy <= 1 && !g_bIsInSmoke[client]; dy++)
            {
                ArrayList bucket = g_hSmokeGrid[SmokeBucket(cellX + dx, cellY + dy)];
                for (int slot = 0; slot < bucket.Length; slot++)
                {
                    int smokeIndex = bucket.Get(slot);
                    if (smokeIndex < 0 || smokeIndex >= g_hSmokes.Length || g_iSmokeVisit[smokeIndex] == g_iSmokeVisitToken)
                        continue;
                    g_iSmokeVisit[smokeIndex] = g_iSmokeVisitToken;

                    SmokeInfo smoke;
                    g_hSmokes.GetArray(smokeIndex, smoke);
                    if (GetVectorDistance(clientPos, smoke.pos, true) <= radiusSq)
                    {
                        g_bIsInSmoke[client] = true;
                        break;
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}

public Action Hook_SetTransmit(int entity, int client)
{
    if (!g_bEnabled || g_iMode == 0 || !IS_CLIENT(client) || !IsClientInGame(client) ||
        !g_bIsInSmoke[client] || entity == client || entity < 1 || entity > MaxClients)
        return Plugin_Continue;

    if (!IsClientInGame(entity) || !IsPlayerAlive(entity)) return Plugin_Continue;
    if (GetClientTeam(entity) == GetClientTeam(client)) return Plugin_Continue;
    return Plugin_Handled;
}

void AntiSmoke_HookAll()
{
    if (g_hSmokeLoop != INVALID_HANDLE) return;
    g_hSmokeLoop = CreateTimer(0.10, Timer_SmokeCheck, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i)) SDKHook(i, SDKHook_SetTransmit, Hook_SetTransmit);
    }
}

void AntiSmoke_UnhookAll()
{
    if (g_hSmokeLoop != INVALID_HANDLE)
    {
        KillTimer(g_hSmokeLoop);
        g_hSmokeLoop = INVALID_HANDLE;
    }
    for (int i = 1; i <= MaxClients; i++)
    {
        g_bIsInSmoke[i] = false;
        if (IsClientInGame(i)) SDKUnhook(i, SDKHook_SetTransmit, Hook_SetTransmit);
    }
}

public Action Command_Status(int client, int args)
{
    PrintToConsole(client, "[IS Anti-Smoke] enabled=%s mode=%s radius=%.1f active_smokes=%i", g_bEnabled ? "ON" : "OFF", g_iMode ? "BLOCK" : "PASSIVE", g_fRadius, g_hSmokes.Length);
    return Plugin_Handled;
}

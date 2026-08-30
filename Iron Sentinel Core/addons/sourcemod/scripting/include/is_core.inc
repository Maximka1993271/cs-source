/*
    Iron Sentinel AntiCheat - Core API
    Version: 1.1.2
*/

#if defined _is_core_included
  #endinput
#endif
#define _is_core_included

// ===========================
//  NATIVE ФУНКЦИИ
// ===========================

/**
 * Забанить игрока через Iron Sentinel
 *
 * @param client        Индекс игрока
 * @param reason        Причина бана
 * @noreturn
 */
native void IS_BanClient(int client, const char[] reason);

/**
 * Записать действие игрока в лог
 *
 * @param client        Индекс игрока; 0 = серверный/системный контекст
 * @param format        Формат сообщения
 * @param ...           Аргументы
 * @noreturn
 */
native void IS_LogAction(int client, const char[] format, any ...);

/**
 * Отправить уведомление всем админам
 *
 * @param format        Формат сообщения
 * @param ...           Аргументы
 * @noreturn
 */
native void IS_PrintAdminNotice(const char[] format, any ...);

/**
 * Обработать обнаружение чита
 *
 * @param client        Индекс игрока
 * @param module        Название модуля
 * @param reason        Причина
 * @return              Plugin_Handled если игрок имеет иммунитет
 */
native int IS_CheatDetected(int client, const char[] module, const char[] reason);

/**
 * Получить длительность бана
 *
 * @return              Длительность в минутах (0 = перманент)
 */
native int IS_GetBanDuration();

/**
 * Проверить, включено ли логирование
 *
 * @return              true если логирование включено
 */
native bool IS_IsLoggingEnabled();

// ===========================
//  МАКРОСЫ
// ===========================

#define IS_CLIENT(%1) ((%1) >= 1 && (%1) <= MaxClients)
#define IS_VALID_CLIENT(%1) ((%1) >= 1 && (%1) <= MaxClients && IsClientInGame(%1))

// ===========================
//  ЗАГРУЗКА БИБЛИОТЕКИ
// ===========================

public SharedPlugin __pl_is_core =
{
    name = "is_core",
    file = "is_core.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_is_core_SetNTVOptional()
{
    MarkNativeAsOptional("IS_BanClient");
    MarkNativeAsOptional("IS_LogAction");
    MarkNativeAsOptional("IS_PrintAdminNotice");
    MarkNativeAsOptional("IS_CheatDetected");
    MarkNativeAsOptional("IS_GetBanDuration");
    MarkNativeAsOptional("IS_IsLoggingEnabled");
}
#endif
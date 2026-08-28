# 🛡️ IRON SENTINEL

<p align="center">
  <b>Полный античит для Counter-Strike: Source</b><br/>
  <b>23 модуля • 85+ настроек • SQLite/MySQL • 30+ языков</b>
</p>

<p align="center">
  <a href="https://github.com/Maximka1993271/cs-source/releases/download/v1.0.0/Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip">
    <img src="https://img.shields.io/badge/%E2%AC%87%EF%B8%8F%20DOWNLOAD-v1.1.2-2ea44f?style=for-the-badge&logo=github" alt="Download Iron Sentinel v1.1.2"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source/releases">
    <img src="https://img.shields.io/badge/Releases-all%20versions-1f6feb?style=for-the-badge&logo=github" alt="GitHub Releases"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-GPLv3-green.svg?style=for-the-badge&logo=opensourceinitiative" alt="GPLv3 License"/>
  </a>
</p>

<p align="center">
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/github/downloads/Maximka1993271/cs-source/total.svg?style=for-the-badge&logo=github" alt="Downloads"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/badge/Open%20Source-%E2%9C%85-brightgreen.svg?style=for-the-badge" alt="Open Source"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge&logo=github" alt="PRs Welcome"/>
  </a>
</p>

<p align="center">
  <b>🛡️ Защита сервера • ⚡ Производительность • 🔒 Локальный анализ • 🗄️ SQLite/MySQL</b>
</p>

---

## 🚀 Быстрый старт

|                       | Ссылка                                                                                                                                                                |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ⬇️ **Скачать v1.1.2** | **[Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip]([https://github.com/Maximka1993271/cs-source/releases/download/v1.0.0/Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip](https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip))** |
| 🏷️ **Все релизы**    | **[GitHub Releases](https://github.com/Maximka1993271/cs-source/releases)**                                                                                           |
| 💻 **Исходный код**   | **[Maximka1993271/cs-source](https://github.com/Maximka1993271/cs-source)**                                                                                           |
| 📜 **Лицензия**       | **[GPLv3](https://github.com/Maximka1993271/cs-source/blob/main/LICENSE)**                                                                                            |

> **v1.1.2 Build & Runtime Fixes** — исправления компиляции и запуска, включая `is_aimbot`, `is_wallhack`, `is_antismoke`, `is_banlist` и `is_core`.
>
> Для применения изменений из исходников необходимо пересобрать соответствующие `.sp` в `.smx` с помощью `spcomp`.

---

## ⚠️ Официальный источник

> **🚨 ВНИМАНИЕ: Это ЕДИНСТВЕННЫЙ официальный канал распространения IRON SENTINEL.**
>
> Античит публикуется **ТОЛЬКО на GitHub** в этом репозитории:
> **https://github.com/Maximka1993271/cs-source**
>
> **Я НЕ выкладываю этот античит на:**
>
> * ❌ AlliedModders
> * ❌ SourceMod плагины
> * ❌ Другие сайты, файлообменники или социальные сети
>
> **Если вы найдёте этот античит где-то ещё — это НЕ оригинальная версия и может содержать вредоносный код.**
>
> **Всегда скачивайте только из официального репозитория GitHub!**

---

## 🔒 Приватность

Весь анализ производится локально на сервере.
Без рекламы, трекинга, телеметрии или сбора данных пользователей.
**Ваша приватность полностью защищена.**

---

---

## 📦 Что входит в релиз

### 23 модуля защиты

| №  | Модуль           | Функция                                                |
| -- | ---------------- | ------------------------------------------------------ |
| 1  | `is_core`        | Ядро, бан, логирование, уведомления, API               |
| 2  | `is_commands`    | Блокировка опасных консольных команд                   |
| 3  | `is_cvars`       | Проверка подозрительных клиентских настроек            |
| 4  | `is_antispam`    | Защита от спама подключениями, сменой ника и командами |
| 5  | `is_speedhack`   | Детектор аномальной скорости                           |
| 6  | `is_aimbot`      | Детектор подозрительных аим-событий                    |
| 7  | `is_wallhack`    | Проверка видимости и подозрительной информации о целях |
| 8  | `is_eyetest`     | Проверка углов обзора                                  |
| 9  | `is_autotrigger` | Обнаружение подозрительного авто-огня и поведения      |
| 10 | `is_spinhack`    | Детектор спинхака                                      |
| 11 | `is_antiflash`   | Защита от подозрительного поведения с flashbang        |
| 12 | `is_antismoke`   | Защита от подозрительного поведения с smoke            |
| 13 | `is_rcon`        | Защита RCON                                            |
| 14 | `is_banlist`     | Проверка и кэширование бан-листов                      |
| 15 | `is_aimlock`     | Детектор подозрительной фиксации прицела               |
| 16 | `is_macro`       | Детектор подозрительных последовательностей ввода      |
| 17 | `is_nolerp`      | Проверка аномальных настроек интерполяции              |
| 18 | `is_backtrack`   | Контроль подозрительных backtrack-сценариев            |
| 19 | `is_ping`        | Контроль максимального ping                            |
| 20 | `is_chatclear`   | Защита от очистки чата                                 |
| 21 | `is_anglepatch`  | Контроль аномальных углов                              |
| 22 | `is_dll`         | DLL Detection при наличии соответствующего расширения  |
| 23 | `is_database`    | Логирование в SQLite/MySQL                             |

---

## ✨ Основные возможности

* ✅ 23 независимых защитных модуля
* ✅ единый конфиг Iron Sentinel
* ✅ SQLite / MySQL через SourceMod Database API
* ✅ кэширование часто используемых данных
* ✅ защита от повторной загрузки и некорректной инициализации
* ✅ fail-safe обработка системного `client = 0`
* ✅ административная система с иммунитетом
* ✅ мультиязычные переводы
* ✅ логирование действий и подозрительных событий
* ✅ безопасная обработка отключившихся игроков
* ✅ минимизация лишних таймеров и повторных операций

---

# 🔧 Исправления версии 1.1.2

## `is_aimbot.sp`

Исправлена ошибка компиляции:

```text
error 017: undefined symbol "iSnaps"
error 017: undefined symbol "fMaxSnap"
```

Причина:

После изменения названий локальных переменных старые имена всё ещё использовались в вызове обработчика.

Исправлено на актуальные переменные:

```sourcepawn
HandleAimbotDetection(client, snaps, maxSnap, fDistance);
```

---

## `is_wallhack.sp`

Исправлена ошибка SourcePawn:

```text
error 008: must be a constant expression
```

Проблемный код использовал runtime-значения внутри initializer массива:

```sourcepawn
float top[3] = {
    center[0],
    center[1],
    g_vTargetPos[entity][2] + g_vMaxs[entity][2]
};
```

Исправлено на пошаговое заполнение массива:

```sourcepawn
float top[3];
top[0] = center[0];
top[1] = center[1];
top[2] = g_vTargetPos[entity][2] + g_vMaxs[entity][2];
```

Это совместимо с компилятором SourcePawn 1.12.

---

## `is_antismoke.sp`

Исправлена критическая ошибка запуска:

```text
Exception reported: Invalid Handle 0
ArrayList.Length.get
```

### Причина

`ArrayList` использовался внутри `OnSettingsChanged()` раньше, чем создавался.

### Исправление

Теперь необходимые структуры данных создаются **до первого вызова обработки настроек**.

Дополнительно удалён неиспользуемый `g_bLogging`, который вызывал:

```text
warning 204: symbol is assigned a value that is never used
```

---

## `is_banlist.sp`

Исправлена ошибка запуска:

```text
Exception reported: Invalid client index 0
```

### Причина

При загрузке бан-листов на старте сервера:

```text
ReloadCaches()
```

вызывал:

```text
IS_LogAction()
```

с `client = 0`.

На старте сервера это нормальный системный контекст, а не игровой клиент.

### Исправление

`client = 0` теперь безопасно обрабатывается как:

```text
SERVER / SYSTEM
```

и не вызывает `ThrowNativeError`.

Это также предотвращает падение/выгрузку `is_banlist.smx` при старте.

---

## `is_core.sp`

Улучшена обработка `client` во внутренних API.

Теперь логирование корректно работает для:

```text
client = 0
```

когда действие выполняется сервером, базовым таймером, database callback или другим системным процессом.

Для реального игрового клиента по-прежнему выполняется проверка валидности индекса.

---

# 🛡️ Fail-Safe архитектура

Iron Sentinel не должен создавать ложный бан из-за ошибки самого сервера.

Поэтому в новой версии применяется принцип:

```text
сомнение → логирование/счётчик
ошибка состояния → пропуск проверки
подтверждённое нарушение → действие
```

Ошибки handles, отсутствующий клиент, неполностью инициализированный модуль или временно недоступные данные не должны автоматически считаться читом.

---

# ⚡ Производительность

В версии 1.1.x проведена оптимизация:

* повторное получение одинаковых данных сокращено;
* тяжёлые операции выполняются только при необходимости;
* временные данные кэшируются;
* очищаются состояния отключившихся игроков;
* исключены ненужные обращения к API;
* исключена работа с неинициализированными handles;
* database callbacks не должны блокировать игровой поток;
* внутренние проверки выполняются только для валидных игроков.

Основная цель:

**минимальная нагрузка на tick loop без снижения стабильности сервера.**

---

# 🧠 Кэширование

Для часто используемых данных используется внутренний cache.

Кэш применяется там, где повторное обращение к данным не имеет смысла выполнять каждый tick или callback.

При изменении конфигурации или отключении игрока соответствующее состояние очищается/перезагружается.

---

# 🚫 Ложные срабатывания

Некоторые детекторы специально работают консервативно.

Например:

### Anti-Smoke

Сам факт нахождения игрока в smoke **не является доказательством чита**.

### Anti-Flash

Сам факт получения flash не является доказательством использования anti-flash.

### Macro

Одиночное быстрое нажатие не считается макросом. Анализируются повторяющиеся подозрительные последовательности.

### NoLerp

Одного подозрительного значения недостаточно для автоматического наказания.

### Backtrack

Подозрительное backtrack-поведение не должно автоматически приводить к бану без дополнительного подтверждения.

---

# 📋 Требования

* **Counter-Strike: Source**
* **SourceMod 1.12.0.7251 или новее**
* **Metamod:Source 1.12.x**
* SDKHooks из состава SourceMod
* Для DLL Detection требуется совместимое AntiDLL/SDK-расширение

---

# 📁 Основные файлы

```text
addons/sourcemod/plugins/
├── is_core.smx
├── is_commands.smx
├── is_cvars.smx
├── is_antispam.smx
├── is_speedhack.smx
├── is_aimbot.smx
├── is_wallhack.smx
├── is_eyetest.smx
├── is_autotrigger.smx
├── is_spinhack.smx
├── is_antiflash.smx
├── is_antismoke.smx
├── is_rcon.smx
├── is_banlist.smx
├── is_aimlock.smx
├── is_macro.smx
├── is_nolerp.smx
├── is_backtrack.smx
├── is_ping.smx
├── is_chatclear.smx
├── is_anglepatch.smx
├── is_dll.smx
└── is_database.smx
```

Исходный код:

```text
addons/sourcemod/scripting/
├── is_core.sp
├── is_commands.sp
├── is_cvars.sp
├── is_antispam.sp
├── is_speedhack.sp
├── is_aimbot.sp
├── is_wallhack.sp
├── is_eyetest.sp
├── is_autotrigger.sp
├── is_spinhack.sp
├── is_antiflash.sp
├── is_antismoke.sp
├── is_rcon.sp
├── is_banlist.sp
├── is_aimlock.sp
├── is_macro.sp
├── is_nolerp.sp
├── is_backtrack.sp
├── is_ping.sp
├── is_chatclear.sp
├── is_anglepatch.sp
├── is_dll.sp
└── is_database.sp
```

---

# ⚙️ Конфигурация

Основной конфиг:

```text
addons/sourcemod/configs/is_config.cfg
```

Дополнительные SourceMod-конфиги:

```text
addons/sourcemod/configs/admins.cfg
addons/sourcemod/configs/admin_groups.cfg
addons/sourcemod/configs/admin_overrides.cfg
addons/sourcemod/configs/databases.cfg
```

Файлы с расширением:

```text
.example
```

являются только шаблонами и автоматически SourceMod не загружаются.

---

# 👑 Администратор

Пример администратора:

```text
"STEAM_0:1:97711058" "99:z"
```

Расшифровка:

```text
99 = immunity level
z  = root
```

Администратор имеет полный набор прав SourceMod и высокий уровень иммунитета.

---

# 🗄️ Database

Iron Sentinel поддерживает:

```text
SQLite
MySQL / MariaDB
```

Для одного сервера рекомендуется SQLite:

```text
is_anticheat_sqlite
```

SQLite не требует отдельного SQL-сервера.

База хранится в каталоге SourceMod:

```text
addons/sourcemod/data/sqlite/
```

### Важно

Если на сервере уже существует:

```text
addons/sourcemod/configs/databases.cfg
```

не заменяйте его полностью.

Добавляйте конфигурацию Iron Sentinel в существующий блок:

```text
"Databases"
{
    ...
}
```

чтобы не потерять базы других плагинов.

---

# 🔨 Компиляция

После изменения `.sp` необходимо пересобрать соответствующий `.smx`.

Для Windows можно использовать:

```text
tools/compile_all_windows.bat
```

или:

```text
tools/compile_runtime_fix_windows.bat
```

Компилятор:

```text
spcomp.exe
```

должен соответствовать используемой версии SourceMod.

---

# ⚠️ Важное замечание о `.smx`

Исходники `.sp` являются основным исправленным кодом.

Если архив содержит старые `.smx`, созданные до последних изменений, их необходимо **перекомпилировать** из актуальных `.sp`.

Нельзя считать старый `.smx` эквивалентным исправленному исходнику только потому, что файл имеет то же имя.

После компиляции необходимо заменить соответствующий `.smx` в:

```text
addons/sourcemod/plugins/
```

---

# 🧪 Проверка после установки

После запуска сервера выполните:

```text
sm plugins list
```

Проверьте, что модули:

```text
is_core
is_antismoke
is_banlist
is_database
```

имеют статус:

```text
running
```

Также рекомендуется проверить:

```text
addons/sourcemod/logs/
```

на отсутствие:

```text
Invalid Handle
Invalid client index
Plugin startup error
```

---

# 🔍 Ожидаемые сообщения

При штатном запуске возможны обычные системные сообщения Source:

```text
Connection to Steam servers successful.
VAC secure mode is activated.
Server is hibernating
```

Они не являются ошибками Iron Sentinel.

Если DLL Detection не имеет соответствующего расширения, возможно:

```text
[IRON SENTINEL] AntiDLL extension not found. DLL detection in limited mode.
```

В этом случае остальные модули продолжают работать.

---

# 📊 Диагностика

Если плагин не загрузился, сначала проверить:

```text
addons/sourcemod/logs/
addons/sourcemod/scripting/
addons/sourcemod/plugins/
addons/metamod/
```

и выполнить:

```text
sm plugins list
meta list
```

После этого проверить ошибки в:

```text
addons/sourcemod/logs/errors_*.txt
```

---

# 📦 Содержание исходного релиза

Релиз содержит:

* 23 `.sp`
* соответствующие `.smx` из сборочного комплекта
* include-файлы
* translations
* конфигурационные примеры
* скрипты компиляции
* документацию
* отчёт аудита
* информацию об исправлениях

---

# 📜 История исправлений

## v1.1.2

### Runtime fixes

* исправлена инициализация `ArrayList` в `is_antismoke`;
* исправлена обработка `client = 0` в `is_core`;
* исправлен стартовый вызов `ReloadCaches()` в `is_banlist`;
* исключены startup exceptions;
* улучшена безопасная работа database callbacks;
* добавлена защита от обращения к невалидным client index;
* улучшена очистка runtime-состояния.

### Compile fixes

* исправлен `undefined symbol "iSnaps"` в `is_aimbot`;
* исправлен `undefined symbol "fMaxSnap"` в `is_aimbot`;
* исправлен `error 008` в `is_wallhack`;
* убран warning `g_bLogging` в `is_antismoke`.

### Stability

* добавлена fail-safe обработка;
* уменьшена вероятность ложных банов;
* улучшена обработка серверных событий;
* исправлен порядок инициализации отдельных модулей.

---

## v1.1.1

* исправлены проблемы компиляции нескольких модулей;
* улучшена совместимость с SourcePawn 1.12;
* исправлены runtime-инициализации;
* добавлены инструкции автоматической компиляции.

---

## v1.0.0

Первоначальный релиз:

* 23 защитных модуля;
* централизованный конфиг;
* админ-система;
* SQLite/MySQL;
* логирование;
* мультиязычные переводы.

---

# 📝 Лицензия

**GPLv3**

---

# 🙏 Благодарности

* **SourceMod Dev Team** — за SourceMod
* **Metamod:Source Team** — за Metamod:Source
* **SMAC Development Team** — за идеи и методы античита
* **Little Anti-Cheat (Lilac)** — за идеи модулей
* **AntiDLL** — за концепцию DLL Detection

Iron Sentinel является самостоятельным проектом и не является официальным продуктом перечисленных проектов.

---

# 📞 Контакты

**GitHub:**
https://github.com/Maximka1993271

**Автор:**
Maxim Melnikov

---

# 🛡️ IRON SENTINEL

**Protection active.**

```text
[IRON SENTINEL] Core initialized.
[IRON SENTINEL] Protection modules loaded.
```

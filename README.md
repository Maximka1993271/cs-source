# 🛡️ IRON SENTINEL

<p align="center">
  <b>Полный античит для Counter-Strike: Source</b><br/>
  <b>23 модуля • 86 настроек • SQLite/MySQL • 30+ языков</b><br/>
  <b>v1.1.2 • Build & Runtime Fixes • Cross-Map Stability</b>
</p>

<p align="center">
  <a href="https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip">
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
  <b>🛡️ Защита сервера • ⚡ Производительность • 🔄 Cross-Map Safe • 🗄️ SQLite/MySQL</b>
</p>

<p align="center">
  <b>⭐ Техническая оценка: 4.5/5 • 9.0/10</b><br/>
  <sub>v1.1.2: 23/23 SourcePawn modules compiled with 0 errors / 0 warnings in the audited build.</sub><br/>
  <sub>Оценка отражает текущее техническое состояние проекта и не является официальным рейтингом GitHub.</sub>
</p>

---

## 🚀 Быстрый старт

|                       | Ссылка                                                                                                                                                               |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ⬇️ **Скачать v1.1.2** | **[Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip](https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip)** |
| 🏷️ **Все релизы**    | **[GitHub Releases](https://github.com/Maximka1993271/cs-source/releases)**                                                                                          |
| 💻 **Исходный код**   | **[Maximka1993271/cs-source](https://github.com/Maximka1993271/cs-source)**                                                                                          |
| 📜 **Лицензия**       | **[GPLv3](https://github.com/Maximka1993271/cs-source/blob/main/LICENSE)**                                                                                           |

> **v1.1.2 Build & Runtime Fixes** — исправления компиляции и запуска, включая `is_aimbot`, `is_wallhack`, `is_antismoke`, `is_banlist` и `is_core`.
>
> Для применения изменений из исходников необходимо пересобрать соответствующие `.sp` в `.smx` с помощью `spcomp`.

### ✅ Что нового в v1.1.2

* 🔧 Исправлены compile/runtime ошибки SourcePawn 1.12.
* 🧠 `is_aimbot` — постоянный ring buffer истории углов без временного массива в hot path.
* 👁️ `is_wallhack` — bounded trace budget, ранние выходы, runtime metrics и безопасный map-change lifecycle.
* ⚡ `is_speedhack` — кэширование порогов/velocity checks, reset peak-state и исправление cross-map timing.
* 💨 `is_antismoke` — spatial grid и безопасное восстановление индексов после удаления smoke.
* 📦 `is_banlist` — mtime cache: неизменившиеся списки не парсятся повторно.
* 🧩 `is_core` — безопасный `client = 0`, ранняя ConVar/native safety.
* 🗄️ `is_database` — auto-reconnect `5 → 10 → 20 → 40 → 60s`, health-check и stale-callback protection.
* 🔄 Исправлен client-slot reuse во всех критичных stateful-модулях.
* 🗺️ Исправлен критический AntiSpam bug при смене карты: `GetGameTime()` заменён на monotonic timing + map-transition IP recognition.
* ⏱️ Исправлен lifecycle persistent timers, которые могли исчезать после `changelevel`.
* 🛡️ Fail-safe обработка снижает риск ложных наказаний и startup exceptions.
* 🧪 Добавлены regression tests для cross-map timing и client-slot reuse.
* 🤖 Добавлен/исправлен GitHub Actions CI/CD и strict build pipeline.

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
* ✅ 86 настроек в `is_config.cfg`
* ✅ SQLite / MySQL через SourceMod Database API
* ✅ кэширование часто используемых данных
* ✅ автоматическое восстановление подключения к базе данных
* ✅ bounded trace budget и метрики нагрузки
* ✅ оптимизированные hot-path проверки для серверов с 20+ игроками
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

## 🚀 Оптимизация v1.1.2

### `is_aimbot`

История углов хранится в постоянном кольцевом буфере с актуальным индексом. В горячем пути `OnPlayerRunCmd` / `AnalyzeAngles` не создаётся временный массив истории на каждый вызов.

### `is_wallhack`

Трассировки ограничиваются bounded budget. Добавлены ранние проверки и runtime-метрики trace-window, включая количество проверок и пропущенных операций.

### `is_speedhack`

Сокращены повторные обращения и вычисления порогов скорости. Runtime и peak state корректно сбрасываются при reuse client slot.

### `is_antismoke`

Добавлено пространственное кэширование/grid. После удаления smoke индексы безопасно перестраиваются, поэтому `ArrayList` не используется с устаревшими индексами.

### `is_banlist`

Добавлена проверка времени изменения файлов: неизменившиеся бан-листы не парсятся повторно.

### `is_core`

Оптимизирован горячий путь логирования и уменьшены лишние проверки/форматирование строк.

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

Production-релиз не содержит файлов `.example`.

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

### 🔄 Автоматическое восстановление

При временной потере SQL-соединения `is_database` автоматически выполняет повторное подключение с backoff:

```text
5 → 10 → 20 → 40 → 60 секунд
```

После восстановления создаётся новое поколение database state, а устаревшие callbacks игнорируются. Это предотвращает использование недействительного соединения или старого состояния игрока.

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

Для строгой проверки без предупреждений:

```text
tools/compile_strict_windows.bat
```

Строгий режим считает любой `warning` ошибкой сборки.

### 🧪 Regression tests

Проект содержит автоматические regression/unit проверки и benchmark-тесты для критичных частей античита.

Проверяются 23 исходных модуля, версия `1.1.2`, `Author: Maxim Melnikov`, обязательные include/dependency checks, 86 настроек `is_config.cfg` и отсутствие `.example` в production package. В последнем аудите добавлены regression cases для cross-map timing, timer lifecycle, database reconnect и client-slot reuse.

### 🤖 CI/CD

GitHub Actions выполняет статическую проверку, regression tests, строгую сборку SourcePawn и подготовку production release package.

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
* production-конфигурация
* скрипты компиляции
* документацию
* отчёт аудита
* информацию об исправлениях

Production package не содержит `.example` файлов, фиктивных SteamID или тестовых паролей. Личные пути разработчика из build scripts удалены.

### 🧾 Source Metadata

Все 23 `.sp` приведены к единому профилю:

```text
Version: 1.1.2
Author: Maxim Melnikov
```

Дополнительно исправлены остаточные compile/runtime проблемы:

* `is_database.sp` — устранён вызов отсутствующего `IS_VALID_CLIENT()`; client validation выполняется локально.
* `is_wallhack.sp` — добавлено и корректно инициализируется `g_fWindowStartedAt`.
* `is_core.sp` — защищены ранние обращения к ConVar до полной инициализации.
* `is_banlist.sp` — стартовый `ReloadCaches()` не зависит от ещё неготового Core.
* исправлена очистка состояния для повторного использования client slot.

---

# 📜 Release Notes

## v1.1.2

Текущий production-релиз объединяет compile, runtime, reliability, performance и QA исправления.

Ключевые изменения:

- 23/23 SourcePawn modules rebuilt.
- 0 compiler errors / 0 warnings in the audited build.
- Cross-map AntiSpam timing fix.
- Persistent timer lifecycle fixes.
- Client-slot reuse protection.
- Database auto-reconnect and stale callback protection.
- 86/86 synchronized CVAR.
- EN/RU configuration documentation.
- Aimbot ring-buffer optimization.
- Wallhack trace budget and metrics.
- AntiSmoke spatial grid.
- Banlist mtime cache.
- RCON duplicate-hook protection.
- Graceful AntiDLL degradation.
- Regression and benchmark coverage.
- Strict build and GitHub Actions CI/CD.


---

# 🗺️ Cross-Map Reliability

После тестирования на реальном CS:S сервере был обнаружен критический сценарий:

```text
Map A
  ↓
changelevel
  ↓
Source re-runs the connection lifecycle
  ↓
GetGameTime() starts again near 0
  ↓
старый reconnect timestamp выглядит "слишком свежим"
  ↓
игрок получает ложный AntiSpam kick
```

В `is_antispam` проблема исправлена двумя независимыми механизмами:

- persistent reconnect timing переведён на `GetTickedTime()`;
- `OnMapEnd()` сохраняет IP игроков, которые легитимно находились в игре, а следующий map-transition reconnect распознаётся отдельно.

При этом обычный быстрый reconnect внутри одной карты по-прежнему проходит через AntiSpam.

Аналогичный аудит времени проведён в:

```text
is_ping
is_backtrack
is_aimbot
is_eyetest
is_macro
is_speedhack
```

Map-local `GetGameTime()` оставлен только там, где он действительно относится к текущей карте.

---

# ⏱️ Timer & Handle Reliability

Проверен lifecycle persistent timers во всех 23 модулях.

Исправлены таймеры, которые могли молча погибать после `changelevel` из-за `TIMER_FLAG_NO_MAPCHANGE`, в том числе:

```text
is_wallhack
is_database
is_banlist
is_speedhack
is_autotrigger
is_eyetest
is_cvars
```

Дополнительно проверены:

```text
CreateTimer()
CreateDataTimer()
KillTimer()
OnMapStart()
OnMapEnd()
OnPluginEnd()
```

Цель:

```text
map change
→ no stale handle
→ no lost persistent loop
→ no invalid callback
```

---

# 👤 Client Slot Safety

Проведён аудит всех state-массивов `[MAXPLAYERS + 1]`.

Проверен сценарий:

```text
Player A → slot 5
disconnect
Player B → slot 5
```

Исправлены реальные случаи наследования состояния в:

```text
is_ping
is_antispam
is_spinhack
```

и повторно проверены:

```text
is_aimbot
is_aimlock
is_speedhack
is_macro
is_nolerp
is_database
```

---

# 🗄️ Database Reliability

`is_database` поддерживает:

```text
SQLite
MySQL / MariaDB
```

При потере соединения используется backoff:

```text
5 → 10 → 20 → 40 → 60 seconds
```

Защита включает:

- отсутствие duplicate reconnect timers;
- health-check;
- generation/token protection;
- игнорирование stale callbacks;
- безопасный client-slot lifecycle;
- корректную работу при map change и plugin reload.

Для одного сервера рекомендуется SQLite.

---

# ⚙️ Configuration Integrity

Финальный аудит `CreateConVar()` и `is_config.cfg`:

```text
86 / 86 CVAR
Missing: 0
Extra: 0
Duplicates: 0
Default mismatches: 0
Bounds mismatches: 0
```

`is_config.cfg` содержит EN/RU документацию.

Это означает, что runtime defaults и production configuration не должны зависеть от случайного порядка загрузки модулей.

---

# 🧪 Verification Status

Подтверждено:

```text
23 / 23 SourcePawn modules compiled
0 errors
0 warnings
23 / 23 current .smx binaries
86 / 86 CVAR synchronized
0 .example files in production package
```

В последнем аудите добавлены regression cases для cross-map timing, client-slot reuse и timer lifecycle.

> **Runtime CS:S status:** статический аудит и компиляция не заменяют длительное тестирование на живом сервере. После установки рекомендуется отдельно проверить `changelevel`, reconnect/disconnect, DB reconnect и plugin reload.

---

# 🔐 Security & Production Hygiene

- `admins.cfg` использует авторизованный SteamID `STEAM_0:1:97711058`.
- Удалены hardcoded developer-machine paths из build scripts.
- Production configuration не содержит реальные DB/API/RCON secrets.
- Optional AntiDLL dependency работает в limited mode без падения остальных модулей.
- `.example`, `.pyc` и `__pycache__` не входят в production package.

---

# 📦 Release Asset

Официальный архив:

```text
Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip
```

[⬇️ Скачать Iron Sentinel v1.1.2](https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.v1.1.2.Build.Runtime.Fixes.zip)

[🏷️ GitHub Releases](https://github.com/Maximka1993271/cs-source/releases)

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

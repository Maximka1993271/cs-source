<div align="center">

# 🛡️ Iron Sentinel Core v1.1.2

</div>

<p align="center">
  <b>Production-oriented Anti-Cheat для Counter-Strike: Source</b><br/>
  <b>24 модуля • 93 настройки • SQLite/MySQL • ML-assisted detection</b><br/>
  <b>Build • Runtime • Reliability • Fail-safe • Performance</b>
</p>

<p align="center">
  <a href="https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.Core.v1.1.2.zip">
    <img src="https://img.shields.io/badge/%E2%AC%87%EF%B8%8F%20DOWNLOAD-v1.1.2-2ea44f?style=for-the-badge&logo=github" alt="Download Iron Sentinel Core v1.1.2"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source/releases">
    <img src="https://img.shields.io/badge/Releases-GitHub-1f6feb?style=for-the-badge&logo=github" alt="GitHub Releases"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/badge/SourceMod-1.12.x-blue?style=for-the-badge" alt="SourceMod 1.12.x"/>
  </a>
</p>

<p align="center">
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/badge/Modules-24-success?style=flat-square" alt="24 Modules"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/badge/CVAR-93-success?style=flat-square" alt="93 CVAR"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/badge/SQLite%20%2F%20MySQL-supported-success?style=flat-square" alt="SQLite / MySQL"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-GPLv3-green?style=flat-square" alt="GPLv3"/>
  </a>
</p>

<p align="center">
  <b>🛡️ Server Protection • ⚡ Optimized Hot Paths • 👁️ Visibility Analysis • 🤖 ML Signal • 🗄️ Database Recovery</b>
</p>

<p align="center">
  <b>⭐ Техническая оценка: 3.8 / 5 • 7.6 / 10</b><br/>
  <sub>Оценка отражает текущее техническое состояние проекта и не является официальным рейтингом GitHub.</sub>
</p>

---

# 🚀 Быстрый старт

|                       |                                                                                                                                        |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ⬇️ **Скачать v1.1.2** | **[Iron.Sentinel.Core.v1.1.2.zip](https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.Core.v1.1.2.zip)** |
| 🏷️ **Все релизы**    | **[GitHub Releases](https://github.com/Maximka1993271/cs-source/releases)**                                                            |
| 💻 **Исходный код**   | **[GitHub Repository](https://github.com/Maximka1993271/cs-source)**                                                                   |
| 📜 **Лицензия**       | **[GPLv3](https://github.com/Maximka1993271/cs-source/blob/main/LICENSE)**                                                             |

> **Iron Sentinel Core v1.1.2** — обновление Build, Runtime & Reliability с исправлениями компиляции, startup exceptions, cross-map timing, timer lifecycle, client-slot reuse, database recovery, ML model loading и производительности.

---

# 🆕 Что нового в v1.1.2

### 🔧 Build / Compilation

* ✅ Исправлены ошибки `iSnaps` и `fMaxSnap` в `is_aimbot`.
* ✅ Исправлен runtime array initializer в `is_wallhack`.
* ✅ Исправлена ссылка на отсутствующий `IS_VALID_CLIENT` в `is_database`.
* ✅ Добавлена корректная инициализация `g_fWindowStartedAt`.
* ✅ Удалено неиспользуемое состояние `g_bLogging` из `is_antismoke`.
* ✅ Исправлены дополнительные SourcePawn 1.12 compatibility issues.
* ✅ Исправлено использование неподдерживаемого `Max()` в `is_wallhack`.

### 🛡️ Runtime / Stability

* ✅ Исправлен `Invalid Handle 0` в `is_antismoke`.
* ✅ Исправлен `Invalid client index 0` при загрузке `is_banlist`.
* ✅ Усилена server/system context обработка в `is_core`.
* ✅ Улучшена очистка client state.
* ✅ Исправлены stale states при reuse client slot.
* ✅ Исправлен timer lifecycle после смены карты.
* ✅ Улучшена обработка late load / reload / disconnect / reconnect.

### 🗺️ Cross-Map

Исправлен критический AntiSpam timing bug:

```text
Map A
  ↓
changelevel
  ↓
Map B
  ↓
legitimate reconnect
  ↓
не считается connection spam
```

Persistent timing переведён на monotonic clock там, где `GetGameTime()` мог приводить к неправильным результатам после смены карты.

### 👁️ Wallhack / Visibility

`is_wallhack` использует bounded trace budget, cache, ранние проверки и runtime metrics.

Отслеживаются:

```text
trace budget
trace usage
visibility checks
trace drops
blocked events
window timing
trace utilization
```

При ошибке или недостатке runtime-информации используется fail-open подход.

### 💨 Anti-Smoke

* ✅ Spatial grid.
* ✅ Безопасная работа с динамическими smoke.
* ✅ Защита от устаревших индексов.
* ✅ Оптимизация количества `players × smokes` проверок.

### 🎯 Aimbot

* ✅ Persistent angle ring buffer.
* ✅ Убрано создание временной истории в hot path.
* ✅ Улучшен reset состояния.
* ✅ Более консервативная оценка подозрительных снапов.

### ⚡ Speedhack

* ✅ Кэширование порогов скорости.
* ✅ Снижение повторных вычислений.
* ✅ Исправлен reset peak state.
* ✅ Улучшен timer lifecycle.

### 🗄️ Database

* ✅ SQLite.
* ✅ MySQL / MariaDB.
* ✅ Async callbacks.
* ✅ Automatic reconnect.
* ✅ Retry backoff:

```text
5 → 10 → 20 → 40 → 60 секунд
```

* ✅ Защита от stale callbacks.
* ✅ Health checks.
* ✅ Безопасный `client = 0` server context.

### 🤖 Machine Learning

В релиз добавлен отдельный необязательный модуль:

```text
is_ml.smx
```

Архитектура:

```text
23 classical detectors
        +
1 ML signal module
        ↓
24 total modules
```

ML работает локально и не требует Python, HTTP API или внешнего сервера во время игры.

Текущая модель:

```text
Model version: 1.0.0-synthetic
Schema version: 1
Features: 7
Checksum: 1504619244
```

### ✅ Live ML verification

На реальном Counter-Strike: Source сервере подтверждена успешная загрузка модели:

```text
[ML] Model loaded: version=1.0.0-synthetic schema=1 features=7 checksum=1504619244 (verified)
```

Также подтверждено:

```text
model_valid=1
```

и успешный reload модели через:

```text
is_ml_reload
```

---

# 🛡️ Fail-Safe Architecture

Iron Sentinel придерживается принципа:

```text
подозрение
    ↓
счётчик / наблюдение
    ↓
дополнительные признаки
    ↓
подтверждение
    ↓
действие
```

Ошибки runtime-состояния:

```text
invalid client
invalid entity
invalid handle
missing optional dependency
unavailable data
```

не должны автоматически превращаться в бан.

Для ML:

```text
invalid model
    ↓
ML disabled
    ↓
23 classical modules continue
```

---

# 📦 24 модуля

|  № | Модуль           | Назначение                                |
| -: | ---------------- | ----------------------------------------- |
|  1 | `is_core`        | Core API, logging, ban, configuration     |
|  2 | `is_commands`    | Command protection                        |
|  3 | `is_cvars`       | Client ConVar checks                      |
|  4 | `is_antispam`    | Connection/name/team spam protection      |
|  5 | `is_speedhack`   | Speed anomaly detection                   |
|  6 | `is_aimbot`      | Aimbot detection                          |
|  7 | `is_wallhack`    | Visibility / trace analysis               |
|  8 | `is_eyetest`     | Eye-angle sanity                          |
|  9 | `is_autotrigger` | Trigger automation detection              |
| 10 | `is_spinhack`    | Spin detection                            |
| 11 | `is_antiflash`   | Flash-related protection                  |
| 12 | `is_antismoke`   | Smoke-related protection                  |
| 13 | `is_rcon`        | RCON protection                           |
| 14 | `is_banlist`     | Cached external banlists                  |
| 15 | `is_aimlock`     | Aim-lock detection                        |
| 16 | `is_macro`       | Input macro detection                     |
| 17 | `is_nolerp`      | Interpolation sanity                      |
| 18 | `is_backtrack`   | Backtrack telemetry                       |
| 19 | `is_ping`        | Ping control                              |
| 20 | `is_chatclear`   | Chat-clear protection                     |
| 21 | `is_anglepatch`  | Angle anomaly protection                  |
| 22 | `is_dll`         | DLL detection when extension is available |
| 23 | `is_database`    | SQLite/MySQL logging                      |
| 24 | `is_ml`          | Optional ML-assisted signal               |

---

# ✨ Основные возможности

* ✅ 24 SourceMod-модуля.
* ✅ 23 classical detection modules.
* ✅ Optional ML signal.
* ✅ 93 CVAR.
* ✅ SQLite / MySQL / MariaDB.
* ✅ Automatic database reconnect.
* ✅ Client-slot isolation.
* ✅ Cross-map state protection.
* ✅ Persistent timer lifecycle protection.
* ✅ Bounded Ray/visibility trace budget.
* ✅ Runtime trace metrics.
* ✅ Aimbot ring-buffer optimization.
* ✅ AntiSmoke spatial grid.
* ✅ Banlist modification-time caching.
* ✅ Fail-open runtime behaviour.
* ✅ SourceMod admin immunity support.
* ✅ Local deterministic ML inference.
* ✅ Model checksum validation.
* ✅ NaN/Inf model protection.
* ✅ SourcePawn 1.12 compatibility.

---

# 🤖 ML Configuration

ML отключён по умолчанию:

```text
is_ml_enabled 0
```

Включение:

```text
is_ml_enabled 1
```

Порог наблюдения:

```text
is_ml_confidence 0.5
```

Порог высокого confidence:

```text
is_ml_threshold 0.75
```

Интервал анализа:

```text
is_ml_sample_interval 5.0
```

Логирование:

```text
is_ml_log 1
```

Debug:

```text
is_ml_debug 1
```

После диагностики:

```text
is_ml_debug 0
```

Перезагрузка модели:

```text
is_ml_reload
```

Статус:

```text
is_ml_status
```

> ML является дополнительным сигналом и не должен использоваться как единственное основание для автоматического наказания.

---

# 🧪 Проверка после установки

## 1. SourceMod

```text
sm version
```

Ожидается SourceMod 1.12.x.

## 2. Metamod

```text
meta list
```

## 3. Все плагины

```text
sm plugins list
```

## 4. Core

```text
is_status
```

## 5. Wallhack / Trace

```text
is_wallhack_status
```

## 6. Aimbot

```text
is_aimbot_status
```

## 7. Anti-Smoke

```text
is_antismoke_status
```

## 8. Banlist

```text
is_banlist_status
```

## 9. Database

```text
is_db_status
```

## 10. ML

```text
is_ml_status
```

---

# 🔍 Проверка команд модулей

```text
sm cmds is_core
sm cmds is_antismoke
sm cmds is_banlist
sm cmds is_database
sm cmds is_ml
```

Это позволяет увидеть команды, реально зарегистрированные каждым плагином.

---

# 🤖 Полная проверка ML

```text
is_ml_status
```

Включить debug:

```text
is_ml_debug 1
```

Перезагрузить модель:

```text
is_ml_reload
```

Проверить:

```text
is_ml_status
```

Включить:

```text
is_ml_enabled 1
```

Проверить снова:

```text
is_ml_status
```

При работающем inference значение:

```text
inferences
```

должно увеличиваться при обработке игроков.

После диагностики:

```text
is_ml_debug 0
```

---

# 🗺️ Проверка после смены карты

После `changelevel`:

```text
sm plugins list
is_status
is_wallhack_status
is_db_status
is_ml_status
```

Проверяется:

```text
plugin state
timer state
client state
trace state
database state
ML state
```

---

# 🔄 Проверка reconnect

После подключения/отключения игрока:

```text
is_status
is_ml_status
```

Ключевое требование:

```text
Player A
↓
disconnect
↓
Player B
↓
same client slot
```

Игрок B не должен наследовать состояние игрока A.

---

# ⚙️ Рекомендуемый production ML profile

Для консервативного режима:

```text
is_ml_enabled 1
is_ml_confidence 0.5
is_ml_threshold 0.75
is_ml_sample_interval 5.0
is_ml_log 1
is_ml_debug 0
```

---

# 👁️ Wallhack / Trace Performance

Проверка:

```text
is_wallhack_status
```

Следить за:

```text
budget
used
checks
drops
blocked
window_elapsed_ms
trace_utilization
```

Если нагрузка становится высокой, система должна ограничивать объём дорогих trace-операций, а не выполнять бесконечное количество трассировок.

---

# 🛡️ Detection Philosophy

Iron Sentinel не считает отдельное событие автоматическим доказательством чита.

Например:

### Anti-Smoke

Нахождение игрока в smoke само по себе не является доказательством чита.

### Anti-Flash

Получение flash само по себе не является доказательством anti-flash.

### Macro

Одно быстрое действие недостаточно для определения макроса.

### NoLerp

Одного подозрительного значения недостаточно для наказания.

### Backtrack

Используется совокупность признаков и повторяемость поведения.

### Wallhack

Visibility/trace data используется как дополнительное evidence, а некорректное состояние обрабатывается fail-open.

---

# 🗄️ Database

Поддерживаются:

```text
SQLite
MySQL
MariaDB
```

Для одного сервера рекомендуется SQLite.

Database status:

```text
is_db_status
```

Reconnect:

```text
is_db_reconnect
```

Retry:

```text
5 → 10 → 20 → 40 → 60 секунд
```

---

# ⚙️ Основной конфиг

```text
addons/sourcemod/configs/is_config.cfg
```

Содержит основные настройки Iron Sentinel.

ML-настройки:

```text
is_ml_*
```

Database:

```text
addons/sourcemod/configs/databases.cfg
```

Не заменяйте существующий `databases.cfg` целиком — добавляйте необходимые настройки Iron Sentinel в существующий блок `Databases`.

---

# 🔨 Компиляция

Windows:

```text
tools/compile_all_windows.bat
```

Runtime-focused:

```text
tools/compile_runtime_fix_windows.bat
```

Strict:

```text
tools/compile_strict_windows.bat
```

ML:

```text
tools/compile_ml_windows.bat
```

После изменения любого `.sp` необходимо пересобрать соответствующий `.smx`.

---

# 📁 Структура

Исходники:

```text
addons/sourcemod/scripting/
```

Плагины:

```text
addons/sourcemod/plugins/
```

Конфигурация:

```text
addons/sourcemod/configs/
```

ML model:

```text
addons/sourcemod/data/is_ml/
```

---

# 📦 Release Package

Основной production archive:

```text
Iron.Sentinel.Core.v1.1.2.zip
```

Содержит:

```text
23 classical SourcePawn modules
+
is_ml
+
configuration
+
translations
+
includes
+
build tools
+
ML model
+
tests
+
documentation
```

---

# 🔒 Security

Проверены и усилены:

* ✅ Client validation.
* ✅ Entity validation.
* ✅ Server/system `client = 0`.
* ✅ Client-slot reuse.
* ✅ Timer lifecycle.
* ✅ Database callbacks.
* ✅ RCON hook lifecycle.
* ✅ Model checksum validation.
* ✅ Model size validation.
* ✅ NaN/Inf model protection.
* ✅ Path handling.
* ✅ Optional AntiDLL degradation.
* ✅ Admin/immunity handling.
* ✅ Fail-open behaviour.

---

# 🧪 Диагностика

При проблемах сначала:

```text
sm plugins list
meta list
sm version
```

Затем:

```text
is_status
is_wallhack_status
is_aimbot_status
is_antismoke_status
is_banlist_status
is_db_status
is_ml_status
```

Проверить:

```text
addons/sourcemod/logs/
addons/sourcemod/logs/errors_*.txt
```

Искать:

```text
Invalid Handle
Invalid client index
Invalid convar handle
Exception reported
Plugin startup error
```

---

# 🈯 Encoding / Русский текст

Ресурсы проекта должны оставаться в корректном UTF-8.

Если Windows console отображает русский текст в виде:

```text
╨Я╨╛╨║╨░╨╖╨░╤В╤М ...
```

это может быть проблема code page терминала.

Для Windows CMD можно проверить:

```bat
chcp 65001
```

После чего повторить команду.

Не перекодируйте исходники и translation files в ANSI только из-за неправильного отображения терминала.

---

# ⚠️ AntiDLL

При отсутствии внешнего расширения возможен режим:

```text
[IRON SENTINEL] AntiDLL extension not found. DLL detection in limited mode.
```

Это допустимый optional режим.

Остальные модули продолжают работать.

---

# 🧾 Source Metadata

Все модули Iron Sentinel используют:

```text
Version: 1.1.2
Author: Maxim Melnikov
```

Архитектура:

```text
23 classical modules
+
1 optional ML module
=
24 total modules
```

---

# 📋 Changelog — v1.1.2

## Build

* Fixed Aimbot undefined symbols.
* Fixed Wallhack constant-expression issue.
* Fixed unsupported `Max()` usage.
* Fixed Database missing native reference.
* Fixed Wallhack window timing state.
* Removed unused AntiSmoke state.
* Improved SourcePawn 1.12 compatibility.

## Runtime

* Fixed AntiSmoke invalid handle.
* Fixed Banlist `client = 0`.
* Hardened Core system context.
* Improved ConVar initialization.
* Improved database callbacks.
* Improved client-state reset.
* Fixed persistent timer lifecycle.

## Cross-Map

* Fixed AntiSpam map-transition reconnect handling.
* Replaced affected persistent timing with monotonic timing.
* Hardened map-change state.
* Improved reconnect history cleanup.

## Performance

* Aimbot ring-buffer optimization.
* Wallhack bounded trace budget.
* Wallhack cache and early exits.
* AntiSmoke spatial grid.
* Speedhack threshold caching.
* Banlist modification-time caching.
* Reduced repeated API work.

## Database

* SQLite support.
* MySQL / MariaDB support.
* Automatic reconnect.
* Retry backoff.
* Health checking.
* Stale callback protection.

## Machine Learning

* Added optional `is_ml` module.
* Added deterministic local inference.
* Added model schema validation.
* Added fixed-point coefficient representation.
* Added checksum validation.
* Added NaN/Inf protection.
* Added model reload.
* Added `is_ml_status`.
* Added debug diagnostics.
* Confirmed live model loading on CS:S server.

## Security

* Improved client validation.
* Improved slot reuse isolation.
* Improved server/system context handling.
* Improved model validation.
* Improved optional dependency handling.
* Improved fail-safe behaviour.

---

# 🧪 Live ML Verification

На реальном сервере подтверждено:

```text
SourceMod: 1.12.0.7251
SourcePawn: 1.12.0.7251
```

ML:

```text
Model loaded
model_valid=1
schema=1
features=7
checksum=1504619244
```

Пример фактического runtime debug:

```text
coefficient[0] = 4.80043220
coefficient[1] = 4.75823879
coefficient[2] = 4.76937675
coefficient[3] = 4.78085613
coefficient[4] = 5.34459400
coefficient[5] = 4.83499717
coefficient[6] = 4.91624879
intercept = -13.59416961
```

Это подтверждает корректное чтение текущей модели SourceMod runtime.

---

# 📜 License

**GPLv3**

---

# 🙏 Credits

* **SourceMod Dev Team** — SourceMod
* **Metamod:Source Team** — Metamod:Source
* **SMAC Development Team** — anti-cheat concepts
* **Little Anti-Cheat (Lilac)** — detection concepts
* **AntiDLL** — DLL Detection concept

Iron Sentinel является самостоятельным проектом и не является официальным продуктом перечисленных проектов.

---

# 📞 Contact

**Author:** Maxim Melnikov

**GitHub:**

https://github.com/Maximka1993271

**Repository:**

https://github.com/Maximka1993271/cs-source

---

<div align="center">

# 🛡️ IRON SENTINEL

### Protection Active

```text
[IRON SENTINEL] Core initialized.
[IRON SENTINEL] Protection modules loaded.
[IRON SENTINEL] ML signal ready.
```

</div>

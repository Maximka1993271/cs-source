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
  <a href="https://github.com/Maximka1993271/cs-source/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-GPLv3-green.svg?style=for-the-badge&logo=opensourceinitiative" alt="GPLv3"/>
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
  <a href="https://github.com/Maximka1993271/cs-source">
    <img src="https://img.shields.io/badge/ML-assisted-available-success?style=flat-square" alt="ML Assisted"/>
  </a>
</p>

<p align="center">
  <b>🛡️ Защита сервера • ⚡ Производительность • 👁️ Visibility / Trace Analysis • 🤖 ML • 🗄️ Database</b>
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

* ✅ Исправлены известные ошибки компиляции SourcePawn 1.12.
* ✅ Исправлены startup exceptions и проблемы с `client = 0`.
* ✅ Исправлены persistent timer lifecycle issues после `changelevel`.
* ✅ Исправлен critical AntiSpam cross-map reconnect bug.
* ✅ Улучшен client-slot state reset.
* ✅ Улучшена Database reconnect/recovery architecture.
* ✅ `is_aimbot` использует оптимизированную angle-history ring buffer.
* ✅ `is_wallhack` использует bounded trace budget и visibility metrics.
* ✅ `is_antismoke` использует spatial grid.
* ✅ `is_speedhack` использует кэширование speed thresholds.
* ✅ `is_banlist` использует cache invalidation по времени изменения файлов.
* ✅ Добавлен отдельный `is_ml` module.
* ✅ ML model validation и checksum verification.
* ✅ ML runtime loader исправлен и проверен на реальном CS:S сервере.
* ✅ Все основные runtime path работают в fail-safe режиме.
* ✅ Расширены regression/property tests.

---

# 🏆 Сравнение с другими SourceMod Anti-Cheat

Iron Sentinel разрабатывался как более современная расширенная система поверх классического rule-based подхода.

Ниже — сравнение по **архитектурным возможностям**, а не заявление о том, что один античит обнаруживает абсолютно каждый чит лучше другого.

| Возможность                          | 🛡️ Iron Sentinel | 🔹 SMAC | 🔹 Lilac | 🔹 Kigen's AC |
| ------------------------------------ | :---------------: | :-----: | :------: | :-----------: |
| Модульная архитектура                |         ✅         |    ✅    |     ✅    |       ✅       |
| Aimbot Detection                     |         ✅         |    ✅    |     ✅    |       ⚠️      |
| Aimlock Detection                    |         ✅         |    ⚠️   |     ✅    |       ❌       |
| Angle Detection                      |         ✅         |    ✅    |     ✅    |       ❌       |
| Wallhack / Visibility                |         ✅         |    ⚠️   |    ⚠️    |       ❌       |
| Ray / Trace Analysis                 |         ✅         |    ❌    |     ❌    |       ❌       |
| Bounded Trace Budget                 |         ✅         |    ❌    |     ❌    |       ❌       |
| Anti-Smoke                           |         ✅         |    ❌    |     ❌    |       ❌       |
| Anti-Flash                           |         ✅         |    ❌    |     ❌    |       ❌       |
| Speedhack Detection                  |         ✅         |    ⚠️   |    ⚠️    |       ❌       |
| Macro Detection                      |         ✅         |    ✅    |     ✅    |       ❌       |
| NoLerp / Interpolation               |         ✅         |    ✅    |     ✅    |       ❌       |
| Backtrack Detection / Telemetry      |         ✅         |    ⚠️   |     ✅    |       ❌       |
| AntiSpam / Reconnect Protection      |         ✅         |    ⚠️   |    ⚠️    |       ✅       |
| Client-slot state protection         |         ✅         |    ⚠️   |    ⚠️    |       ⚠️      |
| Cross-map timing protection          |         ✅         |    ⚠️   |    ⚠️    |       ⚠️      |
| Persistent timer lifecycle hardening |         ✅         |    ⚠️   |    ⚠️    |       ⚠️      |
| SQLite                               |         ✅         |    ⚠️   |     ✅    |       ❌       |
| MySQL / MariaDB                      |         ✅         |    ⚠️   |     ✅    |       ❌       |
| Automatic DB reconnect               |         ✅         |    ⚠️   |    ⚠️    |       ❌       |
| Fail-safe runtime handling           |         ✅         |    ⚠️   |    ⚠️    |       ⚠️      |
| Model integrity validation           |         ✅         |    ❌    |     ❌    |       ❌       |
| Local ML-assisted signal             |         ✅         |    ❌    |     ❌    |       ❌       |
| Regression / property testing        |         ✅         |    ⚠️   |    ⚠️    |       ❌       |
| CI/CD                                |         ✅         |    ⚠️   |     ✅    |       ❌       |

### 🟢 В чём основное отличие Iron Sentinel

```text
23 classical detection modules
                +
runtime hardening
                +
visibility / trace analysis
                +
database infrastructure
                +
optional ML signal
                ↓
        Iron Sentinel Core
```

### ✅ Сильные стороны архитектуры

* ✅ **24 модуля**, включая отдельный `is_ml`.
* ✅ **93 CVAR** для детальной настройки.
* ✅ **Visibility / trace analysis** с ограниченным бюджетом.
* ✅ **Fail-safe** обработка runtime-ошибок.
* ✅ **Cross-map / client-slot** защита состояния.
* ✅ **SQLite / MySQL / MariaDB**.
* ✅ **Automatic database reconnect**.
* ✅ **Локальный ML inference**.
* ✅ **Проверка checksum и целостности модели**.
* ✅ **Regression/property testing**.
* ✅ **GitHub Actions CI/CD**.

> ⚠️ Это архитектурное сравнение. Оно не является независимым benchmark'ом detection accuracy, CPU usage или false-positive rate.

---

# 🛡️ Detection Philosophy

Iron Sentinel не рассматривает единичное событие как автоматическое доказательство чита.

```text
наблюдение
    ↓
счётчик / evidence
    ↓
дополнительные признаки
    ↓
подтверждение
    ↓
действие
```

При ошибке runtime:

```text
invalid state
    ↓
safe fallback
    ↓
проверка пропускается
```

Это позволяет снижать риск ложных срабатываний.

---

# 🤖 ML-Assisted Detection

`is_ml` является дополнительным модулем.

```text
23 classical modules
        +
is_ml
        =
24 modules
```

Текущая модель:

```text
Model version: 1.0.0-synthetic
Schema version: 1
Feature count: 7
Checksum: 1504619244
```

На реальном CS:S сервере подтверждена загрузка:

```text
[ML] Model loaded: version=1.0.0-synthetic schema=1 features=7 checksum=1504619244 (verified)
```

Также подтверждено:

```text
model_valid=1
```

### ML Commands

```text
is_ml_status
is_ml_reload
```

### Debug

```text
is_ml_debug 1
```

После диагностики:

```text
is_ml_debug 0
```

### Enable

```text
is_ml_enabled 1
```

### Recommended ML settings

```text
is_ml_confidence 0.5
is_ml_threshold 0.75
is_ml_sample_interval 5.0
is_ml_log 1
is_ml_debug 0
```

> ML является дополнительным сигналом. Один ML score не должен быть единственным основанием для автоматического наказания.

---

# 👁️ Wallhack / Ray Tracing

`is_wallhack` использует visibility analysis с bounded trace budget.

Статус:

```text
is_wallhack_status
```

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

Принцип:

```text
cheap validation
      ↓
cache
      ↓
early exit
      ↓
trace
      ↓
visibility evidence
```

Это позволяет ограничивать дорогие trace-операции на серверах с большим количеством игроков.

---

# ⚡ Performance

Основные оптимизации:

### `is_aimbot`

Persistent ring buffer без создания временного массива истории в hot path.

### `is_wallhack`

Bounded trace budget, cache, early exits и trace metrics.

### `is_antismoke`

Spatial grid вместо полного перебора всех `players × smokes`.

### `is_speedhack`

Кэширование speed thresholds и сокращение повторных velocity calculations.

### `is_banlist`

Повторный parse только при необходимости.

### `is_core`

Снижение лишнего formatting/API work.

---

# 🗺️ Cross-Map Protection

Исправлен критический сценарий:

```text
Map A
  ↓
changelevel
  ↓
Map B
  ↓
reconnect
```

Легитимный reconnect после смены карты не должен автоматически считаться connection spam.

Также проверяются:

```text
client state
timers
timestamps
trace state
ML state
database state
```

---

# 🗄️ Database

Поддерживаются:

```text
SQLite
MySQL
MariaDB
```

Automatic reconnect:

```text
5 → 10 → 20 → 40 → 60 секунд
```

Проверка:

```text
is_db_status
```

Reconnect:

```text
is_db_reconnect
```

---

# 📦 24 модуля

|  № | Модуль           | Назначение                            |
| -: | ---------------- | ------------------------------------- |
|  1 | `is_core`        | Core API, ban, logging, configuration |
|  2 | `is_commands`    | Command protection                    |
|  3 | `is_cvars`       | Client ConVar validation              |
|  4 | `is_antispam`    | Connection/name/team spam             |
|  5 | `is_speedhack`   | Speed anomaly detection               |
|  6 | `is_aimbot`      | Aimbot detection                      |
|  7 | `is_wallhack`    | Visibility / trace analysis           |
|  8 | `is_eyetest`     | Eye-angle validation                  |
|  9 | `is_autotrigger` | Trigger behaviour                     |
| 10 | `is_spinhack`    | Spin detection                        |
| 11 | `is_antiflash`   | Flash protection                      |
| 12 | `is_antismoke`   | Smoke protection                      |
| 13 | `is_rcon`        | RCON protection                       |
| 14 | `is_banlist`     | Cached banlists                       |
| 15 | `is_aimlock`     | Aim-lock detection                    |
| 16 | `is_macro`       | Macro detection                       |
| 17 | `is_nolerp`      | Interpolation validation              |
| 18 | `is_backtrack`   | Backtrack telemetry                   |
| 19 | `is_ping`        | Ping control                          |
| 20 | `is_chatclear`   | Chat-clear protection                 |
| 21 | `is_anglepatch`  | Angle anomaly protection              |
| 22 | `is_dll`         | DLL detection                         |
| 23 | `is_database`    | SQLite/MySQL logging                  |
| 24 | `is_ml`          | Optional ML-assisted signal           |

---

# ⚙️ Основной конфиг

```text
addons/sourcemod/configs/is_config.cfg
```

В проекте:

```text
86 core CVAR
+
7 ML CVAR
=
93 CVAR
```

---

# 🧪 Проверка после установки

```text
sm version
meta list
sm plugins list
```

Core:

```text
is_status
```

Aimbot:

```text
is_aimbot_status
```

Wallhack:

```text
is_wallhack_status
```

AntiSmoke:

```text
is_antismoke_status
```

Banlist:

```text
is_banlist_status
```

Database:

```text
is_db_status
```

ML:

```text
is_ml_status
```

Команды модулей:

```text
sm cmds is_core
sm cmds is_antismoke
sm cmds is_banlist
sm cmds is_database
sm cmds is_ml
```

---

# 🧪 ML Live Check

```text
is_ml_status
```

Включить:

```text
is_ml_enabled 1
```

Debug:

```text
is_ml_debug 1
```

Reload:

```text
is_ml_reload
```

Проверить:

```text
is_ml_status
```

После проверки:

```text
is_ml_debug 0
```

Для рабочего inference значение:

```text
inferences
```

должно увеличиваться во время работы сервера.

---

# 🗺️ Проверка после смены карты

```text
sm plugins list
is_status
is_wallhack_status
is_db_status
is_ml_status
```

---

# 🔨 Compilation

```text
tools/compile_all_windows.bat
tools/compile_runtime_fix_windows.bat
tools/compile_strict_windows.bat
tools/compile_ml_windows.bat
```

Строгая сборка должна завершаться при наличии warning.

---

# 🔒 Security Hardening

Проверяются:

* ✅ Client validation.
* ✅ Entity validation.
* ✅ `client = 0` server context.
* ✅ Client-slot reuse.
* ✅ Timer lifecycle.
* ✅ Database callback safety.
* ✅ RCON hook lifecycle.
* ✅ Model checksum.
* ✅ Model size.
* ✅ NaN/Inf model data.
* ✅ Path handling.
* ✅ Admin/immunity.
* ✅ Fail-open behaviour.
* ✅ Optional AntiDLL degradation.

---

# 🧪 QA

Покрываются:

```text
compile checks
regression tests
property tests
ML model validation
checksum validation
timer lifecycle
client-slot reuse
cross-map timing
database callbacks
model corruption
NaN / Inf handling
```

Последний зафиксированный regression result:

```text
59 passed
0 failed
```

ML tests:

```text
21 passed
0 failed
```

---

# 🈯 Encoding

Проект использует UTF-8 для исходников, переводов и конфигураций.

Если Windows CMD отображает русский текст неправильно:

```text
╨Я╨╛╨║╨░╨╖╨░╤В╤М ...
```

проверить code page:

```bat
chcp 65001
```

Не переводите файлы проекта в ANSI только из-за проблемы отображения терминала.

---

# ⚠️ AntiDLL

При отсутствии внешнего расширения:

```text
[IRON SENTINEL] AntiDLL extension not found. DLL detection in limited mode.
```

Это допустимый optional режим.

Остальные модули продолжают работать.

---

# 🧾 Source Metadata

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
24 modules
```

---

# 📋 Changelog — v1.1.2

### Build

* ✅ Aimbot compile fixes.
* ✅ Wallhack compile fixes.
* ✅ Database compile fixes.
* ✅ SourcePawn 1.12 compatibility fixes.
* ✅ Wallhack `Max()` compatibility fix.

### Runtime

* ✅ AntiSmoke invalid handle fix.
* ✅ Banlist `client = 0` fix.
* ✅ Core startup/ConVar protection.
* ✅ Client-slot state reset.
* ✅ Timer lifecycle fixes.
* ✅ Cross-map AntiSpam fix.

### Performance

* ✅ Aimbot ring buffer.
* ✅ Wallhack bounded trace budget.
* ✅ Trace cache / early exits.
* ✅ AntiSmoke spatial grid.
* ✅ Speedhack threshold caching.
* ✅ Banlist cache invalidation.
* ✅ Core logging optimization.

### Database

* ✅ SQLite.
* ✅ MySQL / MariaDB.
* ✅ Automatic reconnect.
* ✅ Retry backoff.
* ✅ Health checks.
* ✅ Stale callback protection.

### ML

* ✅ Optional `is_ml`.
* ✅ Local deterministic inference.
* ✅ Model schema validation.
* ✅ Fixed-point coefficient representation.
* ✅ Checksum validation.
* ✅ NaN/Inf protection.
* ✅ Model reload.
* ✅ Live model-load verification.

### Security

* ✅ Client validation.
* ✅ Slot isolation.
* ✅ Timer hardening.
* ✅ Database callback hardening.
* ✅ Model validation.
* ✅ Fail-safe runtime behaviour.

---

# 📞 Contacts

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

# 🛡️ Iron Sentinel v1.1.2


> 📦 **Current release asset:** `Iron.Sentinel.Core.v1.1.2.zip`
>
> [⬇️ Download Iron Sentinel Core v1.1.2](https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.Core.v1.1.2.zip)
<p align="center">
  <b>Полный античит для Counter-Strike: Source</b><br/>
  <b>23 модуля • 86 ConVar • SQLite/MySQL • SourceMod 1.12.x</b><br/>
  <b>Build & Runtime Fixes • Cross-Map Safety • Fail-Safe • Performance</b>
</p>

<p align="center">
  <a href="https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.Core.v1.1.2.zip">
    <img src="https://img.shields.io/badge/%E2%AC%87%EF%B8%8F%20DOWNLOAD-v1.1.2-2ea44f?style=for-the-badge&logo=github" alt="Download Iron Sentinel v1.1.2"/>
  </a>
  <a href="https://github.com/Maximka1993271/cs-source/releases">
    <img src="https://img.shields.io/badge/RELEASES-GitHub-1f6feb?style=for-the-badge&logo=github" alt="GitHub Releases"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SourceMod-1.12.x-blue?style=flat-square" alt="SourceMod"/>
  <img src="https://img.shields.io/badge/Metamod%3ASource-1.12.x-blue?style=flat-square" alt="Metamod:Source"/>
  <img src="https://img.shields.io/badge/Modules-23-success?style=flat-square" alt="23 modules"/>
  <img src="https://img.shields.io/badge/ConVars-86-success?style=flat-square" alt="86 ConVars"/>
  <img src="https://img.shields.io/badge/SQLite%20%2F%20MySQL-supported-success?style=flat-square" alt="SQLite / MySQL"/>
</p>

> 🚀 **v1.1.2** — стабилизирующий релиз с исправлениями компиляции, runtime lifecycle, cross-map timing, client-slot reuse, database recovery, CVAR consistency и производительности.

---

## 📥 Скачать

<p align="center">
  <a href="https://github.com/Maximka1993271/cs-source/releases/download/1.1.2/Iron.Sentinel.Core.v1.1.2.zip">
    <img src="https://img.shields.io/badge/%E2%AC%87%EF%B8%8F%20DOWNLOAD-Iron%20Sentinel%20v1.1.2-2ea44f?style=for-the-badge&logo=github&logoColor=white" alt="Download Iron Sentinel v1.1.2"/>
  </a>
</p>

**Архив:** `Iron.Sentinel.Core.v1.1.2.zip`

[GitHub Releases](https://github.com/Maximka1993271/cs-source/releases) ·
[Исходный код](https://github.com/Maximka1993271/cs-source)

---

## ⭐ Техническая оценка

**★★★★☆ 7.6 / 10**

Оценка относится к инженерному состоянию проекта после аудита. Она не является официальным рейтингом GitHub и учитывает, что live runtime Counter-Strike: Source не был полностью воспроизведён в аудит-среде.

---

## ✅ Подтверждённое состояние

| Область | Результат |
|---|---|
| SourcePawn modules | **23/23** |
| Компиляция | **23/23** |
| Errors | **0** |
| Warnings | **0** |
| Core ConVars | **86/86** |
| Timer / Handle audit | **PASS** |
| Cross-map timing | **PASS** |
| Client-slot reuse | **PASS** |
| Database lifecycle | **PASS** |
| Security checks | **PASS** |
| CI/CD | **PASS** |
| Production package | **PASS** |
| Live CS:S runtime | **NOT VERIFIED** |

**Compiler:** официальный `SourcePawn Compiler 1.12.0.7249`, использованный в финальном аудите.

---

# 🛡️ Что исправлено в v1.1.2

## 🔧 Compile fixes

Исправлены ранее обнаруженные ошибки:

```text
error 017: undefined symbol "iSnaps"
error 017: undefined symbol "fMaxSnap"
error 008: must be a constant expression
warning 204: symbol is assigned a value that is never used
undefined symbol "IS_VALID_CLIENT"
undefined symbol "g_fWindowStartedAt"
```

Ключевые исправления:

- `is_aimbot.sp` — актуальные переменные `snaps/maxSnap`.
- `is_wallhack.sp` — безопасная runtime-инициализация массива `top[3]`.
- `is_antismoke.sp` — устранён неиспользуемый `g_bLogging`.
- `is_database.sp` — локальная проверка client index вместо недоступного `IS_VALID_CLIENT`.
- `is_wallhack.sp` — добавлено состояние `g_fWindowStartedAt`.

---

# 🗺️ Cross-Map / Timing Fix

Один из самых серьёзных runtime-багов проявился на реальном CS:S сервере: `GetGameTime()` сбрасывается при смене карты.

В `is_antispam` это приводило к ложному:

```text
[AntiCheat] Please wait 14 seconds before reconnecting.
```

при обычном `changelevel`.

Исправление:

```text
persistent reconnect timing
        ↓
GetTickedTime()
        +
map-transition IP recognition
        ↓
легитимный reconnect
        ↓
ALLOW
```

При этом обычный reconnect spam **внутри одной карты** по-прежнему блокируется.

Аудит cross-map timing также охватил:

```text
is_ping
is_backtrack
is_aimbot
is_eyetest
is_macro
is_speedhack
```

Map-local `GetGameTime()` не заменялся там, где это было корректным.

---

# ⏱️ Timer / Handle Lifecycle

Проверены все `CreateTimer`, `CreateDataTimer`, `KillTimer` и `TIMER_FLAG_NO_MAPCHANGE`.

Исправлены persistent timers, которые могли исчезнуть после первой смены карты:

- `is_wallhack`
- `is_database`
- `is_banlist`
- `is_speedhack`
- `is_autotrigger`
- `is_eyetest`
- `is_cvars`

Также исправлен stale flash timer lifecycle в `is_antiflash`.

Проверены сценарии:

```text
map change
plugin reload
plugin unload
client disconnect
client reconnect
late load
```

---

# 👤 Client-Slot Reuse

Исправлено наследование состояния:

```text
Player A
slot 5
disconnect
        ↓
Player B
slot 5
connect
```

В частности:

- `is_ping` — detection counter и notification timing;
- `is_antispam` — name/team counters;
- `is_spinhack` — previous angle state.

Дополнительно проверены остальные stateful-модули на reuse одного client slot.

---

# 🗄️ Database Reliability

Поддерживается:

```text
SQLite
MySQL / MariaDB
```

`is_database` теперь включает:

- автоматическое переподключение;
- backoff:

```text
5 → 10 → 20 → 40 → 60 сек
```

- health-check;
- generation/token protection;
- stale callback protection;
- безопасную обработку `client = 0`;
- корректный lifecycle при `changelevel`;
- защиту от client-slot reuse.

Для одного сервера рекомендуется SQLite.

Используемое имя SQLite-коннекта:

```text
is_anticheat_sqlite
```

---

# ⚙️ CVAR Integrity

Финальный audit `CreateConVar()` против `is_config.cfg`:

```text
86 / 86
Missing: 0
Extra: 0
Duplicates: 0
Default mismatches: 0
Bounds mismatches: 0
```

Конфигурация документирована на английском и русском языках.

---

# ⚡ Performance & Caching

## `is_aimbot`

Постоянный ring buffer вместо создания большого временного `history[][]` в hot path.

## `is_wallhack`

Bounded trace budget, ранние выходы и runtime metrics.

## `is_speedhack`

Кэширование квадратов порогов и снижение повторных вычислений.

## `is_antismoke`

Spatial grid вместо полного `players × smokes` прохода.

## `is_banlist`

mtime cache: неизменившийся бан-лист не парсится повторно.

## `is_core`

Сокращены лишние операции форматирования и server/client validation в горячих путях.

---

# 🎯 False-Positive Protection

Принцип:

```text
подозрение
    ↓
score / log
    ↓
validation
    ↓
repeated evidence
    ↓
confirmed violation
    ↓
action
```

Сам по себе один сигнал не должен автоматически означать чит там, где это недостаточно надёжно.

Особенно:

- smoke presence ≠ cheat;
- flash receipt ≠ cheat;
- один быстрый click ≠ macro;
- одно подозрительное `interp` значение ≠ ban;
- единичная speed spike ≠ speedhack;
- одиночная angle anomaly ≠ aimbot.

---

# 🔐 Security Audit

Проверены:

```text
SQL Injection
Path Traversal
Format String
Command Injection
Secret Leakage
Admin/Immunity Bypass
```

По финальному аудиту:

```text
SQL Injection: PASS
Path Traversal: PASS
Format String: PASS
Command Injection: PASS
Secret Leakage: PASS
Admin/Immunity Bypass: PASS
```

Все 17 проверенных kick/ban call sites проходят immunity check до автоматического действия.

Production admin:

```text
STEAM_0:1:97711058
```

с иммунитетом:

```text
99
```

и root flag:

```text
z
```

---

# 🧩 Optional AntiDLL

При отсутствии внешнего AntiDLL extension:

```text
[IRON SENTINEL] AntiDLL extension not found. DLL detection in limited mode.
```

Это считается штатным limited mode.

Остальные модули должны продолжать работать.

---

# 🤖 Machine Learning Status

### v1.1.2 ML STATUS: NOT IMPLEMENTED

В текущем релизе нет:

```text
model
dataset
feature schema
inference engine
training pipeline
ML runtime
```

Существующие 23 модуля являются deterministic/rule-based.

ML рассматривается как отдельное направление для будущей версии.

Рекомендуемая архитектура будущего ML:

```text
offline training
        ↓
validated model
        ↓
local inference
        ↓
ML score
        ↓
classical detector signals
        ↓
confidence fusion
        ↓
final decision
```

Ключевое правило:

```text
ML score != automatic ban
```

ML не должен заменять существующие проверки и не должен отключать fail-safe механизм.

При отсутствии реального размеченного dataset нельзя заявлять accuracy/precision/recall как production metrics.

---

# 🧪 Tests & QA

Проект содержит Python regression/property checks для:

- структуры проекта;
- версии и автора;
- CVAR parity;
- ring-buffer boundaries;
- NaN/Inf safety;
- spatial-grid boundaries;
- database reconnect logic;
- wallhack budget;
- cross-map reconnect;
- client-slot reuse;
- absence of production junk.

### Последний глубокий аудит

В финальном audit report зафиксировано:

```text
35 tests
35 passed
0 failed
0 skipped
```

> В архиве находятся документы нескольких последовательных аудиторских проходов, поэтому старые test reports могут содержать промежуточный результат `28/28`. Для итоговой оценки здесь используется результат, указанный в последнем финальном audit report.

---

# 📊 Algorithmic Benchmarks

Benchmarks не являются измерениями FPS CS:S.

В аудит-среде не было полноценного live Source Engine runtime, поэтому не приводятся выдуманные tick/frame/FPS показатели.

### AntiSmoke

При 32 игроках:

| Smokes | Naive checks | Grid candidates | Reduction |
|---:|---:|---:|---:|
| 0 | 0 | 0 | — |
| 5 | 160 | 71 | 55.6% |
| 10 | 320 | 149 | 53.4% |
| 20 | 640 | 291 | 54.5% |

### Wallhack

Default trace budget:

```text
192 traces / 50 ms window
```

При 32 игроках worst-case модель показывает до:

```text
992 ordered player pairs
2976 theoretical 3-point traces
```

Это **не означает**, что только 6.5% игроков проверяются. Реальный trace count зависит от visibility cache, расстояния, PVS и количества пар в trace budget window.

---

# 🔨 Build

Windows scripts:

```text
tools/compile_all_windows.bat
tools/compile_runtime_fix_windows.bat
tools/compile_strict_windows.bat
```

Linux:

```text
tools/compile_all.sh
```

Tests:

```text
tools/run_tests.bat
```

Strict build должен рассматривать warnings как ошибки.

---

# 🤖 CI/CD

GitHub Actions workflow:

```text
.github/workflows/ci.yml
```

Проверки:

```text
checkout
↓
SourceMod compiler
↓
strict compile
↓
tests
↓
benchmark/validation
↓
package validation
↓
release artifact
```

Release asset:

```text
Iron.Sentinel.Core.v1.1.2.zip
```

---

# 📦 Installation

## 1. Plugins

Скопировать:

```text
addons/sourcemod/plugins/*.smx
```

## 2. Source

Для разработки/перекомпиляции:

```text
addons/sourcemod/scripting/*.sp
addons/sourcemod/scripting/include/*
```

## 3. Translation

```text
addons/sourcemod/translations/is.phrases.txt
```

## 4. Config

```text
cfg/sourcemod/is_config.cfg
```

## 5. SourceMod configs

Используются:

```text
addons/sourcemod/configs/admins.cfg
addons/sourcemod/configs/admin_groups.cfg
addons/sourcemod/configs/admin_overrides.cfg
addons/sourcemod/configs/databases.cfg
```

---

# 👑 Admin

Активный production admin:

```text
"STEAM_0:1:97711058" "99:z"
```

После изменения admin configuration:

```text
sm_reloadadmins
```

---

# 🗄️ Database Configuration

Для SQLite используется:

```text
"is_anticheat_sqlite"
driversqlitedatabaseis_anticheat
```

Не заменяйте существующий `databases.cfg` целиком, если там уже есть конфигурации других плагинов.

---

# 🔍 Verification After Installation

Проверить:

```text
sm plugins list
meta list
```

Особенно:

```text
is_core
is_antismoke
is_banlist
is_database
```

Ожидаемый статус:

```text
running
```

Проверить логи на отсутствие:

```text
Invalid Handle
Invalid client index
Invalid convar handle
Plugin startup error
```

---

# 📁 23 Modules

| # | Plugin | Назначение |
|---:|---|---|
| 1 | `is_core` | Core, bans, logs, API |
| 2 | `is_commands` | Command protection |
| 3 | `is_cvars` | Client CVAR checks |
| 4 | `is_antispam` | Connection/name/team/command anti-spam |
| 5 | `is_speedhack` | Speed anomaly detection |
| 6 | `is_aimbot` | Aim anomaly detection |
| 7 | `is_wallhack` | Visibility / transmit protection |
| 8 | `is_eyetest` | Angle anomaly detection |
| 9 | `is_autotrigger` | Trigger/fire behaviour |
| 10 | `is_spinhack` | Spin detection |
| 11 | `is_antiflash` | Flash protection |
| 12 | `is_antismoke` | Smoke-related protection |
| 13 | `is_rcon` | RCON protection |
| 14 | `is_banlist` | Banlist cache / checks |
| 15 | `is_aimlock` | Aim-lock detection |
| 16 | `is_macro` | Macro pattern detection |
| 17 | `is_nolerp` | Interpolation anomaly checks |
| 18 | `is_backtrack` | Backtrack-related checks |
| 19 | `is_ping` | Ping protection |
| 20 | `is_chatclear` | Chat clear protection |
| 21 | `is_anglepatch` | Angle cheat protection |
| 22 | `is_dll` | Optional DLL detection |
| 23 | `is_database` | Database logging/recovery |

---

# 🧪 Test Framework

Для запуска:

```bash
python3 -m pytest -q -p no:cacheprovider tests/
```

Windows helper:

```text
tools/run_tests.bat
```

Тесты выполняются без необходимости запуска CS:S server.

Они не заменяют engine-level runtime testing.

---

# 🧾 Audit Summary

### Critical findings fixed

- `is_wallhack` persistent timer died after first map change.
- `is_speedhack` detection loop died after first map change.
- `is_antispam` blocked legitimate reconnects after `changelevel`.
- `is_database` recovery timers were vulnerable to the same lifecycle class.
- client-slot state leakage could affect new players.
- startup exceptions existed in `is_antismoke`, `is_banlist`, `is_core`.

### High findings fixed

- database-name fallback mismatch;
- banlist refresh lifecycle;
- CVAR checking lifecycle;
- ping state reuse;
- admin identity.

### Medium / low findings fixed

- 11 CVAR default/bounds mismatches;
- duplicate RCON ConVar hook;
- stale previous angle state;
- timing throttles using map-local clock;
- hardcoded developer paths;
- test runner cache handling.

---

# ⚠️ Runtime Limitation

Даже при:

```text
23/23 compiled
0 errors
0 warnings
```

это не доказывает отсутствие всех engine-level runtime issues.

Для окончательной проверки рекомендуется протестировать на реальном сервере:

```text
startup
connect
disconnect
slot reuse
changelevel
reconnect
plugin reload
database reconnect
20 players
32 players
long uptime
AntiDLL missing
```

Особенно обязательно повторить:

```text
Map A
↓
changelevel
↓
Map B
↓
same player reconnects
```

Игрок не должен получать ложный:

```text
Please wait X seconds before reconnecting
```

из-за смены карты.

---

# 🔒 Privacy

Iron Sentinel предназначен для локальной обработки на игровом сервере.

Релиз не требует:

- cloud anti-cheat API;
- online ML service;
- внешнего telemetry endpoint.

Database logging может содержать серверные данные, которые сам администратор разрешил журналировать.

---

# 📜 License

В предоставленном архиве отдельный файл `LICENSE` отсутствует.

README не должен использовать наличие GPLv3 файла как подтверждённый факт, пока `LICENSE` не добавлен в GitHub repository.

Проверь лицензию репозитория перед публичным распространением.

---

# 👤 Author

**Maxim Melnikov**

GitHub:

https://github.com/Maximka1993271

Repository:

https://github.com/Maximka1993271/cs-source

---

<div align="center">

### 🛡️ IRON SENTINEL

**Protection Active**

`Version 1.1.2`

**Maxim Melnikov**

</div>

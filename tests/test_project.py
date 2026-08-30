from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SPDIR = ROOT / "addons/sourcemod/scripting"
CONFIG = ROOT / "cfg/sourcemod/is_config.cfg"

EXPECTED = {
    "is_aimbot", "is_aimlock", "is_anglepatch", "is_antiflash", "is_antismoke",
    "is_antispam", "is_autotrigger", "is_backtrack", "is_banlist", "is_chatclear",
    "is_commands", "is_core", "is_cvars", "is_database", "is_dll", "is_eyetest",
    "is_macro", "is_nolerp", "is_ping", "is_rcon", "is_speedhack", "is_spinhack",
    "is_wallhack",
}


def test_all_sources_are_v112_and_authored():
    names = {p.stem for p in SPDIR.glob("is_*.sp")}
    assert names == EXPECTED
    for p in SPDIR.glob("is_*.sp"):
        text = p.read_text(encoding="utf-8")
        assert "Version: 1.1.2" in text, p.name
        assert re.search(r'\bauthor\s*=\s*"Maxim Melnikov"', text), p.name
        assert 'version = "1.1.2"' in text, p.name
        stale_version = "1.1" + ".0"
        assert stale_version not in text, p.name


def test_core_config_cvar_parity():
    core = (SPDIR / "is_core.sp").read_text(encoding="utf-8")
    cfg = CONFIG.read_text(encoding="utf-8")
    core_names = set(re.findall(r'CreateConVar\("(is_[a-z0-9_]+)"', core))
    cfg_names = set(re.findall(r'^\s*(is_[a-z0-9_]+)\s+', cfg, re.M))
    assert len(core_names) == 86
    assert core_names == cfg_names
    assert 'is_version "1.1.2"' in cfg


def test_no_example_configs_in_production_tree():
    examples = list(ROOT.rglob("*.example"))
    assert not examples, examples


def test_aimbot_has_no_stack_history_array():
    text = (SPDIR / "is_aimbot.sp").read_text(encoding="utf-8")
    assert "float history[MAX_ANGLE_HISTORY][3]" not in text
    assert "g_iAngleSamples" in text


def test_database_has_reconnect_and_v112_rows():
    text = (SPDIR / "is_database.sp").read_text(encoding="utf-8")
    assert "ScheduleReconnect" in text
    assert "Timer_Reconnect" in text
    assert "Database.Connect(OnDatabaseConnected, g_sDatabase, generation)" in text
    assert "'1.1.2')" in text


def test_no_stale_version_in_project():
    # Readme/ holds dated historical incident/build reports (e.g.
    # AUDIT_RUNTIME_FIX_2026-08-28.md) that legitimately discuss old version numbers in
    # a historical/negated context ("no legacy 1.1.0 metadata remains"). The project's
    # own rule is to leave historical changelog/report content alone rather than edit it
    # for cosmetic reasons, so this scan excludes that archive by directory and keeps
    # full strength everywhere that actually ships as live source or documentation.
    for path in ROOT.rglob("*"):
        if "Readme" in path.relative_to(ROOT).parts:
            continue
        if path.is_file() and path.suffix.lower() in {".sp", ".inc", ".cfg", ".md", ".ps1", ".bat", ".yml", ".yaml", ".txt"}:
            text = path.read_text(encoding="utf-8", errors="ignore")
            assert "1.1.0" not in text, str(path)

def test_database_reconnect_contract():
    text = (ROOT / "addons/sourcemod/scripting/is_database.sp").read_text(encoding="utf-8")
    for symbol in ["ScheduleReconnect", "Timer_Reconnect", "Database.Connect", "g_iConnectionGeneration", "DBPrio_Low", "g_bSchemaReady", "g_hHealthTimer", "Timer_DatabaseHealth"]:
        assert symbol in text, symbol

def test_wallhack_metrics_contract():
    text = (ROOT / "addons/sourcemod/scripting/is_wallhack.sp").read_text(encoding="utf-8")
    for symbol in ["g_iTraceBudgetDrops", "g_iVisibilityChecks", "g_iBlockedTransmits", "g_iTotalTraces", "GetEngineTime", "window_ms"]:
        assert symbol in text, symbol


def test_no_literal_escaped_newlines_in_release_sources():
    for path in ROOT.rglob("*"):
        if path.is_file() and path.suffix.lower() in {".sp", ".inc", ".cfg", ".md", ".ps1", ".bat", ".yml", ".yaml", ".txt"}:
            data = path.read_text(encoding="utf-8", errors="ignore")
            assert "\\n" not in data, str(path)


def test_wallhack_window_metrics_are_time_based():
    text = (SPDIR / "is_wallhack.sp").read_text(encoding="utf-8")
    assert "g_fWindowStartedAt" in text
    assert "GetEngineTime()" in text


def test_database_health_metrics_are_present():
    text = (SPDIR / "is_database.sp").read_text(encoding="utf-8")
    for symbol in ["Timer_DatabaseHealth", "OnDatabaseHealth", "g_iHealthChecks", "g_iHealthFailures", "g_fLastHealthOkTime"]:
        assert symbol in text, symbol


def test_config_has_bilingual_documentation():
    cfg = CONFIG.read_text(encoding="utf-8")
    assert cfg.count("// EN:") >= 40
    assert cfg.count("// RU:") >= 40


def test_antismoke_rebuilds_grid_after_erase():
    text = (SPDIR / "is_antismoke.sp").read_text(encoding="utf-8")
    assert "g_hSmokes.Erase(idx);" in text
    assert "RebuildSmokeGrid();" in text
    assert "void RebuildSmokeGrid()" in text


def test_speed_thresholds_are_cached():
    text = (SPDIR / "is_speedhack.sp").read_text(encoding="utf-8")
    assert "g_fAllowedSpeedSq" in text
    assert "g_fExtremeSpeedSq" in text


def test_release_tree_has_no_python_cache():
    assert not list(ROOT.rglob("*.pyc"))
    assert not list(ROOT.rglob("__pycache__"))


def test_ci_release_asset_matches_public_download_name():
    text = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
    asset = "Iron.Sentinel.Core.v1.1.2.zip"
    assert asset in text


def test_database_health_block_is_real_sourcepawn():
    text = (SPDIR / "is_database.sp").read_text(encoding="utf-8")
    assert "public Action Timer_DatabaseHealth(Handle timer)\n{" in text
    assert "public void OnDatabaseHealth(Database db, DBResultSet results, const char[] error, any data)\n{" in text
    assert "\\n" not in text


def test_wallhack_has_no_dead_trace_counter():
    text = (SPDIR / "is_wallhack.sp").read_text(encoding="utf-8")
    assert "g_iTraceCount" not in text


def test_speed_peak_cache_resets_with_decay():
    text = (SPDIR / "is_speedhack.sp").read_text(encoding="utf-8")
    assert "g_fMaxSpeedReachedSq[i] = 0.0;" in text

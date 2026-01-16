/* CORE SCRIPTING // ENGINEER: MAXIM MELNIKOV */
const input = document.getElementById('console-input');
const logStream = document.getElementById('log-stream');
const downloadBtn = document.getElementById('download-btn');
const lockMsg = document.getElementById('lock-msg');

let isDeployed = false;

// ИНИЦИАЛИЗАЦИЯ ПОДСКАЗКИ
function showInitialHint() {
    const hint = document.createElement('div');
    hint.className = 'system-msg';
    hint.innerHTML = `[SYSTEM]: DEPLOYMENT_LOCKED.<br>
    [ACTION]: Run SteamCMD to fetch binaries.<br>
    [CMD]: <span class="hint-cmd" onclick="copyHint()">steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit</span>`;
    logStream.appendChild(hint);
}

function copyHint() {
    input.value = "steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit";
    input.focus();
}

function setCmd(name) {
    input.value = name;
    input.focus();
}

// ДИНАМИЧЕСКИЕ ДАТЧИКИ (CORE STABILITY / UPTIME)
function updateGauges() {
    const stability = document.getElementById('stability-fill');
    const uptime = document.getElementById('uptime-fill');
    
    // Плавное колебание значений
    if (stability) {
        const sVal = 90 + Math.random() * 8;
        stability.style.height = `${sVal}%`;
    }
    if (uptime) {
        const uVal = 98 + Math.random() * 2;
        uptime.style.height = `${uVal}%`;
    }
}

// ОБРАБОТКА КОМАНД
if (input) {
    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            const val = input.value.trim();
            if (!val) return;

            const line = document.createElement('div');
            line.className = 'system-msg';
            line.style.color = "var(--c-blue)";
            line.innerText = `> ${val}`;
            logStream.appendChild(line);

            if (val.includes('steamcmd') && val.includes('232330')) {
                simulateDownload();
            } else {
                handleCommands(val.toLowerCase());
            }

            input.value = '';
            logStream.scrollTop = logStream.scrollHeight;
        }
    });
}

function handleCommands(cmd) {
    let res = "";
    switch(cmd) {
        case 'status': res = isDeployed ? "STATUS: ONLINE // CORE_V94 // LINK: ACTIVE" : "STATUS: IDLE // DEPLOYMENT_REQUIRED"; break;
        case 'version': res = "CSS_CORE_V94_STABLE // BUILD_2026 // BY MAXIM MELNIKOV"; break;
        case 'matrix': document.documentElement.style.setProperty('--c-blue', '#00ff41'); res = "THEME: MATRIX_ACTIVE"; break;
        case 'reset': document.documentElement.style.setProperty('--c-blue', '#00d4ff'); res = "THEME: DEFAULT"; break;
        case 'clear': logStream.innerHTML = ''; showInitialHint(); return;
        default: res = "ERROR: UNKNOWN_COMMAND. TYPE 'HELP'.";
    }
    const s = document.createElement('div');
    s.className = 'system-msg';
    s.innerText = res;
    logStream.appendChild(s);
}

// СИМУЛЯЦИЯ ЗАГРУЗКИ STEAMCMD
function simulateDownload() {
    const lines = [
        "Connecting to Steam Public...", "Logged in OK", "Updating App 232330...",
        "[ 10%] Downloading...", "[ 40%] Extracting binaries...", "[ 80%] Applying REVEmu patches...",
        "[100%] Success! Build finalized.", "Quitting SteamCMD..."
    ];
    lines.forEach((text, i) => {
        setTimeout(() => {
            const l = document.createElement('div');
            l.className = text.includes('%') ? 'download-progress' : 'system-msg';
            l.innerText = text;
            logStream.appendChild(l);
            logStream.scrollTop = logStream.scrollHeight;
            if (i === lines.length - 1) {
                isDeployed = true;
                unlockUI();
            }
        }, i * 450);
    });
}

function unlockUI() {
    if (lockMsg) lockMsg.style.display = 'none';
    downloadBtn.classList.remove('hidden-btn');
    downloadBtn.classList.add('visible-btn');
    const g = document.getElementById('glitch-overlay');
    g.style.display = 'block';
    setTimeout(() => g.style.display = 'none', 200);
}

function updateClock() {
    const c = document.getElementById('live-clock');
    if (c) c.innerText = new Date().toLocaleString();
}

document.addEventListener('DOMContentLoaded', () => {
    showInitialHint();
    setInterval(updateClock, 1000);
    setInterval(updateGauges, 2000); // Запуск анимации полосок
    updateClock();
    updateGauges();
});
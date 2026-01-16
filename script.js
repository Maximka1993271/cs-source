/* CORE SCRIPTING // ENGINEER: MAXIM MELNIKOV // 2026 */
const input = document.getElementById('console-input');
const logStream = document.getElementById('log-stream');
const downloadBtn = document.getElementById('download-btn');
const lockMsg = document.getElementById('lock-msg');

let isDeployed = false;

// Показ начальной инструкции
function showInitialHint() {
    const hint = document.createElement('div');
    hint.innerHTML = `[SYSTEM]: DEPLOYMENT_LOCKED.<br>[ACTION]: Run SteamCMD protocol.<br>
    [CMD]: <span class="clickable-cmd" onclick="setCmd('steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit')">steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit</span>`;
    logStream.appendChild(hint);
}

// ВЫПОЛНЕНИЕ КОМАНД ЧЕРЕЗ КНОПКИ
function setCmd(name) {
    if (name === 'clear') {
        logStream.innerHTML = '';
        showInitialHint();
    } else {
        processInput(name);
    }
}

// Обработка ввода в консоль
function processInput(val) {
    if (!val) return;
    
    // Печать команды в лог
    const line = document.createElement('div');
    line.style.color = "#fff";
    line.innerText = `> ${val}`;
    logStream.appendChild(line);
    
    // Логика
    const cmd = val.toLowerCase();
    if (cmd.includes('steamcmd')) {
        simulateDownload();
    } else {
        handleBaseCommands(cmd);
    }
    
    logStream.scrollTop = logStream.scrollHeight;
}

// Слушатель клавиатуры
if (input) {
    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            processInput(input.value.trim());
            input.value = '';
        }
    });
}

// Логика базовых команд
function handleBaseCommands(cmd) {
    let res = "";
    switch(cmd) {
        case 'status': res = isDeployed ? "STATUS: ONLINE // CORE_V94" : "STATUS: IDLE // WAITING_FOR_EXTRACTION"; break;
        case 'version': res = "CSS_CORE_V94_FINAL BY MAXIM MELNIKOV"; break;
        case 'matrix': document.documentElement.style.setProperty('--c-blue', '#00ff41'); res = "THEME: MATRIX"; break;
        case 'reset': document.documentElement.style.setProperty('--c-blue', '#00d4ff'); res = "THEME: DEFAULT"; break;
        default: res = "ERROR: UNKNOWN_PROTOCOL";
    }
    const s = document.createElement('div');
    s.innerText = res;
    logStream.appendChild(s);
}

// Имитация процесса загрузки
function simulateDownload() {
    const lines = ["Connecting to Steam...", "Logged in as Anonymous", "App 232330 found", "Downloading content...", "[100%] Verification Complete.", "Quitting..."];
    lines.forEach((text, i) => {
        setTimeout(() => {
            const l = document.createElement('div');
            l.innerText = text;
            logStream.appendChild(l);
            logStream.scrollTop = logStream.scrollHeight;
            if (i === lines.length - 1) {
                isDeployed = true;
                downloadBtn.classList.add('visible-btn');
                lockMsg.style.display = 'none';
            }
        }, i * 600);
    });
}

// АВТО-ОПРЕДЕЛЕНИЕ СКОРОСТИ ИНТЕРНЕТА (NETWORK MONITOR)
function updateNetwork() {
    const conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
    let speed = conn ? conn.downlink : 10; 
    let type = conn ? conn.effectiveType : "4G";

    document.getElementById('rx-val').innerText = speed + " Mbps";
    document.getElementById('tx-val').innerText = type.toUpperCase();

    // Прыгающие бары
    for (let i = 1; i <= 6; i++) {
        const bar = document.getElementById(`bar-${i}`);
        if (bar) {
            let h = (speed * 4) + (Math.random() * 40);
            bar.style.height = Math.min(Math.max(h, 15), 95) + "%";
            bar.style.background = h > 75 ? "var(--c-orange)" : "var(--c-blue)";
        }
    }
}

setInterval(updateNetwork, 400);
setInterval(() => {
    document.getElementById('live-clock').innerText = new Date().toLocaleString();
}, 1000);

document.addEventListener('DOMContentLoaded', showInitialHint);
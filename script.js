/* CORE SCRIPTING // ENGINEER: MAXIM MELNIKOV // 2026 */
const input = document.getElementById('console-input');
const logStream = document.getElementById('log-stream');
const downloadBtn = document.getElementById('download-btn');
const lockMsg = document.getElementById('lock-msg');

let isDeployed = false;

// Начальная подсказка с кликабельной командой
function showInitialHint() {
    const hint = document.createElement('div');
    hint.innerHTML = `
        <span style="color: #00d4ff;">[SYSTEM]: DEPLOYMENT_LOCKED.</span><br>
        <span style="color: #00d4ff;">[ACTION]: Run SteamCMD to fetch binaries.</span><br>
        <span style="color: #ff9d00;">[CMD]: </span><span class="clickable-cmd" style="color: #ff9d00; cursor: pointer; text-decoration: underline;" onclick="setCmd('steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit')">steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit</span>
    `;
    logStream.appendChild(hint);
}

// Выполнение через кнопки QUICK_CMD и клик
function setCmd(name) {
    if (name === 'clear') {
        logStream.innerHTML = '';
        showInitialHint();
    } else {
        processInput(name);
    }
}

// Обработка ввода
function processInput(val) {
    if (!val) return;
    
    const line = document.createElement('div');
    line.style.color = "#fff";
    line.innerText = `> ${val}`;
    logStream.appendChild(line);
    
    const cmd = val.toLowerCase();
    if (cmd.includes('steamcmd')) {
        simulateDownload();
    } else {
        handleBaseCommands(cmd);
    }
    
    logStream.scrollTop = logStream.scrollHeight;
}

// Логика обычных команд
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
    s.style.color = "#00d4ff";
    s.innerText = res;
    logStream.appendChild(s);
}

// ИМИТАЦИЯ ЗАГРУЗКИ КАК НА СКРИНШОТЕ
function simulateDownload() {
    const steps = [
        { text: "Connecting to Steam Public...", delay: 500 },
        { text: "Logged in OK", delay: 1000 },
        { text: "Updating App 232330...", delay: 1500 },
        { text: "<span style='color: #fff;'>[ 10%]</span> Downloading...", delay: 2000 },
        { text: "<span style='color: #fff;'>[ 40%]</span> Extracting binaries...", delay: 3000 },
        { text: "<span style='color: #fff;'>[ 80%]</span> Applying REVEmu patches...", delay: 4000 },
        { text: "<span style='color: #fff;'>[100%]</span> Success! Build finalized.", delay: 5000 },
        { text: "Quitting SteamCMD...", delay: 5500 }
    ];

    steps.forEach((step, i) => {
        setTimeout(() => {
            const l = document.createElement('div');
            l.style.color = "#ff9d00"; // Оранжевый текст как на скрине
            l.innerHTML = step.text;
            logStream.appendChild(l);
            logStream.scrollTop = logStream.scrollHeight;

            if (i === steps.length - 1) {
                isDeployed = true;
                downloadBtn.classList.add('visible-btn');
                if(lockMsg) lockMsg.style.display = 'none';
            }
        }, step.delay);
    });
}

// Мониторинг сети (автоматический)
function updateNetwork() {
    const conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
    let speed = conn ? conn.downlink : 10; 
    let type = conn ? conn.effectiveType : "4G";

    const speedEl = document.getElementById('rx-val');
    const typeEl = document.getElementById('tx-val');
    if(speedEl) speedEl.innerText = speed + " Mbps";
    if(typeEl) typeEl.innerText = type.toUpperCase();

    for (let i = 1; i <= 6; i++) {
        const bar = document.getElementById(`bar-${i}`);
        if (bar) {
            let h = (speed * 4) + (Math.random() * 40);
            bar.style.height = Math.min(Math.max(h, 15), 95) + "%";
            bar.style.background = h > 75 ? "#ff9d00" : "#00d4ff";
        }
    }
}

setInterval(updateNetwork, 400);
setInterval(() => {
    const clock = document.getElementById('live-clock');
    if(clock) clock.innerText = new Date().toLocaleString();
}, 1000);

// Слушатель Enter
input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
        processInput(input.value.trim());
        input.value = '';
    }
});

document.addEventListener('DOMContentLoaded', showInitialHint);
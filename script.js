/* CORE SCRIPTING // ENGINEER: MAXIM MELNIKOV */
const pluginsData = [
    { name: "Auto Silencer", info: "Выводит в чат уведомление о том, что глушитель надет." },
    { name: "Bomb Events", info: "Информирует всех в чате о начале закладки или разминирования C4." },
    { name: "Bot Ping", info: "Эмулирует реалистичный пинг у ботов." },
    { name: "Flashlight", info: "Активирует фонарик (клавиша F)." },
    { name: "Grenades Messages", info: "Уведомления о брошенной гранате." },
    { name: "Hostage Down", info: "Уведомляет о ранении заложников." },
    { name: "Killer Info & Distance", info: "Ник убийцы, его HP и дистанция." },
    { name: "Mani Style Damage Display", info: "Нанесенный урон в чате." },
    { name: "Most Destructive", info: "Игрок с самым высоким уроном за раунд." },
    { name: "NoBlock", info: "Отключает коллизии между игроками." },
    { name: "Online Admins", info: "Проверка админов (!admins)." },
    { name: "Resetscore", info: "Команда !rs для обнуления счета." },
    { name: "Simple Connect Messages", info: "Уведомления о входе/выходе." },
    { name: "Time", info: "Время сервера и остаток карты." },
    { name: "Welcome", info: "Приветствие при входе." }
];

const randomLogs = [
    "SECURITY_SCAN: NO THREATS DETECTED",
    "CORE_TEMPERATURE: STABLE (42°C)",
    "BACKUP_SEQUENCE: COMPLETED_SUCCESSFULLY",
    "INCOMING_DATA_ENCRYPTED: RSA_4096",
    "NEXUS_LINK: STRENGTH_OPTIMAL"
];

function initPlugins() {
    const container = document.getElementById('log-stream');
    if (!container) return;
    container.innerHTML = ''; 
    pluginsData.forEach((p, i) => {
        setTimeout(() => {
            const div = document.createElement('div');
            div.className = 'plugin-item';
            div.innerText = `> ${p.name}`;
            div.onclick = () => {
                document.getElementById('modal-title').innerText = p.name;
                document.getElementById('modal-text').innerText = p.info;
                document.getElementById('plugin-modal').style.display = 'flex';
            };
            container.appendChild(div);
        }, i * 40);
    });
}

const consoleInput = document.getElementById('console-input');
const logStream = document.getElementById('log-stream');
const wrapper = document.querySelector('.terminal-wrapper');

if (wrapper) wrapper.onclick = () => consoleInput.focus();

if (consoleInput) {
    consoleInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
            const command = this.value.toLowerCase().trim();
            executeCommand(command);
            this.value = '';
        }
    });
}

function setCmd(name) {
    if (consoleInput) {
        consoleInput.value = name;
        consoleInput.focus();
    }
}

function executeCommand(cmd) {
    if (!cmd) return;
    const userLine = document.createElement('div');
    userLine.className = 'plugin-item';
    userLine.style.opacity = "1";
    userLine.innerText = `> ${cmd}`;
    logStream.appendChild(userLine);

    let response = "";
    let isError = false;

    switch(cmd) {
        case 'version': 
            response = "CSS_CORE_V94_STABLE // BUILD_2026_JAN"; 
            // Эффект: Логотип немного подсвечивается
            document.querySelector('.giant-header').style.transform = "scale(1.02)";
            setTimeout(() => document.querySelector('.giant-header').style.transform = "scale(1)", 200);
            break;

        case 'status': 
            response = "CORE: ONLINE // LINK: ACTIVE // 14ms"; 
            // Эффект: Дергаем индикатор стабильности
            const fill = document.getElementById('stability-fill');
            fill.style.height = "100%";
            setTimeout(() => fill.style.height = "94%", 1000);
            break;

        case 'matrix':
            document.documentElement.style.setProperty('--c-blue', '#00ff41');
            document.documentElement.style.setProperty('--c-orange', '#003b00');
            response = "OVERRIDE: SYSTEM_THEME_CHANGED";
            break;

        case 'reset':
            document.documentElement.style.setProperty('--c-blue', '#00d4ff');
            document.documentElement.style.setProperty('--c-orange', '#ff9d00');
            response = "SYSTEM_RESTORED_TO_DEFAULT";
            break;

        case 'clear': 
            // Эффект: Вспышка на весь экран
            const glitch = document.getElementById('glitch-overlay');
            glitch.style.display = 'block';
            setTimeout(() => glitch.style.display = 'none', 150);
            logStream.innerHTML = ''; 
            initPlugins(); 
            return;

        case 'help': 
            response = "AVAILABLE: status, version, matrix, reset, clear"; 
            break;

        default: 
            response = "ERROR: UNKNOWN COMMAND"; 
            isError = true;
    }

    setTimeout(() => {
        const sysLine = document.createElement('div');
        sysLine.className = 'system-msg';
        if (isError) {
            sysLine.style.color = "#ff4400";
            wrapper.style.borderColor = "#ff4400";
            setTimeout(() => wrapper.style.borderColor = "rgba(0, 212, 255, 0.1)", 300);
        }
        sysLine.innerText = response;
        logStream.appendChild(sysLine);
        logStream.scrollTo({ top: logStream.scrollHeight, behavior: 'smooth' });
    }, 150);
}

function spawnRandomLog() {
    if (!logStream) return;
    const logMsg = document.createElement('div');
    logMsg.className = 'system-msg';
    logMsg.style.opacity = "0.5";
    logMsg.innerText = `[AUTO] ${randomLogs[Math.floor(Math.random() * randomLogs.length)]}`;
    logStream.appendChild(logMsg);
    logStream.scrollTo({ top: logStream.scrollHeight, behavior: 'smooth' });
}

function updateClock() {
    const clock = document.getElementById('live-clock');
    if (clock) {
        const now = new Date();
        clock.innerText = `${now.getFullYear()}.${String(now.getMonth()+1).padStart(2,'0')}.${String(now.getDate()).padStart(2,'0')} // ${now.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit', second:'2-digit', hour12: false})}`;
    }
}

function closeModal() { document.getElementById('plugin-modal').style.display = 'none'; }

document.addEventListener('DOMContentLoaded', () => {
    initPlugins();
    setInterval(updateClock, 1000);
    setInterval(spawnRandomLog, 45000);
    updateClock();
    window.onclick = (e) => { if (e.target.id === 'plugin-modal') closeModal(); };
});
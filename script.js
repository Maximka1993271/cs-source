const pluginsData = [
    { name: "Auto Silencer", info: "Уведомление о надетом глушителе." },
    { name: "Bomb Events", info: "События C4 в чате." },
    { name: "Bot Ping", info: "Эмуляция пинга ботов." },
    { name: "Flashlight", info: "Фонарик на F." },
    { name: "Grenades Messages", info: "Инфо о гранатах." },
    { name: "Hostage Down", info: "Инфо о заложниках." },
    { name: "Killer Info & Distance", info: "Данные об убийце." },
    { name: "Mani Style Damage", info: "Урон в стиле Mani Admin." },
    { name: "Most Destructive", info: "Топ дамагер раунда." },
    { name: "NoBlock", info: "Проход сквозь игроков." },
    { name: "Online Admins", info: "Список админов (!admins)." },
    { name: "Resetscore", info: "Обнуление счета (!rs)." },
    { name: "Connect Messages", info: "Вход/выход игроков." },
    { name: "Time", info: "Время карты." },
    { name: "Welcome", info: "Приветствие." }
];

function initPlugins() {
    const log = document.getElementById('log-stream');
    if (!log) return;
    log.innerHTML = '';
    pluginsData.forEach((p, i) => {
        setTimeout(() => {
            const d = document.createElement('div');
            d.className = 'plugin-item';
            d.innerText = `> ${p.name}`;
            d.onclick = () => {
                document.getElementById('modal-title').innerText = p.name;
                document.getElementById('modal-text').innerText = p.info;
                document.getElementById('plugin-modal').style.display = 'flex';
            };
            log.appendChild(d);
        }, i * 30);
    });
}

const input = document.getElementById('console-input');
const logStream = document.getElementById('log-stream');

if (input) {
    input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            executeCommand(input.value.toLowerCase().trim());
            input.value = '';
        }
    });
}

function setCmd(name) {
    if (input) {
        input.value = name;
        input.focus();
    }
}

function executeCommand(cmd) {
    if (!cmd) return;
    const line = document.createElement('div');
    line.className = 'plugin-item';
    line.innerText = `>> ${cmd}`;
    logStream.appendChild(line);

    let res = "";
    switch(cmd) {
        case 'status': res = "SYSTEM: ONLINE // STABILITY: 94%"; break;
        case 'version': res = "CORE_V94_STABLE"; break;
        case 'matrix': 
            document.documentElement.style.setProperty('--c-blue', '#00ff41'); 
            res = "THEME: MATRIX_OVERRIDE"; break;
        case 'reset': 
            document.documentElement.style.setProperty('--c-blue', '#00d4ff'); 
            res = "THEME: DEFAULT"; break;
        case 'clear': 
            const g = document.getElementById('glitch-overlay');
            g.style.display = 'block'; setTimeout(()=>g.style.display='none',100);
            logStream.innerHTML = ''; initPlugins(); return;
        default: res = "COMMAND_NOT_RECOGNIZED";
    }

    const s = document.createElement('div');
    s.className = 'system-msg';
    s.innerText = res;
    logStream.appendChild(s);
    logStream.scrollTop = logStream.scrollHeight;
}

function updateClock() {
    const c = document.getElementById('live-clock');
    if (c) c.innerText = new Date().toLocaleString();
}

function closeModal() { document.getElementById('plugin-modal').style.display = 'none'; }

document.addEventListener('DOMContentLoaded', () => {
    initPlugins();
    setInterval(updateClock, 1000);
});
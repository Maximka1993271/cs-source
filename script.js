/**
 * CORE LOGIC // AUTHOR: MAXIM MELNIKOV // 2026
 */
const logStream = document.getElementById('log-stream');
const downloadZone = document.getElementById('download-zone');
const lockMsg = document.getElementById('lock-msg');
let audioCtx, isBoosted = false;

const pluginData = [
    { name: "Auto Silencer", en: "Auto attaches silencers to M4A1/USP.", ru: "Авто-прикрепление глушителей на M4A1/USP." },
    { name: "Bomb Events", en: "Logs and sounds for C4 events.", ru: "Логи и звуки для событий с бомбой C4." },
    { name: "Bot Ping", en: "Fakes scoreboard ping for bots.", ru: "Поддельный пинг для ботов в таблице счета." },
    { name: "Flashlight", en: "Classic flashlight functionality.", ru: "Классическая функция фонарика." },
    { name: "Grenades Messages", en: "Chat info about thrown grenades.", ru: "Инфо в чате о брошенных гранатах." },
    { name: "Hostage Down", en: "Alerts for hostage damage.", ru: "Оповещения при уроне заложникам." },
    { name: "Killer Info", en: "Shows killer's HP and distance.", ru: "Показывает HP и дистанцию убийцы." },
    { name: "Mani Damage", en: "Shows damage in center of screen.", ru: "Показывает урон в центре экрана." },
    { name: "Most Destructive", en: "Damage awards at round end.", ru: "Награды за урон в конце раунда." },
    { name: "NoBlock", en: "Disables player collision.", ru: "Отключает столкновения игроков." },
    { name: "Online Admins", en: "Shows active admins on server.", ru: "Показывает активных админов на сервере." },
    { name: "Resetscore", en: "Command !rs to clear stats.", ru: "Команда !rs для очистки счета." },
    { name: "Simple Connect", en: "Player join notifications.", ru: "Уведомления о входе игроков." },
    { name: "Time", en: "Server time synchronization.", ru: "Синхронизация времени сервера." },
    { name: "Welcome", en: "Greeting messages and sounds.", ru: "Приветственные сообщения и звуки." }
];

function playBeep(f, d) {
    if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    const o = audioCtx.createOscillator(), g = audioCtx.createGain();
    o.type = "sine"; o.frequency.value = f; g.gain.value = 0.005;
    o.connect(g); g.connect(audioCtx.destination); o.start(); o.stop(audioCtx.currentTime + d/1000);
}

function renderPlugins() {
    const grid = document.getElementById('plugin-grid');
    pluginData.forEach(p => {
        const item = document.createElement('div');
        item.className = 'plugin-item';
        item.innerText = p.name;
        item.onclick = () => {
            playBeep(1000, 30);
            logStream.innerHTML += `<div style="color:var(--c-orange); margin-top:5px;">[PLUGIN]: ${p.name.toUpperCase()}</div>`;
            logStream.innerHTML += `<div style="color:var(--c-blue); font-size:0.6rem;">[EN]: ${p.en}</div>`;
            logStream.innerHTML += `<div style="color:#fff; font-size:0.6rem; opacity:0.8;">[RU]: ${p.ru}</div>`;
            logStream.scrollTop = logStream.scrollHeight;
        };
        grid.appendChild(item);
    });
}

function showInitialHint() {
    logStream.innerHTML = `
        <div style="color: var(--c-blue);">[SYSTEM]: DEPLOYMENT_LOCKED.</div>
        <div style="color: var(--c-blue);">[ACTION]: Run SteamCMD to fetch binaries.</div>
        <div style="color: var(--c-orange); cursor: pointer; text-decoration: underline;" onclick="setCmd('steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit')">
            [CMD]: steamcmd +login anonymous +force_install_dir ../css_ds +app_update 232330 +quit
        </div>
    `;
}

function setCmd(cmd) { processInput(cmd); }

function processInput(val) {
    playBeep(1200, 15);
    const line = document.createElement('div');
    line.innerText = `> ${val}`;
    logStream.appendChild(line);
    
    const cmd = val.toLowerCase().trim();
    if (cmd.includes('steamcmd')) simulateInstall();
    else if (cmd === 'scan') runScan();
    else if (cmd === 'matrix') { 
        document.documentElement.style.setProperty('--c-blue', '#00ff41'); 
        logStream.innerHTML += `<div style="color:#00ff41">SYSTEM_RECOGNIZED: FOLLOW THE WHITE RABBIT.</div>`;
    }
    else if (cmd === 'boost') { isBoosted = true; setTimeout(()=>isBoosted=false, 5000); }
    else if (cmd === 'overload') { 
        document.getElementById('frame-master').classList.add('overload-active'); 
        setTimeout(()=>document.getElementById('frame-master').classList.remove('overload-active'), 1500);
    }
    else if (cmd === 'orange') { document.documentElement.style.setProperty('--c-blue', '#ff9d00'); }
    else if (cmd === 'stealth') { document.documentElement.style.setProperty('--c-blue', '#222'); }
    else if (cmd === 'reset') { document.documentElement.style.setProperty('--c-blue', '#00d4ff'); }
    else if (cmd === 'clear') { logStream.innerHTML = ''; showInitialHint(); }
    else if (cmd === 'status') { logStream.innerHTML += `<div style="color:var(--c-blue)">BUILD_V94 // MAXIM MELNIKOV // ONLINE</div>`; }
    
    logStream.scrollTop = logStream.scrollHeight;
}

function runScan() {
    let i = 0;
    const interval = setInterval(() => {
        logStream.innerHTML += `<div style="font-size:0.55rem;">SCANNING_SECTOR_0x${Math.random().toString(16).substr(2,4).toUpperCase()}... OK</div>`;
        logStream.scrollTop = logStream.scrollHeight;
        if(i++ > 10) clearInterval(interval);
    }, 50);
}

function simulateInstall() {
    logStream.innerHTML += `<div style="color:var(--c-orange)">CONNECTING TO STEAM...</div>`;
    setTimeout(() => {
        downloadZone.classList.add('visible-btn');
        lockMsg.innerText = "STATUS: ONLINE // MAXIM MELNIKOV";
        logStream.innerHTML += `<div style="color:var(--c-blue)">SUCCESS! SERVER_V94 LOADED.</div>`;
    }, 2000);
}

function updateUI() {
    for (let i = 1; i <= 5; i++) {
        const bar = document.getElementById(`bar-${i}`);
        if(bar) bar.style.height = (isBoosted ? 80 + Math.random()*20 : 10 + Math.random()*70) + "%";
    }
    document.getElementById('g-cpu').style.height = (isBoosted ? 95 : 15 + Math.random()*30) + "%";
    document.getElementById('g-mem').style.height = (isBoosted ? 45 : 10 + Math.random()*40) + "%";
    document.getElementById('g-net').style.height = (isBoosted ? 98 : 5 + Math.random()*25) + "%";
    document.getElementById('rx-val').innerText = (isBoosted ? 98.4 : Math.random()*35).toFixed(2);
}

setInterval(updateUI, 400);
setInterval(() => { document.getElementById('live-clock').innerText = new Date().toLocaleTimeString(); }, 1000);
window.onload = () => { showInitialHint(); renderPlugins(); };
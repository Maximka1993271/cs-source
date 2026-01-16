/* CORE SCRIPTING 
   ENGINEER: MAXIM MELNIKOV
*/

const pluginList = [
    "Auto Silencer", "Bomb Events", "Bot Ping", "Flashlight", 
    "Grenades Messages", "Hostage Down", "Killer Info & Distance", 
    "Mani Style Damage Display", "Most Destructive", "NoBlock", 
    "Online Admins", "Resetscore", "Simple Connect Messages", 
    "Time", "Welcome"
];

function updateTerminal() {
    // 1. ЖИВОЕ ВРЕМЯ
    const clock = document.getElementById('live-clock');
    if (clock) {
        const now = new Date();
        const dateStr = `${now.getFullYear()}.${String(now.getMonth()+1).padStart(2,'0')}.${String(now.getDate()).padStart(2,'0')}`;
        const timeStr = now.toLocaleTimeString();
        clock.innerText = `${dateStr} // ${timeStr}`;
    }

    // 2. СЛУЧАЙНОЕ МЕРЦАНИЕ ПЛАГИНОВ
    const logContainer = document.getElementById('log-stream');
    if (logContainer && Math.random() > 0.8) {
        const children = logContainer.children;
        if (children.length > 0) {
            const randomPlugin = children[Math.floor(Math.random() * children.length)];
            randomPlugin.style.color = "var(--c-orange)";
            setTimeout(() => { randomPlugin.style.color = "var(--c-blue)"; }, 500);
        }
    }
}

// ФУНКЦИЯ ПРОГРУЗКИ ПЛАГИНОВ
function initPlugins() {
    const logContainer = document.getElementById('log-stream');
    if (!logContainer) return;
    
    logContainer.innerHTML = ''; // Очистка

    pluginList.forEach((plugin, index) => {
        setTimeout(() => {
            let div = document.createElement('div');
            div.className = 'plugin-item';
            div.innerText = `> ${plugin}`;
            logContainer.appendChild(div);
        }, index * 150); // Интервал появления
    });
}

// Запуск всей системы
document.addEventListener('DOMContentLoaded', () => {
    initPlugins();
    setInterval(updateTerminal, 1000);
    updateTerminal();
});
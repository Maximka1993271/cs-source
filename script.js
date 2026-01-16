/* CORE SCRIPTING 
   ENGINEER: MAXIM MELNIKOV
*/

const pluginsData = [
    { name: "Auto Silencer", info: "Выводит в чат уведомление о том, что глушитель надет (игроку нужно надеть его вручную)." },
    { name: "Bomb Events", info: "Информирует всех игроков в чате о начале закладки или разминирования C4." },
    { name: "Bot Ping", info: "Эмулирует задержку (ping) у ботов в таблице счета для большей реалистичности." },
    { name: "Flashlight", info: "Активирует возможность использования фонарика. Управление стандартной клавишей (F)." },
    { name: "Grenades Messages", info: "Выводит в чат уведомления о типе брошенной гранаты (HE, Flash, Smoke)." },
    { name: "Hostage Down", info: "Система мониторинга заложников: уведомляет о ранении или гибели спасаемых объектов." },
    { name: "Killer Info & Distance", info: "После смерти показывает ник убийцы, его оставшееся здоровье и точную дистанцию выстрела." },
    { name: "Mani Style Damage Display", info: "Отображает нанесенный вами урон противнику в текстовом чате сервера." },
    { name: "Most Destructive", info: "Статистический модуль: в конце раунда определяет игрока, нанесшего больше всего урона." },
    { name: "NoBlock", info: "Отключает коллизии между игроками одной команды, предотвращая застревания в проходах." },
    { name: "Online Admins", info: "Позволяет игрокам проверить наличие администраторов на сервере через команды !admins и /admins." },
    { name: "Resetscore", info: "Добавляет команду !rs для мгновенного обнуления личной статистики смертей и убийств." },
    { name: "Simple Connect Messages", info: "Классические уведомления о подключении новых игроков или их выходе с сервера." },
    { name: "Time", info: "Выводит информацию о текущем времени и оставшемся времени до смены текущей карты." },
    { name: "Welcome", info: "Автоматическое приветствие игрока при входе и отображение краткой информации о проекте." }
];

// Далее идет весь остальной код (updateTerminal, initPlugins и т.д.), который я давал раньше.

// 1. ЖИВОЕ ВРЕМЯ В HUD
function updateTerminal() {
    const clock = document.getElementById('live-clock');
    if (clock) {
        const now = new Date();
        const dateStr = `${now.getFullYear()}.${String(now.getMonth()+1).padStart(2,'0')}.${String(now.getDate()).padStart(2,'0')}`;
        const timeStr = now.toLocaleTimeString();
        clock.innerText = `${dateStr} // ${timeStr}`;
    }
}

// 2. ИНИЦИАЛИЗАЦИЯ СПИСКА ПЛАГИНОВ С ВЫПАДЕНИЕМ
function initPlugins() {
    const logContainer = document.getElementById('log-stream');
    if (!logContainer) return;

    logContainer.innerHTML = ''; 

    pluginsData.forEach((plugin, index) => {
        setTimeout(() => {
            let div = document.createElement('div');
            div.className = 'plugin-item';
            div.innerText = `> ${plugin.name}`;
            
            // Добавляем возможность клика для открытия инфо
            div.onclick = () => showPluginInfo(plugin.name, plugin.info);
            
            logContainer.appendChild(div);
        }, index * 100); // Скорость выпадения (100мс)
    });
}

// 3. УПРАВЛЕНИЕ МОДАЛЬНЫМ ОКНОМ
function showPluginInfo(name, info) {
    const modal = document.getElementById('plugin-modal');
    if (!modal) return;
    
    document.getElementById('modal-title').innerText = name;
    document.getElementById('modal-text').innerText = info;
    modal.style.display = 'flex';
}

function closeModal() {
    const modal = document.getElementById('plugin-modal');
    if (modal) modal.style.display = 'none';
}

// Запуск системы
document.addEventListener('DOMContentLoaded', () => {
    initPlugins();
    setInterval(updateTerminal, 1000);
    updateTerminal();

    // Закрытие окна при клике на темную область
    window.onclick = (event) => {
        const modal = document.getElementById('plugin-modal');
        if (event.target == modal) closeModal();
    };
});
/* CORE SCRIPTING // ENGINEER: MAXIM MELNIKOV */

const pluginsData = [
    { name: "Auto Silencer", info: "Выводит в чат уведомление о том, что глушитель надет (игроку нужно надеть его вручную)." },
    { name: "Bomb Events", info: "Информирует всех в чате о начале закладки или разминирования C4." },
    { name: "Bot Ping", info: "Эмулирует реалистичный пинг у ботов в таблице счета." },
    { name: "Flashlight", info: "Активирует возможность использования фонарика (клавиша F)." },
    { name: "Grenades Messages", info: "Уведомления в чате о типе брошенной гранаты (HE, Flash, Smoke)." },
    { name: "Hostage Down", info: "Уведомляет о ранении или гибели заложников." },
    { name: "Killer Info & Distance", info: "Показывает ник убийцы, его HP и точную дистанцию выстрела." },
    { name: "Mani Style Damage Display", info: "Отображает нанесенный вами урон противнику в чате сервера." },
    { name: "Most Destructive", info: "В конце раунда определяет игрока, нанесшего больше всего урона." },
    { name: "NoBlock", info: "Отключает коллизии между игроками одной команды." },
    { name: "Online Admins", info: "Проверка админов через команды !admins и /admins." },
    { name: "Resetscore", info: "Добавляет команду !rs для мгновенного обнуления личной статистики." },
    { name: "Simple Connect Messages", info: "Классические уведомления о подключении/выходе игроков." },
    { name: "Time", info: "Информация о времени сервера и остатке времени карты." },
    { name: "Welcome", info: "Приветственное сообщение при входе на сервер." }
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
        }, i * 100);
    });
}

function updateClock() {
    const clock = document.getElementById('live-clock');
    if (clock) {
        const now = new Date();
        clock.innerText = `${now.getFullYear()}.${String(now.getMonth()+1).padStart(2,'0')}.${String(now.getDate()).padStart(2,'0')} // ${now.toLocaleTimeString()}`;
    }
}

function closeModal() { document.getElementById('plugin-modal').style.display = 'none'; }

document.addEventListener('DOMContentLoaded', () => {
    initPlugins();
    setInterval(updateClock, 1000);
    updateClock();
    window.onclick = (e) => { if (e.target.id === 'plugin-modal') closeModal(); };
});
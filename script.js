/* CORE SCRIPTING 
   ENGINEER: MAXIM MELNIKOV
*/

function updateTerminal() {
    // 1. ЖИВОЕ ВРЕМЯ
    const clock = document.getElementById('live-clock');
    const now = new Date();
    const dateStr = `${now.getFullYear()}.${String(now.getMonth()+1).padStart(2,'0')}.${String(now.getDate()).padStart(2,'0')}`;
    const timeStr = now.toLocaleTimeString();
    clock.innerText = `${dateStr} // ${timeStr}`;

    // 2. ДИНАМИЧЕСКИЕ ЛОГИ (Справа)
    const logContainer = document.getElementById('log-stream');
    const logs = [
        "> ПРОВЕРКА ЦЕЛОСТНОСТИ ЯДРА...",
        "> СИСТЕМА REVEMU АКТИВНА",
        "> ПОДКЛЮЧЕНИЕ К NEXUS СЕКТОРУ 17",
        "> ПАКЕТЫ ДАННЫХ V94 ПРИНЯТЫ",
        "> ШИФРОВАНИЕ ENCRYPT_SUPREME"
    ];

    if (Math.random() > 0.8) {
        let div = document.createElement('div');
        div.innerText = logs[Math.floor(Math.random() * logs.length)];
        logContainer.prepend(div);
        if (logContainer.childNodes.length > 12) logContainer.removeChild(logContainer.lastChild);
    }
}

// Запуск
setInterval(updateTerminal, 1000);
updateTerminal();
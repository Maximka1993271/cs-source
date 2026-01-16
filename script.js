/**
 * CSS CORE TERMINAL ENGINE
 * Living Clock & Interface Logic
 */

function updateSystemTime() {
    const clockElement = document.getElementById('live-clock');
    if (!clockElement) return;

    const now = new Date();

    // Получаем компоненты даты
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');

    // Получаем компоненты времени
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');

    // Формируем строку в стиле HL2: ГГГГ.ММ.ДД // ЧЧ:ММ:СС
    const timeString = `${year}.${month}.${day} // ${hours}:${minutes}:${seconds}`;

    // Выводим в HUD
    clockElement.textContent = timeString;
}

// Запускаем обновление каждую секунду
setInterval(updateSystemTime, 1000);

// Инициализируем сразу при загрузке
document.addEventListener('DOMContentLoaded', () => {
    updateSystemTime();
    console.log("CSS CORE: System Clock Online");
    
    // Добавим небольшой эффект "мерцания" при обновлении (по желанию)
    const clock = document.getElementById('live-clock');
    clock.style.transition = "0.2s opacity";
});
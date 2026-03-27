#!/system/bin/sh

# Скрипт очистки при удалении модуля

# Останавливаем все процессы
pkill -f "led_charger.sh"
pkill -f "led_notify.sh"

# Удаляем PID файлы
rm -f /data/local/tmp/led_charger.pid
rm -f /data/local/tmp/led_notify.pid

# Удаляем логи
rm -f /data/local/tmp/led_charger.log
rm -f /data/local/tmp/led_notify.log

# Удаляем временные файлы (если есть)
rm -f /data/local/tmp/led_*.tmp

# Логируем удаление
echo "LED Controller module uninstalled" > /dev/kmsg

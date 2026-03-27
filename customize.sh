#!/system/bin/sh

# Установочный скрипт модуля
# Выполняется при установке/обновлении модуля

MODULE_NAME="led_controller"
SERVICE_DIR="/data/adb/service.d"

# Удаляем старый скрипт из service.d (первая версия модуля)
OLD_SCRIPT="$SERVICE_DIR/led_charger.sh"
if [ -f "$OLD_SCRIPT" ]; then
    echo "Removing old script from service.d..." >&2
    rm -f "$OLD_SCRIPT"
    # Также удаляем возможный конфиг, если он был
    rm -f "$SERVICE_DIR/led_charger.conf"
fi

# Удаляем старые PID файлы (если остались от первой версии)
rm -f /data/local/tmp/led_charger.pid
rm -f /data/local/tmp/led_notify.pid

# Удаляем старые логи (опционально, можно оставить для истории)
# rm -f /data/local/tmp/led_charger.log
# rm -f /data/local/tmp/led_notify.log

# Выставляем права на скрипты (хотя Magisk это делает автоматически)
chmod 755 "$MODPATH/system/bin/led_charger.sh"
chmod 755 "$MODPATH/system/bin/led_notify.sh"

# Проверяем наличие БД настроек LineageOS
DB_PATH="/data/user_de/0/org.lineageos.lineagesettings/databases/lineagesettings.db"
if [ ! -f "$DB_PATH" ]; then
    echo "Warning: LineageOS Settings database not found" >&2
    echo "Module may not work correctly without LineageOS Settings" >&2
fi

# Останавливаем старые процессы (если работают)
if pgrep -f "led_charger.sh" > /dev/null; then
    echo "Stopping old led_charger process..." >&2
    pkill -f "led_charger.sh"
fi

if pgrep -f "led_notify.sh" > /dev/null; then
    echo "Stopping old led_notify process..." >&2
    pkill -f "led_notify.sh"
fi

# Логируем успешную установку
echo "$MODULE_NAME installed successfully (cleaned old files)" > /dev/kmsg

# Выводим сообщение об успешной установке (будет видно в логе установки)
echo "✓ Module installed successfully"
echo "✓ Old scripts removed from service.d"
echo "✓ Services will start after reboot"

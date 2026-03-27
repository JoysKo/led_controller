#!/system/bin/sh

# Выполняется на ранней стадии загрузки, до старта Android
# Здесь доступно /data, но не все сервисы ещё запущены

# Ждём монтирования /data (уже смонтировано на этом этапе)
# Но подождём немного для стабильности
sleep 10

# Запускаем сервисы
if [ -f /data/adb/modules/led_controller/system/bin/led_charger.sh ]; then
    /data/adb/modules/led_controller/system/bin/led_charger.sh &
fi

if [ -f /data/adb/modules/led_controller/system/bin/led_notify.sh ]; then
    /data/adb/modules/led_controller/system/bin/led_notify.sh &
fi

# Логируем запуск
echo "LED Controller services started (post-fs-data)" > /dev/kmsg

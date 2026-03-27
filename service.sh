#!/system/bin/sh

# Выполняется после завершения загрузки Android
# Здесь доступны все системные сервисы и БД

# Ждём полной загрузки системы
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Дополнительная задержка для инициализации БД LineageOS
sleep 30

# Проверяем, что скрипты существуют
if [ -f /data/adb/modules/led_controller/system/bin/led_charger.sh ]; then
    # Запускаем индикатор зарядки
    nohup /data/adb/modules/led_controller/system/bin/led_charger.sh &
    echo "LED charger service started" > /dev/kmsg
fi

if [ -f /data/adb/modules/led_controller/system/bin/led_notify.sh ]; then
    # Запускаем индикатор уведомлений
    nohup /data/adb/modules/led_controller/system/bin/led_notify.sh &
    echo "LED notify service started" > /dev/kmsg
fi

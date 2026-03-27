#!/system/bin/sh

# LED Notification indicator for Mi Max 3
# by JoysKo (with big help of DeepSeek), 2026
LED="/sys/class/leds/white/brightness"
DB_PATH="/data/user_de/0/org.lineageos.lineagesettings/databases/lineagesettings.db"
LOG="/data/local/tmp/led_notify.log"

# Проверяем, не запущен ли уже
if [ -f /data/local/tmp/led_notify.pid ]; then
    pid=$(cat /data/local/tmp/led_notify.pid 2>/dev/null)
    if kill -0 $pid 2>/dev/null; then
        echo "LED notify already running" >> $LOG
        exit 0
    fi
fi
echo $$ > /data/local/tmp/led_notify.pid

echo none > $LED

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG
}

get_lineage_setting() {
    sqlite3 "$DB_PATH" "SELECT value FROM system WHERE name='$1';" 2>/dev/null
}

get_notification_brightness() {
    local zen_mode=$(settings get global zen_mode 2>/dev/null)
    local brightness_level
    
    if [ "$zen_mode" != "0" ] && [ -n "$zen_mode" ]; then
        brightness_level=$(get_lineage_setting "notification_light_brightness_level_zen")
    else
        brightness_level=$(get_lineage_setting "notification_light_brightness_level")
    fi
    
    if [ -n "$brightness_level" ] && [ "$brightness_level" -gt 100 ]; then
        brightness_level=$((brightness_level * 100 / 255))
    fi
    
    [ -z "$brightness_level" ] && brightness_level=100
    [ "$brightness_level" -lt 0 ] && brightness_level=0
    [ "$brightness_level" -gt 100 ] && brightness_level=100
    
    echo $((brightness_level * 255 / 100))
}

blink() {
    local on=$1 off=$2 times=$3 brightness=$4
    for i in $(seq 1 $times); do
        echo $brightness > $LED
        sleep $on
        echo 0 > $LED
        sleep $off
    done
}

check_missed_calls() {
    content query --uri content://call_log/calls --where "type=3 AND is_read=0" 2>/dev/null | grep -q Row
    return $?
}

check_sms() {
    content query --uri content://sms/inbox --where "read=0" 2>/dev/null | grep -q Row
    return $?
}

check_notifications() {
    dumpsys notification 2>/dev/null | grep "NotificationRecord" | \
        grep -v "ONGOING" | \
        grep -v "FOREGROUND_SERVICE" | \
        grep -v "com.hb.dialer" | \
        grep -v "com.android.mms" | \
        grep -q "pkg="
    return $?
}

should_process_notifications() {
    local screen_enabled=$(get_lineage_setting "notification_light_screen_on_enable")
    local screen_on=$(dumpsys display 2>/dev/null | grep -q "mScreenState=ON" && echo 1 || echo 0)
    
    [ "$screen_on" = "0" ] && return 0
    [ "$screen_enabled" = "1" ] && return 0
    return 1
}

log "LED notify started"

while true; do
    notification_enabled=$(settings get system notification_light_pulse 2>/dev/null)
    
    if [ "$notification_enabled" = "1" ] && should_process_notifications; then
        brightness=$(get_notification_brightness)
        
        if check_missed_calls; then
            log "Missed call detected"
            blink 1 0.5 3 $brightness
            sleep 5
        elif check_sms; then
            log "SMS detected"
            blink 0.3 0.3 3 $brightness
            sleep 5
        elif check_notifications; then
            log "Notification detected"
            blink 0.2 0.2 2 $brightness
            sleep 5
        fi
    fi
    
    sleep 3
done

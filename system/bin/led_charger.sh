#!/system/bin/sh

# LED Charging Indicator for Mi Max 3
# by JoysKo (with big help of DeepSeek), 2026
LED="/sys/class/leds/white/brightness"
DB_PATH="/data/user_de/0/org.lineageos.lineagesettings/databases/lineagesettings.db"
LOG="/data/local/tmp/led_charger.log"
PID_FILE="/data/local/tmp/led_charger.pid"

# Проверка на повторный запуск через PID-файл
if [ -f "$PID_FILE" ]; then
    old_pid=$(cat "$PID_FILE" 2>/dev/null)
    if kill -0 "$old_pid" 2>/dev/null; then
        exit 0
    fi
fi
echo $$ > "$PID_FILE"

# Удаляем PID при выходе
trap "rm -f $PID_FILE" EXIT

echo none > $LED 2>/dev/null

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG
}

get_lineage_setting() {
    sqlite3 "$DB_PATH" "SELECT value FROM system WHERE name='$1';" 2>/dev/null
}

get_battery_brightness() {
    local zen_mode=$(settings get global zen_mode 2>/dev/null)
    local brightness_level
    
    if [ "$zen_mode" != "0" ] && [ -n "$zen_mode" ]; then
        brightness_level=$(get_lineage_setting "battery_light_brightness_level_zen")
    else
        brightness_level=$(get_lineage_setting "battery_light_brightness_level")
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
        echo $brightness > $LED 2>/dev/null
        sleep $on
        echo 0 > $LED 2>/dev/null
        sleep $off
    done
}

log "LED charger started"

while true; do
    battery_enabled=$(get_lineage_setting "battery_light_enabled")
    
    if [ "$battery_enabled" = "1" ]; then
        status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
        cap=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null)
        pulse=$(get_lineage_setting "battery_light_pulse")
        full_disable=$(get_lineage_setting "battery_light_full_charge_disabled")
        
        if [ "$status" = "Charging" ] && [ -n "$cap" ]; then
            if [ "$full_disable" = "1" ] && [ "$cap" -eq 100 ]; then
                echo 0 > $LED 2>/dev/null
            else
                max_brightness=$(get_battery_brightness)
                brightness=$((max_brightness * (100 - cap) / 100))
                min_brightness=$((max_brightness * 35 / 100))
                [ "$brightness" -lt "$min_brightness" ] && brightness=$min_brightness
                [ "$brightness" -gt "$max_brightness" ] && brightness=$max_brightness
                
                if [ "$pulse" = "1" ] && [ "$cap" -lt 15 ]; then
                    blink 0.5 0.5 2 $brightness
                else
                    echo $brightness > $LED 2>/dev/null
                fi
            fi
        else
            echo 0 > $LED 2>/dev/null
        fi
    else
        echo 0 > $LED 2>/dev/null
    fi
    
    sleep 2
done

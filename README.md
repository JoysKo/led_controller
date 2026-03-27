# LED Controller for Mi Max 3

LED Control module for Xiaomi Mi Max 3 with support for charging and notification indicators.

## Features

- 🔋 **Battery charging indicator** with brightness based on charge level
- 🔔 **Notification LED** for missed calls, SMS, and app notifications
- ⚙️ **Integration with LineageOS Settings** (battery light, notification light, zen mode)
- 🎨 **Adaptive brightness** for different zen modes
- 💨 **Pulse effect** when battery is low (<15%)

## Requirements

- Magisk 20.0+ or KernelSU
- LineageOS 18.1+ (or any ROM with LineageOS Settings)
- Xiaomi Mi Max 3 (or any device with LED at `/sys/class/leds/white/brightness`)

## Installation

1. Download the latest `led_controller_vX.X.zip` from [Releases](https://github.com/JoysKo/led_controller/releases)
2. Open Magisk/KernelSU app
3. Go to Modules section
4. Click "Install from storage" and select the downloaded zip
5. Reboot your device

## Configuration

The module reads settings directly from LineageOS Settings database:
- `battery_light_enabled` - Enable/disable charging LED
- `battery_light_brightness_level` - LED brightness during charging
- `battery_light_pulse` - Enable pulse effect at low battery
- `battery_light_full_charge_disabled` - Turn off LED at 100%
- `notification_light_pulse` - Enable notification LED
- `notification_light_brightness_level` - LED brightness for notifications
- `notification_light_screen_on_enable` - Show notifications when screen is on

These can be configured in:
- Settings → System → Buttons & gestures → Battery light
- Settings → System → Buttons & gestures → Notification light

## How it works

- **Charging LED**: Brightness changes proportionally to battery level (dimmer when battery is low)
- **Notification LED**: Different blink patterns for calls, SMS, and other notifications
- **Zen mode**: Automatically adjusts brightness when Do Not Disturb is enabled

## Manual control

You can manually start/stop services:

```bash
# Start services
su -c /data/adb/modules/led_controller/system/bin/led_charger.sh &
su -c /data/adb/modules/led_controller/system/bin/led_notify.sh &

# Stop services
su -c pkill -f led_charger.sh
su -c pkill -f led_notify.sh

# Check logs
cat /data/local/tmp/led_charger.log
cat /data/local/tmp/led_notify.log
```

## Uninstallation

1. Open Magisk/KernelSU app
2. Go to Modules section
3. Find LED Controller and click "Remove"
4. Reboot your device

## Changelog

See CHANGELOG.md

## Credits

· Author: JoysKo
· Assistant: DeepSeek AI
· Tested on: Xiaomi Mi Max 3 (LineageOS 20)

## License

MIT License - see LICENSE file

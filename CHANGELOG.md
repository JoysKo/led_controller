
### `CHANGELOG.md`
```markdown
# Changelog

## [1.1] - 2026-03-27

### Changed
- Complete module restructure for Magisk/KernelSU compatibility
- Integration with LineageOS Settings
- Scripts moved from `/data/adb/service.d/` to `/data/adb/modules/led_controller/system/bin/`
- Added proper `customize.sh` with old script cleanup
- Improved service startup with `post-fs-data.sh` and `service.sh`

### Fixed
- Fixed encoding issues in comments
- Fixed PID file management
- Better error handling for missing LineageOS Settings database

## [1.0] - 2026-03-20

### Added
- Initial release
- Battery charging LED with brightness control
- Notification LED for missed calls, SMS, and apps
- Adaptive brightness for zen mode
- Low battery pulse effect

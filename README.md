# MultiVol

MultiVol is a Swift-based dual-platform project scaffold for controlling audio source volume with WidgetKit support.

## What is included

- Shared domain and service layer in `MultiVolShared/`
- iOS app entry point and UI in `MultiVoliOS/`
- macOS app entry point and UI in `MultiVolMac/`
- WidgetKit extension source in `MultiVolWidgets/`
- AppIntent action (`AdjustVolumeIntent`) for widget-driven volume adjustment

## Platform notes

- macOS: Uses CoreAudio APIs to read/write default output device volume.
- iOS: Apple does not expose public APIs for per-source system volume control. The implementation stores per-source intent values and is ready to connect to app-owned audio sessions.

## Xcode setup

1. Create a new Xcode workspace and add these folders as groups.
2. Create three targets:
   - iOS App target using files in `MultiVoliOS/` + `MultiVolShared/`
   - macOS App target using files in `MultiVolMac/` + `MultiVolShared/`
   - Widget Extension target using files in `MultiVolWidgets/` + `MultiVolShared/`
3. Enable the `App Groups` capability for app targets and widget extension.
4. If you need live background updates, enable Background Modes where required.

## Release branches

Use separate branches for each platform release stream:

- `release/macos`
- `release/ios`

These branches are created from `main` so iOS and macOS release work can proceed independently.

# MultiVol

MultiVol is a Swift dual-platform app + widget project for controlling and monitoring audio source levels.

## What is included

- Shared domain, persistence, and service layer in `MultiVolShared/`
- iOS app entry point and UI in `MultiVoliOS/`
- macOS app entry point and UI in `MultiVolMac/`
- WidgetKit extension source in `MultiVolWidgets/`
- AppIntent action (`AdjustVolumeIntent`) for widget-driven volume adjustments
- XcodeGen project spec in `project.yml`

## Current platform behavior

- macOS:
   - Real control for system output volume and microphone input volume via CoreAudio.
   - Dynamic source rows for active apps (Spotify, FaceTime, YouTube browser app context).
   - App-source sliders are app-mix levels persisted by MultiVol for widget/app consistency.
- iOS:
   - Shared, persistent app-group-backed source levels used by app, widget, and intents.
   - iOS does not provide public APIs for true per-app system volume control; labels like system/media/call represent MultiVol-managed mix levels.

## Widget behavior

- The widget reads/writes shared app-group state and supports inline +/- adjustments through `AdjustVolumeIntent`.
- On macOS, widget placement is available in the widget system (desktop/notification center) rather than as a native Control Center audio mixer replacement.

## Build and run

1. Generate the project:

    ```bash
    xcodegen generate
    ```

2. Open `MultiVol.xcodeproj` in Xcode.
3. Select `MultiVoliOS` or `MultiVolMac` scheme and run.

## Tests

- Shared logic tests are in `MultiVolSharedTests/`.
- Run with:

   ```bash
   xcodebuild -project MultiVol.xcodeproj -scheme MultiVolSharedTests test
   ```

## Release branches

- `release/macos`
- `release/ios`

These branches are intended for independent platform shipping pipelines.

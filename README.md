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
   - Real app-owned mixer buses (Music Bus, Call Bus, Effects Bus) powered by AVAudioEngine player nodes with independent per-source volume.
   - App-owned bus levels are persisted and shared across app and widget surfaces.
   - When a known external call app (for example WhatsApp/FaceTime) is active, the `Call Bus` slider also bridges to system output volume so live calls are affected.
- iOS:
   - True app-owned mixer buses (Music Bus, Call Bus, Effects Bus) powered by AVAudioEngine with per-source controls.
   - Shared, persistent app-group-backed source levels used by app, widget, and intents.
   - iOS does not provide public APIs for true per-app system volume control; labels like system/media/call represent MultiVol-managed mix levels.
   - iOS shipping model still requires a host app for extensions. MultiVol exposes quick controls in the app navigation bar and widget/control surfaces, but cannot legally inject arbitrary per-app system volume controls across FaceTime/Spotify/other apps.

## Control-panel UX

- macOS runs as a menu-bar control panel (`MenuBarExtra`) for source sliders.
- iOS provides quick source actions in the navigation bar "Control Panel" menu and widget intent actions.
- Neither platform supports replacing Apple system audio control center with third-party arbitrary per-app volume controls using public APIs.

## Wiring real app-owned sources

`AppOwnedAudioMixer` now exposes real routing APIs for your own audio graph:

- `attachMicrophoneInput(to:)`: route capture input into a bus (for call monitor flows).
- `attachLoopingAudioFile(at:to:)`: route a real media file into a bus.
- `attachPlayerNode(_:format:to:)`: attach your own `AVAudioPlayerNode` for app-managed streams.

Default buses:

- `owned.music`
- `owned.call`
- `owned.fx`

Use these source IDs from your app playback/call stacks to control per-source mix levels through the existing service/UI/widget pipeline.

### Default bootstrap behavior

- `AppOwnedMixerBootstrap` initializes routing on app launch.
- Microphone input is not auto-routed by default (to avoid interfering with device output routing).
- If present in the app bundle, the following files are auto-routed:
   - `music-loop.m4a` / `music-loop.wav` / `music-loop.mp3` -> `owned.music`
   - `fx-loop.m4a` / `fx-loop.wav` / `fx-loop.mp3` -> `owned.fx`

To wire your production streams, call `attachPlayerNode(_:format:to:)` with your own media/call players.
To enable call capture routing, call `connectMicrophoneToCallBus()` explicitly.

### One-call production integration

Use `AppOwnedStreamRouter` for direct stack wiring:

```swift
import AVFAudio

let mediaNode = AVAudioPlayerNode()
let mediaProvider = PlayerNodeMediaAudioProvider(playerNode: mediaNode, outputFormat: nil)
await AppOwnedStreamRouter.shared.connect(mediaProvider: mediaProvider)

let callNode = AVAudioPlayerNode()
let callProvider = PlayerNodeCallAudioProvider(playerNode: callNode, outputFormat: nil)
await AppOwnedStreamRouter.shared.connect(callProvider: callProvider)

await AppOwnedStreamRouter.shared.connectMicrophoneToCallBus()
```

This gives a single call per stream type while preserving MultiVol slider-based bus volume control.

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

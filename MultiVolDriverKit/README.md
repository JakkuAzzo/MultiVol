# MultiVol DriverKit Scaffold

This folder is the scaffold for the future MultiVol-owned virtual output device and user client bridge.

## Planned bundle identifiers

- App host: `com.jakkuazzo.multivol.macos`
- Driver extension: `com.jakkuazzo.multivol.macos.driver`
- Default virtual device UID: `com.jakkuazzo.multivol.output.main`

## Intended responsibilities

- Publish a dedicated MultiVol output device through AudioDriverKit.
- Accept session gain snapshots and mix metadata from the host app.
- Expose a stable user client channel so the host app can exchange audio-route control messages with the driver.
- Provide a predictable output route that the macOS app can detect and register through `registerIsolatedOutputDevice(...)`.

## Current scaffold status

The project now includes a real DriverKit target with custom driver, device, stream, and user-client sources. It is not yet wired back into the main macOS app scheme, because the remaining IIG/runtime plumbing still needs to compile cleanly before the app can safely embed the `.dext`.

The target currently provides:

- `MultiVolAudioDriver`, a `IOUserAudioDriver` subclass
- `MultiVolAudioDevice`, a `IOUserAudioDevice` subclass
- `MultiVolAudioStream`, a `IOUserAudioStream` subclass
- `MultiVolAudioUserClient`, a custom `IOUserClient` bridge for future app-to-driver IPC

This is still an implementation scaffold, not a finished audio route. It publishes the extension shape, the AudioDriverKit object model, and the project target we need for activation and future IPC work.

The host app is already prepared to:

- detect an embedded extension with identifier `com.jakkuazzo.multivol.macos.driver`
- request activation through `OSSystemExtensionRequest`
- detect a dedicated MultiVol output device once it exists

## Next implementation slice

1. Replace the current stub audio buffer path with real shared-memory or queue-backed IPC.
2. Wire the host bridge to open `MultiVolAudioUserClient` and send `MultiVolOwnedOutputBridgeMessage` payloads.
3. Decide whether the production route should stay DriverKit-backed or move to Apple’s preferred virtual-device plug-in architecture for purely virtual audio endpoints.
4. Add signing and provisioning profiles for local activation and system approval flows.

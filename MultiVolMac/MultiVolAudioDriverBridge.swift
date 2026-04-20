#if os(macOS)
import Foundation
import SystemExtensions

@MainActor
final class MultiVolAudioDriverBridge: NSObject, ObservableObject {
    enum ActivationState: Equatable {
        case notEmbedded
        case embedded
        case activationRequested
        case awaitingUserApproval
        case activated
        case failed(String)

        var description: String {
            switch self {
            case .notEmbedded:
                return "The MultiVol driver extension is not embedded in this app bundle yet."
            case .embedded:
                return "A MultiVol driver extension bundle is embedded and ready for activation."
            case .activationRequested:
                return "Activation request submitted for the MultiVol driver extension."
            case .awaitingUserApproval:
                return "macOS requires approval before the MultiVol driver extension can finish installing."
            case .activated:
                return "The MultiVol driver extension has been activated."
            case let .failed(message):
                return message
            }
        }
    }

    @Published private(set) var activationState: ActivationState = .notEmbedded

    override init() {
        super.init()
        refreshEmbeddedExtensionStatus()
    }

    func refreshEmbeddedExtensionStatus() {
        activationState = embeddedDriverExtensionURL() == nil ? .notEmbedded : .embedded
    }

    func activateEmbeddedDriver() {
        guard embeddedDriverExtensionURL() != nil else {
            activationState = .notEmbedded
            return
        }

        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: MultiVolOwnedOutputRoute.driverExtensionIdentifier,
            queue: .main
        )
        request.delegate = self
        activationState = .activationRequested
        OSSystemExtensionManager.shared.submitRequest(request)
    }

    func currentBridgeStatus(routeState: MacOSDedicatedOutputRouteState) -> MultiVolOwnedOutputBridgeStatus {
        switch routeState {
        case .unavailable:
            return MultiVolOwnedOutputBridgeStatus(
                phase: embeddedDriverExtensionURL() == nil ? .staged : .driverEmbedded,
                detail: activationState.description
            )
        case let .availableButInactive(route):
            return MultiVolOwnedOutputBridgeStatus(
                phase: .routeAvailable,
                routeUID: route.id,
                detail: "Dedicated route detected but inactive: \(route.name)."
            )
        case let .active(route):
            return MultiVolOwnedOutputBridgeStatus(
                phase: .routeActive,
                routeUID: route.id,
                detail: "Dedicated route active: \(route.name)."
            )
        }
    }

    private func embeddedDriverExtensionURL() -> URL? {
        Bundle.main.builtInPlugInsURL?
            .deletingLastPathComponent()
            .appendingPathComponent("SystemExtensions", isDirectory: true)
            .appendingPathComponent("\(MultiVolOwnedOutputRoute.driverExtensionIdentifier).systemextension", isDirectory: true)
            .standardizedFileURL
            .takeIf { FileManager.default.fileExists(atPath: $0.path) }
    }
}

extension MultiVolAudioDriverBridge: OSSystemExtensionRequestDelegate {
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        activationState = .awaitingUserApproval
    }

    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        activationState = .activated
    }

    func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        activationState = .failed("Driver activation failed: \(error.localizedDescription)")
    }

    func request(
        _ request: OSSystemExtensionRequest,
        actionForReplacingExtension existing: OSSystemExtensionProperties,
        withExtension ext: OSSystemExtensionProperties
    ) -> OSSystemExtensionRequest.ReplacementAction {
        .replace
    }
}

private extension URL {
    func takeIf(_ predicate: (URL) -> Bool) -> URL? {
        predicate(self) ? self : nil
    }
}
#endif

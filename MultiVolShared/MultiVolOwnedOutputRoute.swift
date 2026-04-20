#if os(macOS)
import Foundation

public enum MultiVolOwnedOutputRoute {
    public static let deviceUIDPrefix = "com.jakkuazzo.multivol.output."
    public static let deviceNamePrefix = "MultiVol"
    public static let driverExtensionIdentifier = "com.jakkuazzo.multivol.macos.driver"
    public static let driverTeamEntitlementKey = "com.apple.developer.system-extension.install"
    public static let appGroupIdentifier = "group.com.jakkuazzo.multivol"

    public static func deviceUID(suffix: String = "main") -> String {
        "\(deviceUIDPrefix)\(suffix)"
    }

    public static func defaultDeviceName(suffix: String = "Output") -> String {
        "\(deviceNamePrefix) \(suffix)"
    }

    public static func matchesDevice(uid: String, name: String) -> Bool {
        uid.hasPrefix(deviceUIDPrefix) || name.localizedCaseInsensitiveContains(deviceNamePrefix)
    }
}
#endif

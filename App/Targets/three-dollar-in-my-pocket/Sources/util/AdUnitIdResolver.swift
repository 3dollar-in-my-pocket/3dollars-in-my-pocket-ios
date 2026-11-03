import Foundation

enum AdUnitIdResolver {
    static func resolve(serverAdUnitId: String?, fallback: String, usesServerAdUnitId: Bool) -> String {
        guard usesServerAdUnitId,
              let serverAdUnitId = serverAdUnitId?.trimmingCharacters(in: .whitespacesAndNewlines),
              serverAdUnitId.isEmpty == false else { return fallback }

        return serverAdUnitId
    }
}

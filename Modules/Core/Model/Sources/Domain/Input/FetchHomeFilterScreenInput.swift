import Foundation

public struct FetchHomeFilterScreenInput: Encodable {
    public let preset: String?
    public let tabId: String?

    public init(preset: String? = nil, tabId: String? = nil) {
        self.preset = preset
        self.tabId = tabId
    }
}

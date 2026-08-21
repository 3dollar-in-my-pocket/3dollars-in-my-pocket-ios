import Foundation

public struct FetchHomeFilterScreenInput: Encodable {
    public let preset: String?

    public init(preset: String? = nil) {
        self.preset = preset
    }
}

import Foundation

public struct CursorRequestInput: Encodable {
    public let size: Int
    public let cursor: String?

    public init(size: Int, cursor: String?) {
        self.size = size
        self.cursor = cursor
    }
}

import Foundation

public struct SDBorder: Decodable, Equatable, Hashable {
    public let color: String
    public let width: Double

    public init(color: String, width: Double) {
        self.color = color
        self.width = width
    }
}

public struct SDSurfaceStyle: Decodable, Hashable {
    public let backgroundColor: String
    public let border: SDBorder?

    public init(
        backgroundColor: String,
        border: SDBorder? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.border = border
    }
}

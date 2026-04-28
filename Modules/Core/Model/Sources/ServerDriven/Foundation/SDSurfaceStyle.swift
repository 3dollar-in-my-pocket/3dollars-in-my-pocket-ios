import Foundation

public struct SDSurfaceStyle: Decodable, Hashable {
    public let backgroundColor: String
    public let borderColor: String?
    public let borderWidth: Double?
    public let cornerRadius: Double?

    public init(
        backgroundColor: String,
        borderColor: String? = nil,
        borderWidth: Double? = nil,
        cornerRadius: Double? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
}

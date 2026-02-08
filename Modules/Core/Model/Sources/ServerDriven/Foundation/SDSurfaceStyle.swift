import Foundation

public struct SDSurfaceStyle: Decodable, Hashable {
    public let backgroundColor: String
    public let borderColor: String?
    public let borderWidth: Double?
    public let cornerRadius: Double?
}

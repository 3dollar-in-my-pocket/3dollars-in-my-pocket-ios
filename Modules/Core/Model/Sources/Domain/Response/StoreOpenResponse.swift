import Foundation

public struct StoreOpenResponse: Decodable, Hashable {
    public let status: StoreOpenStatus
    public let openStartDateTime: String?
    public let isOpening: Bool

    public enum StoreOpenStatus: String, Decodable {
        case open = "OPEN"
        case closed = "CLOSED"
        case unknown
        
        public init(from decoder: Decoder) throws {
            self = try StoreOpenStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}

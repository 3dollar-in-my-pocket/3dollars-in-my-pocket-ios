import Foundation

public struct StoreCouponIssuedResponse: Decodable {
    public let issuedKey: String
    public let status: Status
    
    public enum Status: String, Codable {
        case active = "ACTIVE"
        case used = "USED"
        case expired = "EXPIRED"
        case unknown
        
        public init(from decoder: Decoder) throws {
            self = try Status(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }
}

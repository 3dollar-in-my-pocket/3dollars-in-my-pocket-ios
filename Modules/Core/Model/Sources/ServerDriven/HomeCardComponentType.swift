import Foundation

public enum HomeCardComponentType: String, Decodable {
    case homeAdCard = "HOME_AD_CARD"
    case homeAdmob = "HOME_ADMOB_CARD"
    case homeCard = "HOME_CARD"
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try HomeCardComponentType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

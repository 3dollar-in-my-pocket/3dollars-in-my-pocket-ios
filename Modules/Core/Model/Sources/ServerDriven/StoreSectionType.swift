import Foundation

public enum StoreSectionType: String, Decodable {
    case callout = "CALLOUT"
    case preview = "PREVIEW"
    case admob = "AD_MOB"
    case tab = "TAB"
    case edit = "EDIT"
    case coupon = "COUPON"
    case visit = "VISIT"
    case post = "POST"
    case image = "IMAGE"
    case appearanceDay = "APPEARANCE_DAY"
    case infoV1 = "INFO_V1"
    case infoV2 = "INFO_V2"
    case relatedStores = "RELATED_STORES"
    case cta = "CTA"
    case review = "REVIEW"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try StoreSectionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

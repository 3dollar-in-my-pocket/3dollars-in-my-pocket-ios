import Foundation

public struct ContentListStoreDisplayResponse: Decodable {
    public let contents: [StoreDisplayResponse]
}

public struct StoreDisplayResponse: Decodable {
    public let itemType: StoreDisplayItemType
    public let description: String
    public let isVisible: Bool
    public let trigger: StoreDisplayTrigger?
}

public enum StoreDisplayItemType: String, Codable {
    case disappearanceInquiryModal = "DISAPPEARANCE_INQUIRY_MODAL"
    case visitCertificationInducementModal = "VISIT_CERTIFICATION_INDUCEMENT_MODAL"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try StoreDisplayItemType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public struct StoreDisplayTrigger: Decodable {
    public let type: StoreDisplayTriggerType
    public let displayAfterSeconds: Double
    public let displayDurationSeconds: Double?
    public let conditions: StoreDisplayTriggerConditions?
}

public enum StoreDisplayTriggerType: String, Codable {
    case pageEnter = "PAGE_ENTER"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try StoreDisplayTriggerType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public struct StoreDisplayTriggerConditions: Decodable {
    public let sessionViewCountRange: SessionViewCountRange?
}

public struct SessionViewCountRange: Decodable {
    public let min: Int?
    public let max: Int?

    public func contains(_ count: Int) -> Bool {
        if let min, count < min { return false }
        if let max, count > max { return false }
        return true
    }
}

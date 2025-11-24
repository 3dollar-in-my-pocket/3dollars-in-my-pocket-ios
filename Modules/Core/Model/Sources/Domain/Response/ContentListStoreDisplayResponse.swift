import Foundation

public struct ContentListStoreDisplayResponse: Decodable {
    public let contents: [StoreDisplayResponse]
}

public struct StoreDisplayResponse: Decodable {
    public let itemType: StoreDisplayItemType
    public let description: String
    public let isVisible: Bool
}

public enum StoreDisplayItemType: String, Codable {
    case disappearanceInquiryModal = "DISAPPEARANCE_INQUIRY_MODAL"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try StoreDisplayItemType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

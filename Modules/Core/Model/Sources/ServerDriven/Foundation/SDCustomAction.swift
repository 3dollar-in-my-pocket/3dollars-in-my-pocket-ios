import Foundation

public struct SDCustomAction: Decodable, Equatable, Hashable {
    public let actionType: SDCustomActionType
    public let extraParams: [String: SDClickLogValue]

    public init(actionType: SDCustomActionType, extraParams: [String: SDClickLogValue] = [:]) {
        self.actionType = actionType
        self.extraParams = extraParams
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.actionType = try container.decode(SDCustomActionType.self, forKey: .actionType)
        self.extraParams = try container.decodeIfPresent([String: SDClickLogValue].self, forKey: .extraParams) ?? [:]
    }

    private enum CodingKeys: String, CodingKey {
        case actionType
        case extraParams
    }
}

public enum SDCustomActionType: String, Decodable, Equatable, Hashable {
    case storePreviewShare = "STORE_PREVIEW_SECTION_SHARE"
    case storePreviewFavorite = "STORE_PREVIEW_SECTION_FAVORITE"
    case storePreviewUnfavorite = "STORE_PREVIEW_SECTION_UNFAVORITE"
    case storePreviewNavigation = "STORE_PREVIEW_SECTION_NAVIGATION"
    case storePreviewReviewWrite = "STORE_PREVIEW_SECTION_REVIEW_WRITE"
    case storePreviewClose = "STORE_PREVIEW_SECTION_CLOSE"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try SDCustomActionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

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
    case storePreviewNavigation = "STORE_PREVIEW_SECTION_NAVIGATION"
    case storePreviewReviewWrite = "STORE_PREVIEW_SECTION_REVIEW_WRITE"
    case storeEditUpdate = "STORE_EDIT_SECTION_UPDATE"
    case storeEditReport = "STORE_EDIT_SECTION_REPORT"
    case storeCouponIssue = "STORE_COUPON_SECTION_COUPON_ISSUE"
    case storeCouponUse = "STORE_COUPON_SECTION_COUPON_USE"
    case storePostAddLike = "STORE_POST_SECTION_ADD_LIKE"
    case storePostCancelLike = "STORE_POST_SECTION_CANCEL_LIKE"
    case storeImageAddImage = "STORE_IMAGE_SECTION_ADD_IMAGE"
    case storeImageEnlarge = "STORE_IMAGE_SECTION_IMAGE_ENLARGE"
    case storeReviewWrite = "STORE_REVIEW_SECTION_REVIEW_WRITE"
    case storeReviewReport = "STORE_REVIEW_SECTION_REPORT"
    case storeReviewDelete = "STORE_REVIEW_SECTION_DELETE"
    case storeReviewAddLike = "STORE_REVIEW_SECTION_ADD_LIKE"
    case storeReviewCancelLike = "STORE_REVIEW_SECTION_CANCEL_LIKE"
    case storeEditCopyAddress = "STORE_EDIT_SECTION_COPY_ADDRESS"
    case storeEditMapEnlarge = "STORE_EDIT_SECTION_MAP_ENLARGE"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try SDCustomActionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

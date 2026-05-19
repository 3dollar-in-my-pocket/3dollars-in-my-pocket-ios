import Foundation

public struct ParameterName: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension ParameterName {
    static let screen = ParameterName(rawValue: "screen")
    static let objectId = ParameterName(rawValue: "object_id")
    static let objectType = ParameterName(rawValue: "object_type")
    static let type = ParameterName(rawValue: "type")
    static let nickname = ParameterName(rawValue: "nickname")
    static let address = ParameterName(rawValue: "address")
    static let categoryName = ParameterName(rawValue: "category_name")
    static let storeId = ParameterName(rawValue: "store_id")
    static let value = ParameterName(rawValue: "value")
    static let advertisementId = ParameterName(rawValue: "advertisement_id")
    static let categoryId = ParameterName(rawValue: "category_id")
    static let count = ParameterName(rawValue: "count")
    static let reviewId = ParameterName(rawValue: "review_id")
    static let rating = ParameterName(rawValue: "rating")
    static let pollId = ParameterName(rawValue: "poll_id")
    static let optionId = ParameterName(rawValue: "option_id")
    static let title = ParameterName(rawValue: "title")
    static let pollFirstOption = ParameterName(rawValue: "poll_first_option")
    static let pollSecondOption = ParameterName(rawValue: "poll_second_option")
    static let buildingName = ParameterName(rawValue: "building_name")
    static let medalId = ParameterName(rawValue: "medal_id")
    static let storeType = ParameterName(rawValue: "store_type")
    static let experimentType = ParameterName(rawValue: "experiment_type")
    static let experimentKey = ParameterName(rawValue: "experiment_key")
    static let experimentVariant = ParameterName(rawValue: "experiment_variant")
    static let referer = ParameterName(rawValue: "referer")
    static let reasonType = ParameterName(rawValue: "reason_type")
}

import Foundation

public enum HomeBottomTabViewType: String, Decodable {
    case curation = "CURATION"
    case storeList = "STORE_LIST"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeBottomTabViewType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public struct HomeBottomSheetTabSection: HomeScreenSection {
    public let type: HomeScreenSectionType
    public let tabs: [HomeBottomTab]
}

public struct HomeBottomTab: Decodable, Hashable {
    public let tabId: String
    public let viewType: HomeBottomTabViewType
    public let selected: TabState
    public let unselected: TabState
    public let defaultSelected: Bool
    public let clickLog: SDClickLog
}

public struct TabState: Decodable, Hashable {
    public let title: SDText
    public let style: SDSurfaceStyle
}

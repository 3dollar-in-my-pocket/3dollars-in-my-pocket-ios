import Foundation

public struct BottomNavigationResponse: Decodable, Equatable {
    public let tabs: [BottomNavigationItem]
    public let viewLog: SDPageViewLog?

    public init(tabs: [BottomNavigationItem], viewLog: SDPageViewLog? = nil) {
        self.tabs = tabs
        self.viewLog = viewLog
    }
}

public struct BottomNavigationItem: Decodable, Equatable, Hashable {
    public let id: String
    public let label: String
    public let icon: SDImage
    public let selectedTintColor: String
    public let type: BottomNavigationItemType?
    public let link: SDLink?
    public let clickLog: SDClickLog?

    public init(
        id: String,
        label: String,
        icon: SDImage,
        selectedTintColor: String,
        type: BottomNavigationItemType? = nil,
        link: SDLink? = nil,
        clickLog: SDClickLog? = nil
    ) {
        self.id = id
        self.label = label
        self.icon = icon
        self.selectedTintColor = selectedTintColor
        self.type = type
        self.link = link
        self.clickLog = clickLog
    }
}

public enum BottomNavigationItemType: String, Decodable {
    case appDefined = "APP_DEFINED"
    case dynamic = "DYNAMIC"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try BottomNavigationItemType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

import Foundation

public enum HomeScreenSectionType: String, Decodable {
    case homeFilter = "HOME_FILTER"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeScreenSectionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public enum HomeFilterBarType: String, Decodable {
    case categoryBar = "CATEGORY_BAR"
    case radioBar = "RADIO_BAR"
    case actionBar = "ACTION_BAR"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeFilterBarType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public protocol HomeScreenSection: Decodable {
    var type: HomeScreenSectionType { get }
}

public protocol HomeFilterBar: Decodable, Hashable {
    var type: HomeFilterBarType { get }
}

public struct HomeFilterSection: HomeScreenSection {
    public let type: HomeScreenSectionType
    public let bars: [any HomeFilterBar]

    public enum CodingKeys: String, CodingKey {
        case type
        case bars
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(HomeScreenSectionType.self, forKey: .type)

        var barsArray = try container.nestedUnkeyedContainer(forKey: .bars)
        var tempContainer = barsArray
        var bars: [any HomeFilterBar] = []

        while !barsArray.isAtEnd {
            let preview = try barsArray.decode(BarTypePreview.self)
            let barDecoder = try tempContainer.superDecoder()

            switch preview.type {
            case .categoryBar:
                bars.append(try HomeFilterCategoryBar(from: barDecoder))
            case .radioBar:
                bars.append(try HomeFilterRadioBar(from: barDecoder))
            case .actionBar:
                bars.append(try HomeFilterActionBar(from: barDecoder))
            case .unknown:
                continue
            }
        }
        self.bars = bars
    }
}

public struct HomeFilterCategoryBar: HomeFilterBar {
    public let type: HomeFilterBarType
    public let categoriesFilter: SDChip
    public let categoriesFilterClickLog: SDClickLog
    public let currentCategoryFilter: HomeFilterCurrentCategory?
}

public struct HomeFilterCurrentCategory: Decodable, Hashable {
    public let fontColor: String
    public let style: SDSurfaceStyle
    public let clickLog: SDClickLog
}

public struct HomeFilterRadioBar: HomeFilterBar {
    public let type: HomeFilterBarType
    public let paramKey: String
    public let options: [HomeFilterRadioOption]
}

public struct HomeFilterRadioOption: Decodable, Hashable {
    public let chip: SDChip
    public let paramValue: String?
    public let clickLog: SDClickLog?
}

public struct HomeFilterActionBar: HomeFilterBar {
    public let type: HomeFilterBarType
    public let button: SDButton
    public let clickLog: SDClickLog
}

private struct BarTypePreview: Decodable {
    let type: HomeFilterBarType
}

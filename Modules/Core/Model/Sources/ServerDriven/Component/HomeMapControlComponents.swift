import Foundation

public enum HomeMapControlType: String, Decodable {
    case filter = "FILTER"
    case action = "ACTION"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeMapControlType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public protocol HomeMapControl: Decodable {
    var type: HomeMapControlType { get }
}

public struct HomeMapControlSection: HomeScreenSection {
    public let type: HomeScreenSectionType
    public let controls: [any HomeMapControl]

    public enum CodingKeys: String, CodingKey {
        case type
        case controls
    }

    public init(type: HomeScreenSectionType = .homeMapControl, controls: [any HomeMapControl]) {
        self.type = type
        self.controls = controls
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(HomeScreenSectionType.self, forKey: .type)

        var controlsArray = try container.nestedUnkeyedContainer(forKey: .controls)
        var tempContainer = controlsArray
        var controls: [any HomeMapControl] = []

        while !controlsArray.isAtEnd {
            let preview = try controlsArray.decode(ControlTypePreview.self)
            let controlDecoder = try tempContainer.superDecoder()

            switch preview.type {
            case .filter:
                controls.append(try HomeMapStoreFilterControl(from: controlDecoder))
            case .action:
                controls.append(try HomeMapActionControl(from: controlDecoder))
            case .unknown:
                continue
            }
        }
        self.controls = controls
    }
}

public struct HomeMapActionControl: HomeMapControl, Equatable {
    public let type: HomeMapControlType
    public let button: SDButton

    public init(type: HomeMapControlType = .action, button: SDButton) {
        self.type = type
        self.button = button
    }
}

public struct HomeMapStoreFilterControl: HomeMapControl, Equatable {
    public let type: HomeMapControlType
    public let paramKey: String
    public let options: [HomeMapStoreFilterOption]

    public init(type: HomeMapControlType = .filter, paramKey: String, options: [HomeMapStoreFilterOption]) {
        self.type = type
        self.paramKey = paramKey
        self.options = options
    }
}

public struct HomeMapStoreFilterOption: Decodable, Equatable {
    public let button: SDButton
    public let paramValue: Bool

    public init(button: SDButton, paramValue: Bool) {
        self.button = button
        self.paramValue = paramValue
    }
}

private struct ControlTypePreview: Decodable {
    let type: HomeMapControlType
}

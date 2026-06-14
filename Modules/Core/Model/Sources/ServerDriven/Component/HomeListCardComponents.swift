import Foundation

public enum HomeListCardType: String, Decodable {
    case basicCard = "BASIC_CARD"
    case admobCard = "ADMOB_CARD"
    case emptyCard = "EMPTY_CARD"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try HomeListCardType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public protocol HomeListCardComponent: Equatable, Hashable, Decodable {
    var type: HomeListCardType { get }
    var cardId: String { get }
}

public struct HomeListBasicCardResponse: Decodable, Hashable, HomeListCardComponent {
    public let type: HomeListCardType
    public let cardId: String
    public let header: HomeListCardHeader
    public let metadata: HomeListCardMetadata
    public let images: [SDImage]
    public let bodies: [HomeListCardBody]
    public let marker: HomeListCardMarker?
    public let link: SDLink?
    public let style: SDSurfaceStyle
    public let clickLog: SDClickLog
    public let impressionLog: SDImpressionLog
}

public struct HomeListAdmobCardResponse: Decodable, Hashable, HomeListCardComponent {
    public let type: HomeListCardType
    public let cardId: String
    public let clickLog: SDClickLog
    public let impressionLog: SDImpressionLog
}

public struct HomeListEmptyCardResponse: Decodable, Hashable, HomeListCardComponent {
    public let type: HomeListCardType
    public let cardId: String
    public let clickLog: SDClickLog?
    public let impressionLog: SDImpressionLog
}

public struct HomeListCardHeader: Decodable, Hashable, Equatable {
    public let title: SDText?
    public let badge: SDImage?
}

public struct HomeListCardMetadata: Decodable, Hashable, Equatable {
    public let primary: [SDChip]
    public let secondary: [SDChip]
    public let separator: SDImage
}

public struct HomeListCardBody: Decodable, Hashable, Equatable {
    public let text: SDText
    public let style: SDSurfaceStyle
}

public struct HomeListCardMarker: Decodable, Hashable, Equatable {
    public let focused: SDChip
    public let unfocused: SDChip
    public let location: LocationResponse
    public let link: SDLink?
    public let clickLog: SDClickLog
}

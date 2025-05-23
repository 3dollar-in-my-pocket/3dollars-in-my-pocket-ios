import Foundation

public protocol HomeCardComponent: Equatable, Hashable, Decodable {
    var type: SDComponentType { get }
    var sectionId: String { get }
}

public struct HomeAdCardSectionResponse: Decodable, Hashable, HomeCardComponent {
    public let type: SDComponentType
    public let sectionId: String
    public let title: SDText?
    public let subTitle: SDText?
    public let labels: [SDChip]
    public let image: SDImage?
    public let link: SDLink?
}

public struct HomeAdmobCardSectionResponse: Decodable, Hashable, HomeCardComponent {
    public let type: SDComponentType
    public let sectionId: String
}

public struct HomeCardSectionResponse: Decodable, Hashable, HomeCardComponent {
    public let type: SDComponentType
    public let sectionId: String
    public let title: SDText?
    public let subTitle: SDText?
    public let image: SDImage?
    public let labels: [SDChip]
    public let metadata: [SDChip]
    public let badge: SDImage?
    public let button: SDButton?
    public let link: SDLink?
    public let marker: HomeCardSectionMarkerResponse?
}

public struct HomeCardSectionMarkerResponse: Decodable, Hashable, Equatable {
    public let location: LocationResponse
    public let focusedImage: SDImage
    public let unfocusedImage: SDImage
}

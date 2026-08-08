import Foundation

public struct StoreMapSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let location: StoreMapLocation
    public let footerLeft: SDActionBar?
    public let footerRight: SDActionBar
}

public struct StoreMapLocation: Decodable, Equatable, Hashable {
    public let latitude: Double
    public let longitude: Double
}

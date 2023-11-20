import Foundation

public struct SearchAddressSection: Hashable {
    public var items: [SearchAddressSectionItem]
    
    public init(items: [SearchAddressSectionItem]) {
        self.items = items
    }
}

public enum SearchAddressSectionItem: Hashable {
    case address(PlaceDocument)
}

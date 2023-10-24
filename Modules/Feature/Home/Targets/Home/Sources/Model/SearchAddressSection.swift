import Foundation

import Model

struct SearchAddressSection: Hashable {
    var items: [SearchAddressSectionItem]
}

enum SearchAddressSectionItem: Hashable {
    case address(PlaceDocument)
}

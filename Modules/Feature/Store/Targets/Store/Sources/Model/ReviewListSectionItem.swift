import Foundation

import Model

enum ReviewListSectionItem: Hashable {
    case review(StoreDetailReview)
    case filtered(StoreDetailReview)
}

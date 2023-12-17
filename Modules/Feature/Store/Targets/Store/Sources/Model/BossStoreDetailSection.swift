import Foundation

struct BossStoreDetailSection: Hashable {
    enum SectionType: Hashable {
        case overview
        case info
        case workday
        case feedbacks
    }

    var type: SectionType
    var items: [BossStoreDetailSectionItem]
}

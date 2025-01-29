import Foundation

struct BossStoreDetailSection: Hashable {
    enum SectionType: Hashable {
        case overview
        case info
        case workday
        case feedbacks
        case post
        case review
    }

    var type: SectionType
    var header: StoreDetailSectionHeader?
    var items: [BossStoreDetailSectionItem]
    
    init(type: SectionType, header: StoreDetailSectionHeader? = nil, items: [BossStoreDetailSectionItem]) {
        self.type = type
        self.header = header
        self.items = items
    }
}

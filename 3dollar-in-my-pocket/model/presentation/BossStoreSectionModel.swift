import RxDataSources

struct BossStoreSectionModel: Equatable {
    var items: [Item]
}

extension BossStoreSectionModel: SectionModelType {
    typealias Item = SectionItemType
    
    enum SectionItemType: Equatable {
        case overview(BossStore)
        case info(
            contacts: String?,
            snsUrl: String?,
            introduction: String?,
            imageUrl: String?
        )
        case menu(BossStoreMenu)
        case appearanceDay([BossStoreAppearanceDay])
    }
    
    init(original: BossStoreSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(store: BossStore) {
        self.items = [.overview(store)]
    }
    
    init(
        contacts: String?,
        snsUrl: String?,
        introduction: String?,
        imageUrl: String?
    ) {
        self.items = [
            .info(
                contacts: contacts,
                snsUrl: snsUrl,
                introduction: introduction,
                imageUrl: imageUrl
            )
        ]
    }
    
    init(menus: [BossStoreMenu]) {
        self.items = menus.map { SectionItemType.menu($0) }
    }
    
    init(appearanceDays: [BossStoreAppearanceDay]) {
        self.items = [SectionItemType.appearanceDay(appearanceDays)]
    }
}

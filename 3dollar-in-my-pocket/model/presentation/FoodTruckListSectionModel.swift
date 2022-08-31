import RxDataSources

struct FoodTruckListSectionModel: Equatable {
    var items: [Item]
}

extension FoodTruckListSectionModel: SectionModelType {
    typealias Item = SectionItemType
    
    enum SectionItemType: Equatable {
        case map([BossStore])
        case empty
        case store(BossStore)
        case advertisement(Advertisement)
    }
    
    init(original: FoodTruckListSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(stores: [BossStore]) {
        self.items = [.map(stores)]
    }
    
    init(stores: [BossStore], advertisement: Advertisement?) {
        if stores.isEmpty {
            self.items = [.empty]
        } else {
            let storeSection = stores.map { SectionItemType.store($0) }
            
            if let advertisement = advertisement {
                let advertisementSection = SectionItemType.advertisement(advertisement)
                
                self.items = [advertisementSection] + storeSection
            } else {
                self.items = storeSection
            }
        }
    }
}

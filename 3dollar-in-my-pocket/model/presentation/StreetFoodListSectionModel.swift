import RxDataSources

struct StreetFoodListSectionModel: Equatable {
    var items: [Item]
}

extension StreetFoodListSectionModel: SectionModelType {
    typealias Item = SectionItemType
    
    enum SectionItemType: Equatable {
        case map([Store])
        case empty
        case store(Store)
        case advertisement(Advertisement)
    }
    
    init(original: StreetFoodListSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(stores: [Store]) {
        self.items = [.map(stores)]
    }
    
    init(stores: [Store], advertisement: Advertisement?) {
        if stores.isEmpty {
            self.items = [.empty]
        } else {
            let storeSection = stores.map { SectionItemType.store($0) }
            if let advertisement = advertisement {
                let advertisementSection = SectionItemType.advertisement(advertisement)
                
                self.items = storeSection + [advertisementSection]
            } else {
                self.items = storeSection
            }
        }
    }
}

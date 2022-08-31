import RxDataSources

struct CategoryFilterSectionModel {
    var items: [Item]
}

extension CategoryFilterSectionModel: SectionModelType {
    typealias Item = SectionItemType
    
    enum SectionItemType {
        case category(Categorizable)
        
    }
    
    init(original: CategoryFilterSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    init(categories: [Categorizable]) {
        self.items = categories.map { SectionItemType.category($0) }
    }
}

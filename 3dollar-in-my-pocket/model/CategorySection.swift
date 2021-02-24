import RxDataSources

struct CategorySection {
  
  var category: StoreCategory
  var headerType: CategoryHeaderType?
  var stores: [StoreCard] = []
  var items: [StoreCard?]
}

extension CategorySection: SectionModelType {
  
  typealias Item = StoreCard?
  
  init(original: CategorySection, items: [StoreCard?]) {
    self = original
    self.items = items
  }
}

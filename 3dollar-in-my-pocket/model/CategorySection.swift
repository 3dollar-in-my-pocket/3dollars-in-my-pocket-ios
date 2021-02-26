import RxDataSources

struct CategorySection {
  
  var headerType: CategoryHeaderType?
  var items: [StoreCard?]
}

extension CategorySection: SectionModelType {
  
  typealias Item = StoreCard?
  
  init(original: CategorySection, items: [StoreCard?]) {
    self = original
    self.items = items
  }
}

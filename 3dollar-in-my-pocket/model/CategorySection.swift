import RxDataSources

struct CategorySection {
  
  var category: StoreCategory
  var location: (Double, Double)
  var items: [StoreCard?]
}

extension CategorySection: SectionModelType {
  
  typealias Item = StoreCard?
  
  init(original: CategorySection, items: [StoreCard?]) {
    self = original
    self.items = items
  }
}

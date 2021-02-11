import RxDataSources

struct StoreSection {
  
  var store: Store
  var items: [Review?]
}

extension StoreSection: SectionModelType {
  
  typealias Item = Review?
  
  init(original: StoreSection, items: [Review?]) {
    self = original
    self.items = items
  }
}

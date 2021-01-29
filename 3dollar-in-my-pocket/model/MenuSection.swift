import RxDataSources

struct MenuSection {
  
  var category: StoreCategory?
  var items: [Menu]
}

extension MenuSection: SectionModelType {
  
  typealias Item = Menu
  
  init(original: MenuSection, items: [Menu]) {
    self = original
    self.items = items
  }
}

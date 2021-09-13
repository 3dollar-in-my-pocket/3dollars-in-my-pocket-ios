import RxDataSources

struct MenuSection {
  
  var category: StoreCategory
  var items: [Menu]
  
  func toMenu() -> [Menu] {
    var menus: [Menu] = []
    for item in items {
      if (item.name != nil && item.price != nil) {
        menus.append(Menu(category: self.category, name: item.name, price: item.price))
      }
    }
    
    return menus
  }
}

extension MenuSection: SectionModelType {
  
  typealias Item = Menu
  
  init(original: MenuSection, items: [Menu]) {
    self = original
    self.items = items
  }
}

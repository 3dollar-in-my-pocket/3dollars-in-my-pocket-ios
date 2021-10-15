struct MenuRequest: Requestable {
  
  let category: StoreCategory
  let name: String
  let price: String
  
  var params: [String: Any] {
    return [
      "category": self.category.getValue(),
      "name": self.name,
      "price": self.price
    ]
  }
  
  
  init(
    category: StoreCategory,
    name: String = "",
    price: String = ""
  ) {
    self.category = category
    self.name = name
    self.price = price
  }
  
  init(menu: Menu) {
    self.category = menu.category ?? .BUNGEOPPANG
    self.name = menu.name ?? ""
    self.price = menu.price ?? ""
  }
}

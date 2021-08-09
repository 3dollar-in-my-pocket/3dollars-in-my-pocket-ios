struct Menu: Codable {
  
  let category: StoreCategory
  let menuId: Int
  var name: String
  var price: String
  
  init(
    category: StoreCategory,
    name: String = "",
    price: String = ""
  ) {
    self.category = category
    self.menuId = 0
    self.name = name
    self.price = price
  }
}

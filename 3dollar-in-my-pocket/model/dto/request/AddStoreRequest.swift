struct AddStoreRequest: Requestable {
  
  let appearanceDays: [WeekDay]
  let latitude: Double
  let longitude: Double
  let menus: [MenuRequest]
  let paymentMethods: [PaymentType]
  let storeName: String
  let storeType: StoreType?
  
  var params: [String: Any] {
    return [
      "appearanceDays": self.appearanceDays.map { $0.rawValue },
      "latitude": self.latitude,
      "longitude": self.longitude,
      "menus": self.menus.map { $0.params },
      "paymentMethods": self.paymentMethods.map { $0.rawValue },
      "storeName": self.storeName,
      "storeType": self.storeType?.rawValue as Any
    ]
  }
  
  init(store: Store) {
    self.appearanceDays = store.appearanceDays
    self.latitude = store.latitude
    self.longitude = store.longitude
    self.menus = store.menus.map(MenuRequest.init)
    self.paymentMethods = store.paymentMethods
    self.storeName = store.storeName
    self.storeType = store.storeType
  }
}

struct AddVisitHistoryRequest: Requestable {
  
  let storeId: Int
  let type: VisitType
  
  var params: [String : Any] {
    return [
      "storeId": self.storeId,
      "type": self.type.rawValue
    ]
  }
}

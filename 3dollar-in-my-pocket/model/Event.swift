struct Event {
    var id: Int!
    var imageUrl: String!
    var url: String!
    
    init(map: [String: Any]) {
        self.id = map["id"] as! Int
        self.imageUrl = map["image"] as! String
        self.url = map["url"] as! String
    }
}

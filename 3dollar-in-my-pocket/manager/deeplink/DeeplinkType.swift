enum DeeplinkType: String {
    case bookmark = "/bookmark"
    
    var path: String {
        self.rawValue
    }
}

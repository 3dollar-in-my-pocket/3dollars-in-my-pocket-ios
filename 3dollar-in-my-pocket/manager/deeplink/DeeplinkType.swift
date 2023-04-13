enum DeeplinkType: String {
    case bookmark
    case store
    
    var path: String {
        self.rawValue
    }
}

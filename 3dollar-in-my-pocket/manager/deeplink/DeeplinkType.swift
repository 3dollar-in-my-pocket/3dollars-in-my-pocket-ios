enum DeeplinkType: String {
    case bookmark
    case store
    case home
    
    var path: String {
        self.rawValue
    }
}

enum DeeplinkType: String {
    case bookmark
    case store
    case home
    case medal
    
    var path: String {
        self.rawValue
    }
}

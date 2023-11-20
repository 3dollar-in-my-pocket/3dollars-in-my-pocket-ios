enum BookmarkListSection: Int {
    case overview
    case bookmarkStores
    case unknown
    
    init(sectionIndex: Int) {
        switch sectionIndex {
        case 0:
            self = .overview
            
        case 1:
            self = .bookmarkStores
            
        default:
            self = .unknown
        }
    }
}

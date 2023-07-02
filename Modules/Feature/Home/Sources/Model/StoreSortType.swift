enum StoreSortType: String {
    case distanceAsc = "DISTANCE_ASC"
    case latest = "LATEST"
    case unknown
    
    init(value: String) {
        self = StoreSortType(rawValue: value) ?? .unknown
    }
}

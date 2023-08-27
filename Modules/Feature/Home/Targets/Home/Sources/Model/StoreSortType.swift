enum StoreSortType: String {
    case distanceAsc = "DISTANCE_ASC"
    case latest = "LATEST"
    case unknown
    
    init(value: String) {
        self = StoreSortType(rawValue: value) ?? .unknown
    }
    
    func toggled() -> StoreSortType {
        switch self {
        case .distanceAsc:
            return .latest
        case .latest:
            return .distanceAsc
        case .unknown:
            return .distanceAsc
        }
    }
}

public enum StoreSortType: String {
    case distanceAsc = "DISTANCE_ASC"
    case latest = "LATEST"
    case unknown
    
    public init(value: String) {
        self = StoreSortType(rawValue: value) ?? .unknown
    }
    
    public func toggled() -> StoreSortType {
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

public enum StoreSortType: String, Encodable {
    /// 거리순
    case distanceAsc = "DISTANCE_ASC"
    
    /// 최신순
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

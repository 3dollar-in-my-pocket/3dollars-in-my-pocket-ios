public enum PollListSortType: String {
    case latest = "LATEST"
    case popular = "POPULAR"
    case unknown

    public init(value: String) {
        self = PollListSortType(rawValue: value) ?? .unknown
    }
}

public extension PollListSortType {
    var title: String? {
        switch self {
        case .latest: "최신순"
        case .popular: "실시간 참여순"
        default: nil
        }
    }
    
    static var list: [PollListSortType] {
        return [.popular, .latest]
    }
}

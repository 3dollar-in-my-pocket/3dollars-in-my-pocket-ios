public enum PollListSortType: String {
    case latest = "LATEST"
    case popular = "POPULAR"
    case unknown

    public init(value: String) {
        self = PollListSortType(rawValue: value) ?? .unknown
    }
}

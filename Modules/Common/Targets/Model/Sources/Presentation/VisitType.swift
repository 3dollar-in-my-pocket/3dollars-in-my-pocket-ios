public enum VisitType: String, Hashable {
    case exists = "EXISTS"
    case notExists = "NOT_EXISTS"
    
    public init(value: String) {
        self = VisitType(rawValue: value) ?? .exists
    }
}


public enum VisitType: String, Hashable, Codable {
    case exists = "EXISTS"
    case notExists = "NOT_EXISTS"
    case unknown
    
    public init(value: String) {
        self = VisitType(rawValue: value) ?? .exists
    }
    
    public init(from decoder: Decoder) throws {
        self = try VisitType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}


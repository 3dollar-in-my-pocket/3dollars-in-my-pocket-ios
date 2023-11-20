enum OpenStatusResponse: String, Decodable {
    case closed  = "CLOSED"
    case open = "OPEN"
    
    init(from decoder: Decoder) throws {
        let rawValud = try decoder.singleValueContainer().decode(RawValue.self)
        
        self = OpenStatusResponse(rawValue: rawValud) ?? .closed
    }
}

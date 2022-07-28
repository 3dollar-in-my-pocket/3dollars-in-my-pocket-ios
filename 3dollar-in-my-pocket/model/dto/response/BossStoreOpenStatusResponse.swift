struct BossStoreOpenStatusResponse: Decodable {
    let openStartDateTime: String?
    let status: OpenStatusResponse
    
    enum CodingKeys: String, CodingKey {
        case openStartDateTime
        case status
    }
    
    init(
        openStartDateTime: String = "",
        status: OpenStatusResponse = .closed
    ) {
        self.openStartDateTime = openStartDateTime
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.openStartDateTime = try values.decodeIfPresent(
            String.self,
            forKey: .openStartDateTime
        )
        self.status = try values.decodeIfPresent(
            OpenStatusResponse.self,
            forKey: .status
        ) ?? .closed
    }
}

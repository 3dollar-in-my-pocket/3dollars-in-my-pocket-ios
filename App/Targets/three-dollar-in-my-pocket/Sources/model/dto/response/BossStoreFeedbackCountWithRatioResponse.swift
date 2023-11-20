struct BossStoreFeedbackCountWithRatioResponse: Decodable {
    let count: Int
    let feedbackType: String
    let ratio: Double
    
    enum CodingKeys: String, CodingKey {
        case count
        case feedbackType
        case ratio
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.count = try values.decodeIfPresent(Int.self, forKey: .count) ?? 0
        self.feedbackType = try values.decodeIfPresent(
            String.self,
            forKey: .feedbackType
        ) ?? ""
        self.ratio = try values.decodeIfPresent(Double.self, forKey: .ratio) ?? 0
    }
}

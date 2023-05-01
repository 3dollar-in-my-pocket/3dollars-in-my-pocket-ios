struct BossStoreFeedbackTypeResponse: Decodable {
    let description: String
    let emoji: String
    let feedbackType: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case emoji
        case feedbackType
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.description = try values.decodeIfPresent(
            String.self,
            forKey: .description
        ) ?? ""
        self.emoji = try values.decodeIfPresent(
            String.self,
            forKey: .emoji
        ) ?? ""
        self.feedbackType = try values.decodeIfPresent(
            String.self,
            forKey: .feedbackType
        ) ?? ""
    }
}

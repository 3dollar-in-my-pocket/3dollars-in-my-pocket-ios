struct BossStoreWithFeedbacksResponse: Decodable {
    let feedbacks: [BossStoreFeedbackCountWithRatioResponse]
    let store: BossStoreInfoResponse
    
    enum CodingKeys: String, CodingKey {
        case feedbacks
        case store
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.feedbacks = try values.decodeIfPresent(
            [BossStoreFeedbackCountWithRatioResponse].self,
            forKey: .feedbacks
        ) ?? []
        self.store = try values.decodeIfPresent(
            BossStoreInfoResponse.self,
            forKey: .store
        ) ?? BossStoreInfoResponse()
    }
}

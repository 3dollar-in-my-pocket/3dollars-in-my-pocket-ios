struct BossStoreFeedbackMeta {
    let description: String
    let emoji: String
    let feedbackType: BossStoreFeedbackType
    
    init(response: BossStoreFeedbackTypeResponse) {
        self.description = response.description
        self.emoji = response.emoji
        self.feedbackType = BossStoreFeedbackType(rawValue: response.feedbackType) ?? .bossIsKind
    }
}

struct BossStoreFeedbackMeta: Equatable {
    let description: String
    let emoji: String
    let feedbackType: BossStoreFeedbackType
    
    init(response: BossStoreFeedbackTypeResponse) {
        self.description = response.description
        self.emoji = response.emoji
        self.feedbackType
        = BossStoreFeedbackType(rawValue: response.feedbackType) ?? .bossIsKind
    }
    
    init(feedbackType: BossStoreFeedbackType) {
        self = MetaContext.shared.feedbackTypes
            .first(where: { $0.feedbackType == feedbackType }) ?? BossStoreFeedbackMeta()
    }
    
    init() {
        self.description = ""
        self.emoji = ""
        self.feedbackType = .bossIsKind
    }
}

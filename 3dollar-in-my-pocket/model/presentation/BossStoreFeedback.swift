struct BossStoreFeedback: Equatable {
    let count: Int
    let type: BossStoreFeedbackMeta
    let ratio: Double
    
    init(response: BossStoreFeedbackCountWithRatioResponse) {
        self.count = response.count
        self.ratio = response.ratio
        
        let type = BossStoreFeedbackType(rawValue: response.feedbackType) ?? .bossIsKind
        
        self.type = BossStoreFeedbackMeta(feedbackType: type)
    }
}

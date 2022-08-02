struct BossStoreFeedback: Equatable {
    let count: Int
    let type: BossStoreFeedbackType
    let ratio: Double
    
    init(response: BossStoreFeedbackCountWithRatioResponse) {
        self.count = response.count
        self.type = BossStoreFeedbackType(rawValue: response.feedbackType) ?? .bossIsKind
        self.ratio = response.ratio
    }
}

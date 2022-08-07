final class MetaContext {
    static let shared = MetaContext()
    
    /// 모든 메달정보를 저장해둡니다.
    var medals: [Medal] = []
    
    /// 푸드트럭 피드백 타입을 저장해둡니다.
    var feedbackTypes: [BossStoreFeedbackMeta] = []
}

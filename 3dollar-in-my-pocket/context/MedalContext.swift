final class MedalContext {
    static let shared = MedalContext()
    
    /// 모든 메달정보를 저장해둡니다.
    var medals: [Medal] = []
}

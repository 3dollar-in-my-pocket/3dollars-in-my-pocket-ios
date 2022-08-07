import Foundation

import RxSwift

final class GlobalState {
    static let shared = GlobalState()
    
    /// 가게 업데이트하는 경우
    let updateStore = PublishSubject<StoreProtocol>()
    
    /// 푸드트럭 피드백 추가한 경우
    let updateFeedbacks = PublishSubject<[BossStoreFeedback]>()
}

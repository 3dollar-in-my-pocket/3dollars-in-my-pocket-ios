import Foundation

import RxSwift

final class GlobalState {
    static let shared = GlobalState()
    
    /// 가게 업데이트하는 경우
    let updateStore = PublishSubject<StoreProtocol>()
    
    /// 푸드트럭 피드백 추가한 경우
    let updateFeedbacks = PublishSubject<[BossStoreFeedback]>()
    
    /// 카테고리 필터 선택한 경우
    let updateCategoryFilter = PublishSubject<Categorizable>()
    
    /// 사진 제보 완료된 경우
    let addStorePhotos = PublishSubject<[Image]>()
}

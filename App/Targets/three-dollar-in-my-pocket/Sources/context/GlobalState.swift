import Foundation

import RxSwift

final class GlobalState {
    static let shared = GlobalState()
    
    /// 푸드트럭 피드백 추가한 경우
    let updateFeedbacks = PublishSubject<[BossStoreFeedback]>()
    
    /// 즐겨찾기 추가한 경우
    let addBookmarkStore = PublishSubject<StoreProtocol>()
    
    /// 즐겨찾기 해제한 경우
    let deleteBookmarkStore = PublishSubject<[String]>()
    
    /// 즐겨찾기 제목, 설명을 수정한 경우
    let updateBookmarkFolder = PublishSubject<BookmarkFolder>()
    
    /// 닉네임 변경된 경우
    let updateNickname = PublishSubject<String>()
    
    /// 칭호 변경한 경우
    let updateMedal = PublishSubject<Medal>()
}

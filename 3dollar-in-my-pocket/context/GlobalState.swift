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
    
    /// 사진을 삭제한 경우: Image.imageId 를 전달
    let deletedPhoto = PublishSubject<Int>()
    
    /// 길거리 음식점 리뷰를 남긴 경우
    let addStoreReview = PublishSubject<Review>()
    
    /// 가게 제보를 완료한 경우
    let addStore = PublishSubject<Store>()
    
    /// 즐겨찾기 추가한 경우
    let addBookmarkStore = PublishSubject<StoreProtocol>()
    
    /// 즐겨찾기 해제한 경우
    let deleteBookmarkStore = PublishSubject<[String]>()
    
    /// 즐겨찾기 제목, 설명을 수정한 경우
    let updateBookmarkFolder = PublishSubject<BookmarkFolder>()
}

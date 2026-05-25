import UIKit
import Combine

import Model

public struct UploadPhotoConfig {
    public let storeId: Int
    public let shouldDeferUpload: Bool
    public let onSelectedPhotos: ((([Data]) -> Void))?

    public init(
        storeId: Int,
        shouldDeferUpload: Bool = false,
        onSelectedPhotos: (([Data]) -> Void)? = nil
    ) {
        self.storeId = storeId
        self.shouldDeferUpload = shouldDeferUpload
        self.onSelectedPhotos = onSelectedPhotos
    }
}

public protocol StoreInterface {
    func getStoreDetailViewController(storeId: Int) -> UIViewController

    func getBossStoreDetailViewController(
        storeId: String,
        shouldPushReviewList: Bool
    ) -> UIViewController

    func getVisitViewController(storeId: Int, onSuccessVisit: @escaping (() -> Void)) -> UIViewController

    /// 가게 상세화면의 "리뷰쓰기"와 동일한 리뷰 작성 바텀시트(PanModal). 작성 성공 시 `onSuccessWriteReview` 가 호출된다.
    func getReviewBottomSheetViewController(
        storeId: Int,
        onSuccessWriteReview: @escaping (() -> Void)
    ) -> UIViewController

    func getMapDetailViewController(location: LocationResponse, storeName: String) -> UIViewController

    func getCouponListViewController(onReload: @escaping (() -> Void)) -> UIViewController

    func getUploadPhotoViewController(config: UploadPhotoConfig) -> UIViewController
}

import UIKit
import Combine

import Model

public struct UploadPhotoConfig {
    public let storeId: Int
    public let shouldDeferUpload: Bool
    public let onSelectedPhotos: ((([Data]) -> Void))?
    /// 가게 사진 업로드가 서버에 정상 반영되어 완료되었을 때 호출된다. (shouldDeferUpload == false 인 직접 업로드 경로)
    public let onSuccessUpload: (() -> Void)?

    public init(
        storeId: Int,
        shouldDeferUpload: Bool = false,
        onSelectedPhotos: (([Data]) -> Void)? = nil,
        onSuccessUpload: (() -> Void)? = nil
    ) {
        self.storeId = storeId
        self.shouldDeferUpload = shouldDeferUpload
        self.onSelectedPhotos = onSelectedPhotos
        self.onSuccessUpload = onSuccessUpload
    }
}

/// 가게 상세 섹션 화면. 딥링크 fragment(#info 등)로 특정 섹션 스크롤 요청을 받을 수 있다.
public protocol StoreSectionScrollable: AnyObject {
    var scrollableStoreId: Int { get }
    func scrollToSection(fragment: String)
}

public protocol StoreDetailSectionsLoadable: AnyObject {
    func loadSectionsIfNeeded()
}

public protocol StoreInterface {
    /// 딥링크·공유 링크 등 지도 컨텍스트가 없는 진입점용 V2 전체 화면 가게 상세다.
    func getStoreDetailFullScreenViewController(storeId: Int) -> UIViewController

    /// Home 바텀시트가 Store 모듈의 v2 SDUI 상세를 자식 화면으로 임베드할 때 사용한다.
    func getStoreDetailSectionsViewController(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        placeholderPreview: StoreScreenPreviewSection?,
        onScrollOffsetChanged: @escaping (CGFloat) -> Void,
        onSectionsLoaded: @escaping () -> Void
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

    func getPhotoListViewController(storeId: Int) -> UIViewController

    /// Home 등 Store 모듈 밖의 화면에서 가게 활동 유도 모달을 레거시 상세와 같은 시점에 표시한다.
    func presentStoreDisplayItemModal(
        from viewController: UIViewController,
        storeId: Int,
        itemType: StoreDisplayItemType,
        trigger: StoreDisplayTrigger?,
        onDisplayed: @escaping () -> Void
    )
}

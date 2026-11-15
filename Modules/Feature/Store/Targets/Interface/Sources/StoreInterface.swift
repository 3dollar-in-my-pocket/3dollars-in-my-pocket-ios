import UIKit
import Combine

import Model

public struct UploadPhotoConfig {
    public let storeId: Int
    public let shouldDeferUpload: Bool
    public let onSelectedPhotos: ((([Data]) -> Void))?
    public let limitOfPhoto: Int?
    /// 가게 사진 업로드가 서버에 정상 반영되어 완료되었을 때 호출된다. (shouldDeferUpload == false 인 직접 업로드 경로)
    public let onSuccessUpload: (() -> Void)?

    public init(
        storeId: Int,
        shouldDeferUpload: Bool = false,
        onSelectedPhotos: (([Data]) -> Void)? = nil,
        onSuccessUpload: (() -> Void)? = nil,
        limitOfPhoto: Int? = nil
    ) {
        self.storeId = storeId
        self.shouldDeferUpload = shouldDeferUpload
        self.onSelectedPhotos = onSelectedPhotos
        self.onSuccessUpload = onSuccessUpload
        self.limitOfPhoto = limitOfPhoto
    }
}

/// 가게 상세 섹션 화면. 딥링크 fragment(#info 등)로 특정 섹션 스크롤 요청을 받을 수 있다.
public protocol StoreSectionScrollable: AnyObject {
    var scrollableStoreId: Int { get }
    func scrollToSection(fragment: String)
}

public protocol StoreDetailSectionsLoadable: AnyObject {
    var sectionsScrollView: UIScrollView { get }
    var onRequestClose: (() -> Void)? { get set }
    func loadSectionsIfNeeded()
    func reloadSections()
    func updatePlaceholderPreview(_ preview: StoreScreenPreviewSection)
    func markSectionsDisplayed()
}

/// 가게 미리보기 시트가 공용 섹션 뷰에서 받는 사용자 이벤트.
public enum StorePreviewSectionsEvent {
    case tapActionBar(index: Int)
    case tapImage(index: Int)
    case tapAddPhoto
    case tapBody
    case tapSave
    case tapClose
    case clickAd(SDClickLog?)
    case impression(SDImpressionLog?)
}

/// 가게 상세와 같은 섹션 셀을 등록한 공용 컬렉션뷰. 미리보기 시트는 이 뷰를 미리보기 스타일로 사용한다.
public protocol StorePreviewSectionsViewProtocol: AnyObject where Self: UIView {
    var onEvent: ((StorePreviewSectionsEvent) -> Void)? { get set }
    /// 셀 실측 후 컨텐츠 높이가 바뀔 때 호출된다. 시트 tip 높이 계산에 사용한다.
    var onContentHeightChanged: ((CGFloat) -> Void)? { get set }
    var isPeekingNextSection: Bool { get }
    func apply(_ sections: [any StoreSectionComponent])
    func setFavorited(_ isFavorited: Bool)
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

    /// 미리보기 시트가 가게 상세와 같은 섹션 셀로 서버 섹션을 렌더링할 때 사용한다.
    func createStorePreviewSectionsView(rootViewController: UIViewController) -> any StorePreviewSectionsViewProtocol

    func getContributorsViewController(storeId: Int) -> UIViewController

    func getVisitViewController(storeId: Int, onSuccessVisit: @escaping (() -> Void)) -> UIViewController

    /// 가게 상세화면의 "리뷰쓰기"와 동일한 리뷰 작성 바텀시트(PanModal). 작성 성공 시 `onSuccessWriteReview` 가 호출된다.
    func getReviewBottomSheetViewController(
        storeId: Int,
        storeName: String?,
        onSuccessWriteReview: @escaping (() -> Void)
    ) -> UIViewController

    func getMapDetailViewController(location: LocationResponse, storeName: String) -> UIViewController

    func getCouponListViewController(onReload: @escaping (() -> Void)) -> UIViewController

    func getUploadPhotoViewController(config: UploadPhotoConfig) -> UIViewController

    func getPhotoListViewController(storeId: Int) -> UIViewController

    func getPhotoViewerViewController(imageUrls: [String], selectedIndex: Int) -> UIViewController

    /// Home 등 Store 모듈 밖의 화면에서 가게 활동 유도 모달을 레거시 상세와 같은 시점에 표시한다.
    @discardableResult
    func presentStoreDisplayItemModal(
        from viewController: UIViewController,
        storeId: Int,
        itemType: StoreDisplayItemType,
        trigger: StoreDisplayTrigger?,
        onDisplayed: @escaping () -> Void
    ) -> UIView?
}

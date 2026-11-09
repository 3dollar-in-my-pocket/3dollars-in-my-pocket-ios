import Foundation
import UIKit

import Model
import StoreInterface
import DependencyInjection

public final class MockStoreModuleInterfaceImpl: StoreInterface {
    public func getStoreDetailFullScreenViewController(storeId: Int) -> UIViewController {
        EmptyViewController()
    }

    public func getContributorsViewController(storeId: Int) -> UIViewController {
        EmptyViewController()
    }

    public func getStoreDetailSectionsViewController(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        placeholderPreview: StoreScreenPreviewSection?,
        onScrollOffsetChanged: @escaping (CGFloat) -> Void,
        onSectionsLoaded: @escaping () -> Void
    ) -> UIViewController {
        EmptyViewController()
    }

    public func createStorePreviewSectionsView(
        rootViewController: UIViewController
    ) -> any StorePreviewSectionsViewProtocol {
        MockStorePreviewSectionsView()
    }

    public func getVisitViewController(storeId: Int, onSuccessVisit: @escaping () -> Void) -> UIViewController {
        EmptyViewController()
    }

    public func getReviewBottomSheetViewController(
        storeId: Int,
        storeName: String?,
        onSuccessWriteReview: @escaping () -> Void
    ) -> UIViewController {
        EmptyViewController()
    }

    public func getMapDetailViewController(location: LocationResponse, storeName: String) -> UIViewController {
        return EmptyViewController()
    }

    public func getCouponListViewController(onReload: @escaping () -> Void) -> UIViewController {
        EmptyViewController()
    }

    public func getUploadPhotoViewController(config: UploadPhotoConfig) -> UIViewController {
        EmptyViewController()
    }

    public func getPhotoListViewController(storeId: Int) -> UIViewController {
        return UIViewController()
    }

    public func getPhotoViewerViewController(imageUrls: [String], selectedIndex: Int) -> UIViewController {
        return UIViewController()
    }

    public func presentStoreDisplayItemModal(
        from viewController: UIViewController,
        storeId: Int,
        itemType: StoreDisplayItemType,
        trigger: StoreDisplayTrigger?,
        onDisplayed: @escaping () -> Void
    ) -> UIView? {
        return nil
    }
}

extension MockStoreModuleInterfaceImpl {
    public static func registerModuleInterface() {
        DIContainer.shared.container.register(StoreInterface.self) { _ in
            return MockStoreModuleInterfaceImpl()
        }
    }
}

private final class MockStorePreviewSectionsView: UIView, StorePreviewSectionsViewProtocol {
    var onEvent: ((StorePreviewSectionsEvent) -> Void)?
    var onContentHeightChanged: ((CGFloat) -> Void)?
    func apply(_ sections: [any StoreSectionComponent]) { }
    func setFavorited(_ isFavorited: Bool) { }
}

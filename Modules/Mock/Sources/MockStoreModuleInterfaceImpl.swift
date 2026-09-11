import Foundation
import UIKit

import Model
import StoreInterface
import DependencyInjection

public final class MockStoreModuleInterfaceImpl: StoreInterface {
    public func getStoreDetailFullScreenViewController(storeId: Int) -> UIViewController {
        EmptyViewController()
    }

    public func getStoreDetailSectionsViewController(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        onScrollOffsetChanged: @escaping (CGFloat) -> Void
    ) -> UIViewController {
        EmptyViewController()
    }

    public func getVisitViewController(storeId: Int, onSuccessVisit: @escaping () -> Void) -> UIViewController {
        EmptyViewController()
    }

    public func getReviewBottomSheetViewController(
        storeId: Int,
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

    public func presentStoreDisplayItemModal(
        from viewController: UIViewController,
        storeId: Int,
        itemType: StoreDisplayItemType,
        trigger: StoreDisplayTrigger?,
        onDisplayed: @escaping () -> Void
    ) { }
}

extension MockStoreModuleInterfaceImpl {
    public static func registerModuleInterface() {
        DIContainer.shared.container.register(StoreInterface.self) { _ in
            return MockStoreModuleInterfaceImpl()
        }
    }
}

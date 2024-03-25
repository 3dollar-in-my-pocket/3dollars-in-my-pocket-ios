import UIKit
import Combine

import DependencyInjection
import MyPageInterface
import Model

public final class MyPageInterfaceImpl: MyPageInterface {
    public func getMyPageViewController() -> UIViewController {
        return MyPageViewController.instance()
    }
    
    public func getMyMedalViewController() -> UIViewController {
        return MyMedalViewController()
    }
    
    public func getBookmarkViewerViewController(folderId: String) -> UIViewController {
        return BookmarkViewerViewController(folderId: folderId)
    }
}

public extension MyPageInterfaceImpl {
    static func registerMyPageInterface() {
        DIContainer.shared.container.register(MyPageInterface.self) { _ in
            return MyPageInterfaceImpl()
        }
    }
}

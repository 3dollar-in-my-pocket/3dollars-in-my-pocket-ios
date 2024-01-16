import UIKit
import Combine

import DependencyInjection
import MyPageInterface
import Model

public final class MyPageInterfaceImpl: MyPageInterface {
    public func getMyPageViewController() -> UIViewController {
        return MyPageViewController.instance()
    }
}

public extension MyPageInterfaceImpl {
    static func registerMyPageInterface() {
        DIContainer.shared.container.register(MyPageInterface.self) { _ in
            return MyPageInterfaceImpl()
        }
    }
}

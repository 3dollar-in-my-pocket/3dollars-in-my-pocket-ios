import UIKit

import DependencyInjection
import MembershipInterface

public final class MembershipInterfaceImpl: MembershipInterface {
    public func createSigninAnonymousViewController() -> UIViewController {
        return SigninAnonymousViewController.instance()
    }
    
    public func createPolicyViewController() -> UIViewController {
        return PolicyViewController.instance()
    }
    
    public func createSigninBottomSheetViewController() -> UIViewController {
        return SigninBottomSheetViewController()
    }
    
    public func createAccountInfoViewController() -> UIViewController {
        return AccountInfoViewController()
    }
}

public extension MembershipInterfaceImpl {
    static func registerMembershipInterface() {
        DIContainer.shared.container.register(MembershipInterface.self) { _ in
            return MembershipInterfaceImpl()
        }
    }
}

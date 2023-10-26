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
}

public extension MembershipInterfaceImpl {
    static func registerMembershipInterface() {
        DIContainer.shared.container.register(MembershipInterface.self) { _ in
            return MembershipInterfaceImpl()
        }
    }
}

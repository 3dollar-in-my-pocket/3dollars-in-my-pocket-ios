import UIKit

import Common
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
    
    public func createAccountInfoViewModel(config: AccountInfoViewModelConfig) -> BaseViewModel {
        return AccountInfoViewModel(config: config)
    }
    
    public func createAccountInfoViewController(viewModel: BaseViewModel) -> UIViewController? {
        guard let viewModel = viewModel as? AccountInfoViewModel else { return nil }
        return AccountInfoViewController(viewModel: viewModel)
    }
}

public extension MembershipInterfaceImpl {
    static func registerMembershipInterface() {
        DIContainer.shared.container.register(MembershipInterface.self) { _ in
            return MembershipInterfaceImpl()
        }
    }
}

import UIKit

import Common

public protocol MembershipInterface {
    func createSigninAnonymousViewController() -> UIViewController
    
    func createPolicyViewController() -> UIViewController
    
    func createSigninBottomSheetViewController() -> UIViewController
    
    func createAccountInfoViewModel(config: AccountInfoViewModelConfig) -> BaseViewModel
    
    func createAccountInfoViewController(viewModel: BaseViewModel) -> UIViewController?
}

public struct AccountInfoViewModelConfig {
    public let shouldPush: Bool
    
    public init(shouldPush: Bool) {
        self.shouldPush = shouldPush
    }
}

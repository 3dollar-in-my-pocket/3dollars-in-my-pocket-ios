import UIKit

public protocol MembershipInterface {
    func createSigninAnonymousViewController() -> UIViewController
    
    func createPolicyViewController() -> UIViewController
}

import Foundation
import UIKit

import AppInterface
import Model
import DependencyInjection


public final class MockAppModuleInterfaceImpl: AppModuleInterface {
    public var userDefaults: UserDefaultProtocol = MockUserDefault()
    
    public var kakaoSigninManager: SigninManagerProtocol = MockSigninManager()
    
    public var appleSigninManager: SigninManagerProtocol = MockSigninManager()
    
    public var deeplinkManager: DeeplinkManagerProtocol = MockDeeplinkManager()
    
    public var photoManager: PhotoManagerProtocol = MockPhotoManager()
    
    public var onClearSession: (() -> Void) = { }
    
    public var globalEventBus: GlobalEventBusProtocol = MockGlobalEventBus.shared
    
    public init(userDefaults: UserDefaultProtocol) {
        self.userDefaults = userDefaults
    }
    
    public func createAdBannerView(adType: AdType) -> AdBannerViewProtocol {
        return MockAdBannerView()
    }
    
    public func getFCMToken(completion: @escaping ((String) -> ())) { }
    
    public func goToMain() { }
    
    public func goToSignin() {}
    
    public func createBookmarkViewerViewController(folderId: String) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    public func createWebViewController(webviewType: Model.WebViewType) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    public func shareKakao(storeId: Int, storeType: Model.StoreType, storeDetailOverview: StoreDetailOverview) { }
    
    public func requestATTIfNeeded() { }
    
    public func sendPageView(screenName: String, type: AnyObject.Type) { }
    
    public func sendEvent(name: String, parameters: [String : Any]?) { }
    
    public func subscribeMarketingFCMTopic(completion: @escaping ((Error?) -> Void)) { }
    
    public func unsubscribeMarketingFCMTopic(completion: @escaping ((Error?) -> Void)) { }
    
    public func presentMailComposeViewController(nickname: String, targetViewController: UIViewController) { }
    
    public func createWebViewController(title: String, url: String) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    public func showFrontAdmob(adType: Model.AdType, viewController: UIViewController) { }
    
    public func createBookmarkURL(folderId: String, name: String) async -> String {
        return await withCheckedContinuation { continuation in
            return continuation.resume(returning: "")
        }
    }
}

extension MockAppModuleInterfaceImpl {
    public static func registerAppModuleInterface(userDefaults: UserDefaultProtocol) {
        DIContainer.shared.container.register(AppModuleInterface.self) { _ in
            return MockAppModuleInterfaceImpl(userDefaults: userDefaults)
        }
    }
}

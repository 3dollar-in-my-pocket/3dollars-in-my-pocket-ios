import Foundation
import UIKit

import AppInterface
import Model
import DependencyInjection


final class MockAppModuleInterfaceImpl: AppModuleInterface {
    var userDefaults: UserDefaultProtocol = MockUserDefault()
    
    var kakaoSigninManager: SigninManagerProtocol = MockSigninManager()
    
    var appleSigninManager: SigninManagerProtocol = MockSigninManager()
    
    var deeplinkManager: DeeplinkManagerProtocol = MockDeeplinkManager()
    
    var photoManager: PhotoManagerProtocol = MockPhotoManager()
    
    var adBannerView: AdBannerViewProtocol = MockAdBannerView()
    
    var onClearSession: (() -> Void) = { }
    
    func getFCMToken(completion: @escaping ((String) -> ())) { }
    
    func goToMain() { }
    
    func createBookmarkViewerViewController(folderId: String) -> UIViewController { 
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    func createWebViewController(webviewType: Model.WebViewType) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    func shareKakao(storeId: Int, storeType: Model.StoreType, storeDetailOverview: StoreDetailOverview) { }
    
    func requestATTIfNeeded() { }
    
    func sendPageView(screenName: String, type: AnyObject.Type) { }
    
    func sendEvent(name: String, parameters: [String : Any]?) { }
}

extension MockAppModuleInterfaceImpl {
    static func registerAppModuleInterface() {
        DIContainer.shared.container.register(AppModuleInterface.self) { _ in
            return MockAppModuleInterfaceImpl()
        }
    }
}

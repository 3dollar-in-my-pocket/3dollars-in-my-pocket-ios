import Foundation
import UIKit

import AppInterface
import Model
import DependencyInjection
import DesignSystem


public final class MockAppModuleInterfaceImpl: AppModuleInterface {
    public var kakaoSigninManager: SigninManagerProtocol = MockSigninManager()
    
    public var appleSigninManager: SigninManagerProtocol = MockSigninManager()
    
    public var deepLinkHandler: DeepLinkHandlerProtocol = MockDeepLinkHandler()
    
    public var photoManager: PhotoManagerProtocol = MockPhotoManager()
    
    public var onClearSession: (() -> Void) = { 
        ToastManager.shared.show(message: "onClearSession")
    }
    
    public var globalEventBus: GlobalEventBusProtocol = MockGlobalEventBus.shared
    
    public func createAdBannerView(adType: AdType) -> AdBannerViewProtocol {
        return MockAdBannerView()
    }
    
    public func getFCMToken(completion: @escaping ((String) -> ())) { 
        ToastManager.shared.show(message: "getFCMToken")
    }
    
    public func goToMain() {
        ToastManager.shared.show(message: "goToMain")
    }
    
    public func goToSignin() {
        ToastManager.shared.show(message: "goToSignin")
    }
    
    public func createBookmarkViewerViewController(folderId: String) -> UIViewController {
        return EmptyViewController()
    }
    
    public func createWebViewController(webviewType: Model.WebViewType) -> UIViewController {
        return EmptyViewController()
    }
    
    public func shareKakao(storeId: Int, storeType: Model.StoreType, storeDetailOverview: StoreDetailOverview) {
        ToastManager.shared.show(message: "shareKakao")
    }
    
    public func requestATTIfNeeded() { 
        ToastManager.shared.show(message: "requestATTIfNeeded")
    }
    
    public func sendPageView(screenName: String, type: AnyObject.Type) { }
    
    public func sendEvent(name: String, parameters: [String : Any]?) { }
    
    public func presentMailComposeViewController(nickname: String, targetViewController: UIViewController) { 
        ToastManager.shared.show(message: "presentMailComposeViewController")
    }
    
    public func createWebViewController(title: String, url: String) -> UIViewController {
        return EmptyViewController()
    }
    
    public func showFrontAdmob(adType: Model.AdType, viewController: UIViewController) { 
        ToastManager.shared.show(message: "showFrontAdmob")
    }
    
    public func createBookmarkURL(folderId: String, name: String) async -> String {
        return await withCheckedContinuation { continuation in
            return continuation.resume(returning: "")
        }
    }
}

extension MockAppModuleInterfaceImpl {
    public static func registerAppModuleInterface() {
        DIContainer.shared.container.register(AppModuleInterface.self) { _ in
            return MockAppModuleInterfaceImpl()
        }
    }
}

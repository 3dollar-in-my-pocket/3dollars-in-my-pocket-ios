import Foundation
import UIKit
import Combine
import Model

public protocol AppModuleInterface {
    var kakaoSigninManager: SigninManagerProtocol { get }
    var appleSigninManager: SigninManagerProtocol { get }
    var deepLinkHandler: DeepLinkHandlerProtocol { get }
    var photoManager: PhotoManagerProtocol { get }
    var onClearSession: (() -> Void) { get }
    var globalEventBus: GlobalEventBusProtocol { get }
    var kakaoChannelUrl: String { get }
    
    func createAdBannerView(adType: AdType) -> AdBannerViewProtocol
    func createWebViewController(title: String, url: String) -> UIViewController
    func getFCMToken(completion: @escaping ((String) -> ()))
    func goToMain()
    func goToSignin()
    func createWebViewController(webviewType: WebViewType) -> UIViewController
    func shareKakao(storeId: Int, storeType: StoreType, storeDetailOverview: StoreDetailOverview)
    func requestATTIfNeeded()
    func showFrontAdmob(adType: AdType, viewController: UIViewController)
    func createBookmarkURL(folderId: String) -> String
    
    /// GA
    func sendPageView(screenName: String, type: AnyObject.Type)
    func sendEvent(name: String, parameters: [String: Any]?)
}

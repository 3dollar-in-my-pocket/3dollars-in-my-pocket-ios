import Foundation
import UIKit
import Combine
import Model

public protocol AppModuleInterface {
    var userDefaults: UserDefaultProtocol { get set }
    var kakaoSigninManager: SigninManagerProtocol { get }
    var appleSigninManager: SigninManagerProtocol { get }
    var deeplinkManager: DeeplinkManagerProtocol { get }
    var photoManager: PhotoManagerProtocol { get }
    var onClearSession: (() -> Void) { get }
    var globalEventBus: GlobalEventBusProtocol { get }
    
    func createAdBannerView(adType: AdType) -> AdBannerViewProtocol
    func createWebViewController(title: String, url: String) -> UIViewController
    func getFCMToken(completion: @escaping ((String) -> ()))
    func goToMain()
    func createBookmarkViewerViewController(folderId: String) -> UIViewController
    func createWebViewController(webviewType: WebViewType) -> UIViewController
    func shareKakao(storeId: Int, storeType: StoreType, storeDetailOverview: StoreDetailOverview)
    func requestATTIfNeeded()
    func subscribeMarketingFCMTopic(completion: @escaping ((Error?) -> Void))
    func unsubscribeMarketingFCMTopic(completion: @escaping ((Error?) -> Void))
    func showFrontAdmob(adType: AdType, viewController: UIViewController)
    
    /// GA
    func sendPageView(screenName: String, type: AnyObject.Type)
    func sendEvent(name: String, parameters: [String: Any]?)
}

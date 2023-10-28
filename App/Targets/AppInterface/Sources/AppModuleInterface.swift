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
    var adBannerView: AdBannerViewProtocol { get }
    var onClearSession: (() -> Void) { get }
    
    func getFCMToken(completion: @escaping ((String) -> ()))
    func goToMain()
    func createBookmarkViewerViewController(folderId: String) -> UIViewController
    func createWebViewController(webviewType: WebViewType) -> UIViewController
    func shareKakao(storeId: Int, storeType: StoreType, storeDetailOverview: StoreDetailOverview)
    func requestATTIfNeeded()
    
    /// GA
    func sendPageView(screenName: String, type: AnyObject.Type)
    func sendEvent(name: String, parameters: [String: Any]?)
}

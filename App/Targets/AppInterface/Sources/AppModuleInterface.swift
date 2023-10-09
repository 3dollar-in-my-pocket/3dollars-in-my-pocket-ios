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
    var analyticsManager: AnalyticsManagerProtocol { get }
    
    func getFCMToken(completion: @escaping ((String) -> ()))
    func goToMain()
    func createBookmarkViewerViewController(folderId: String) -> UIViewController
    func createWebViewController(webviewType: WebViewType) -> UIViewController
    func shareKakao(storeId: Int, storeDetailOverview: StoreDetailOverview)
}

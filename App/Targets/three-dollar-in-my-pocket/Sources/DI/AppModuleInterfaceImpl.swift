import UIKit

import AppInterface
import DependencyInjection
import Model

import FirebaseMessaging
import KakaoSDKShare
import KakaoSDKTemplate

final class AppModuleInterfaceImpl: AppModuleInterface {
    private var _userDefaults: AppInterface.UserDefaultProtocol = UserDefaultsUtil()
    
    var userDefaults: AppInterface.UserDefaultProtocol {
        set {
            _userDefaults = newValue
        }
        get {
            return _userDefaults
        }
    }
    
    var kakaoSigninManager: AppInterface.SigninManagerProtocol {
        return NewKakaoSigninManager.shared
    }
    
    var appleSigninManager: AppInterface.SigninManagerProtocol {
        return NewAppleSigninManager.shared
    }
    
    var deeplinkManager: DeeplinkManagerProtocol {
        return DeeplinkManager.shared
    }
    
    var photoManager: AppInterface.PhotoManagerProtocol {
        return CombinePhotoManager.shared
    }
    
    var analyticsManager: AnalyticsManagerProtocol {
        return AnalyticsManager.shared
    }
    
    func getFCMToken(completion: @escaping ((String) -> ())) {
        Messaging.messaging().token { token, error in
            guard let token = token else {
                print("⚠️Error in send FCM token")
                return
            }
            
            completion(token)
        }
    }
    
    func goToMain() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        sceneDelegate.goToMain()
    }
    
    func createBookmarkViewerViewController(folderId: String) -> UIViewController {
        return BookmarkViewerViewController.instance(folderId: folderId)
    }
    
    func createWebViewController(webviewType: WebViewType) -> UIViewController {
        return WebViewController.instance(webviewType: webviewType)
    }
    
    func shareKakao(storeId: Int, storeDetailOverview: StoreDetailOverview) {
        let storeName = storeDetailOverview.storeName
        let latitude = storeDetailOverview.location.latitude
        let longitude = storeDetailOverview.location.longitude
        
        let urlString =
        "https://map.kakao.com/link/map/\(storeName),\(latitude),\(longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let webURL = URL(string: urlString)
        let link = Link(
            webUrl: webURL,
            mobileWebUrl: webURL,
            androidExecutionParams: [
                "storeId": String(storeId),
                "storeType": "streetFood"
            ],
            iosExecutionParams: [
                "storeId": String(storeId),
                "storeType": "streetFood"
            ]
        )
        let content = Content(
            title: "store_detail_share_title".localized,
            imageUrl: URL(string: "https://storage.threedollars.co.kr/share/share-with-kakao.png")!,
            imageWidth: 500,
            imageHeight: 500,
            description: "store_detail_share_description".localized,
            link: link
        )
        let feedTemplate = FeedTemplate(
            content: content,
            social: nil,
            buttonTitle: nil,
            buttons: [Button(title: "store_detail_share_button".localized, link: link)]
        )
        
        ShareApi.shared.shareDefault(templatable: feedTemplate) { linkResult, error in
            
            if let error = error,
               let rootViewController = SceneDelegate.shared?.window?.rootViewController {
                AlertUtils.showWithAction(
                    viewController: rootViewController,
                    message: error.localizedDescription,
                    onTapOk: nil
                )
                
            } else {
                if let linkResult = linkResult {
                    UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension AppModuleInterfaceImpl {
    static func registerAppModuleInterface() {
        DIContainer.shared.container.register(AppModuleInterface.self) { _ in
            return AppModuleInterfaceImpl()
        }
    }
}

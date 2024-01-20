import UIKit
import MessageUI
import AppTrackingTransparency

import AppInterface
import DependencyInjection
import Model

import FirebaseMessaging
import FirebaseAnalytics
import KakaoSDKShare
import KakaoSDKTemplate
import DeviceKit

final class AppModuleInterfaceImpl: NSObject, AppModuleInterface {
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
    
    var onClearSession: (() -> Void) {
        let onClearSession = {
            UserDefaultsUtil().clear()
            if let sceneDelegate
                = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.goToSignIn()
            }
        }
        
        return onClearSession
    }
    
    var globalEventBus: GlobalEventBusProtocol {
        return GlobalEventBus.shared
    }
    
    func createAdBannerView(adType: AdType) -> AdBannerViewProtocol {
        return AdBannerView(adType: adType)
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
    
    func shareKakao(storeId: Int, storeType: Model.StoreType, storeDetailOverview: StoreDetailOverview) {
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
                "storeType": storeType.kakaoParameterValue
            ],
            iosExecutionParams: [
                "storeId": String(storeId),
                "storeType": storeType.kakaoParameterValue
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
                guard let linkResult = linkResult,
                      UIApplication.shared.canOpenURL(linkResult.url) else {
                    if let rootViewController = SceneDelegate.shared?.window?.rootViewController {
                        AlertUtils.showWithAction(
                            viewController: rootViewController,
                            message: "카카오톡 URL을 열 수 없습니다.",
                            onTapOk: nil
                        )
                    }
                    return
                }
                UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func requestATTIfNeeded() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { _ in                
            }
        }
    }
    
    func sendPageView(screenName: String, type: AnyObject.Type) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: NSStringFromClass(type.self)
        ])
    }
    
    func sendEvent(name: String, parameters: [String : Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func subscribeMarketingFCMTopic(completion: @escaping ((Error?) -> Void)) {
        Messaging.messaging().subscribe(toTopic: "marketing_ios", completion: completion)
    }
    
    func unsubscribeMarketingFCMTopic(completion: @escaping ((Error?) -> Void)) {
        Messaging.messaging().unsubscribe(fromTopic: "marketing_ios", completion: completion)
    }
    
    func presentMailComposeViewController(
        nickname: String,
        targetViewController: UIViewController
    ) {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let iosVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let deviceModel = Device.current
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["3dollarinmypocket@gmail.com"])
        composer.setSubject("가슴속 3천원 문의")
        composer.setMessageBody("\n\n\n\n----------\n닉네임: \(nickname)\n앱 버전: \(appVersion)\nOS: ios \(iosVersion)\n디바이스: \(deviceModel)", isHTML: false)
        
        targetViewController.present(composer, animated: true)
    }
}

extension AppModuleInterfaceImpl {
    static func registerAppModuleInterface() {
        DIContainer.shared.container.register(AppModuleInterface.self) { _ in
            return AppModuleInterfaceImpl()
        }
    }
}

extension AppModuleInterfaceImpl: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}

import UIKit
import AppTrackingTransparency

import AppInterface
import DependencyInjection
import Model
import Common

import FirebaseMessaging
import FirebaseAnalytics
import KakaoSDKShare
import KakaoSDKTemplate
import GoogleMobileAds
import FirebaseDynamicLinks

final class AppModuleInterfaceImpl: NSObject, AppModuleInterface {
    var kakaoSigninManager: AppInterface.SigninManagerProtocol {
        return KakaoSigninManager.shared
    }
    
    var appleSigninManager: AppInterface.SigninManagerProtocol {
        return AppleSigninManager.shared
    }
    
    var deeplinkManager: DeeplinkManagerProtocol {
        return DeeplinkManager.shared
    }
    
    var photoManager: AppInterface.PhotoManagerProtocol {
        return CombinePhotoManager.shared
    }
    
    var onClearSession: (() -> Void) {
        let onClearSession = {
            Preference.shared.clear()
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
    
    func createWebViewController(title: String, url: String) -> UIViewController {
        return WebViewController(title: title, url: url)
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
    
    func goToSignin() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        sceneDelegate.goToSignIn()
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
            title: Strings.storeDetailShareTitle,
            imageUrl: URL(string: "https://storage.threedollars.co.kr/share/share-with-kakao.png")!,
            imageWidth: 500,
            imageHeight: 500,
            description: Strings.storeDetailShareDescription,
            link: link
        )
        let feedTemplate = FeedTemplate(
            content: content,
            social: nil,
            buttonTitle: nil,
            buttons: [Button(title: Strings.storeDetailShareButton, link: link)]
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
    
    func showFrontAdmob(adType: AdType, viewController: UIViewController) {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: Bundle.getAdmobId(adType: adType),
            request: request,
            completionHandler: { [weak viewController] ad, error in
                guard let viewController else { return }
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                ad?.present(fromRootViewController: viewController)
            }
        )
    }
    
    func createBookmarkURL(folderId: String, name: String) async -> String {
        return await withCheckedContinuation { continuation in
            guard let link = Deeplink.bookmark(folderId: folderId).url else {
                return continuation.resume(returning: "")
            }
            let dynamicLinksDomainURIPrefix = Bundle.dynamicLinkURL
            let linkBuilder = DynamicLinkComponents(
                link: link,
                domainURIPrefix: dynamicLinksDomainURIPrefix
            )
            
            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.bundleId)
            linkBuilder?.iOSParameters?.appStoreID = Bundle.appstoreId
            linkBuilder?.iOSParameters?.minimumAppVersion = "3.3.0"
            linkBuilder?.androidParameters
            = DynamicLinkAndroidParameters(packageName: Bundle.androidPackageName)
            linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
            linkBuilder?.socialMetaTagParameters?.title = Strings.myPageBookmarkDescription
            linkBuilder?.socialMetaTagParameters?.descriptionText = name
            linkBuilder?.socialMetaTagParameters?.imageURL
            = URL(string: "https://storage.threedollars.co.kr/share/favorite_share.png")
            
            linkBuilder?.shorten(completion: { url, _, _ in
                if let shortURL = url {
                    continuation.resume(returning: shortURL.absoluteString)
                } else {
                    guard let longDynamicLink = linkBuilder?.url else {
                        return continuation.resume(returning: "")
                    }
                    
                    return continuation.resume(returning: longDynamicLink.absoluteString)
                }
            })
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

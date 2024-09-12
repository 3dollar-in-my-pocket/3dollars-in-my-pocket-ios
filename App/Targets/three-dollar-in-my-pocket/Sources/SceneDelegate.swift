import UIKit

import Common
import Membership

import KakaoSDKAuth
import FirebaseDynamicLinks
import netfox

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    static var shared: SceneDelegate? {
        UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if DEBUG
        window = ShakeDetectingWindow(frame: windowScene.coordinateSpace.bounds)
        #else
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        #endif
        
        window?.windowScene = windowScene
        window?.backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
        window?.rootViewController = SplashViewController(nibName: nil, bundle: nil)
        window?.makeKeyAndVisible()
        
        self.reserveDynamicLinkIfExisted(connectionOptions: connectionOptions)
        self.reserveDeepLinkIfExisted(connectionOptions: connectionOptions)
        self.reserveNotificationDeepLinkIfExisted(connectionOptions: connectionOptions)
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            } else if self.isKakaoLinkUrl(url: url) {
                if let params = url.params(),
                   let storeId = params["storeId"] as? String,
                   let storeType = params["storeType"] as? String {
                    Preference.shared.shareLink = "\(storeType):\(storeId)"
                }
            }
            DeepLinkHandler.shared.handle(url.absoluteString)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else { return }
        DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, _ in
            guard let url = dynamicLink?.url else { return }
                
            DeepLinkHandler.shared.handle(url.absoluteString)
        }
    }
    
    func goToMain() {
        let tabBarViewController = MainTabBarViewController()
        let navigationViewController = UINavigationController(rootViewController: tabBarViewController)
        navigationViewController.isNavigationBarHidden = true
        navigationViewController.interactivePopGestureRecognizer?.delegate = nil
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }
    
    func goToSignIn() {
        window?.rootViewController = SigninViewController.instance()
        window?.makeKeyAndVisible()
    }
    
    private func isKakaoLinkUrl(url: URL) -> Bool {
        let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String ?? ""
        
        return url.absoluteString.hasPrefix("kakao\(kakaoAppKey)://kakaolink")
    }
    
    private func reserveDynamicLinkIfExisted(connectionOptions: UIScene.ConnectionOptions) {
        for userActivity in connectionOptions.userActivities {
            if let incomingURL = userActivity.webpageURL {
                DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                    guard error == nil else {
                        Log.debug("Found an error \(error!.localizedDescription)")
                        return
                    }
                    
                    guard let url = dynamicLink?.url else { return }
                    DeepLinkHandler.shared.handle(url.absoluteString)
                }
                break
            }
        }
    }
    
    private func reserveDeepLinkIfExisted(connectionOptions: UIScene.ConnectionOptions) {
        guard let url = connectionOptions.urlContexts.first?.url else { return }
        
        DeepLinkHandler.shared.handle(url.absoluteString)
    }
    
    private func reserveNotificationDeepLinkIfExisted(connectionOptions: UIScene.ConnectionOptions) {
        guard let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo,
              let deepLink = userInfo["link"] as? String else { return }
        DeepLinkHandler.shared.handle(deepLink)
    }
}

extension SceneDelegate {
    final class ShakeDetectingWindow: UIWindow {
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                notificationFeedbackGenerator.prepare()
                notificationFeedbackGenerator.notificationOccurred(.success)
                NFX.sharedInstance().show()
            }
            super.motionEnded(motion, with: event)
        }
    }
}

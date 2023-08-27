import UIKit

import AppInterface
import DependencyInjection
import Model

import FirebaseMessaging

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
}

extension AppModuleInterfaceImpl {
    static func registerAppModuleInterface() {
        DIContainer.shared.container.register(AppModuleInterface.self) { _ in
            return AppModuleInterfaceImpl()
        }
    }
}

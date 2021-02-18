import UIKit
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    window?.windowScene = windowScene
    window?.backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
    window?.rootViewController = SplashVC.instance()
    window?.makeKeyAndVisible()
    self.scene(scene, openURLContexts: connectionOptions.urlContexts)
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
      if (AuthApi.isKakaoTalkLoginUrl(url)) {
        _ = AuthController.handleOpenUrl(url: url)
      } else if self.isKakaoLinkUrl(url: url) {
        if let params = url.params(),
           let storeIdString = params["storeId"] as? String,
           let storeId = Int(storeIdString) {
          self.saveStoreDetailLink(storeId: storeId)
        }
      }
    }
  }
  
  func goToMain() {
    window?.rootViewController = TabBarVC.instance()
    window?.makeKeyAndVisible()
  }
  
  func goToSignIn() {
    window?.rootViewController = SignInVC.instance()
    window?.makeKeyAndVisible()
  }
  
  private func isKakaoLinkUrl(url: URL) -> Bool {
    let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String ?? ""
    
    return url.absoluteString.hasPrefix("kakao\(kakaoAppKey)://kakaolink")
  }
  
  private func saveStoreDetailLink(storeId: Int) {
    UserDefaultsUtil().setDetailLink(storeId: storeId)
  }
}


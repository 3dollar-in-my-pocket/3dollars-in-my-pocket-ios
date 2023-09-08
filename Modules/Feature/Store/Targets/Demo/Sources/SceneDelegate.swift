import UIKit

import Store

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    static var shared: SceneDelegate? {
        UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = StoreDetailViewController.instance()
        window?.makeKeyAndVisible()
    }
}

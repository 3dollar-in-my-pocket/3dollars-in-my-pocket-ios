import UIKit

import Store

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    static var shared: SceneDelegate? {
        UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let rootViewController = StoreDemoViewController()
        let navigationViewController = UINavigationController(rootViewController: rootViewController)
//        let rootViewController = StoreDetailViewController.instance(storeId: 126)
//        let navigationViewController = UINavigationController(rootViewController: rootViewController)
//        navigationViewController.isNavigationBarHidden = true
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }
}

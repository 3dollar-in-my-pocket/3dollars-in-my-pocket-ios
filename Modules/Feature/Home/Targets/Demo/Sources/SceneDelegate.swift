import UIKit

import Home

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    static var shared: SceneDelegate? {
        UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([HomeViewController.instance()], animated: true)
        tabBarController.tabBar.layer.borderWidth = 0
        tabBarController.tabBar.layer.borderColor = UIColor.clear.cgColor
        tabBarController.tabBar.clipsToBounds = true
        tabBarController.tabBar.barTintColor = .white
        
        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        
        let navigationViewController = UINavigationController(rootViewController: tabBarController)
        navigationViewController.isNavigationBarHidden = true
        navigationViewController.interactivePopGestureRecognizer?.delegate = nil
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }
}

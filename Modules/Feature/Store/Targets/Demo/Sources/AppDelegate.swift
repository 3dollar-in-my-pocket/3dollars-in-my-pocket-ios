import UIKit

import Common
import Store
import Mock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        initializeDI()
        return true
    }
      
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    private func initializeDI() {
        MockAppModuleInterfaceImpl.registerAppModuleInterface()
        MockNetworkConfiguration.registerNetworkConfiguration()
        StoreInterfaceImpl.registerStoreInterface()
    }
}

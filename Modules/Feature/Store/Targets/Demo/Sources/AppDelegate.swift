import UIKit

import Common
import Store
import Mock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var networkConfiguration = MockNetworkConfiguration()
    var mockUserDefaults = MockUserDefault()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        initializeDI()
        return true
    }
      
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    private func initializeDI() {
        MockTokenService().generateTestToken { [weak self] auth in
            self?.networkConfiguration.authToken = auth.token
            self?.mockUserDefaults.authToken = auth.token
            self?.mockUserDefaults.userId = auth.userId
            self?.mockUserDefaults.isAnonymousUser = false
        }
        
        MockAppModuleInterfaceImpl.registerAppModuleInterface(userDefaults: mockUserDefaults)
        MockNetworkConfiguration.registerNetworkConfiguration(networkConfiguration)
        StoreInterfaceImpl.registerStoreInterface()
    }
}

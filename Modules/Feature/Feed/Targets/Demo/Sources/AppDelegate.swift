import UIKit

import Common
import Mock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var networkConfiguration = MockNetworkConfiguration()
    var preference = Preference(name: "Feed-Demo")
    
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
            self?.preference.authToken = auth.token
            self?.preference.userId = auth.userId
            self?.preference.isAnonymousUser = false
        }
        
        MockAppModuleInterfaceImpl.registerAppModuleInterface()
        MockNetworkConfiguration.registerNetworkConfiguration(networkConfiguration)
    }
}

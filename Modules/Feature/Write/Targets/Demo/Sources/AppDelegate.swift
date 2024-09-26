import UIKit

import Common
import Mock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        initializeMock()
        return true
    }
      
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    private func initializeMock() {
        MockAppModuleInterfaceImpl.registerAppModuleInterface()
        MockNetworkConfiguration.registerNetworkConfiguration()
        MockAppInformationImpl.registerAppInformation()
    }
}

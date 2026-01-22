import UIKit

import Common
import Mock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var networkConfiguration = MockNetworkConfiguration()
    var preference = Preference(name: "SDU-Demo")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        return true
    }
      
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

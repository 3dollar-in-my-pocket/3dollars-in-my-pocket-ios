import UIKit
import Firebase
import SwiftyBeaver
import GoogleMobileAds
import KakaoSDKCommon

typealias Log = SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Override point for customization after application launch.
    initializeFirebase()
    initializeNetworkLogger()
    initilizeSwiftyBeaver()
    initilizeKakao()
    
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  private func initializeNetworkLogger() {
    NetworkActivityLogger.shared.startLogging()
    NetworkActivityLogger.shared.level = .debug
  }
  
  private func initializeFirebase() {
    FirebaseApp.configure()
  }
  
  private func initilizeAdmob() {
    GADMobileAds.sharedInstance().start(completionHandler: nil)
  }
  
  private func initilizeSwiftyBeaver() {
    let console = ConsoleDestination()
    let platform = SBPlatformDestination(
      appID: "g6PNqN",
      appSecret: "sxvb0isaxBuyz95xtqajnwrbfM3Dw7Bd",
      encryptionKey: "yybiGqoyhddpxgp2fmghh9Zcyqacpe5u"
    )
    
    platform.minLevel = .warning
    console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    Log.addDestination(console)
    Log.addDestination(platform)
  }
  
  private func initilizeKakao() {
    let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String ?? ""
    Log.debug("kakaoAppKey: \(kakaoAppKey)")
    KakaoSDKCommon.initSDK(appKey: kakaoAppKey)
  }
}

import UIKit
import KakaoOpenSDK
import NaverThirdPartyLogin
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initializeNaverLogin()
        initializeGoogleLogin()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        
        NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)
        GIDSignIn.sharedInstance().handle(url)
        
        return false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        KOSession.handleDidBecomeActive()
    }

    private func initializeNaverLogin() {
        guard let connection = NaverThirdPartyLoginConnection.getSharedInstance() else {
            AlertUtils.show(title: "error", message: "네이버 로그인 초기화 실패")
            return
        }
        
        connection.isNaverAppOauthEnable = true
        connection.isInAppOauthEnable = true
        connection.setOnlyPortraitSupportInIphone(true)
        connection.serviceUrlScheme = kServiceAppUrlScheme
        connection.consumerKey = kConsumerKey
        connection.consumerSecret = kConsumerSecret
        connection.appName = kServiceAppName
    }
    
    private func initializeGoogleLogin() {
        guard let gidSignIn = GIDSignIn.sharedInstance() else {
            AlertUtils.show(title: "error", message: "GIDSignIn 초기화 실패")
            return
        }
        
        gidSignIn.clientID = "1014726034007-cr8jiho91de2ctkvqttro93oem0gddqf.apps.googleusercontent.com"
    }
}




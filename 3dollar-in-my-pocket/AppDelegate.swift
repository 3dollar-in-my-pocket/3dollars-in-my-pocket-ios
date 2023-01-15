import UIKit

import SnapKit
import Firebase
import SwiftyBeaver
import GoogleMobileAds
import KakaoSDKCommon
import FirebaseMessaging

typealias Log = SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Override point for customization after application launch.
        self.initilizeNotification()
        initializeFirebase()
        initializeNetworkLogger()
        initilizeSwiftyBeaver()
        initilizeKakao()
        initilizeAdmob()
        application.registerForRemoteNotifications()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    private func initializeNetworkLogger() {
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
    }
    
    private func initializeFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    private func initilizeAdmob() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    private func initilizeSwiftyBeaver() {
        let console = ConsoleDestination()
        
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        Log.addDestination(console)
    }
    
    private func initilizeKakao() {
        let kakaoAppKey
            = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String ?? ""
        Log.debug("kakaoAppKey: \(kakaoAppKey)")
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
    
    private func initilizeNotification() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]) { isGranted, error in
                let userPropertyValue = isGranted ? "granted" : "denied"
                
                Analytics.setUserProperty(userPropertyValue, forName: "isPushGranted")
                if let error = error {
                    Log.debug("error: \(error)")
                }
            }
    }
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamiclink, error in
            Log.debug("dynamic link url: \(dynamiclink?.url?.absoluteString ?? "")")
        }
        
        return handled
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
    
        if #available(iOS 14.0, *) {
            completionHandler([[.sound, .banner, .alert]])
        } else {
            completionHandler([[.alert, .sound]])
        }
    }
}

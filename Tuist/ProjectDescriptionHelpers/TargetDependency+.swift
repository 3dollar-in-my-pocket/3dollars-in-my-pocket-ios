import ProjectDescription

public extension TargetDependency {
    static let mock = TargetDependency.project(
        target: "Mock",
        path: .relativeToRoot("./Modules/Mock")
    )
    
    class Core {
        public static let dependencyInjection = TargetDependency.project(
            target: "DependencyInjection",
            path: .relativeToRoot("./Modules/Core/DependencyInjection")
        )
        
        public static let networking = TargetDependency.project(
            target: "Networking",
            path: .relativeToRoot("./Modules/Core/Network")
        )
        
        public static let common = TargetDependency.project(
            target: "Common",
            path: .relativeToRoot("./Modules/Core/Common")
        )
        
        public static let model = TargetDependency.project(
            target: "Model",
            path: .relativeToRoot("./Modules/Core/Model")
        )
        
        public static let log = TargetDependency.project(
            target: "Log",
            path: .relativeToRoot("./Modules/Core/Log")
        )
        
        public static let designSystem = TargetDependency.project(
            target: "DesignSystem",
            path: .relativeToRoot("./Modules/Core/DesignSystem")
        )
    }
    
    class Feature {
        public static let home = TargetDependency.project(
            target: "Home",
            path: .relativeToRoot("./Modules/Feature/Home")
        )
        
        public static let community = TargetDependency.project(
            target: "Community",
            path: .relativeToRoot("./Modules/Feature/Community")
        )
        
        public static let membership = TargetDependency.project(
            target: "Membership",
            path: .relativeToRoot("./Modules/Feature/Membership")
        )
        
        public static let store = TargetDependency.project(
            target: "Store",
            path: .relativeToRoot("./Modules/Feature/Store")
        )
        
        public static let write = TargetDependency.project(
            target: "Write",
            path: .relativeToRoot("./Modules/Feature/Write")
        )
        
        public static let myPage = TargetDependency.project(
            target: "MyPage",
            path: .relativeToRoot("./Modules/Feature/MyPage")
        )
        
        public static let feed = TargetDependency.project(
            target: "Feed",
            path: .relativeToRoot("./Modules/Feature/Feed")
        )
    }
    
    class Interface {
        public static let appInterface = TargetDependency.project(
            target: "AppInterface",
            path: .relativeToRoot("./App")
        )
        
        public static let communityInterface = TargetDependency.project(
            target: "CommunityInterface",
            path: .relativeToRoot("./Modules/Feature/Community")
        )
        
        public static let membershipInterface = TargetDependency.project(
            target: "MembershipInterface",
            path: .relativeToRoot("./Modules/Feature/Membership")
        )
        
        public static let storeInterface = TargetDependency.project(
            target: "StoreInterface",
            path: .relativeToRoot("./Modules/Feature/Store")
        )
        
        public static let writeInterface = TargetDependency.project(
            target: "WriteInterface",
            path: .relativeToRoot("./Modules/Feature/Write")
        )
        
        public static let myPageInterface = TargetDependency.project(
            target: "MyPageInterface",
            path: .relativeToRoot("./Modules/Feature/MyPage")
        )
        
        public static let feedInterface = TargetDependency.project(
            target: "FeedInterface",
            path: .relativeToRoot("./Modules/Feature/Feed")
        )
    }
    
    class SPM {
        public static let lottie = TargetDependency.external(name: "Lottie")
        public static let swinject = TargetDependency.external(name: "Swinject")
        public static let kingfisher = TargetDependency.external(name: "Kingfisher")
        public static let snapKit = TargetDependency.external(name: "SnapKit")
        public static let then = TargetDependency.external(name: "Then")
        public static let panModal = TargetDependency.external(name: "PanModal")
        public static let combineCocoa = TargetDependency.external(name: "CombineCocoa")
        public static let zMarkupParser = TargetDependency.external(name: "ZMarkupParser")
        public static let naverMap = TargetDependency.external(name: "NMapsMap")
    }
    
    class Package {
        public static let cameraPermission = TargetDependency.package(product: "CameraPermission")
        
        public static let deviceKit = TargetDependency.package(product: "DeviceKit")
        
        public static let firebaseAnalytics = TargetDependency.package(product: "FirebaseAnalytics")
        
        public static let firebaseCrashlytics = TargetDependency.package(product: "FirebaseCrashlytics")
        
        public static let firebaseDynamicLinks = TargetDependency.package(product: "FirebaseDynamicLinks")
        
        public static let firebaseFirestore = TargetDependency.package(product: "FirebaseFirestore")
        
        public static let firebaseMessaging = TargetDependency.package(product: "FirebaseMessaging")
        
        public static let firebaseRemoteConfig = TargetDependency.package(product: "FirebaseRemoteConfig")
        
        public static let kakaoSDK = TargetDependency.package(product: "KakaoSDK")
        
        public static let kakaoSDKAuth = TargetDependency.package(product: "KakaoSDKAuth")
        
        public static let kakaoSDKCommon = TargetDependency.package(product: "KakaoSDKCommon")
        
        public static let kakaoSDKShare = TargetDependency.package(product: "KakaoSDKShare")
        
        public static let kakaoSDKTalk = TargetDependency.package(product: "KakaoSDKTalk")
        
        public static let kakaoSDKTemplate = TargetDependency.package(product: "KakaoSDKTemplate")
        
        public static let kakaoSDKUser = TargetDependency.package(product: "KakaoSDKUser")
        
        public static let locationAlwaysPermission = TargetDependency.package(product: "LocationAlwaysPermission")
        
        public static let locationWhenInUsePermission = TargetDependency.package(product: "LocationWhenInUsePermission")
        
        public static let photoLibraryPermission = TargetDependency.package(product: "PhotoLibraryPermission")
        
        public static let swiftyBeaver = TargetDependency.package(product: "SwiftyBeaver")
        
        public static let netfox = TargetDependency.package(product: "netfox")
        
        public static let admob = TargetDependency.package(product: "GoogleMobileAds")
    }
}

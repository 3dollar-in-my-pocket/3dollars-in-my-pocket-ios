import ProjectDescription

public extension Package {
    static let kakaoSDK = Package.remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .exact("2.11.1"))
    
    static let swiftyBeaver = Package.remote(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", requirement: .exact("1.9.6"))
    
    static let deviceKit = Package.remote(url: "https://github.com/devicekit/DeviceKit.git", requirement: .exact("5.0.0"))
    
    static let permissionsKit = Package.remote(url: "https://github.com/sparrowcode/PermissionsKit", requirement: .exact("9.0.2"))
    
    static let firebaseSDK = Package.remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .exact("12.5.0"))
    
    static let netfox = Package.remote(url: "https://github.com/kasketis/netfox", requirement: .exact("1.21.0"))
    
    static let admob = Package.remote(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", requirement: .exact("12.13.0"))
    
    static let naverMap = Package.remote(
        url: "https://github.com/navermaps/SPM-NMapsMap",
        requirement: .exact("3.23.0")
    )
}

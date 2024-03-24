import ProjectDescription

public extension Package {
    static let kakaoSDK = Package.remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .exact("2.11.1"))
    
    static let swiftyBeaver = Package.remote(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", requirement: .exact("1.9.6"))
    
    static let deviceKit = Package.remote(url: "https://github.com/devicekit/DeviceKit.git", requirement: .exact("5.0.0"))
    
    static let permissionsKit = Package.remote(url: "https://github.com/sparrowcode/PermissionsKit", requirement: .exact("9.0.2"))
    
    static let firebaseSDK = Package.remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .exact("10.22.1"))
}

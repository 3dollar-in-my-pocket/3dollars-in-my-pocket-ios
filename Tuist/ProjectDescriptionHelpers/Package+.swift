import ProjectDescription

public extension Package {
    static let reactorKit = Package.remote(url: "https://github.com/ReactorKit/ReactorKit.git", requirement: .upToNextMajor(from: "3.0.0"))
    
    static let kakaoSDK = Package.remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .exact("2.11.1"))
    
    static let rxDataSources = Package.remote(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", requirement: .upToNextMajor(from: "5.0.0"))
    
    static let swiftyBeaver = Package.remote(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", requirement: .exact("1.9.6"))
    
    static let deviceKit = Package.remote(url: "https://github.com/devicekit/DeviceKit.git", requirement: .exact("5.0.0"))
    
    static let permissionsKit = Package.remote(url: "https://github.com/sparrowcode/PermissionsKit", requirement: .exact("9.0.2"))
    
    static let firebaseSDK = Package.remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "10.4.0"))
    
    static let rxSwift = Package.remote(url: "https://github.com/ReactiveX/RxSwift.git", requirement: .exact("6.5.0"))
}

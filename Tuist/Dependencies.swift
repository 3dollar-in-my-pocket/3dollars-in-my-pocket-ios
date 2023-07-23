import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/devxoul/Then", requirement: .upToNextMajor(from: "2.0.0")),
        .remote(url: "https://github.com/SnapKit/SnapKit", requirement: .upToNextMajor(from: "5.0.0")),
        .remote(url: "https://github.com/onevcat/Kingfisher.git", requirement: .exact("7.6.2")),
        .remote(url: "https://github.com/airbnb/lottie-ios.git", requirement: .exact("4.0.1")),
        .remote(url: "https://github.com/slackhq/PanModal.git", requirement: .exact("1.2.6"))
    ],
    platforms: [.iOS]
)

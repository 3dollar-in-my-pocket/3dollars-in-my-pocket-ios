// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers

    let packageSettings = PackageSettings(
        productTypes: [
            "Then": .framework,
            "SnapKit": .framework,
            "Kingfisher": .framework,
            "lottie-ios": .framework,
            "PanModal": .framework,
            "Swinject": .framework,
            "CombineCocoa": .framework,
            "ZMarkupParser": .framework
        ]
    )
#endif

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/devxoul/Then", from: "2.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.6.2"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.0.1"),
        .package(url: "https://github.com/slackhq/PanModal.git", from: "1.2.6"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.4.1"),
        .package(url: "https://github.com/ZhgChgLi/ZMarkupParser.git", from: "1.12.0")
    ],
    targets: []
)

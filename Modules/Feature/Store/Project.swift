import ProjectDescription
import ProjectDescriptionHelpers

struct Version {
    static let targetVersion = "14.0"
}

struct BuildSetting {
    struct Project {
        static let base: SettingsDictionary = [
            "IPHONEOS_DEPLOYMENT_TARGET": "14.0"
        ]
    }
}


let project = Project(
    name: "Store",
    organizationName: "macgongmon",
    packages: [],
    settings: .settings(
        base: BuildSetting.Project.base,
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ]
    ),
    targets: [
        Target(
            name: "Store",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.store",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Store/Sources/**"],
            resources: ["Targets/Store/Resources/**"],
            dependencies: [
                .project(target: "Networking", path: "../../Network"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Common", path: "../../Common"),
                .project(target: "Model", path: "../../Common"),
                .project(target: "DependencyInjection", path: "../../DependencyInjection"),
                .project(target: "AppInterface", path: "../../../App"),
                .project(target: "StoreInterface", path: "./"),
                .project(target: "WriteInterface", path: "../Write"),
                .external(name: "SnapKit"),
                .external(name: "Then"),
                .external(name: "PanModal")
            ]
        ),
        Target(
            name: "StoreDemo",
            platform: .iOS,
            product: .app,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.store-demo",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: "Targets/Demo/Info.plist",
            sources: ["Targets/Demo/Sources/**"],
            dependencies: [
                .project(target: "StoreInterface", path: "./"),
                .project(target: "Store", path: "./"),
                .project(target: "Common", path: "../../Common"),
                .project(target: "Mock", path: "../../Mock"),
                .external(name: "SnapKit")
            ]
        ),
        Target(
            name: "StoreInterface",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.store-interface",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Interface/Sources/**"],
            dependencies: [
                .project(target: "DependencyInjection", path: "../../DependencyInjection"),
                .project(target: "Model", path: "../../Common")
            ]
        )
    ],
    schemes: [
        Scheme(
            name: "Store",
            buildAction: BuildAction(targets: ["Store"])
        ),
        Scheme(
            name: "StoreDemo",
            buildAction: BuildAction(targets: ["StoreDemo", "Store"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: true
            ),
            archiveAction: .archiveAction(configuration: .debug)
        ),
    ]
)

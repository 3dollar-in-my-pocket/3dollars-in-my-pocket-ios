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
    name: "Write",
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
            name: "Write",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.write",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Write/Sources/**"],
            resources: ["Targets/Write/Resources/**"],
            dependencies: [
                .Core.networking,
                .Core.common,
                .Core.model,
                .Core.dependencyInjection,
                .Core.log,
                .Interface.appInterface,
                .Interface.storeInterface,
                .Interface.writeInterface,
                .designSystem,
                .external(name: "SnapKit"),
                .external(name: "Then"),
                .external(name: "PanModal")
            ]
        ),
        Target(
            name: "WriteDemo",
            platform: .iOS,
            product: .app,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.write-demo",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: "Targets/Demo/Info.plist",
            sources: ["Targets/Demo/Sources/**"],
            dependencies: [
                .project(target: "Write", path: "./")
            ]
        ),
        Target(
            name: "WriteInterface",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.write-interface",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Interface/Sources/**"],
            dependencies: [
                .Core.dependencyInjection,
                .Core.model
            ]
        )
    ],
    schemes: [
        Scheme(
            name: "Write",
            buildAction: BuildAction(targets: ["Write"])
        ),
        Scheme(
            name: "WriteDemo",
            buildAction: BuildAction(targets: ["WriteDemo", "Write"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: true
            ),
            archiveAction: .archiveAction(configuration: .debug)
        ),
    ]
)

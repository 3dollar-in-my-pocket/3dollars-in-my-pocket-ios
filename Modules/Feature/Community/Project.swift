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
    name: "Community",
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
            name: "Community",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.community",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Community/Sources/**"],
            resources: ["Targets/Community/Resources/**"],
            dependencies: [
                .Core.networking,
                .Core.common,
                .Core.model,
                .Core.dependencyInjection,
                .designSystem,
                .project(target: "CommunityInterface", path: "./"),
                .external(name: "SnapKit"),
                .external(name: "Then")
            ]
        ),
        Target(
            name: "CommunityDemo",
            platform: .iOS,
            product: .app,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.community-demo",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: "Targets/Demo/Info.plist",
            sources: ["Targets/Demo/Sources/**"],
            dependencies: [
                .project(target: "Community", path: "./")
            ]
        ),
        Target(
            name: "CommunityInterface",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.community-interface",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Interface/Sources/**"],
            dependencies: [
                .Core.model,
                .designSystem,
            ]
        )
    ],
    schemes: [
        Scheme(
            name: "Community",
            buildAction: BuildAction(targets: ["Community"])
        ),
        Scheme(
            name: "CommunityDemo",
            buildAction: BuildAction(targets: ["CommunityDemo", "Community"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: true
            ),
            archiveAction: .archiveAction(configuration: .debug)
        ),
    ]
)

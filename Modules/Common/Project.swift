import ProjectDescription

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
    name: "Common",
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
            name: "Common",
            platform: .iOS,
            product: .staticLibrary,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.common",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            sources: ["Targets/Common/Sources/**"],
            dependencies: [
                .external(name: "Kingfisher")
            ]
        ),
        Target(
            name: "Resource",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.resource",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            resources: ["Targets/Resource/Resources/**"]
        ),
        Target(
            name: "Model",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.model",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            sources: ["Targets/Model/Sources/**"],
            dependencies: [
                .project(target: "Networking", path: "../Network")
            ]
        )
    ]
)

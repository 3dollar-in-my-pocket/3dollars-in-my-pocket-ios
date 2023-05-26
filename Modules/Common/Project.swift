import ProjectDescription

struct Version {
    static let version: SettingValue = "1.0.0"
    static let buildNumber: SettingValue = "1"
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
            sources: ["Sources/**"],
            dependencies: []
        )
    ]
)

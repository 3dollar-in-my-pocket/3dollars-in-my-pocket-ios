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
    name: "Membership-Demo",
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
            name: "Membership-Demo",
            platform: .iOS,
            product: .app,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.membership-demo",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: "Info.plist",
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Membership", path: "../")
            ]
        )
    ]
)

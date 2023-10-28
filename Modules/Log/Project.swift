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
    name: "Log",
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
            name: "Log",
            platform: .iOS,
            product: .staticLibrary,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.log",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "AppInterface", path: "../../App")
            ]
        )
    ],
    schemes: [
        Scheme(
            name: "Log",
            buildAction: BuildAction(targets: ["Log"])
        )
    ]
)


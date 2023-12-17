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
    name: "Mock",
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
            name: "Mock",
            platform: .iOS,
            product: .staticLibrary,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.mock",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "AppInterface", path: "../../App"),
                .project(target: "DependencyInjection", path: "../DependencyInjection"),
            ]
        )
    ],
    schemes: [
        Scheme(
            name: "Mock",
            buildAction: BuildAction(targets: ["Mock"])
        )
    ]
)

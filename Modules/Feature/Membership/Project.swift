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
    name: "Membership",
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
            name: "Membership",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.membership",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/Membership/Sources/**"],
            resources: ["Targets/Membership/Resources/**"],
            dependencies: [
                .project(target: "Networking", path: "../../Network"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Common", path: "../../Common"),
                .project(target: "Resource", path: "../../Common"),
                .project(target: "Model", path: "../../Common"),
                .project(target: "DependencyInjection", path: "../../DependencyInjection"),
                .project(target: "AppInterface", path: "../../../App"),
                .project(target: "MembershipInterface", path: "./"),
                .project(target: "Log", path: "../../Log"),
                .external(name: "SnapKit"),
                .external(name: "Then")
            ]
        ),
        Target(
            name: "MembershipDemo",
            platform: .iOS,
            product: .app,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.membership-demo",
            deploymentTarget: .iOS(targetVersion: Version.targetVersion, devices: .iphone),
            infoPlist: "Targets/Demo/Info.plist",
            sources: ["Targets/Demo/Sources/**"],
            dependencies: [
                .project(target: "Membership", path: "./")
            ]
        ),
        Target(
            name: "MembershipInterface",
            platform: .iOS,
            product: .framework,
            bundleId: "com.macgongmon.-dollar-in-my-pocket.membership-interface",
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
            name: "Membership",
            buildAction: BuildAction(targets: ["Membership"])
        ),
        Scheme(
            name: "MembershipDemo",
            buildAction: BuildAction(targets: ["MembershipDemo", "Membership"]),
            runAction: .runAction(
                configuration: .debug,
                attachDebugger: true
            ),
            archiveAction: .archiveAction(configuration: .debug)
        ),
    ]
)

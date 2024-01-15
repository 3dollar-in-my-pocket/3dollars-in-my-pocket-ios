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
                .Core.networking,
                .Core.common,
                .Core.resource,
                .Core.model,
                .Core.dependencyInjection,
                .Core.log,
                .Interface.appInterface,
                .Interface.membershipInterface,
                .designSystem,
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
                .Core.dependencyInjection,
                .Core.model
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

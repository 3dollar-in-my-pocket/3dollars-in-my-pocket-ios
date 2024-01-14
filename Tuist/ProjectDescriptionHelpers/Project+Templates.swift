import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    /// Helper function to create the Project for this ExampleApp
//    public static func app(name: String, platform: Platform, additionalTargets: [String]) -> Project {
//        var targets = makeAppTargets(name: name,
//                                     platform: platform,
//                                     dependencies: additionalTargets.map { TargetDependency.target(name: $0) })
//        targets += additionalTargets.flatMap({ makeFrameworkTargets(name: $0, platform: platform) })
//        return Project(name: name,
//                       organizationName: "tuist.io",
//                       targets: targets)
//    }
    
    public static func makeModule(
        name: String,
        product: Product,
        package: [Package] = [],
        includeSource: Bool = true,
        includeResource: Bool = false,
        dependencies: [ProjectDescription.TargetDependency]
    ) -> Project {
        return Project(
            name: name,
            organizationName: DefaultSetting.organizaationName,
            packages: package,
            settings: .settings(
                base: DefaultSetting.baseProductSetting,
                configurations: [
                    .debug(name: .debug),
                    .release(name: .release)
                ]
            ),
            targets: [
                Target(
                    name: name,
                    platform: .iOS,
                    product: product,
                    bundleId: DefaultSetting.bundleId(moduleName: name),
                    deploymentTarget: .iOS(
                        targetVersion: DefaultSetting.targetVersion.stringValue,
                        devices: .iphone
                    ),
                    sources: includeSource ? ["Sources/**"] : nil,
                    resources: includeResource ? ["Resources/**"] : nil,
                    dependencies: dependencies
                )
            ],
            schemes: [
                Scheme(
                    name: name,
                    buildAction: BuildAction(targets: [.project(path: ".", target: name)])
                )
            ]
        )
    }

    private static func makeFeatureModule(
        name: String,
        dependencies: [TargetDependency],
        includeDemo: Bool = false
    ) -> [Target] {
        var targets: [Target] = []
        // TODO: 여기 변경 필요
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
        ]
        
        let mainTarget = Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: DefaultSetting.bundleId(moduleName: name),
            infoPlist: .file(path: .relativeToCurrentFile("Targets/\(name)/")),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )
        targets.append(mainTarget)
        
        let interfaceTarget = Target(
            name: "\(name)Interface",
            platform: .iOS,
            product: .framework,
            bundleId: DefaultSetting.bundleId(moduleName: name) + "-interface",
            infoPlist: .default,
            sources: ["Targets/Interface/Sources/**"],
            dependencies: [
                .Core.dependencyInjection,
                .Core.model
            ]
        )
        targets.append(interfaceTarget)

        if includeDemo {
            let demoTarget = Target(
                name: "\(name)Tests",
                platform: .iOS,
                product: .app,
                bundleId: DefaultSetting.bundleId(moduleName: name.lowercased()) + "-demo",
                infoPlist: "Targets/Demo/Info.plist",
                sources: ["Targets/Demo/Sources/**"],
                dependencies: [
                    .target(name: "\(name)")
            ])
            
            targets.append(demoTarget)
        }
        
        return targets
    }
}

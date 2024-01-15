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

    public static func makeFeatureModule(
        name: String,
        package: [Package] = [],
        dependencies: [TargetDependency],
        includeInterface: Bool = true,
        includeDemo: Bool = false
    ) -> Project {
        var targets: [Target] = []
        var schemes: [Scheme] = []
        
        let mainTarget = Target(
            name: name,
            platform: .iOS,
            product: .framework,
            bundleId: DefaultSetting.bundleId(moduleName: name),
            infoPlist: "Targets/\(name)/Info.plist",
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )
        targets.append(mainTarget)
        
        let mainScheme = Scheme(
            name: name,
            buildAction: BuildAction(targets: ["\(name)"])
        )
        schemes.append(mainScheme)
        
        if includeInterface {
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
        }

        if includeDemo {
            let demoTarget = Target(
                name: "\(name)Demo",
                platform: .iOS,
                product: .app,
                bundleId: DefaultSetting.bundleId(moduleName: name.lowercased()) + "-demo",
                infoPlist: "Targets/Demo/Info.plist",
                sources: ["Targets/Demo/Sources/**"],
                dependencies: [
                    .project(target: "\(name)", path: "./")
                ]
            )
            
            targets.append(demoTarget)
            
            let demoScheme = Scheme(
                name: name + "Demo",
                buildAction: BuildAction(targets: ["\(name)", "\(name)Demo"]),
                runAction: .runAction(
                    configuration: .debug,
                    attachDebugger: true
                )
            )
            schemes.append(demoScheme)
        }
        
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
            targets: targets,
            schemes: schemes
        )
    }
}

import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
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
            organizationName: DefaultSetting.organizationName,
            packages: package,
            settings: .settings(
                base: DefaultSetting.baseProductSetting,
                configurations: [
                    .debug(name: .debug),
                    .release(name: .release)
                ]
            ),
            targets: [
                .target(
                    name: name,
                    destinations: .iOS,
                    product: product,
                    bundleId: DefaultSetting.bundleId(moduleName: name),
                    deploymentTargets: .iOS(DefaultSetting.targetVersion.stringValue),
                    sources: includeSource ? ["Sources/**"] : nil,
                    resources: includeResource ? ["Resources/**"] : nil,
                    dependencies: dependencies
                )
            ],
            schemes: [
                .scheme(
                    name: name,
                    buildAction: .buildAction(targets: [.project(path: ".", target: name)])
                )
            ]
        )
    }

    public static func makeFeatureModule(
        name: String,
        package: [Package] = [],
        dependencies: [TargetDependency],
        includeInterface: Bool,
        includeDemo: Bool
    ) -> Project {
        var targets: [Target] = []
        var schemes: [Scheme] = []
        
        let mainTarget: Target = .target(
            name: name,
            destinations: .iOS,
            product: .framework,
            bundleId: DefaultSetting.bundleId(moduleName: name),
            infoPlist: "Targets/\(name)/Info.plist",
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )
        targets.append(mainTarget)
        
        let mainScheme: Scheme = .scheme(
            name: name,
            buildAction: .buildAction(targets: ["\(name)"])
        )
        schemes.append(mainScheme)
        
        if includeInterface {
            let interfaceTarget: Target = .target(
                name: "\(name)Interface",
                destinations: .iOS,
                product: .framework,
                bundleId: DefaultSetting.bundleId(moduleName: name) + "-interface",
                infoPlist: .default,
                sources: ["Targets/Interface/Sources/**"],
                dependencies: [
                    .Core.dependencyInjection,
                    .Core.model,
                    .Core.common,
                    .Core.networking
                ]
            )
            targets.append(interfaceTarget)
        }

        if includeDemo {
            let demoTarget: Target = .target(
                name: "\(name)Demo",
                destinations: .iOS,
                product: .app,
                bundleId: DefaultSetting.bundleId(moduleName: name.lowercased()) + "-demo",
                infoPlist: "Targets/Demo/Info.plist",
                sources: ["Targets/Demo/Sources/**"],
                dependencies: [
                    .project(target: "\(name)", path: "./"),
                    .mock,
                    .SPM.snapKit
                ]
            )
            
            targets.append(demoTarget)
            
            let demoScheme: Scheme = .scheme(
                name: name + "Demo",
                buildAction: .buildAction(targets: ["\(name)Demo", "\(name)"]),
                runAction: .runAction(
                    configuration: .debug,
                    attachDebugger: true
                )
            )
            schemes.append(demoScheme)
        }
        
        return Project(
            name: name,
            organizationName: DefaultSetting.organizationName,
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

import Foundation
import ProjectDescription

public final class ModuleProvider {
    public class func makeModule(
        name: String,
        product: Product,
        dependencise: [ProjectDescription.TargetDependency]
    ) -> Project {
        return Project(
            name: name,
            organizationName: DefaultSetting.organizaationName,
            packages: [],
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
                    deploymentTarget: .iOS(targetVersion: DefaultSetting.targetVersion.stringValue, devices: .iphone),
                    sources: ["Sources/**"],
                    dependencies: dependencise
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
}

import ProjectDescription

public extension TargetDependency {
    static let appInterface = TargetDependency.project(
        target: "AppInterface",
        path: .relativeToRoot("./App")
    )
    
    static let dependencyInjection = TargetDependency.project(
        target: "DependencyInjection",
        path: .relativeToRoot("./Modules/DependencyInjection")
    )
}

import ProjectDescription
import ProjectDescriptionHelpers

let name = "Mock"

let projdct = Project.makeModule(
    name: name,
    product: .staticLibrary,
    dependencies: [
        .Core.dependencyInjection,
        .Interface.appInterface,
        .Core.designSystem
    ]
)

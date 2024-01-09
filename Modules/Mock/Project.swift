import ProjectDescription
import ProjectDescriptionHelpers

let name = "Mock"

let projdct = Project.makeModule(
    name: name,
    product: .staticLibrary,
    dependencies: [
        .Interface.appInterface,
        .Core.dependencyInjection
    ]
)

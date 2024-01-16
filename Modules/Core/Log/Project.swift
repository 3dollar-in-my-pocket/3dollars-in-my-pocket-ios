import ProjectDescription
import ProjectDescriptionHelpers

let name = "Log"

let project = Project.makeModule(
    name: name,
    product: .staticLibrary,
    dependencies: [
        .Core.dependencyInjection,
        .Interface.appInterface
    ]
)

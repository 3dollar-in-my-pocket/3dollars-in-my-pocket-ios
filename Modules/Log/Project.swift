import ProjectDescription
import ProjectDescriptionHelpers

let name = "Log"

let project = Project.makeModule(
    name: name,
    product: .staticLibrary,
    dependencies: [
        .Interface.appInterface
    ]
)

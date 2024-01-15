import ProjectDescription
import ProjectDescriptionHelpers

let name = "Networking"

let project = Project.makeModule(
    name: name,
    product: .framework,
    dependencies: [
        .Core.common,
        .designSystem
    ]
)

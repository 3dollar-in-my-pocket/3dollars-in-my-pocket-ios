import ProjectDescription
import ProjectDescriptionHelpers

let name = "Resource"

let project = Project.makeModule(
    name: name,
    product: .framework,
    includeSource: false,
    includeResource: true,
    dependencies: []
)

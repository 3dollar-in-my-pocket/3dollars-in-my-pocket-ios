import ProjectDescription
import ProjectDescriptionHelpers

let name = "Model"

let project = Project.makeModule(
    name: name,
    product: .framework,
    includeResource: false,
    dependencies: []
)

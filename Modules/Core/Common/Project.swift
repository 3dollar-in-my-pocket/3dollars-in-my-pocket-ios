import ProjectDescription
import ProjectDescriptionHelpers

let name = "Common"

let project = Project.makeModule(
    name: name,
    product: .framework,
    includeResource: false,
    dependencies: [
        .Core.model,
        .Core.log,
        .Core.dependencyInjection,
        .Interface.appInterface,
        .SPM.kingfisher
    ]
)

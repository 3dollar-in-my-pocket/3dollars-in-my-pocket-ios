import ProjectDescription
import ProjectDescriptionHelpers

let name = "DependencyInjection"

let project = Project.makeModule(
    name: name,
    product: .framework,
    dependencies: [
        .SPM.swinject
    ]
)

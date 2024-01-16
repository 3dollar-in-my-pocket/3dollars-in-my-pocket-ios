import ProjectDescription
import ProjectDescriptionHelpers

let name = "DesignSystem"

let project = Project.makeModule(
    name: name,
    product: .framework,
    includeResource: true,
    dependencies: [
        .SPM.lottie
    ]
)

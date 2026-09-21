import ProjectDescription
import ProjectDescriptionHelpers

let name = "SDU"

let project = Project.makeModule(
    name: name,
    product: .framework,
    includeResource: true,
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.designSystem,
        .SPM.snapKit,
        .SPM.kingfisher,
        .SPM.combineCocoa
    ]
)

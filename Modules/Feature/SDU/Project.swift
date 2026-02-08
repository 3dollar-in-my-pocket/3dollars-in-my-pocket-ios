import ProjectDescription
import ProjectDescriptionHelpers

let name = "SDU"

let project = Project.makeFeatureModule(
    name: name,
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.designSystem,
        .SPM.snapKit,
        .SPM.kingfisher,
        .SPM.combineCocoa
    ],
    includeInterface: true,
    includeDemo: true
)

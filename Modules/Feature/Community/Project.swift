import ProjectDescription
import ProjectDescriptionHelpers

let name = "Community"

let project = Project.makeFeatureModule(
    name: name,
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.dependencyInjection,
        .Core.designSystem,
        .Interface.communityInterface,
        .SPM.snapKit,
        .SPM.then
    ],
    includeInterface: true,
    includeDemo: true
)

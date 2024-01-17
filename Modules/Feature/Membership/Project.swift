import ProjectDescription
import ProjectDescriptionHelpers

let name = "Membership"

let project = Project.makeFeatureModule(
    name: name,
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.dependencyInjection,
        .Core.log,
        .Core.designSystem,
        .Interface.appInterface,
        .Interface.membershipInterface,
        .SPM.snapKit,
        .SPM.then
    ],
    includeInterface: true,
    includeDemo: true
)

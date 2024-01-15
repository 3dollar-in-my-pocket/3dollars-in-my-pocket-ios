import ProjectDescription
import ProjectDescriptionHelpers

let name = "Home"

let project = Project.makeFeatureModule(
    name: name,
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.log,
        .Interface.appInterface,
        .Interface.storeInterface,
        .Interface.membershipInterface,
        .designSystem,
        .SPM.snapKit,
        .SPM.then,
        .SPM.panModal
    ],
    includeInterface: false,
    includeDemo: true
)

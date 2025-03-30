import ProjectDescription
import ProjectDescriptionHelpers

let name = "Feed"

let project = Project.makeFeatureModule(
    name: name,
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.log,
        .Core.designSystem,
        .Interface.appInterface,
        .Interface.membershipInterface,
        .Interface.storeInterface,
        .Interface.feedInterface,
        .SPM.snapKit,
        .SPM.combineCocoa,
        .SPM.kingfisher
    ],
    includeInterface: true,
    includeDemo: true
)

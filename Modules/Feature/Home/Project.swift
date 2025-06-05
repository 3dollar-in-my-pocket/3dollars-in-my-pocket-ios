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
        .Core.designSystem,
        .Interface.appInterface,
        .Interface.storeInterface,
        .Interface.membershipInterface,
        .Interface.feedInterface,
        .SPM.snapKit,
        .SPM.then,
        .SPM.panModal,
        .SPM.combineCocoa,
        .SPM.kingfisher,
        .SPM.naverMap,
        .Feature.feed
    ],
    includeInterface: false,
    includeDemo: true
)

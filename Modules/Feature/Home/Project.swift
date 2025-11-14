import ProjectDescription
import ProjectDescriptionHelpers

let name = "Home"

let project = Project.makeFeatureModule(
    name: name,
    package: [
        .naverMap
    ],
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
        .Package.naverMap,
        .Feature.feed
    ],
    includeInterface: false,
    includeDemo: true
)

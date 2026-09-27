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
        .Interface.writeInterface,
        .SPM.snapKit,
        .SPM.panModal,
        .SPM.combineCocoa,
        .SPM.kingfisher,
        .SPM.floatingPanel,
        .Package.naverMap
    ],
    includeInterface: false,
    includeDemo: true
)

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
        .SPM.snapKit,
        .SPM.then,
        .SPM.panModal,
        .SPM.combineCocoa,
        .Framework.naverMap,
        .Framework.naverGeometry
    ],
    includeInterface: false,
    includeDemo: true
)

import ProjectDescription
import ProjectDescriptionHelpers

let name = "Write"

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
        .Interface.storeInterface,
        .Interface.writeInterface,
        .SPM.snapKit,
        .SPM.then,
        .SPM.panModal,
        .Framework.naverMap,
        .Framework.naverGeometry
    ],
    includeInterface: true,
    includeDemo: true
)

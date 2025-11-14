import ProjectDescription
import ProjectDescriptionHelpers

let name = "Store"

let project = Project.makeFeatureModule(
    name: name,
    package: [
        .naverMap
    ],
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.dependencyInjection,
        .Core.designSystem,
        .Interface.appInterface,
        .Interface.storeInterface,
        .Interface.writeInterface,
        .SPM.snapKit,
        .SPM.then,
        .SPM.panModal,
        .SPM.combineCocoa,
        .Package.naverMap,
    ],
    includeInterface: true,
    includeDemo: true
)

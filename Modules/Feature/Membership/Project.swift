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
        .Interface.myPageInterface,
        .SPM.snapKit,
        .SPM.then,
        .SPM.combineCocoa
    ],
    includeInterface: true,
    includeDemo: true
)

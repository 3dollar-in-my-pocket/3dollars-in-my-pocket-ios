import ProjectDescription
import ProjectDescriptionHelpers

let name = "MyPage"

let project = Project.makeFeatureModule(
    name: name,
    dependencies: [
        .Core.networking,
        .Core.common,
        .Core.model,
        .Core.dependencyInjection,
        .Core.designSystem,
        .Interface.appInterface,
        .Interface.myPageInterface,
        .Interface.storeInterface,
        .Interface.membershipInterface,
        .SPM.snapKit,
        .SPM.then,
        .Package.deviceKit
    ],
    includeInterface: true,
    includeDemo: true
)

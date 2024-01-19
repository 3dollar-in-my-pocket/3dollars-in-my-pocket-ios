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
        .SPM.snapKit,
        .SPM.then
    ],
    includeInterface: true,
    includeDemo: true
)

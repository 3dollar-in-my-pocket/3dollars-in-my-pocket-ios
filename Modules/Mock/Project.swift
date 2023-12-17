import ProjectDescription
import ProjectDescriptionHelpers

let project = ModuleProvider.makeModule(
    name: "Mock",
    product: .staticLibrary,
    dependencise: [
        .appInterface,
        .dependencyInjection
    ]
)

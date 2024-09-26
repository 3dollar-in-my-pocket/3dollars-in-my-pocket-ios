import Foundation

import AppInterface
import DependencyInjection

struct AppInformationImpl: AppInformation {
    var bundleId: String {
        return Bundle.bundleId
    }
}

extension AppInformationImpl {
    static func registerAppInformation() {
        DIContainer.shared.container.register(AppInformation.self) { _ in
            return AppInformationImpl()
        }
    }
}

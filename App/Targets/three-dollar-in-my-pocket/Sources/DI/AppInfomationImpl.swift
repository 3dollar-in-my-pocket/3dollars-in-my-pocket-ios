import Foundation

import DependencyInjection

struct AppInfomationImpl: AppInfomation {
    var bundleId: String {
        return Bundle.bundleId
    }
}

extension AppInfomationImpl {
    static func registerAppInfomation() {
        DIContainer.shared.container.register(AppInfomation.self) { _ in
            return AppInfomationImpl()
        }
    }
}

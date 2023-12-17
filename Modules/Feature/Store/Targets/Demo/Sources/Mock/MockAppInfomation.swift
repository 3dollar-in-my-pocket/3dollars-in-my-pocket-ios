import Foundation

import AppInterface
import DependencyInjection

struct MockAppInfomationImpl: AppInfomation {
    var bundleId: String {
        return "com.macgongmon.-dollar-in-my-pocket-debug"
    }
}

extension MockAppInfomationImpl {
    static func registerAppInfomation() {
        DIContainer.shared.container.register(AppInfomation.self) { _ in
            return MockAppInfomationImpl()
        }
    }
}



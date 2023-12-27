import Foundation

import AppInterface
import DependencyInjection

public struct MockAppInfomationImpl: AppInfomation {
    public var bundleId: String {
        return "com.macgongmon.-dollar-in-my-pocket-debug"
    }
}

extension MockAppInfomationImpl {
    public static func registerAppInfomation() {
        DIContainer.shared.container.register(AppInfomation.self) { _ in
            return MockAppInfomationImpl()
        }
    }
}



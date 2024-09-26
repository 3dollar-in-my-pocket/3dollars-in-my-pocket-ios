import Foundation

import AppInterface
import DependencyInjection

public struct MockAppInformationImpl: AppInformation {
    public var bundleId: String {
        return "com.macgongmon.-dollar-in-my-pocket-debug"
    }
}

extension MockAppInformationImpl {
    public static func registerAppInformation() {
        DIContainer.shared.container.register(AppInformation.self) { _ in
            return MockAppInformationImpl()
        }
    }
}



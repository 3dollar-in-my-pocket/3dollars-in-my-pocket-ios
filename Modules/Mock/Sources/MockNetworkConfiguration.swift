import Model

import DependencyInjection

public struct MockNetworkConfiguration: NetworkConfigurable {
    public var endPoint: String {
        return "https://dev.threedollars.co.kr"
    }
    
    public var timeoutForRequest: Double {
        return 15
    }
    
    public var timeoutForResource: Double {
        return 30
    }
    
    public var appStoreVersion: String? {
        return "3.4.0"
    }
    
    public var userAgent: String {
        return "3.4.0 (com.macgongmon.-dollar-in-my-pocket-debug; build:1; iOS 16.6.0)"
    }
    
    public var authToken: String? {
        return "03572dd2-cc32-413c-baf2-e1e08048f4d4"
    }
}

extension MockNetworkConfiguration {
    public static func registerNetworkConfiguration() {
        DIContainer.shared.container.register(NetworkConfigurable.self) { _ in
            return MockNetworkConfiguration()
        }
    }
}

import Model

import DependencyInjection

struct MockNetworkConfiguration: NetworkConfigurable {
    var endPoint: String {
        return "https://dev.threedollars.co.kr"
    }
    
    var timeoutForRequest: Double {
        return 15
    }
    
    var timeoutForResource: Double {
        return 30
    }
    
    var appStoreVersion: String? {
        return "3.4.0"
    }
    
    var userAgent: String {
        return "3.4.0 (com.macgongmon.-dollar-in-my-pocket-debug; build:1; iOS 16.6.0)"
    }
    
    var authToken: String? {
        return nil
    }
}

extension MockNetworkConfiguration {
    static func registerNetworkConfiguration() {
        DIContainer.shared.container.register(NetworkConfigurable.self) { _ in
            return MockNetworkConfiguration()
        }
    }
}

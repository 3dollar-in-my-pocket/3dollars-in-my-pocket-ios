import Foundation

import DependencyInjection
import Model
import Common

struct NetworkConfigurationImpl: NetworkConfigurable {
    var endPoint: String {
        return HTTPUtils.url
    }
    
    var timeoutForRequest: Double {
        return 4
    }
    
    var timeoutForResource: Double {
        return 30
    }
    
    var appStoreVersion: String? {
        let info = Bundle.main.infoDictionary
        let appVersion = info?["CFBundleShortVersionString"] as? String
        
        return appVersion
    }
    
    var userAgent: String {
        return HTTPUtils.userAgent
    }
    
    var authToken: String? {
        return Preference.shared.authToken
    }
}

extension NetworkConfigurationImpl {
    static func registerNetworkConfiguration() {
        DIContainer.shared.container.register(NetworkConfigurable.self) { _ in
            return NetworkConfigurationImpl()
        }
    }
}

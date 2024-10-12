import Foundation
import CoreLocation

import DependencyInjection
import Model
import Common

struct NetworkConfigurationImpl: NetworkConfigurable {
    var endPoint: String {
        return HTTPUtils.url
    }
    
    var timeoutForRequest: Double {
        return 8
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
    
    var userCurrentLocation: CLLocation {
        return Preference.shared.userCurrentLocation
    }
}

extension NetworkConfigurationImpl {
    static func registerNetworkConfiguration() {
        DIContainer.shared.container.register(NetworkConfigurable.self) { _ in
            return NetworkConfigurationImpl()
        }
    }
}

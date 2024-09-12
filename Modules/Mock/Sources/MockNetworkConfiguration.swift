import Model
import CoreLocation

import DependencyInjection

public final class MockNetworkConfiguration: NetworkConfigurable {
    public var endPoint: String
    public var timeoutForRequest: Double
    public var timeoutForResource: Double
    public var appStoreVersion: String?
    public var userAgent: String
    public var authToken: String?
    public var userCurrentLocation: CLLocation
    
    public init(
        endPoint: String = "https://dev.threedollars.co.kr",
        timeoutForRequest: Double = 15,
        timeoutForResource: Double = 30,
        appStoreVersion: String? = "3.4.0",
        userAgent: String = "3.4.0 (com.macgongmon.-dollar-in-my-pocket-debug; build:1; iOS 16.6.0)",
        authToken: String? = "03572dd2-cc32-413c-baf2-e1e08048f4d4",
        userCurrentLocation: CLLocation = CLLocation(latitude: 37.497941, longitude: 127.027616)
    ) {
        self.endPoint = endPoint
        self.timeoutForRequest = timeoutForRequest
        self.timeoutForResource = timeoutForResource
        self.appStoreVersion = appStoreVersion
        self.userAgent = userAgent
        self.authToken = authToken
        self.userCurrentLocation = userCurrentLocation
    }
}

extension MockNetworkConfiguration {
    public static func registerNetworkConfiguration(_ configuration: MockNetworkConfiguration = MockNetworkConfiguration()) {
        DIContainer.shared.container.register(NetworkConfigurable.self) { _ in
            return configuration
        }
    }
}

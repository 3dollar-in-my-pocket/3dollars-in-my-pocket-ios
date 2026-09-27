import Foundation
import CoreLocation

import Common

/// LocationManagerProtocol 목. `getCurrentLocation()` 만 스텁한다.
/// `getCurrentLocationPublisher()` 는 실제 CLLocationManager 를 감싼 타입이라 스텁할 수 없으므로 테스트에서 구독하지 않는다.
final class MockLocationManager: LocationManagerProtocol {
    var getCurrentLocationResult: Result<CLLocation, Error>
    private(set) var getCurrentLocationCallCount = 0

    init(getCurrentLocationResult: Result<CLLocation, Error> = .failure(MockError.notStubbed())) {
        self.getCurrentLocationResult = getCurrentLocationResult
    }

    func getCurrentLocationPublisher() -> LocationManager.LocationPublisher {
        LocationManager.shared.getCurrentLocationPublisher()
    }

    func getCurrentLocation() async throws -> CLLocation {
        getCurrentLocationCallCount += 1
        return try getCurrentLocationResult.get()
    }
}

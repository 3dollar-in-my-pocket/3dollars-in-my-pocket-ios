import CoreLocation
import Combine

protocol CombineLocationManagerProtocol {
    func getCurrentLocation() -> AnyPublisher<CLLocation, Error>
}

final class CombineLocationManager: NSObject, CombineLocationManagerProtocol {
    static let shared = CombineLocationManager()
    fileprivate var locationPublisher = PassthroughSubject<CLLocation, Error>()
    private var manager = CLLocationManager()
    
    override init() {
        super.init()
        
        self.manager.delegate = self
    }
    
    func getCurrentLocation() -> AnyPublisher<CLLocation, Error> {
        if CLLocationManager.locationServicesEnabled() {
            if manager.authorizationStatus == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else {
                locationPublisher = PassthroughSubject<CLLocation, Error>()
                manager.startUpdatingLocation()
            }
            
            return locationPublisher.eraseToAnyPublisher()
        } else {
            return Fail(error: LocationError.disableLocationService).eraseToAnyPublisher()
        }
    }
}

extension CombineLocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            self.locationPublisher.send(completion: .failure(LocationError.denied))
            
        case .authorizedAlways, .authorizedWhenInUse:
            self.manager.startUpdatingHeading()
            
        case .notDetermined:
            self.manager.requestWhenInUseAuthorization()
            
        default:
            self.locationPublisher.send(completion: .failure(LocationError.unknown))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.manager.stopUpdatingHeading()
        
        guard let lastLocation = locations.last else {
            self.locationPublisher.send(completion: .failure(LocationError.unknown))
            return
        }
        
        self.locationPublisher.send(lastLocation)
        self.locationPublisher.send(completion: .finished)
    }
}

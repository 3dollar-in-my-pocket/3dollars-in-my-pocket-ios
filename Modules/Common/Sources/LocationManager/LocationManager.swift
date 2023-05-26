import Foundation
import CoreLocation
import Combine

public protocol LocationManagerProtocol {
    func getCurrentLocationPublisher() -> LocationManager.LocationPublisher
}

public class LocationManager: NSObject, LocationManagerProtocol {
    public static let shared = LocationManager()
    
    public func getCurrentLocationPublisher() -> LocationPublisher {
        return LocationPublisher()
    }
}

extension LocationManager {
    public struct LocationPublisher: Publisher {
        public typealias Output = CLLocation
        public typealias Failure = Error
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = LocationSubscription(subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
        
        final class LocationSubscription<S: Subscriber> : NSObject, CLLocationManagerDelegate, Subscription where S.Input == Output, S.Failure == Failure{
            var subscriber: S
            var locationManager = CLLocationManager()
            
            init(subscriber: S) {
                self.subscriber = subscriber
                super.init()
                locationManager.delegate = self
            }
            
            func request(_ demand: Subscribers.Demand) {
                DispatchQueue.global().async { [weak self] in
                    if CLLocationManager.locationServicesEnabled() {
                        if self?.locationManager.authorizationStatus == .notDetermined {
                            self?.locationManager.requestWhenInUseAuthorization()
                        } else {
                            self?.locationManager.startUpdatingLocation()
                        }
                    } else {
                        self?.subscriber.receive(completion: .failure(LocationError.disableLocationService))
                    }
                    self?.locationManager.startUpdatingLocation()
                    self?.locationManager.requestWhenInUseAuthorization()
                }
            }
            
            func cancel() {
                locationManager.stopUpdatingLocation()
            }
            
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                locationManager.stopUpdatingHeading()
                
                guard let lastLocation = locations.last else {
                    subscriber.receive(completion: .failure(LocationError.unknown))
                    return
                }
                
                _ = subscriber.receive(lastLocation)
            }
            
            func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
                switch manager.authorizationStatus {
                case .denied, .restricted:
                    subscriber.receive(completion: .failure(LocationError.denied))
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.startUpdatingHeading()
                    
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                    
                default:
                    subscriber.receive(completion: .failure(LocationError.unknown))
                }
            }
        }
    }
}

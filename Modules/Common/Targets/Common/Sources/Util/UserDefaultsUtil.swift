import Foundation
import CoreLocation

public final class UserDefaultsUtil {
    public static let shared = UserDefaultsUtil()
    
    private let instance: UserDefaults
    
    public init(name: String? = nil) {
        if let name {
            UserDefaults().removePersistentDomain(forName: name)
            instance = UserDefaults(suiteName: name)!
        } else {
            instance = UserDefaults.standard
        }
    }
    
    public var userCurrentLocation: CLLocation {
        set {
            instance.set(newValue.coordinate.latitude, forKey: "KEY_CURRENT_LATITUDE")
            instance.set(newValue.coordinate.longitude, forKey: "KEY_CURRENT_LONGITUDE")
        }
        get {
            let latitude = instance.double(forKey: "KEY_CURRENT_LATITUDE")
            let longitude = instance.double(forKey: "KEY_CURRENT_LONGITUDE")
            
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}

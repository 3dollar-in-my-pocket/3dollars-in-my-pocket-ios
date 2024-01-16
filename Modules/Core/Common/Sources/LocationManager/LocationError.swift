import Foundation

public enum LocationError: LocalizedError {
    case denied
    case unknown
    case unknownLocation
    case disableLocationService
}

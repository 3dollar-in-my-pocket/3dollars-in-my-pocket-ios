import Model
import Combine
import CoreLocation

public struct WriteAddressViewModelConfig {
    public let address: String
    public let location: CLLocation
    public let shouldSkipCheckingAround: Bool
    
    public init(
        address: String,
        location: CLLocation,
        shouldSkipCheckingAround: Bool
    ) {
        self.address = address
        self.location = location
        self.shouldSkipCheckingAround = shouldSkipCheckingAround
    }
}

public protocol WriteAddressViewModelInterface {
    var onFinishWriteAddress: PassthroughSubject<(address: String, location: CLLocation), Never> { get }
    
    init(config: WriteAddressViewModelConfig)
}

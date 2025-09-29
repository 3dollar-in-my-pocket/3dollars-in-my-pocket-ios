import Model
import Combine
import CoreLocation

public struct WriteAddressViewModelConfig {
    public let address: String
    public let location: CLLocation
    
    public init(address: String, location: CLLocation) {
        self.address = address
        self.location = location
    }
}

public protocol WriteAddressViewModelInterface {
    var onFinishWriteAddress: PassthroughSubject<(address: String, location: CLLocation), Never> { get }
    
    init(config: WriteAddressViewModelConfig)
}

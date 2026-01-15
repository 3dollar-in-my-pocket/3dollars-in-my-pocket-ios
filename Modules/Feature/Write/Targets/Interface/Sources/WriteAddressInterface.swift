import Model
import Combine
import CoreLocation

public struct WriteAddressViewModelConfig {
    public let address: String
    public let location: CLLocation
    public let storeId: String?

    public init(address: String, location: CLLocation, storeId: String? = nil) {
        self.address = address
        self.location = location
        self.storeId = storeId
    }
}

public protocol WriteAddressViewModelInterface {
    var onFinishWriteAddress: PassthroughSubject<(address: String, location: CLLocation), Never> { get }
    
    init(config: WriteAddressViewModelConfig)
}

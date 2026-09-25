import Foundation

import Model
import Networking

final class MockMapRepository: MapRepository {
    var getAddressFromLocationResult: Result<String, Error> = .failure(MockError.notStubbed())

    func getAddressFromLocation(latitude: Double, longitude: Double) async -> Result<String, Error> { getAddressFromLocationResult }
    func searchAddress(keyword: String) async -> Result<LocalResponse<PlaceDocument>, Error> { .failure(MockError.notStubbed()) }
    func getCurrentAddress(latitude: Double, longitude: Double) async -> Result<LocalResponse<AddressDocument>, Error> { .failure(MockError.notStubbed()) }
}

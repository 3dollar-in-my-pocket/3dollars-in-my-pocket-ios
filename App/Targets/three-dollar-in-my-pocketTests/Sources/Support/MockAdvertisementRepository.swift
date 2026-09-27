import Foundation

import Model
import Networking

final class MockAdvertisementRepository: AdvertisementRepository {
    var fetchAdvertisementsResult: Result<AdvertisementListResponse, Error> = .failure(MockError.notStubbed())

    func fetchAdvertisements(input: FetchAdvertisementInput) async -> Result<AdvertisementListResponse, Error> { fetchAdvertisementsResult }
}

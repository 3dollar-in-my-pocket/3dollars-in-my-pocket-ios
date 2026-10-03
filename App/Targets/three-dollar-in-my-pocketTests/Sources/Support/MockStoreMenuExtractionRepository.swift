import Foundation

import Model
import Networking

final class MockStoreMenuExtractionRepository: StoreMenuExtractionRepository {
    var extractStoreMenusResult: Result<StoreMenuExtractionListResponse, Error> = .failure(MockError.notStubbed())
    private(set) var requestedImages: [Data] = []

    init(extractStoreMenusResult: Result<StoreMenuExtractionListResponse, Error>? = nil) {
        if let extractStoreMenusResult {
            self.extractStoreMenusResult = extractStoreMenusResult
        }
    }

    func extractStoreMenus(image: Data) async -> Result<StoreMenuExtractionListResponse, Error> {
        requestedImages.append(image)
        return extractStoreMenusResult
    }
}

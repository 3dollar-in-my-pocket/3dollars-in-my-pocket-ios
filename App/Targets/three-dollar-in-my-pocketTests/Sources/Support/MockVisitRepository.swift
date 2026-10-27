import Foundation

import Model
import Networking

final class MockVisitRepository: VisitRepository {
    var deleteStoreVisitResult: Result<String?, Error> = .failure(MockError.notStubbed())
    private(set) var deletedVisitIds: [String] = []

    func visitStore(input: VisitStoreRequestInput) async -> Result<String?, Error> {
        .failure(MockError.notStubbed())
    }

    func deleteStoreVisit(visitId: String) async -> Result<String?, Error> {
        deletedVisitIds.append(visitId)
        return deleteStoreVisitResult
    }
}

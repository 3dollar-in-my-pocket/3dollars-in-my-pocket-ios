import Foundation

import Model
import Networking

final class MockServiceCreatorRepository: ServiceCreatorRepository {
    var listCreatorsResult: Result<ContentListCreatorGroupResponse, Error> = .failure(MockError.notStubbed())

    func listCreators() async -> Result<ContentListCreatorGroupResponse, Error> {
        return listCreatorsResult
    }
}

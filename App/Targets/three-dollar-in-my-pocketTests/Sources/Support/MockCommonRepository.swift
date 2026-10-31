import Foundation

import Model
import Networking

final class MockCommonRepository: CommonRepository {
    var createNonceTokenResult: Result<NonceResponse, Error> = .failure(MockError.notStubbed())

    func createNonceToken() async -> Result<NonceResponse, Error> {
        return createNonceTokenResult
    }
}

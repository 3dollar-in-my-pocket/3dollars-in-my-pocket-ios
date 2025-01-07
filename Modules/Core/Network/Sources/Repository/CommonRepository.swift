import Foundation

import Model

public protocol CommonRepository {
    func createNonceToken() async -> Result<NonceResponse, Error>
}

public final class CommonRepositoryImpl: CommonRepository {
    public init() { }
    
    public func createNonceToken() async -> Result<NonceResponse, any Error> {
        let request = CommonApi.createNonceToken
        
        return await  NetworkManager.shared.request(requestType: request)
    }
}

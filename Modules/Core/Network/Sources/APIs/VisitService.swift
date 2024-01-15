import Foundation

import Model

public protocol VisitServiceProtocol {
    func visitStore(storeId: Int, type: VisitType) async -> Result<String?, Error>
}

public struct VisitService: VisitServiceProtocol {
    public init() { }
    
    public func visitStore(storeId: Int, type: VisitType) async -> Result<String?, Error> {
        let input = VisitStoreRequestInput(storeId: storeId, visitType: type.rawValue)
        let request = VisitStoreRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}


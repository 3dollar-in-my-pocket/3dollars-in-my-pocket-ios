import Foundation

import Model

public protocol VisitRepository {
    func visitStore(input: VisitStoreRequestInput) async -> Result<String?, Error>

    func deleteStoreVisit(visitId: String) async -> Result<String?, Error>
}

public struct VisitRepositoryImpl: VisitRepository {
    public init() { }
    
    public func visitStore(input: VisitStoreRequestInput) async -> Result<String?, Error> {
        let request = VisitApi.visitStore(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }

    public func deleteStoreVisit(visitId: String) async -> Result<String?, Error> {
        let request = VisitApi.deleteStoreVisit(visitId: visitId)

        return await NetworkManager.shared.request(requestType: request)
    }
}

import Foundation

import Model

public protocol ServiceCreatorRepository {
    func listCreators() async -> Result<ContentListCreatorGroupResponse, Error>
}

public struct ServiceCreatorRepositoryImpl: ServiceCreatorRepository {
    public init() { }

    public func listCreators() async -> Result<ContentListCreatorGroupResponse, Error> {
        let request = ServiceCreatorApi.listCreators

        return await NetworkManager.shared.request(requestType: request)
    }
}

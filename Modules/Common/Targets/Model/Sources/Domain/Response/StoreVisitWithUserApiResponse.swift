import Foundation

public struct StoreVisitWithUserApiResponse: Decodable {
    public let visit: StoreVisitApiResponse
    public let visitor: UserApiResponse
}


import Foundation

public struct StoreVisitWithUserResponse: Decodable {
    public let visit: StoreVisitResponse
    public let visitor: UserResponse
}

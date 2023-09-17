import Foundation

public struct UserApiResponse: Decodable {
    public let userId: Int?
    public let name: String
    public let socialType: String?
    public let medal: MedalResponse
}

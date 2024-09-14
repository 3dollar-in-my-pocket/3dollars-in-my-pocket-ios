import Foundation

public struct UserResponse: Decodable {
    public let userId: Int?
    public let name: String
    public let socialType: SocialType?
    public let medal: MedalResponse
}

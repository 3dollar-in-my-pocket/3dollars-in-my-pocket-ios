import Foundation

public struct User: Hashable {
    public let userId: Int?
    public let name: String
    public let socialType: SocialType
    public let medal: Medal
    
    public init(response: UserResponse) {
        self.userId = response.userId
        self.name = response.name
        self.socialType = response.socialType ?? .unknown
        self.medal = Medal(response: response.medal)
    }
}

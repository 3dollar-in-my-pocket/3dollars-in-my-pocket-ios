import Foundation

public struct User: Hashable {
    public let userId: Int?
    public let name: String
    public let socialType: SocialType
    public let medal: Medal
    
    public init(response: UserApiResponse) {
        self.userId = response.userId
        self.name = response.name
        self.socialType = SocialType(value: response.socialType ?? "")
        self.medal = Medal(response: response.medal)
    }
}

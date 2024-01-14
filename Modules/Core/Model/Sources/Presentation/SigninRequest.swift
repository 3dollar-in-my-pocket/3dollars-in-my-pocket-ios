public struct SigninRequest {
    public let socialType: SocialType
    public let token: String
    
    public init(socialType: SocialType, token: String) {
        self.socialType = socialType
        self.token = token
    }
}

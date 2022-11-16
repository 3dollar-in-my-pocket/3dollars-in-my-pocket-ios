struct SigninRequest {
    let socialType: SocialType
    let token: String
    
    var parameters: [String: Any] {
        return [
            "socialType": self.socialType.value,
            "token": self.token
        ]
    }
}

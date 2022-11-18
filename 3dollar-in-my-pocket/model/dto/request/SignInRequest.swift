struct SigninRequest: Requestable {
    let socialType: SocialType
    let token: String
    
    var params: [String : Any] {
        return [
            "socialType": self.socialType.value,
            "token": self.token
        ]
    }
}

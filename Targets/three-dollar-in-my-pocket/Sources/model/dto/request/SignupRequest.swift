struct SignupRequest {
    let name: String
    let socialType: SocialType
    let token: String
    
    var parameters: [String: Any] {
        return [
            "name": name,
            "socialType": socialType.value,
            "token": token
        ]
    }
}

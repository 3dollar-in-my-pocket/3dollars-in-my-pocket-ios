struct User {
    
    let name: String
    let userId: Int
    let socialType: SocialType
    let activity: UserActivity
    
    
    init() {
        self.name = ""
        self.userId = -1
        self.socialType = .KAKAO
        self.activity = UserActivity()
    }
    
    init(response: UserInfoResponse) {
        self.name = response.name
        self.userId = response.userId
        self.socialType = response.socialType
        self.activity = UserActivity()
    }
    
    init(response: UserWithActivityResponse) {
        self.name = response.name
        self.userId = response.userId
        self.socialType = response.socialType
        self.activity = UserActivity(response: response.activity)
    }
}

struct User {
    let name: String
    let userId: Int
    let socialType: SocialType
    let activity: UserActivity
    var medal: Medal
    
    
    init() {
        self.name = ""
        self.userId = -1
        self.socialType = .KAKAO
        self.activity = UserActivity()
        self.medal = Medal()
    }
    
    init(response: UserInfoResponse) {
        self.name = response.name
        self.userId = response.userId
        self.socialType = response.socialType
        self.activity = UserActivity()
        self.medal = Medal(response: response.medal)
    }
    
    init(response: UserWithActivityResponse) {
        self.name = response.name
        self.userId = response.userId
        self.socialType = response.socialType
        self.activity = UserActivity(response: response.activity)
        self.medal = Medal(response: response.medal)
    }
}

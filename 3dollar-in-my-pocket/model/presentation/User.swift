struct User: Equatable {
    let name: String
    let userId: Int
    let socialType: SocialType
    let activity: UserActivity
    var medal: Medal
    var pushInfo: PushInfo
    var marketingConsent: MarketingConsentType
    
    init() {
        self.name = ""
        self.userId = -1
        self.socialType = .unknown
        self.activity = UserActivity()
        self.medal = Medal()
        self.pushInfo = PushInfo()
        self.marketingConsent = .unknown
    }
    
    init(response: UserInfoResponse) {
        self.name = response.name
        self.userId = response.userId
        self.socialType = SocialType(value: response.socialType)
        self.activity = UserActivity()
        self.medal = Medal(response: response.medal)
        self.pushInfo = PushInfo(response: response.device)
        self.marketingConsent = MarketingConsentType(value: response.marketingConsent)
    }
    
    init(response: UserWithActivityResponse) {
        self.name = response.name
        self.userId = response.userId
        self.socialType = response.socialType
        self.activity = UserActivity(response: response.activity)
        self.medal = Medal(response: response.medal)
        self.pushInfo = PushInfo()
        self.marketingConsent = .unknown
    }
}

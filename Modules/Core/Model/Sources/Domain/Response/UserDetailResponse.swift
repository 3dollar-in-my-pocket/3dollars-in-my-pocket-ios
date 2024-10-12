public struct UserDetailResponse: Decodable {
    public let userId: Int
    public var name: String
    public let socialType: String?
    public var gender: Gender?
    public var birth: UserBirthResponse?
    public let representativeMedal: MedalResponse
    public let ownedMedals: [MedalResponse]
    public var settings: UserAccountSettingApiResponse
    public let activities: UserActivitiesApiResponse?
    public let createdAt: String
    public let updatedAt: String
}

public struct UserAccountSettingApiResponse: Decodable {
    public var enableActivitiesPush: Bool
    public var marketingConsent: String
}

public struct UserBirthResponse: Decodable {
    public var year: Int
    
    public init(year: Int) {
        self.year = year
    }
}

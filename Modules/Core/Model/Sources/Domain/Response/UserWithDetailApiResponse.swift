public struct UserWithDetailApiResponse: Decodable {
    public let userId: Int
    public let name: String
    public let socialType: String?
    public let representativeMedal: MedalResponse
    public let ownedMedals: [MedalResponse]
    public let settings: UserAccountSettingApiResponse
    public let activities: UserActivitiesApiResponse?
    public let createdAt: String
    public let updatedAt: String
}

public struct UserAccountSettingApiResponse: Decodable {
    public let enableActivitiesPush: Bool
    public let marketingConsent: String
}

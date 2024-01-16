public struct UserActivitiesApiResponse: Decodable {
    public let createStoreCount: Int
    public let writeReviewCount: Int
    public let visitStoreCount: Int
    public let favoriteStoreCount: Int
}

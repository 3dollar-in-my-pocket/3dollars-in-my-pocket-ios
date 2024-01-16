import Foundation

public struct FavoriteStoreWithTotalSubscribersCountApiResponse: Decodable {
    public let isFavorite: Bool
    public let totalSubscribersCount: Int
}

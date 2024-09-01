import Foundation

public struct StoreFavoriteResponse: Decodable {
    public let isFavorite: Bool
    public let totalSubscribersCount: Int
}

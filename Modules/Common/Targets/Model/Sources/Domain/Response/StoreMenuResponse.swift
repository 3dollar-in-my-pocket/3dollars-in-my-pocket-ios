import Foundation

public struct StoreMenuResponse: Decodable {
    public let createdAt: String
    public let updatedAt: String
    public let menuId: Int
    public let name: String?
    public let price: String?
    // TODO: 카테고리 필드 구조 변경 필요
    public let category: String?
}

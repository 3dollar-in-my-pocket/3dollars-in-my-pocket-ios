import Foundation

public struct FetchPollsRequestInput: Encodable {
    public let categoryId: String
    public let sortType: String
    public let size: Int
    public let cursor: String?

    public init(categoryId: String = "TASTE_VS_TASTE", sortType: String = "LATEST", size: Int = 20, cursor: String? = nil) {
        self.categoryId = categoryId
        self.sortType = sortType
        self.size = size
        self.cursor = cursor
    }
}

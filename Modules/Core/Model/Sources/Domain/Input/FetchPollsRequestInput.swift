import Foundation

public struct FetchPollsRequestInput: Encodable {
    public let categoryId: String
    public let sortType: String
    public let size: Int
    public let cursor: String?

    public init(categoryId: String, sortType: PollListSortType, size: Int = 20, cursor: String? = nil) {
        self.categoryId = categoryId
        self.sortType = sortType.rawValue
        self.size = size
        self.cursor = cursor
    }
}

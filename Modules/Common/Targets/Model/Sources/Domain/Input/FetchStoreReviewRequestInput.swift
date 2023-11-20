import Foundation

public struct FetchStoreReviewRequestInput: Encodable {
    public let size: Int
    public let cursor: String?
    public let sort: String
    
    public init(size: Int, cursor: String?, sort: String) {
        self.size = size
        self.cursor = cursor
        self.sort = sort
    }
}

import Foundation

public struct WriteReviewRequestInput: Encodable {
    public let storeId: Int
    public let contents: String
    public let rating: Int
    
    public init(storeId: Int, contents: String, rating: Int) {
        self.storeId = storeId
        self.contents = contents
        self.rating = rating
    }
}

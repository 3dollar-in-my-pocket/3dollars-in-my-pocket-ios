import Foundation

public struct EditReviewRequestInput: Encodable {
    public let contents: String
    public let rating: Int
    
    public init(contents: String, rating: Int) {
        self.contents = contents
        self.rating = rating
    }
}

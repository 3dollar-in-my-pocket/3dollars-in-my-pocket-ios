import Foundation

public struct EditReviewRequestInput: Encodable {
    public let contents: String
    public let rating: Int
    public let nonceToken: String
    
    public init(contents: String, rating: Int, nonceToken: String) {
        self.contents = contents
        self.rating = rating
        self.nonceToken = nonceToken
    }
}

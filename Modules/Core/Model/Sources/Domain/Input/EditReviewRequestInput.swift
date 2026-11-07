import Foundation

public struct EditReviewRequestInput: Encodable {
    public let contents: String
    public let rating: Int
    public let nonceToken: String
    public let images: [WriteReviewRequestInput.Image]
    
    public init(contents: String, rating: Int, nonceToken: String, images: [WriteReviewRequestInput.Image]) {
        self.contents = contents
        self.rating = rating
        self.nonceToken = nonceToken
        self.images = images
    }
    
    enum CodingKeys: CodingKey {
        case contents
        case rating
        case images
    }
}

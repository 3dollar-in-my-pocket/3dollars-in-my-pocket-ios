import Foundation

public struct WriteReviewRequestInput: Encodable {
    public let storeId: Int
    public let contents: String
    public let rating: Int
    public let nonceToken: String
    public let images: [Image]
    public let feedbacks: [Feedback]
    
    public init(storeId: Int, contents: String, rating: Int, nonceToken: String, images: [Image] = [], feedbacks: [Feedback] = []) {
        self.storeId = storeId
        self.contents = contents
        self.rating = rating
        self.nonceToken = nonceToken
        self.images = images
        self.feedbacks = feedbacks
    }
    
    enum CodingKeys: CodingKey {
        case storeId
        case contents
        case rating
        case nonceToken
        case images
        case feedbacks
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.storeId, forKey: .storeId)
        try container.encode(self.contents, forKey: .contents)
        try container.encode(self.rating, forKey: .rating)
        try container.encode(self.images, forKey: .images)
        try container.encode(self.feedbacks, forKey: .feedbacks)
    }
}

public extension WriteReviewRequestInput {
    struct Image: Encodable {
        public let url: String
        public let width: Int
        public let height: Int
        
        public init(url: String, width: Int, height: Int) {
            self.url = url
            self.width = width
            self.height = height
        }
    }
    
    struct Feedback: Encodable {
        public let emojiType: String
        
        public init(emojiType: String) {
            self.emojiType = emojiType
        }
    }
}

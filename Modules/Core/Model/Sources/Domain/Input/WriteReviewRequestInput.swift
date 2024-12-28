import Foundation

public struct WriteReviewRequestInput: Encodable {
    public let storeId: Int
    public let contents: String
    public let rating: Int
    public let nonceToken: String
    
    public init(storeId: Int, contents: String, rating: Int, nonceToken: String) {
        self.storeId = storeId
        self.contents = contents
        self.rating = rating
        self.nonceToken = nonceToken
    }
    
    enum CodingKeys: CodingKey {
        case storeId
        case contents
        case rating
        case nonceToken
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.storeId, forKey: .storeId)
        try container.encode(self.contents, forKey: .contents)
        try container.encode(self.rating, forKey: .rating)
    }
}

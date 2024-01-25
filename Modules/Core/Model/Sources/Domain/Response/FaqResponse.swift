import Foundation

public struct FaqResponse: Decodable {
    public let faqId: Int
    public let question: String
    public let answer: String
    public let categoryInfo: FaqCategoryResponse
    public let createdAt: String
    public let updatedAt: String
}

public struct FaqCategoryResponse: Decodable, Hashable {
    public let category: String
    public let description: String
    
    public init(category: String, description: String) {
        self.category = category
        self.description = description
    }
}

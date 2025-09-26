import Foundation

public struct UserStoreMenuRequestV3: Encodable {
    public var name: String
    public var count: Int?
    public var price: Int?
    public var category: String
    public var description: String?
    
    public init(
        name: String = "",
        count: Int? = nil,
        price: Int? = nil,
        category: String = "",
        description: String? = nil
    ) {
        self.name = name
        self.count = count
        self.price = price
        self.category = category
        self.description = description
    }
    
    public init(response: UserStoreMenuResponseV3) {
        self.name = response.name
        self.count = response.count
        self.price = response.price
        self.category = response.category.categoryId
        self.description = nil // count, price는 지웠지만 description이 안지워져서 수정이 제대로 이루어지지 않는 케이스 존재.
    }
}

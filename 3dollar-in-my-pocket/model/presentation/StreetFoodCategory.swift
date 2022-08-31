struct StreetFoodCategory: Categorizable, Equatable {
    let id: String
    let category: StreetFoodStoreCategory
    let description: String
    let imageUrl: String
    let isNew: Bool
    let name: String
    
    init(
        id: String,
        category: StreetFoodStoreCategory,
        description: String,
        imageUrl: String,
        isNew: Bool,
        name: String
    ) {
        self.id = id
        self.category = category
        self.description = description
        self.imageUrl = imageUrl
        self.isNew = isNew
        self.name = name
    }
    
    init(response: MenuCategoryResponse) {
        self.id = response.categoryId
        self.category
        = StreetFoodStoreCategory(rawValue: response.category) ?? .BUNGEOPPANG
        self.description = response.description
        self.imageUrl = response.imageUrl
        self.isNew = response.isNew
        self.name = response.name
    }
}

extension StreetFoodCategory {
    static let totalCategory = StreetFoodCategory(
        id: "0",
        category: .BUNGEOPPANG,
        description: "",
        imageUrl: "",
        isNew: false,
        name: "전체"
    )
}

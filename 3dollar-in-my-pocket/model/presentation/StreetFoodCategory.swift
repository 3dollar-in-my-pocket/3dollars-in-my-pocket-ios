struct StreetFoodCategory: Categorizable {
    let id: String
    let category: StreetFoodStoreCategory
    let description: String
    let isNew: Bool
    let name: String
    
    init(
        id: String,
        category: StreetFoodStoreCategory,
        description: String,
        isNew: Bool,
        name: String
    ) {
        self.id = id
        self.category = category
        self.description = description
        self.isNew = isNew
        self.name = name
    }
    
    init(response: MenuCategoryResponse) {
        self.id = response.categoryId
        self.category
        = StreetFoodStoreCategory(rawValue: response.category) ?? .BUNGEOPPANG
        self.description = response.description
        self.isNew = response.isNew
        self.name = response.name
    }
}

extension StreetFoodCategory {
    static let totalCategory = StreetFoodCategory(
        id: "0",
        category: .BUNGEOPPANG,
        description: "",
        isNew: false,
        name: "전체"
    )
}

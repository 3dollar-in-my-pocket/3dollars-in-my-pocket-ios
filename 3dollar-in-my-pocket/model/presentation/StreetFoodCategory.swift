struct StreetFoodCategory: Categorizable {
    let id: String
    let category: StreetFoodStoreCategory
    let description: String
    let isNew: Bool
    let name: String
    
    init(response: MenuCategoryResponse) {
        self.id = response.categoryId
        self.category
        = StreetFoodStoreCategory(rawValue: response.category) ?? .BUNGEOPPANG
        self.description = response.description
        self.isNew = response.isNew
        self.name = response.name
    }
}

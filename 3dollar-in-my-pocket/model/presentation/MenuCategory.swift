struct MenuCategory {
    let category: StoreCategory
    let description: String
    let isNew: Bool
    let name: String
    
    init(response: MenuCategoryResponse) {
        self.category = response.category
        self.description = response.description
        self.isNew = response.isNew
        self.name = response.name
    }
}

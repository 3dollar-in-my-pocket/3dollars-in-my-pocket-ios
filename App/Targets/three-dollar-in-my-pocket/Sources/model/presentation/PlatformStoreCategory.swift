struct PlatformStoreCategory: Categorizable {
    let id: String
    let category: String
    let description: String
    let imageUrl: String
    let isNew: Bool
    let name: String
    
    init(response: PlatformStoreCategoryResponse) {
        self.id = response.categoryId
        self.category = response.category
        self.description = response.description
        self.imageUrl = response.imageUrl
        self.isNew = response.isNew
        self.name = response.name
    }
}

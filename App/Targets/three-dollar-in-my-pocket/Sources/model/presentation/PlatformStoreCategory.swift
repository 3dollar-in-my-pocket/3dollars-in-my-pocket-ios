import Model

struct PlatformStoreCategory: Categorizable {
    let id: String
    let category: String
    let description: String
    let imageUrl: String
    let disableImageUrl: String
    let isNew: Bool
    let name: String
    
    init(response: PlatformStoreCategoryResponse) {
        self.id = response.categoryId
        self.category = response.category
        self.description = response.description
        self.imageUrl = response.imageUrl
        self.disableImageUrl = ""
        self.isNew = response.isNew
        self.name = response.name
    }
    
    init(response: Model.PlatformStoreCategoryResponse) {
        self.id = response.categoryId
        self.category = response.category
        self.description = response.description
        self.imageUrl = response.imageUrl
        self.disableImageUrl = response.disableImageUrl
        self.isNew = response.isNew
        self.name = response.name
    }
}

extension PlatformStoreCategory: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

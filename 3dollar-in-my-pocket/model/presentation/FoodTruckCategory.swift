struct FoodTruckCategory: Categorizable {
    let id: String
    let name: String
    let imageUrl: String
    let description: String
    
    init(id: String, name: String, imageUrl: String, description: String) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.description = description
    }
    
    init(response: BossStoreCategoryResponse) {
        self.id = response.categoryId
        self.name = response.name
        self.imageUrl = response.imageUrl
        self.description = response.description
    }
}

extension FoodTruckCategory {
    static let totalCategory = FoodTruckCategory(
        id: "0",
        name: "전체",
        imageUrl: "",
        description: ""
    )
}

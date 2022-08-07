struct FoodTruckCategory: Categorizable {
    let id: String
    let name: String
    let imageUrl: String
    
    init(id: String, name: String, imageUrl: String) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
    
    init(response: BossStoreCategoryResponse) {
        self.id = response.categoryId
        self.name = response.name
        self.imageUrl = response.imageUrl
    }
}

extension FoodTruckCategory {
    static let totalCategory = FoodTruckCategory(id: "0", name: "전체", imageUrl: "")
}

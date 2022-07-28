struct FoodTruckCategory: Categorizable {
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    init(response: BossStoreCategoryResponse) {
        self.id = response.categoryId
        self.name = response.name
    }
}

extension FoodTruckCategory {
    static let totalCategory = FoodTruckCategory(id: "0", name: "전체")
}

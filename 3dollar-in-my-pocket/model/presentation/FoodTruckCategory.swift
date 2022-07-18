struct FoodTruckCategory: Categorizable {
    let id: String
    let name: String
    
    init(response: BossStoreCategoryResponse) {
        self.id = response.categoryId
        self.name = response.name
    }
}

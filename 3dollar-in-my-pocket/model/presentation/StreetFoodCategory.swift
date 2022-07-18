struct StreetFoodCategory: Categorizable {
    let id: String = "" // 푸드트럭에만 있는 필드라서 아직 사용하지 않습니다.
    let category: StreetFoodStoreCategory
    let description: String
    let isNew: Bool
    let name: String
    
    init(response: MenuCategoryResponse) {
        self.category
        = StreetFoodStoreCategory(rawValue: response.category) ?? .BUNGEOPPANG
        self.description = response.description
        self.isNew = response.isNew
        self.name = response.name
    }
}

final class MetaContext {
    static let shared = MetaContext()
    
    /// 모든 메달정보를 저장해둡니다.
    var medals: [Medal] = []
    
    /// 푸드트럭 피드백 타입을 저장해둡니다.
    var feedbackTypes: [BossStoreFeedbackMeta] = []
    
    /// 활성화된 길거리 음식점 카테고리를 저장해둡니다.
    var streetFoodCategories: [Categorizable] = []
    
    /// 활성화된 푸드트럭 카테고리를 저장해둡니다.
    var foodTruckCategories: [Categorizable] = []
    
    func findStreetFoodCategory(category: StreetFoodStoreCategory) -> StreetFoodCategory? {
        for categorizable in self.streetFoodCategories {
            if let streetFoodCategory = categorizable as? StreetFoodCategory,
               streetFoodCategory.category == category {
                return streetFoodCategory
            }
        }
        
        return nil
    }
}

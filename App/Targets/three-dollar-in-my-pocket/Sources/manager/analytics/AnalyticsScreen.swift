enum AnalyticsScreen: String {
    case splashPopup = "splash_popup"
    case home
    case categoryFilter = "category_filter"
    case streetFoodList = "street_food_list"
    case foodTruckList = "food_truck_list"
    
    /// 푸드트럭 상세화면
    case bossStoreDetail = "boss_store_detail"
    
    // MARK: v4
    
    /// 제보 주소 화면
    case writeAddress = "write_address"
    case writeAddressPopup = "write_address_popop"
    
    case categorySelection = "category_selection"
}

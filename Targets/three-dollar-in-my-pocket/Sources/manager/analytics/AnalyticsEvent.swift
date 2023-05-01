enum AnalyticsEvent {
    case splashPopupClicked(id: String)
    case homeAdBannerClicked(id: String)
    case storeListAdBannerClicked(id: String)
    case categoryAdBannerClicked(id: String)
    case foodtruckListAdBannerClicked(id: String)
    case viewBossStoreDetail(storeId: String)
    
    var name: String {
        switch self {
        case .splashPopupClicked:
            return "splash_popup_clicked"
            
        case .homeAdBannerClicked:
            return "home_ad_banner_clicked"
            
        case .storeListAdBannerClicked:
            return "store_list_ad_banner_clicked"
            
        case .categoryAdBannerClicked:
            return "category_ad_banner_clicked"
            
        case .foodtruckListAdBannerClicked:
            return "foodtruck_list_ad_banner_clicked"
            
        case .viewBossStoreDetail:
            return "view_boss_store_detail"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .splashPopupClicked(let id):
            return ["id": id]
            
        case .homeAdBannerClicked(let id):
            return ["id": id]
            
        case .storeListAdBannerClicked(let id):
            return ["id": id]
            
        case .categoryAdBannerClicked(let id):
            return ["id": id]
            
        case .foodtruckListAdBannerClicked(let id):
            return ["id": id]
            
        case .viewBossStoreDetail(let id):
            return ["id": id]
        }
    }
}

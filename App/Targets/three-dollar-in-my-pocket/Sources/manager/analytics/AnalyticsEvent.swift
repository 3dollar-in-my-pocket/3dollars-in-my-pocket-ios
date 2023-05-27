enum AnalyticsEvent {
    case splashPopupClicked(id: String)
    case homeAdBannerClicked(id: String)
    case storeListAdBannerClicked(id: String)
    case categoryAdBannerClicked(id: String)
    case foodtruckListAdBannerClicked(id: String)
    case viewBossStoreDetail(storeId: String)
    
    // MARK: v4
    /// 공용
    case clickCurrentLocation
    
    /// write-address 제보주소화면
    case clickSetAddress(address: String)
    case clickAddressOk(address: String)
    
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
            
        case .clickCurrentLocation:
            return "click_current_location"
            
        case .clickSetAddress:
            return "click_set_address"
            
        case .clickAddressOk:
            return "click_address_ok"
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
            
        case .clickCurrentLocation:
            return [:]
            
        case .clickSetAddress(let address):
            return ["address": address]
            
        case .clickAddressOk(let address):
            return ["address": address]
        }
    }
}

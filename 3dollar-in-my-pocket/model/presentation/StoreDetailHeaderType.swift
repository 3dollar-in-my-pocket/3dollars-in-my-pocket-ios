enum StoreDetailHeaderType {
    case info
    case photo
    case review
    
    var title: String {
        switch self {
        case .info:
            return R.string.localization.store_detail_header_info()
            
        case .photo:
            return R.string.localization.store_detail_header_photo()
            
        case .review:
            return R.string.localization.store_detail_header_review()
        }
    }
    
    var rightButtonTitle: String {
        switch self {
        case .info:
            return R.string.localization.store_detail_header_modify_info()
            
        case .photo:
            return R.string.localization.store_detail_header_add_photo()
            
        case .review:
            return R.string.localization.store_detail_header_add_review()
        }
    }
}

enum StoreDetailHeaderType {
    case info
    case photo
    case review
    
    var title: String {
        switch self {
        case .info:
            return "store_detail_header_info".localized
            
        case .photo:
            return "store_detail_header_photo".localized
            
        case .review:
            return "store_detail_header_review".localized
        }
    }
    
    var rightButtonTitle: String {
        switch self {
        case .info:
            return "store_detail_header_modify_info".localized
            
        case .photo:
            return "store_detail_header_add_photo".localized
            
        case .review:
            return "store_detail_header_add_review".localized
        }
    }
}

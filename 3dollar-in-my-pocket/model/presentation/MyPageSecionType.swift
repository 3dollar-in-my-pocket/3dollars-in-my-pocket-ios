import UIKit

enum MyPageSecionType {
    case visitHistory
    case bookmark
}

extension MyPageSecionType {
    var icon: UIImage? {
        switch self {
        case .visitHistory:
            return R.image.ic_bedge()?.withRenderingMode(.alwaysTemplate)
            
        case .bookmark:
            return R.image.ic_bookmark_on()?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var iconLabel: String {
        switch self {
        case .visitHistory:
            return R.string.localization.my_page_visit()
            
        case .bookmark:
            return R.string.localization.store_detail_bookmark()
        }
    }
    
    var title: String {
        switch self {
        case .visitHistory:
            return R.string.localization.my_page_visit_description()
            
        case .bookmark:
            return "my_page_bookmark_description".localized
        }
    }
}

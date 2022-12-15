import UIKit

enum MyPageSectionType {
    case visitHistory
    case bookmark
    case unknown
    
    init(sectionIndex: Int) {
        switch sectionIndex {
        case 1:
            self = .visitHistory
            
        case 2:
            self = .bookmark
            
        default:
            self = .unknown
        }
    }
}

extension MyPageSectionType {
    var icon: UIImage? {
        switch self {
        case .visitHistory:
            return R.image.ic_bedge()?.withRenderingMode(.alwaysTemplate)
            
        case .bookmark:
            return R.image.ic_bookmark_on()?.withRenderingMode(.alwaysTemplate)
            
        case .unknown:
            return nil
        }
    }
    
    var iconLabel: String {
        switch self {
        case .visitHistory:
            return R.string.localization.my_page_visit()
            
        case .bookmark:
            return R.string.localization.store_detail_bookmark()
            
        case .unknown:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .visitHistory:
            return R.string.localization.my_page_visit_description()
            
        case .bookmark:
            return "my_page_bookmark_description".localized
            
        case .unknown:
            return ""
        }
    }
}
